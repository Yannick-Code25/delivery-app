import 'package:flutter/material.dart';

/// A saved delivery address, from ref/.../mes_adresses_de_livraison.
@immutable
class DeliveryAddress {
  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.line1,
    required this.city,
    required this.icon,
    this.line2,
    this.isDefault = false,
  });

  final String id;

  /// "Domicile", "Bureau"…
  final String label;
  final String line1;

  /// Floor, apartment, landmark.
  final String? line2;
  final String city;
  final IconData icon;
  final bool isDefault;

  String get fullAddress => [line1, ?line2, city].join(' • ');

  DeliveryAddress copyWith({bool? isDefault}) => DeliveryAddress(
        id: id,
        label: label,
        line1: line1,
        city: city,
        icon: icon,
        line2: line2,
        isDefault: isDefault ?? this.isDefault,
      );
}
