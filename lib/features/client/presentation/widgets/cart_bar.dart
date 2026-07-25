import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../application/cart_providers.dart';

/// Floating "Voir le panier" pill from ref/.../d_tails_restaurant/code.html.
/// It slides in from below the moment the cart stops being empty, as the
/// reference does when its hidden class is removed.
class CartBar extends ConsumerWidget {
  const CartBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedSlide(
      offset: cart.isEmpty ? const Offset(0, 1.6) : Offset.zero,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: cart.isEmpty ? 0 : 1,
        duration: const Duration(milliseconds: 250),
        child: IgnorePointer(
          ignoring: cart.isEmpty,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Pressable(
                onTap: () => context.push(AppRoutes.clientCart),
                child: Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: AppRadius.pill,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: AppTextStyles.labelMd.copyWith(
                            color: colorScheme.primaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Voir le panier',
                          style: AppTextStyles.headlineMd.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        Money.format(cart.subtotal),
                        style: AppTextStyles.headlineMd.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
