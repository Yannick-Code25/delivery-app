import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/money.dart';
import '../../../shared/widgets/pressable.dart';
import '../application/order_providers.dart';
import '../data/mock_past_orders.dart';
import '../domain/order.dart';

/// Order history, adapted from ref/.../mes_commandes_babali_style/code.html:
/// the order in progress on top with its own stepper and actions, then past
/// orders with a reorder shortcut. Copy is translated, the mockup being English.
class ClientOrdersScreen extends ConsumerWidget {
  const ClientOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeOrder = ref.watch(orderProvider);
    final showActive = activeOrder != null && activeOrder.status != OrderStatus.delivered;

    return Scaffold(
      appBar: AppBar(title: Text('Mes commandes', style: AppTextStyles.headlineMd)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile,
          AppSpacing.gutter,
          AppSpacing.marginMobile,
          AppSpacing.xl,
        ),
        children: [
          if (showActive) ...[
            _SectionHeader(
              title: 'Commande en cours',
              trailing: '1 commande',
            ),
            const SizedBox(height: AppSpacing.sm),
            _ActiveOrderCard(order: activeOrder),
            const SizedBox(height: AppSpacing.lg),
          ],
          _SectionHeader(title: 'Commandes passées'),
          const SizedBox(height: AppSpacing.sm),
          for (final order in mockPastOrders) ...[
            _PastOrderRow(order: order),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Commandes des 6 derniers mois',
            style: AppTextStyles.labelSm.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(title, style: AppTextStyles.headlineMd)),
        if (trailing != null)
          Text(
            trailing!,
            style: AppTextStyles.labelMd.copyWith(color: colorScheme.secondary),
          ),
      ],
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeIndex = OrderStatus.values.indexOf(order.status);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.delivery_dining,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.status == OrderStatus.onTheWay
                          ? 'Votre livreur arrive'
                          : 'Commande en préparation',
                      style: AppTextStyles.labelMd,
                    ),
                    Text(
                      'Livraison estimée dans ${order.etaMinutes} min',
                      style: AppTextStyles.labelSm.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              for (final status in OrderStatus.values) ...[
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: OrderStatus.values.indexOf(status) <= activeIndex
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: AppRadius.pill,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        status.label,
                        style: AppTextStyles.labelSm.copyWith(
                          color: OrderStatus.values.indexOf(status) == activeIndex
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (status != OrderStatus.values.last)
                  const SizedBox(width: AppSpacing.base),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push(AppRoutes.clientOrderTracking(order.id)),
                  icon: const Icon(Icons.person_pin_circle_outlined, size: 20),
                  label: const Text('Suivre'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    textStyle: AppTextStyles.labelMd,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  // TODO: open the courier chat once messaging exists.
                  onPressed: () => ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      const SnackBar(content: Text('Messagerie bientôt disponible')),
                    ),
                  icon: const Icon(Icons.chat_bubble_outline, size: 20),
                  label: const Text('Message'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    textStyle: AppTextStyles.labelMd,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PastOrderRow extends StatelessWidget {
  const _PastOrderRow({required this.order});

  final PastOrderSummary order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Pressable(
      onTap: () => context.push(AppRoutes.clientRestaurant(order.restaurantId)),
      pressedScale: 0.99,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: AppRadius.card,
          border: Border.all(color: colorScheme.surfaceContainer),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(Icons.receipt_long, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.restaurantName,
                    style: AppTextStyles.labelMd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${order.dateLabel} • ${order.itemCount} article'
                    '${order.itemCount > 1 ? 's' : ''} • ${Money.format(order.total)}',
                    style: AppTextStyles.labelSm.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => context.push(AppRoutes.clientRestaurant(order.restaurantId)),
              icon: Icon(Icons.replay, color: colorScheme.primary),
              tooltip: 'Commander à nouveau',
            ),
          ],
        ),
      ),
    );
  }
}
