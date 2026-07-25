import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class CartItem {
  const CartItem({
    required this.id,
    required this.name,
    required this.unitPrice,
    this.quantity = 1,
  });

  final String id;
  final String name;
  final double unitPrice;
  final int quantity;

  double get lineTotal => unitPrice * quantity;

  CartItem copyWith({int? quantity}) => CartItem(
        id: id,
        name: name,
        unitPrice: unitPrice,
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

  double get total => items.fold(0, (sum, item) => sum + item.lineTotal);
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  void add(CartItem item, {required String restaurantId}) {
    // Switching restaurant replaces the cart rather than mixing menus.
    final items = state.restaurantId == restaurantId ? [...state.items] : <CartItem>[];

    final index = items.indexWhere((existing) => existing.id == item.id);
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = items[index].copyWith(quantity: items[index].quantity + item.quantity);
    }

    state = CartState(restaurantId: restaurantId, items: items);
  }

  void setQuantity(String itemId, int quantity) {
    final items = [...state.items];
    final index = items.indexWhere((item) => item.id == itemId);
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
