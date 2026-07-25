import 'package:flutter/foundation.dart';

@immutable
class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.categories,
    required this.rating,
    required this.deliveryMinMinutes,
    required this.deliveryMaxMinutes,
    required this.deliveryFee,
    required this.imageUrl,
    required this.logoUrl,
    this.reviewCount = 0,
    this.isOpen = true,
  });

  final String id;
  final String name;
  final List<String> categories;
  final double rating;
  final int deliveryMinMinutes;
  final int deliveryMaxMinutes;

  /// Delivery cost in CFA francs; zero means "Livraison gratuite".
  final int deliveryFee;
  final String imageUrl;
  final String logoUrl;

  /// Shown as "(500+ avis)" on the detail header.
  final int reviewCount;
  final bool isOpen;

  bool get hasFreeDelivery => deliveryFee == 0;

  String get categoriesLabel => categories.join(' • ');

  String get deliveryTimeLabel => '$deliveryMinMinutes-$deliveryMaxMinutes min';
}
