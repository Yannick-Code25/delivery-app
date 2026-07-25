import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A chosen extra, kept on the line so the cart can list what was added.
@immutable
class CartExtra {
  const CartExtra({required this.label, required this.price});

  final String label;
  final int price;
}

@immutable
class CartItem {
  const CartItem({
    required this.menuItemId,
    required this.name,
    required this.basePrice,
    this.sizeLabel,
    this.extras = const [],
    this.note,
    this.quantity = 1,
  });

  final String menuItemId;
  final String name;

  /// Price of the item at the chosen size, before extras, in CFA francs.
  final int basePrice;
  final String? sizeLabel;
  final List<CartExtra> extras;
  final String? note;
  final int quantity;

  /// Two lines merge only when the same item was configured identically.
  String get configurationKey {
    final extraIds = extras.map((extra) => extra.label).toList()..sort();
    return '$menuItemId|${sizeLabel ?? ''}|${extraIds.join(',')}|${note ?? ''}';
  }

  int get unitPrice => basePrice + extras.fold(0, (sum, extra) => sum + extra.price);

  int get lineTotal => unitPrice * quantity;

  /// "Large (40cm) • Double Fromage, Olives Noires", or null when plain.
  String? get configurationLabel {
    final parts = [
      ?sizeLabel,
      if (extras.isNotEmpty) extras.map((extra) => extra.label).join(', '),
    ];
    return parts.isEmpty ? null : parts.join(' • ');
  }

  CartItem copyWith({int? quantity}) => CartItem(
        menuItemId: menuItemId,
        name: name,
        basePrice: basePrice,
        sizeLabel: sizeLabel,
        extras: extras,
        note: note,
        quantity: quantity ?? this.quantity,
      );
}

@immutable
class CartState {
  const CartState({this.restaurantId, this.items = const []});

  /// A cart belongs to a single restaurant, as in the reference checkout flow.
  final String? restaurantId;
  final List<CartItem> items;

  bool get isEmpty => items.isEmpty;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Items only; delivery and service fees are added at checkout.
  int get subtotal => items.fold(0, (sum, item) => sum + item.lineTotal);
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  /// Adds a line, merging with an identically configured one. Returns false when
  /// the cart belonged to another restaurant and was replaced.
  bool add(CartItem item, {required String restaurantId}) {
    final sameRestaurant = state.restaurantId == null || state.restaurantId == restaurantId;
    final items = sameRestaurant ? [...state.items] : <CartItem>[];

    final index = items.indexWhere(
      (existing) => existing.configurationKey == item.configurationKey,
    );
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = items[index].copyWith(
        quantity: items[index].quantity + item.quantity,
      );
    }

    state = CartState(restaurantId: restaurantId, items: items);
    return sameRestaurant;
  }

  void setQuantity(String configurationKey, int quantity) {
    final items = [...state.items];
    final index = items.indexWhere((item) => item.configurationKey == configurationKey);
    if (index == -1) return;

    if (quantity <= 0) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(quantity: quantity);
    }

    state = items.isEmpty
        ? const CartState()
        : CartState(restaurantId: state.restaurantId, items: items);
  }

  void clear() => state = const CartState();
}

final cartProvider = NotifierProvider<CartController, CartState>(CartController.new);
