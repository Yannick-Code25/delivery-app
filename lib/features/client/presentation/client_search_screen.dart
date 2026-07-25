import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/pressable.dart';
import '../data/mock_menus.dart';
import '../data/mock_restaurants.dart';
import '../domain/restaurant.dart';
import 'widgets/restaurant_card.dart';

/// Search, adapted from ref/.../recherche_client/code.html: a search field, then
/// recent searches, category shortcuts and a trending list. Typing replaces all
/// of that with results. Copy is translated, the mockup being in English.
class ClientSearchScreen extends StatefulWidget {
  const ClientSearchScreen({super.key});

  @override
  State<ClientSearchScreen> createState() => _ClientSearchScreenState();
}

class _ClientSearchScreenState extends State<ClientSearchScreen> {
  static const _categories = [
    ('Burgers', Icons.lunch_dining),
    ('Sushi', Icons.set_meal),
    ('Pizza', Icons.local_pizza),
    ('Dessert', Icons.icecream),
  ];

  final _controller = TextEditingController();

  /// TODO: persist recent searches locally and sync them with the account.
  final _recentSearches = <String>['Pizza', 'Sushi Master', 'Poulet yassa'];

  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      _query = query;
      _controller.text = query;
      _controller.selection = TextSelection.collapsed(offset: query.length);
      if (query.trim().isNotEmpty) {
        _recentSearches
          ..remove(query)
          ..insert(0, query);
        if (_recentSearches.length > 6) _recentSearches.removeLast();
      }
    });
  }

  /// Matches restaurant names, cuisines, and the dishes on their menus.
  List<Restaurant> get _results {
    final needle = _query.trim().toLowerCase();
    if (needle.isEmpty) return const [];

    return mockRestaurants.where((restaurant) {
      if (restaurant.name.toLowerCase().contains(needle)) return true;
      if (restaurant.categories.any((c) => c.toLowerCase().contains(needle))) return true;

      return menuForRestaurant(restaurant.id).any(
        (category) => category.items.any(
          (item) => item.name.toLowerCase().contains(needle),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final searching = _query.trim().isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: TextField(
                controller: _controller,
                autofocus: false,
                textInputAction: TextInputAction.search,
                onChanged: (value) => setState(() => _query = value),
                onSubmitted: _search,
                decoration: InputDecoration(
                  hintText: 'Un restaurant, un plat…',
                  prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                  suffixIcon: searching
                      ? IconButton(
                          onPressed: () => _search(''),
                          icon: const Icon(Icons.close),
                          tooltip: 'Effacer',
                        )
                      : null,
                ),
              ),
            ),
            Expanded(
              child: searching
                  ? _Results(results: _results, query: _query)
                  : _Discovery(
                      recentSearches: _recentSearches,
                      categories: _categories,
                      onSearch: _search,
                      onClearRecents: () => setState(_recentSearches.clear),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.results, required this.query});

  final List<Restaurant> results;
  final String query;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off,
                size: 56,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Aucun résultat', style: AppTextStyles.headlineMd),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Rien ne correspond à « $query ».',
                style: AppTextStyles.bodyMd.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        0,
        AppSpacing.marginMobile,
        AppSpacing.xl,
      ),
      itemCount: results.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) => RestaurantCard(
        restaurant: results[index],
        onTap: () => context.push(AppRoutes.clientRestaurant(results[index].id)),
      ),
    );
  }
}

class _Discovery extends StatelessWidget {
  const _Discovery({
    required this.recentSearches,
    required this.categories,
    required this.onSearch,
    required this.onClearRecents,
  });

  final List<String> recentSearches;
  final List<(String, IconData)> categories;
  final ValueChanged<String> onSearch;
  final VoidCallback onClearRecents;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // The mockup's "Trending near you" list; ordered by rating here.
    final trending = [...mockRestaurants]..sort((a, b) => b.rating.compareTo(a.rating));

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.marginMobile,
        0,
        AppSpacing.marginMobile,
        AppSpacing.xl,
      ),
      children: [
        if (recentSearches.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text('Recherches récentes', style: AppTextStyles.headlineMd),
              ),
              GestureDetector(
                onTap: onClearRecents,
                child: Text(
                  'Effacer',
                  style: AppTextStyles.labelMd.copyWith(color: colorScheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final search in recentSearches)
            Pressable(
              onTap: () => onSearch(search),
              pressedScale: 0.99,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(Icons.history, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(search, style: AppTextStyles.bodyMd)),
                    Icon(
                      Icons.north_west,
                      size: 18,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
        ],
        Text('Catégories populaires', style: AppTextStyles.headlineMd),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 2.4,
          children: [
            for (final (label, icon) in categories)
              Pressable(
                onTap: () => onSearch(label),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLow,
                    borderRadius: AppRadius.card,
                  ),
                  child: Row(
                    children: [
                      Icon(icon, color: colorScheme.primary),
                      const SizedBox(width: AppSpacing.base),
                      Expanded(
                        child: Text(
                          label,
                          style: AppTextStyles.labelMd,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Tendances près de vous', style: AppTextStyles.headlineMd),
        const SizedBox(height: AppSpacing.sm),
        for (final restaurant in trending.take(3))
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: RestaurantCard(
              restaurant: restaurant,
              onTap: () => context.push(AppRoutes.clientRestaurant(restaurant.id)),
            ),
          ),
      ],
    );
  }
}
