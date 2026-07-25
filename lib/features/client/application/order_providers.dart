import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../data/mock_restaurants.dart';
import '../domain/delivery_address.dart';
import '../domain/order.dart';
import '../domain/payment_method.dart';
import 'cart_providers.dart';

/// Service fee charged per order, in CFA francs.
/// TODO: the backend should return this with the quote rather than hardcoding it.
const serviceFee = 200;

/// Saved delivery addresses, from ref/.../mes_adresses_de_livraison.
final addressesProvider = StateProvider<List<DeliveryAddress>>((ref) => mockAddresses);

final selectedAddressProvider = StateProvider<DeliveryAddress>((ref) => mockAddresses.first);

/// Saved payment methods, from ref/.../moyens_de_paiement.
final paymentMethodsProvider = StateProvider<List<PaymentMethod>>((ref) => mockPaymentMethods);

final selectedPaymentMethodProvider =
    StateProvider<PaymentMethod>((ref) => mockPaymentMethods.first);

/// Delivery fee of the restaurant the cart belongs to.
final deliveryFeeProvider = Provider<int>((ref) {
  final restaurantId = ref.watch(cartProvider).restaurantId;
  if (restaurantId == null) return 0;
  return restaurantById(restaurantId)?.deliveryFee ?? 0;
});

final orderTotalProvider = Provider<int>((ref) {
  final int subtotal = ref.watch(cartProvider).subtotal;
  if (subtotal == 0) return 0;

  final int deliveryFee = ref.watch(deliveryFeeProvider);
  final int total = subtotal + deliveryFee + serviceFee;
  return total;
});

/// Holds the order currently being followed on the tracking screen.
class OrderController extends Notifier<Order?> {
  @override
  Order? build() => null;

  /// Snapshots the cart into an order. Returns null when the cart is empty.
  /// TODO: replace with the create-order endpoint; the id must come from the API.
  Order? placeFromCart() {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty || cart.restaurantId == null) return null;

    final restaurant = restaurantById(cart.restaurantId!);
    final order = Order(
      id: 'DBL-${cart.subtotal}${cart.items.length}',
      restaurantId: cart.restaurantId!,
      restaurantName: restaurant?.name ?? 'Restaurant',
      lines: [
        for (final item in cart.items)
          OrderLine(
            name: item.name,
            quantity: item.quantity,
            configurationLabel: item.configurationLabel,
            lineTotal: item.lineTotal,
          ),
      ],
      subtotal: cart.subtotal,
      deliveryFee: restaurant?.deliveryFee ?? 0,
      serviceFee: serviceFee,
      address: ref.read(selectedAddressProvider),
      paymentMethod: ref.read(selectedPaymentMethodProvider),
      status: OrderStatus.confirmed,
      etaMinutes: restaurant?.deliveryMaxMinutes ?? 30,
    );

    state = order;
    return order;
  }

  void attachRating(int rating) {
    final order = state;
    if (order == null) return;
    state = order.copyWith(rating: rating);
  }

  void advanceStatus() {
    final order = state;
    if (order == null) return;

    final next = OrderStatus.values.indexOf(order.status) + 1;
    if (next >= OrderStatus.values.length) return;
    state = order.copyWith(status: OrderStatus.values[next]);
  }
}

final orderProvider = NotifierProvider<OrderController, Order?>(OrderController.new);

/// Addresses follow ref/.../mes_adresses_de_livraison, which places the app in
/// Dakar.
const mockAddresses = <DeliveryAddress>[
  DeliveryAddress(
    id: 'home',
    label: 'Maison',
    line1: 'Rue 12, Point E',
    line2: 'Sonner au portail noir',
    city: 'Dakar',
    icon: Icons.home_outlined,
    isDefault: true,
  ),
  DeliveryAddress(
    id: 'work',
    label: 'Bureau',
    line1: 'Immeuble Horizon, Plateau',
    line2: '4ème étage',
    city: 'Dakar',
    icon: Icons.work_outline,
  ),
];

/// The mockup lists Apple Pay and two cards. Mobile money leads by far in the
/// CFA zone, so it is the default here; the card entries stay for completeness.
const mockPaymentMethods = <PaymentMethod>[
  PaymentMethod(
    id: 'momo',
    label: 'Mobile Money',
    details: 'Principal • •••• 67 89',
    icon: Icons.smartphone,
    kind: PaymentKind.mobileMoney,
    isDefault: true,
  ),
  PaymentMethod(
    id: 'visa',
    label: 'Visa •••• 1234',
    details: 'Expire 08/26',
    icon: Icons.credit_card,
    kind: PaymentKind.card,
  ),
  PaymentMethod(
    id: 'cash',
    label: 'Espèces à la livraison',
    details: 'Prévoir le montant exact',
    icon: Icons.payments_outlined,
    kind: PaymentKind.cash,
  ),
];
