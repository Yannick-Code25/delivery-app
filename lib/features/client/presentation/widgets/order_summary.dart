import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../application/cart_providers.dart';
import '../../application/order_providers.dart';

/// Fee breakdown from ref/.../panier_paiement: subtotal, delivery, service, then
/// the total above a divider.
class OrderSummary extends ConsumerWidget {
  const OrderSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final subtotal = ref.watch(cartProvider).subtotal;
    final deliveryFee = ref.watch(deliveryFeeProvider);
    final total = ref.watch(orderTotalProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        children: [
          _SummaryRow(label: 'Sous-total', amount: subtotal),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: 'Frais de livraison',
            amount: deliveryFee,
            freeWhenZero: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(label: 'Frais de service', amount: serviceFee),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(),
          ),
          Row(
            children: [
              Expanded(child: Text('Total', style: AppTextStyles.headlineMd)),
              Text(
                Money.format(total),
                style: AppTextStyles.headlineMd.copyWith(color: colorScheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.amount,
    this.freeWhenZero = false,
  });

  final String label;
  final int amount;
  final bool freeWhenZero;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFree = freeWhenZero && amount == 0;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ),
        Text(
          isFree ? 'Gratuite' : Money.format(amount),
          style: AppTextStyles.labelMd.copyWith(
            color: isFree ? colorScheme.tertiary : colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
