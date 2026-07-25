import 'package:flutter/material.dart';

enum PaymentKind { mobileMoney, card, cash }

/// A saved payment method, from ref/.../moyens_de_paiement.
///
/// Card details are never stored in the app: [details] holds only the masked
/// summary the payment provider returns, and charging goes through the provider
/// SDK so no card number ever reaches this codebase or the backend.
@immutable
class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.label,
    required this.details,
    required this.icon,
    required this.kind,
    this.isDefault = false,
  });

  final String id;
  final String label;

  /// Masked summary, e.g. "•••• 4242 — expire 12/26".
  final String details;
  final IconData icon;
  final PaymentKind kind;
  final bool isDefault;

  PaymentMethod copyWith({bool? isDefault}) => PaymentMethod(
        id: id,
        label: label,
        details: details,
        icon: icon,
        kind: kind,
        isDefault: isDefault ?? this.isDefault,
      );
}
