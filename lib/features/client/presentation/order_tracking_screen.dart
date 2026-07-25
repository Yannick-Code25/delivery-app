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
import '../domain/order.dart';
import 'widgets/map_placeholder.dart';

/// Live order tracking, adapted from
/// ref/.../suivi_de_commande_en_direct/code.html: a live map, then a sheet with
/// the courier, a three-step progress bar, the order summary and a tip action.
class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({required this.orderId, super.key});

  static const _mapHeight = 340.0;
  static const _sheetOverlap = 32.0;

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(orderProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (order == null || order.id != orderId) {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: () => context.go(AppRoutes.client)),
          title: Text('Suivi', style: AppTextStyles.headlineMd),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: Text(
              'Cette commande n\'est plus suivie.',
              style: AppTextStyles.bodyMd.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
            surfaceTintColor: Colors.transparent,
            leading: BackButton(onPressed: () => context.go(AppRoutes.client)),
            title: Text('Suivi en direct', style: AppTextStyles.headlineMd),
          ),
          // Map and sheet share one sliver: as separate slivers the map would
          // paint over the sheet that overlaps it.
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: _mapHeight,
                  child: MapPlaceholder(
                    showRoute: true,
                    showCourier: order.status != OrderStatus.delivered,
                    showDestinationPin: true,
                    showLiveBadge: order.status != OrderStatus.delivered,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: _mapHeight - _sheetOverlap,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.shell),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 32,
                          offset: const Offset(0, -8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.marginMobile,
                      AppSpacing.sm,
                      AppSpacing.marginMobile,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 48,
                            height: 6,
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: AppRadius.pill,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _CourierRow(order: order),
                        const SizedBox(height: AppSpacing.md),
                        _StatusStepper(status: order.status),
                        const SizedBox(height: AppSpacing.lg),
                        _OrderCard(order: order),
                        const SizedBox(height: AppSpacing.md),
                        if (order.status == OrderStatus.delivered)
                          Pressable(
                            onTap: () => context.push(
                              AppRoutes.clientOrderReview(order.id),
                            ),
                            child: _PrimaryPill(
                              icon: Icons.star_outline,
                              label: 'Noter ma commande',
                            ),
                          )
                        else
                          Pressable(
                            // TODO: wire tipping to the payment provider.
                            onTap: () => ScaffoldMessenger.of(context)
                              ..clearSnackBars()
                              ..showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Pourboires bientôt disponibles',
                                  ),
                                ),
                              ),
                            child: _PrimaryPill(
                              icon: Icons.volunteer_activism_outlined,
                              label: 'Ajouter un pourboire',
                            ),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '${order.courierName} fait de son mieux pour vous livrer '
                          'rapidement et en toute sécurité.',
                          style: AppTextStyles.labelSm.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Stands in for the courier app pushing status updates.
                        if (order.status != OrderStatus.delivered)
                          OutlinedButton(
                            onPressed: () => ref
                                .read(orderProvider.notifier)
                                .advanceStatus(),
                            child: const Text('Simuler l\'étape suivante'),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Continue the sheet colour to the bottom of the viewport, so no
          // scaffold background shows through beneath the panel.
          SliverFillRemaining(
            hasScrollBody: false,
            child: ColoredBox(color: colorScheme.surfaceContainerLowest),
          ),
        ],
      ),
    );
  }
}

class _CourierRow extends StatelessWidget {
  const _CourierRow({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final delivered = order.status == OrderStatus.delivered;

    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              alignment: Alignment.center,
              child: Text(
                order.courierName.characters.first,
                style: AppTextStyles.headlineLg.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.surfaceContainerLowest,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.star,
                  size: 12,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VOTRE LIVREUR',
                style: AppTextStyles.labelSm.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                delivered
                    ? '${order.courierName} a livré votre commande'
                    : '${order.courierName} est en route',
                style: AppTextStyles.headlineMd,
              ),
              Text(
                delivered ? 'Livrée' : 'Arrivée dans ${order.etaMinutes} min',
                style: AppTextStyles.bodyMd.copyWith(
                  color: colorScheme.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Pressable(
          // TODO: place the call through the courier masking service.
          onTap: () {},
          pressedScale: 0.9,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(Icons.call, size: 28, color: colorScheme.primary),
          ),
        ),
      ],
    );
  }
}

/// Three-segment progress bar; the active segment shimmers as in the reference.
class _StatusStepper extends StatefulWidget {
  const _StatusStepper({required this.status});

  final OrderStatus status;

  @override
  State<_StatusStepper> createState() => _StatusStepperState();
}

class _StatusStepperState extends State<_StatusStepper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeIndex = OrderStatus.values.indexOf(widget.status);

    return Row(
      children: [
        for (final status in OrderStatus.values) ...[
          Expanded(
            child: _StepperSegment(
              status: status,
              index: OrderStatus.values.indexOf(status),
              activeIndex: activeIndex,
              shimmer: _shimmer,
              colorScheme: colorScheme,
            ),
          ),
          if (status != OrderStatus.values.last)
            const SizedBox(width: AppSpacing.base),
        ],
      ],
    );
  }
}

class _StepperSegment extends StatelessWidget {
  const _StepperSegment({
    required this.status,
    required this.index,
    required this.activeIndex,
    required this.shimmer,
    required this.colorScheme,
  });

  final OrderStatus status;
  final int index;
  final int activeIndex;
  final Animation<double> shimmer;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final isDone = index < activeIndex;
    final isActive = index == activeIndex;
    // Done steps fade back, upcoming ones fade out further — as in the reference.
    final opacity = isActive ? 1.0 : (isDone ? 0.4 : 0.2);

    return Opacity(
      opacity: opacity,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: AppRadius.pill,
            child: SizedBox(
              height: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: isDone || isActive
                        ? colorScheme.primary
                        : colorScheme.surfaceContainerHighest,
                  ),
                  if (isActive)
                    AnimatedBuilder(
                      animation: shimmer,
                      builder: (context, child) => FractionallySizedBox(
                        widthFactor: 0.4,
                        alignment: Alignment(shimmer.value * 4 - 2, 0),
                        child: ColoredBox(
                          color: colorScheme.surfaceContainerLowest.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            status.label,
            style: AppTextStyles.labelSm.copyWith(
              color: isActive ? colorScheme.primary : colorScheme.onSurface,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.receipt_long,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Commande ${order.id}', style: AppTextStyles.labelMd),
                Text(
                  '${order.itemCount} article${order.itemCount > 1 ? 's' : ''} • '
                  '${Money.format(order.total)}',
                  style: AppTextStyles.labelSm.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (context) => _OrderDetailsSheet(order: order),
            ),
            child: Text(
              'Détails',
              style: AppTextStyles.labelMd.copyWith(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  const _OrderDetailsSheet({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile,
          0,
          AppSpacing.marginMobile,
          AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(order.restaurantName, style: AppTextStyles.headlineMd),
            const SizedBox(height: AppSpacing.sm),
            for (final line in order.lines)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.base),
                child: Row(
                  children: [
                    Text('${line.quantity}×', style: AppTextStyles.labelMd),
                    const SizedBox(width: AppSpacing.base),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(line.name, style: AppTextStyles.bodyMd),
                          if (line.configurationLabel != null)
                            Text(
                              line.configurationLabel!,
                              style: AppTextStyles.labelSm.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      Money.format(line.lineTotal),
                      style: AppTextStyles.labelMd,
                    ),
                  ],
                ),
              ),
            const Divider(),
            const SizedBox(height: AppSpacing.base),
            Row(
              children: [
                Expanded(child: Text('Total', style: AppTextStyles.headlineMd)),
                Text(
                  Money.format(order.total),
                  style: AppTextStyles.headlineMd.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Payé avec ${order.paymentMethod.label} • livré à ${order.address.label}',
              style: AppTextStyles.labelSm.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryPill extends StatelessWidget {
  const _PrimaryPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colorScheme.onPrimary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.headlineMd.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
