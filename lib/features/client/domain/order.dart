import 'package:flutter/foundation.dart';

import 'delivery_address.dart';
import 'payment_method.dart';

/// Tracking steps, matching the stepper in
/// ref/.../suivi_de_commande_en_direct: Préparée → En livraison → Arrivée.
enum OrderStatus {
  confirmed('Préparée'),
  onTheWay('En livraison'),
  delivered('Arrivée');

  const OrderStatus(this.label);

  final String label;
}

@immutable
class OrderLine {
  const OrderLine({
    required this.name,
    required this.quantity,
    required this.lineTotal,
    this.configurationLabel,
  });

  final String name;
  final int quantity;

  /// Chosen size and extras, e.g. "Large (40cm) • Double Fromage".
  final String? configurationLabel;
  final int lineTotal;
}

@immutable
class Order {
  const Order({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.lines,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.etaMinutes,
    this.courierName = 'Moussa',
    this.rating,
  });

  final String id;
  final String restaurantId;
  final String restaurantName;
  final List<OrderLine> lines;
  final int subtotal;
  final int deliveryFee;
  final int serviceFee;
  final DeliveryAddress address;
  final PaymentMethod paymentMethod;
  final OrderStatus status;
  final int etaMinutes;
  final String courierName;

  /// Set once the customer has reviewed the order.
  final int? rating;

  int get total => subtotal + deliveryFee + serviceFee;

  int get itemCount => lines.fold(0, (sum, line) => sum + line.quantity);

  Order copyWith({OrderStatus? status, int? rating}) => Order(
        id: id,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        lines: lines,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        serviceFee: serviceFee,
        address: address,
        paymentMethod: paymentMethod,
        status: status ?? this.status,
        etaMinutes: etaMinutes,
        courierName: courierName,
        rating: rating ?? this.rating,
      );
}
