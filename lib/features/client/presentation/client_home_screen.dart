import 'package:flutter/material.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/pressable.dart';
import '../data/mock_restaurants.dart';
import '../domain/restaurant.dart';
import 'widgets/restaurant_card.dart';

/// Client home, adapted from ref/.../accueil_babali_style/code.html: brand app
/// bar, a sticky filter row, then the restaurant feed.
class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  static const _filters = ['Ouvert', 'Livraison gratuite', 'Note 4+', 'Cuisine'];

  final _activeFilters = <String>{};

  /// TODO: move filtering server-side once the catalogue endpoint exists.
  List<Restaurant> get _visibleRestaurants {
    return mockRestaurants.where((restaurant) {
      if (_activeFilters.contains('Ouvert') && !restaurant.isOpen) return false;
      if (_activeFilters.contains('Livraison gratuite') && !restaurant.hasFreeDelivery) {
        return false;
      }
      if (_activeFilters.contains('Note 4+') && restaurant.rating < 4) return false;
      return true;
    }).toList();
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (!_activeFilters.remove(filter)) _activeFilters.add(filter);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final restaurants = _visibleRestaurants;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: colorScheme.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 2,
          leading: IconButton(
            onPressed: () {},
            icon: Icon(Icons.menu, color: colorScheme.primary),
            tooltip: 'Menu',
          ),
          title: Text('Dabali', style: AppTextStyles.headlineXl.copyWith(
            color: colorScheme.primary,
          )),
          actions: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.search, color: colorScheme.primary),
              tooltip: 'Rechercher',
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.shopping_cart_outlined, color: colorScheme.primary),
              tooltip: 'Panier',
            ),
            const SizedBox(width: AppSpacing.base),
          ],
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _FilterBarDelegate(
            filters: _filters,
            activeFilters: _activeFilters,
            onToggle: _toggleFilter,
            backgroundColor: colorScheme.surface,
            dividerColor: colorScheme.surfaceContainerHighest,
          ),
        ),
        if (restaurants.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyState(onReset: () => setState(_activeFilters.clear)),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.marginMobile,
              AppSpacing.md,
              AppSpacing.marginMobile,
              AppSpacing.xl,
            ),
            sliver: SliverList.separated(
              itemCount: restaurants.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => RestaurantCard(
                restaurant: restaurants[index],
                onTap: () {
                  // TODO: open ref/.../d_tails_restaurant once that screen exists.
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// Sticky filter row: a leading "Filtres" chip then the toggleable filters.
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  _FilterBarDelegate({
    required this.filters,
    required this.activeFilters,
    required this.onToggle,
    required this.backgroundColor,
    required this.dividerColor,
  });

  static const _height = 64.0;

  final List<String> filters;
  final Set<String> activeFilters;
  final ValueChanged<String> onToggle;
  final Color backgroundColor;
  final Color dividerColor;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(bottom: BorderSide(color: dividerColor.withValues(alpha: 0.3))),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile,
          vertical: AppSpacing.sm,
        ),
        children: [
          _FilterChip(
            label: 'Filtres',
            selected: true,
            leadingIcon: Icons.tune,
            onTap: () {},
          ),
          for (final filter in filters) ...[
            const SizedBox(width: AppSpacing.sm),
            _FilterChip(
              label: filter,
              selected: activeFilters.contains(filter),
              trailingIcon: filter == 'Cuisine' ? Icons.expand_more : null,
              onTap: () => onToggle(filter),
            ),
          ],
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_FilterBarDelegate oldDelegate) =>
      oldDelegate.activeFilters != activeFilters ||
      oldDelegate.filters != filters ||
      oldDelegate.backgroundColor != backgroundColor;
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground =
        selected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant;

    return Pressable(
      onTap: onTap,
      pressedScale: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHigh,
          borderRadius: AppRadius.pill,
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 18, color: foreground),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(label, style: AppTextStyles.labelMd.copyWith(color: foreground)),
            if (trailingIcon != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(trailingIcon, size: 18, color: foreground),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onReset});

  final VoidCallback onReset;

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
              Icons.no_meals_outlined,
              size: 56,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Aucun restaurant ne correspond',
              style: AppTextStyles.headlineMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Essaie de retirer un filtre.',
              style: AppTextStyles.bodyMd.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: onReset,
              child: const Text('Réinitialiser les filtres'),
            ),
          ],
        ),
      ),
    );
  }
}
