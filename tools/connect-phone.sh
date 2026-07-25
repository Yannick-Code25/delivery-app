#!/usr/bin/env bash
# Reconnecte le téléphone en ADB sans fil sur le réseau WiFi courant.
#
# Usage:
#   ./tools/connect-phone.sh              # cherche le téléphone sur le réseau
#   ./tools/connect-phone.sh 192.168.1.42 # IP connue, plus rapide
#
# Prérequis : le mode sans fil doit avoir été activé une fois par USB
# (adb tcpip 5555). Il reste actif jusqu'au redémarrage du téléphone.
# Après un redémarrage : rebrancher le câble et relancer ce script avec --usb.

set -uo pipefail

ADB="${ANDROID_HOME:-$HOME/Android/Sdk}/platform-tools/adb"
PORT=5555

[ -x "$ADB" ] || { echo "adb introuvable: $ADB" >&2; exit 1; }

# Réactive le mode sans fil via USB, puis continue en WiFi.
if [ "${1:-}" = "--usb" ]; then
  echo "Activation du mode sans fil via USB..."
  "$ADB" tcpip "$PORT" || exit 1
  sleep 3
  set --
fi

try_connect() {
  local ip="$1"
  "$ADB" connect "$ip:$PORT" 2>&1 | grep -qiE "connected to" || return 1
  # "connected" peut mentir si l'appareil n'est pas autorisé.
  sleep 1
  "$ADB" devices | grep -q "^$ip:$PORT[[:space:]]*device$"
}

# IP fournie en argument.
if [ $# -ge 1 ]; then
  if try_connect "$1"; then
    echo "Connecté : $1:$PORT"
    exit 0
  fi
  echo "Échec sur $1 — recherche sur le réseau..." >&2
fi

# Déduit le sous-réseau depuis l'interface WiFi du PC.
subnet=$(ip -o -4 addr show 2>/dev/null \
  | awk '$2 ~ /^(wl|wlan)/ {print $4}' | head -1 | cut -d/ -f1 | cut -d. -f1-3)

[ -n "$subnet" ] || { echo "Pas de WiFi actif sur ce PC." >&2; exit 1; }

# Si le téléphone est joignable en USB, on lui demande son IP WiFi : c'est plus
# fiable qu'un scan, et ça permet de distinguer "hors réseau" de "isolation client".
usb_serial=$("$ADB" devices | awk '$2 == "device" && $1 !~ /:/ {print $1; exit}')
if [ -n "$usb_serial" ]; then
  phone_ip=$("$ADB" -s "$usb_serial" shell ip -o -4 addr 2>/dev/null \
    | awk '$2 ~ /^wlan/ {print $4}' | head -1 | cut -d/ -f1)

  if [ -z "$phone_ip" ]; then
    echo "Le WiFi du téléphone est éteint — active-le et rejoins le même réseau." >&2
    exit 1
  fi

  if [ "${phone_ip%.*}" != "$subnet" ]; then
    echo "Le téléphone est sur $phone_ip, le PC sur $subnet.x : réseaux différents." >&2
    exit 1
  fi

  # Même réseau : si le téléphone ne répond pas au ping alors que la passerelle
  # répond, le point d'accès isole ses clients (fréquent en partage de connexion).
  if ! ping -c 2 -W 2 "$phone_ip" >/dev/null 2>&1 \
     && ping -c 2 -W 2 "$subnet.1" >/dev/null 2>&1; then
    cat >&2 <<EOF
Le PC joint la passerelle mais pas le téléphone ($phone_ip).
Ce réseau WiFi isole ses clients (AP isolation) — l'ADB sans fil y est
impossible. Utilise l'USB, ou un réseau sans cette restriction :
  flutter run -d $usb_serial
EOF
    exit 2
  fi

  if try_connect "$phone_ip"; then
    echo "Connecté : $phone_ip:$PORT"
    echo
    echo "Lancer l'app :  flutter run -d $phone_ip:$PORT"
    exit 0
  fi
fi

echo "Recherche du téléphone sur $subnet.0/24 ..."

# Un scan de port est plus rapide qu'un adb connect sur 254 adresses.
for i in $(seq 1 254); do
  ip="$subnet.$i"
  (timeout 0.3 bash -c "echo > /dev/tcp/$ip/$PORT" 2>/dev/null && echo "$ip") &
done | sort -u > /tmp/adb-candidates.$$
wait 2>/dev/null

found=""
while read -r ip; do
  [ -n "$ip" ] || continue
  if try_connect "$ip"; then found="$ip"; break; fi
done < /tmp/adb-candidates.$$
rm -f /tmp/adb-candidates.$$

if [ -n "$found" ]; then
  echo "Connecté : $found:$PORT"
  echo
  echo "Lancer l'app :  flutter run -d $found:$PORT"
  exit 0
fi

cat >&2 <<'EOF'
Téléphone non trouvé. Vérifier que :
  - le téléphone est sur le même WiFi que ce PC
  - il n'a pas redémarré depuis l'activation du sans fil
    (si redémarré : rebrancher l'USB puis relancer avec --usb)
  - le débogage USB est toujours activé dans les options développeur
EOF
exit 1
