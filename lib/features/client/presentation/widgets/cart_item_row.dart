import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../../shared/widgets/remote_image.dart';
import '../../application/cart_providers.dart';

/// Cart line from ref/.../panier_babali_style: thumbnail, name, the chosen
/// options, the line price and a pill-shaped quantity stepper.
class CartItemRow extends StatelessWidget {
  const CartItemRow({
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
    this.imageUrl,
    super.key,
  });

  final CartItem item;
  final String? imageUrl;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final subtitle = item.configurationLabel ?? item.note;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(
              width: 80,
              height: 80,
              child: imageUrl == null
                  ? ColoredBox(
                      color: colorScheme.surfaceContainerHigh,
                      child: Icon(
                        Icons.restaurant,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                      ),
                    )
                  : RemoteImage(url: imageUrl!),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: AppTextStyles.labelMd),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSm.copyWith(color: colorScheme.secondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: AppSpacing.base),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        Money.format(item.lineTotal),
                        style: AppTextStyles.labelMd.copyWith(color: colorScheme.primary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _QuantityStepper(
                      quantity: item.quantity,
                      onDecrease: onDecrease,
                      onIncrease: onIncrease,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.pill,
      ),
      child: Row(
        children: [
          Pressable(
            onTap: onDecrease,
            pressedScale: 0.85,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Icon(
                // Removing the last unit deletes the line.
                quantity > 1 ? Icons.remove : Icons.delete_outline,
                size: 20,
                color: colorScheme.primary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text('$quantity', style: AppTextStyles.labelMd),
          ),
          Pressable(
            onTap: onIncrease,
            pressedScale: 0.85,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Icon(Icons.add, size: 20, color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
