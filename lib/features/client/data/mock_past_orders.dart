import 'package:flutter/foundation.dart';

/// A completed order as listed under "Past orders" in
/// ref/.../mes_commandes_babali_style.
@immutable
class PastOrderSummary {
  const PastOrderSummary({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.dateLabel,
    required this.itemCount,
    required this.total,
  });

  final String id;
  final String restaurantId;
  final String restaurantName;

  /// Pre-formatted because there is no order date from a backend yet.
  final String dateLabel;
  final int itemCount;
  final int total;
}

/// TODO: replace with the order-history endpoint.
const mockPastOrders = <PastOrderSummary>[
  PastOrderSummary(
    id: 'DBL-1042',
    restaurantId: 'sushi-master',
    restaurantName: 'Sushi Master',
    dateLabel: '24 juil.',
    itemCount: 2,
    total: 8500,
  ),
  PastOrderSummary(
    id: 'DBL-1039',
    restaurantId: 'burger-lab',
    restaurantName: 'The Burger Lab',
    dateLabel: '20 juil.',
    itemCount: 1,
    total: 4500,
  ),
  PastOrderSummary(
    id: 'DBL-1031',
    restaurantId: 'petit-bistro',
    restaurantName: 'Le Petit Bistro Gourmet',
    dateLabel: '15 juil.',
    itemCount: 3,
    total: 15000,
  ),
];
