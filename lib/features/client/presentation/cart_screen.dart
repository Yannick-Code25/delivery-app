import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/money.dart';
import '../../../shared/widgets/pressable.dart';
import '../application/cart_providers.dart';
import '../application/order_providers.dart';
import '../data/mock_menus.dart';
import '../data/mock_restaurants.dart';
import 'widgets/address_card.dart';
import 'widgets/cart_item_row.dart';
import 'widgets/order_summary.dart';

/// Cart and checkout, adapted from ref/.../panier_babali_style and
/// ref/.../panier_paiement. Those two mockups differ only by the payment block
/// and totals, so this screen renders both and takes a [showPayment] flag: the
/// cart step lets you adjust quantities, the checkout step adds the payment
/// method, the fee breakdown, the promo field and the confirm bar.
class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({this.showPayment = false, super.key});

  final bool showPayment;

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final _promoController = TextEditingController();

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _confirmOrder() {
    final order = ref.read(orderProvider.notifier).placeFromCart();
    if (order == null) return;

    ref.read(cartProvider.notifier).clear();
    context.go(AppRoutes.clientOrderTracking(order.id));
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final restaurant =
        cart.restaurantId == null ? null : restaurantById(cart.restaurantId!);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(
          widget.showPayment ? 'Paiement' : 'Panier',
          style: AppTextStyles.headlineMd.copyWith(color: colorScheme.primary),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.help_outline, color: colorScheme.primary),
            tooltip: 'Aide',
          ),
          const SizedBox(width: AppSpacing.base),
        ],
      ),
      body: cart.isEmpty
          ? const _EmptyCart()
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                AppSpacing.gutter,
                AppSpacing.marginMobile,
                AppSpacing.xl,
              ),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text('Votre commande', style: AppTextStyles.headlineLgMobile),
                    ),
                    Text(
                      '${cart.itemCount} article${cart.itemCount > 1 ? 's' : ''}',
                      style: AppTextStyles.labelMd.copyWith(color: colorScheme.secondary),
                    ),
                  ],
                ),
                if (restaurant != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      restaurant.name,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.md),
                for (final item in cart.items) ...[
                  CartItemRow(
                    item: item,
                    imageUrl: cart.restaurantId == null
                        ? null
                        : menuItemById(cart.restaurantId!, item.menuItemId)?.imageUrl,
                    onDecrease: () => ref
                        .read(cartProvider.notifier)
                        .setQuantity(item.configurationKey, item.quantity - 1),
                    onIncrease: () => ref
                        .read(cartProvider.notifier)
                        .setQuantity(item.configurationKey, item.quantity + 1),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                const SizedBox(height: AppSpacing.md),
                _SectionHeader(
                  title: 'Adresse de livraison',
                  actionLabel: 'Modifier',
                  onAction: () => context.push(AppRoutes.clientAddresses),
                ),
                const SizedBox(height: AppSpacing.sm),
                const AddressCard(),
                if (widget.showPayment) ...[
                  const SizedBox(height: AppSpacing.md),
                  _SectionHeader(
                    title: 'Moyen de paiement',
                    onAction: () => context.push(AppRoutes.clientPaymentMethods),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const _PaymentMethodTile(),
                  const SizedBox(height: AppSpacing.md),
                  const OrderSummary(),
                  const SizedBox(height: AppSpacing.md),
                  _PromoField(controller: _promoController),
                ],
              ],
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : _BottomBar(
              showPayment: widget.showPayment,
              onContinue: () => context.push(AppRoutes.clientCheckout),
              onConfirm: _confirmOrder,
            ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.headlineMd)),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: AppTextStyles.labelMd.copyWith(color: colorScheme.primary),
            ),
          ),
      ],
    );
  }
}

/// Saved card row from the payment mockup; tapping it opens the full list.
class _PaymentMethodTile extends ConsumerWidget {
  const _PaymentMethodTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final method = ref.watch(selectedPaymentMethodProvider);

    return Pressable(
      onTap: () => context.push(AppRoutes.clientPaymentMethods),
      pressedScale: 0.99,
      child: Container(
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
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(method.icon, color: colorScheme.onSecondaryContainer),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method.label, style: AppTextStyles.labelMd),
                  Text(
                    method.details,
                    style: AppTextStyles.labelSm.copyWith(color: colorScheme.secondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colorScheme.secondary),
          ],
        ),
      ),
    );
  }
}

class _PromoField extends StatelessWidget {
  const _PromoField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Code promo'),
          ),
        ),
        const SizedBox(width: AppSpacing.base),
        SizedBox(
          height: 56,
          child: Pressable(
            // TODO: validate the code against the promotions endpoint.
            onTap: () => ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                const SnackBar(content: Text('Codes promo bientôt disponibles')),
              ),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: AppRadius.input,
              ),
              child: Text(
                'Appliquer',
                style: AppTextStyles.labelMd.copyWith(
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar({
    required this.showPayment,
    required this.onContinue,
    required this.onConfirm,
  });

  final bool showPayment;
  final VoidCallback onContinue;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final total = ref.watch(orderTotalProvider);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.gutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Pressable(
                onTap: showPayment ? onConfirm : onContinue,
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: AppRadius.pill,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          showPayment
                              ? 'Confirmer la commande'
                              : 'Continuer • ${Money.format(total)}',
                          style: AppTextStyles.headlineMd.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          showPayment ? Icons.trending_flat : Icons.arrow_forward,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (showPayment)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.base),
                  child: Text(
                    'En confirmant, vous acceptez nos CGV et notre politique de confidentialité.',
                    style: AppTextStyles.labelSm.copyWith(
                      color: colorScheme.secondary,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 56,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Ton panier est vide', style: AppTextStyles.headlineMd),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Choisis un restaurant pour commencer.',
              style: AppTextStyles.bodyMd.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: () => context.go(AppRoutes.client),
              child: const Text('Voir les restaurants'),
            ),
          ],
        ),
      ),
    );
  }
}
