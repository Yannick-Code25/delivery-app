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
    this.isOpen = true,
  });

  final String id;
  final String name;
  final List<String> categories;
  final double rating;
  final int deliveryMinMinutes;
  final int deliveryMaxMinutes;

  /// Delivery cost; zero means the card shows "Livraison gratuite".
  final double deliveryFee;
  final String imageUrl;
  final String logoUrl;
  final bool isOpen;

  bool get hasFreeDelivery => deliveryFee == 0;

  String get categoriesLabel => categories.join(' • ');

  String get deliveryTimeLabel => '$deliveryMinMinutes-$deliveryMaxMinutes min';
}
