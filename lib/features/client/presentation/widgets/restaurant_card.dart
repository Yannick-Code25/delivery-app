import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money.dart';
import '../../../../shared/widgets/pressable.dart';
import '../../../../shared/widgets/remote_image.dart';
import '../../domain/restaurant.dart';

/// Restaurant card from ref/.../accueil_babali_style/code.html: photo with glass
/// badges, then a logo overlapping the photo's lower edge beside the details.
class RestaurantCard extends StatelessWidget {
  const RestaurantCard({required this.restaurant, this.onTap, super.key});

  static const _photoHeight = 192.0; // ref: h-48
  static const _logoSize = 56.0; // ref: h-14 w-14
  static const _logoOverlap = 40.0; // ref: -mt-10

  final Restaurant restaurant;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Pressable(
      onTap: onTap,
      child: Container(
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Photo(restaurant: restaurant),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -_logoOverlap),
                    child: _Logo(url: restaurant.logoUrl),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _Details(restaurant: restaurant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: RestaurantCard._photoHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RemoteImage(url: restaurant.imageUrl),
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: _GlassBadge(
              borderRadius: BorderRadius.circular(AppRadius.base),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    restaurant.rating.toStringAsFixed(1),
                    style: AppTextStyles.labelMd,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: AppSpacing.sm,
            left: AppSpacing.sm,
            child: _GlassBadge(
              borderRadius: AppRadius.pill,
              child: Text(restaurant.deliveryTimeLabel, style: AppTextStyles.labelSm),
            ),
          ),
        ],
      ),
    );
  }
}

/// ref: .glass-badge — 90% white over an 8px backdrop blur.
class _GlassBadge extends StatelessWidget {
  const _GlassBadge({required this.child, required this.borderRadius});

  final Widget child;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: RestaurantCard._logoSize,
      height: RestaurantCard._logoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(child: RemoteImage(url: url, fallbackIcon: Icons.storefront)),
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(restaurant.name, style: AppTextStyles.headlineMd),
        Text(
          restaurant.categoriesLabel,
          style: AppTextStyles.bodyMd.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Icon(
              restaurant.hasFreeDelivery ? Icons.verified_outlined : Icons.delivery_dining,
              size: 16,
              color: restaurant.hasFreeDelivery
                  ? colorScheme.tertiary
                  : colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                restaurant.hasFreeDelivery
                    ? 'Livraison gratuite'
                    : 'Livraison ${Money.format(restaurant.deliveryFee)}',
                style: AppTextStyles.labelMd.copyWith(
                  color: restaurant.hasFreeDelivery
                      ? colorScheme.tertiary
                      : colorScheme.onTertiaryContainer,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
