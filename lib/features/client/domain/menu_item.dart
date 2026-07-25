import 'package:flutter/material.dart';

/// A size choice, from the "Choisir la taille" block in
/// ref/.../d_tails_personnalisation_produit. The price is absolute, not a
/// surcharge — picking a size replaces the base price.
@immutable
class MenuItemSize {
  const MenuItemSize({
    required this.id,
    required this.label,
    required this.price,
    required this.icon,
    this.iconScale = 1,
  });

  final String id;
  final String label;
  final int price;
  final IconData icon;

  /// The reference draws the larger size with a visibly bigger glyph.
  final double iconScale;
}

/// An optional paid add-on, from the "Suppléments" list.
@immutable
class MenuItemExtra {
  const MenuItemExtra({
    required this.id,
    required this.label,
    required this.price,
    this.imageUrl,
  });

  final String id;
  final String label;
  final int price;
  final String? imageUrl;
}

@immutable
class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.rating,
    this.sizes = const [],
    this.extras = const [],
  });

  final String id;
  final String name;
  final String description;

  /// Base price in CFA francs, used when the item has no size choice.
  final int price;
  final String? imageUrl;
  final double? rating;
  final List<MenuItemSize> sizes;
  final List<MenuItemExtra> extras;

  /// Items with choices open the customisation screen; the rest add straight
  /// to the cart from the menu list.
  bool get isCustomisable => sizes.isNotEmpty || extras.isNotEmpty;
}

@immutable
class MenuCategory {
  const MenuCategory({required this.id, required this.name, required this.items});

  final String id;
  final String name;
  final List<MenuItem> items;
}
