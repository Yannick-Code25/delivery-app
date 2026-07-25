import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/money.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/remote_image.dart';
import '../application/cart_providers.dart';
import '../data/mock_menus.dart';
import '../data/mock_restaurants.dart';
import '../domain/menu_item.dart';
import '../domain/restaurant.dart';
import 'widgets/cart_bar.dart';

/// Restaurant detail, adapted from ref/.../d_tails_restaurant/code.html: a photo
/// hero under a transparent bar that fills in on scroll, an overlapping info
/// sheet, sticky category tabs, then the menu grouped by category.
class RestaurantDetailScreen extends ConsumerStatefulWidget {
  const RestaurantDetailScreen({required this.restaurantId, super.key});

  final String restaurantId;

  @override
  ConsumerState<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState
    extends ConsumerState<RestaurantDetailScreen> {
  static const _heroHeight = 265.0; // ref: h-[265px]
  static const _sheetOverlap = 48.0; // ref: -mt-12
  static const _scrollThreshold = 100.0; // ref: scrollThreshold

  final _scrollController = ScrollController();

  /// One key per category so the tabs can scroll to their section.
  final _categoryKeys = <String, GlobalKey>{};

  bool _barIsSolid = false;
  String? _activeCategoryId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final solid = _scrollController.offset > _scrollThreshold;
    if (solid != _barIsSolid) setState(() => _barIsSolid = solid);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCategory(String categoryId) {
    final key = _categoryKeys[categoryId];
    final context = key?.currentContext;
    if (context == null) return;

    setState(() => _activeCategoryId = categoryId);
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      // Leave room for the app bar and the pinned tab row.
      alignment: 0,
      alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
    );
  }

  void _addToCart(MenuItem item, Restaurant restaurant) {
    if (item.isCustomisable) {
      context.push(AppRoutes.clientProduct(restaurant.id, item.id));
      return;
    }

    final keptCart = ref
        .read(cartProvider.notifier)
        .add(
          CartItem(menuItemId: item.id, name: item.name, basePrice: item.price),
          restaurantId: restaurant.id,
        );

    // A successful add needs no message: the cart bar slides in and its counter
    // moves. Only warn when the previous cart had to be thrown away — and a
    // snackbar would otherwise sit on top of that very cart bar.
    if (!mounted || keptCart) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Panier remplacé : il ne peut contenir qu\'un seul restaurant',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final restaurant = restaurantById(widget.restaurantId);
    if (restaurant == null) return const _UnknownRestaurant();

    final menu = menuForRestaurant(restaurant.id);
    final colorScheme = Theme.of(context).colorScheme;

    for (final category in menu) {
      _categoryKeys.putIfAbsent(category.id, GlobalKey.new);
    }
    final activeCategoryId =
        _activeCategoryId ?? (menu.isEmpty ? null : menu.first.id);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Hero and info sheet share one sliver: separate slivers paint in
              // an order that would let the photo cover the overlapping sheet.
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: _heroHeight,
                      child: _Hero(imageUrl: restaurant.imageUrl),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: _heroHeight - _sheetOverlap,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppRadius.shell),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.marginMobile,
                          AppSpacing.md,
                          AppSpacing.marginMobile,
                          AppSpacing.sm,
                        ),
                        child: _RestaurantHeader(restaurant: restaurant),
                      ),
                    ),
                  ],
                ),
              ),
              if (menu.isNotEmpty)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _CategoryTabsDelegate(
                    categories: menu,
                    activeCategoryId: activeCategoryId,
                    onSelect: _scrollToCategory,
                    backgroundColor: colorScheme.surface,
                    dividerColor: colorScheme.surfaceContainerHighest,
                  ),
                ),
              SliverPadding(
                // The sheet is shifted up, so pull the following content up too.
                padding: const EdgeInsets.only(
                  left: AppSpacing.marginMobile,
                  right: AppSpacing.marginMobile,
                  bottom: 120,
                ),
                sliver: SliverList.list(
                  children: [
                    for (final category in menu) ...[
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        category.name,
                        key: _categoryKeys[category.id],
                        style: AppTextStyles.headlineLg,
                      ),
                      const SizedBox(height: AppSpacing.gutter),
                      for (final item in category.items) ...[
                        _MenuItemCard(
                          item: item,
                          onAdd: () => _addToCart(item, restaurant),
                          onTap: item.isCustomisable
                              ? () => _addToCart(item, restaurant)
                              : null,
                        ),
                        const SizedBox(height: AppSpacing.gutter),
                      ],
                    ],
                    if (menu.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xl),
                        child: Text(
                          'Le menu de ce restaurant arrive bientôt.',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          _FloatingBar(isSolid: _barIsSolid, title: restaurant.name),
          const Positioned(left: 0, right: 0, bottom: 0, child: CartBar()),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _RestaurantDetailScreenState._heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RemoteImage(url: imageUrl),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Transparent overlay bar that fills with the surface colour once scrolled,
/// matching the reference's scroll listener.
class _FloatingBar extends StatelessWidget {
  const _FloatingBar({required this.isSolid, required this.title});

  final bool isSolid;
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: isSolid ? colorScheme.surface : Colors.transparent,
        boxShadow: isSolid
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginMobile,
            ),
            child: Row(
              children: [
                _CircleButton(
                  icon: Icons.arrow_back,
                  onTap: () => context.pop(),
                ),
                Expanded(
                  child: AnimatedOpacity(
                    opacity: isSolid ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Text(
                        title,
                        style: AppTextStyles.headlineMd,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
                _CircleButton(icon: Icons.share_outlined, onTap: () {}),
                const SizedBox(width: AppSpacing.base),
                _CircleButton(icon: Icons.search, onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Pressable(
      onTap: onTap,
      pressedScale: 0.9,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: colorScheme.onSurface),
      ),
    );
  }
}

class _RestaurantHeader extends StatelessWidget {
  const _RestaurantHeader({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                restaurant.name,
                style: AppTextStyles.headlineLg.copyWith(letterSpacing: -0.5),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: AppRadius.pill,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 18,
                        color: colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        restaurant.rating.toStringAsFixed(1),
                        style: AppTextStyles.labelMd.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                if (restaurant.reviewCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Text(
                      '(${restaurant.reviewCount}+ avis)',
                      style: AppTextStyles.labelSm.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.gutter,
          runSpacing: AppSpacing.base,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _MetaChip(
              icon: Icons.restaurant_outlined,
              label: restaurant.categoriesLabel,
            ),
            _MetaChip(
              icon: Icons.schedule,
              label: restaurant.deliveryTimeLabel,
            ),
            _MetaChip(
              icon: Icons.delivery_dining,
              label: restaurant.hasFreeDelivery
                  ? 'Livraison gratuite'
                  : Money.format(restaurant.deliveryFee),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Flexible(
          child: Text(
            label,
            style: AppTextStyles.bodyMd.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CategoryTabsDelegate extends SliverPersistentHeaderDelegate {
  _CategoryTabsDelegate({
    required this.categories,
    required this.activeCategoryId,
    required this.onSelect,
    required this.backgroundColor,
    required this.dividerColor,
  });

  static const _height = 64.0;

  final List<MenuCategory> categories;
  final String? activeCategoryId;
  final ValueChanged<String> onSelect;
  final Color backgroundColor;
  final Color dividerColor;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: _height,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          bottom: BorderSide(color: dividerColor.withValues(alpha: 0.5)),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMobile,
          vertical: AppSpacing.sm,
        ),
        children: [
          for (final category in categories)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: Pressable(
                onTap: () => onSelect(category.id),
                pressedScale: 0.95,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.gutter,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: category.id == activeCategoryId
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainerLow,
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(
                    category.name,
                    style: AppTextStyles.labelMd.copyWith(
                      color: category.id == activeCategoryId
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_CategoryTabsDelegate oldDelegate) =>
      oldDelegate.activeCategoryId != activeCategoryId ||
      oldDelegate.categories != categories;
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({required this.item, required this.onAdd, this.onTap});

  final MenuItem item;
  final VoidCallback onAdd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.gutter),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: AppRadius.card,
          border: Border.all(color: colorScheme.surfaceContainer),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.bodyLg.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.description,
                    style: AppTextStyles.labelSm.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.gutter),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Money.format(item.price),
                          style: AppTextStyles.labelMd.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      _AddButton(
                        onTap: onAdd,
                        isCustomisable: item.isCustomisable,
                        itemName: item.name,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (item.imageUrl != null) ...[
              const SizedBox(width: AppSpacing.gutter),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: RemoteImage(url: item.imageUrl!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.onTap,
    required this.isCustomisable,
    required this.itemName,
  });

  final VoidCallback onTap;
  final bool isCustomisable;
  final String itemName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Naming the dish keeps the button meaningful to a screen reader, where the
    // bare "+" of the mockup would be ambiguous among a list of dishes.
    return Tooltip(
      message: isCustomisable ? 'Personnaliser $itemName' : 'Ajouter $itemName',
      child: Pressable(
        onTap: onTap,
        pressedScale: 0.9,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            // Customisable items open a screen rather than adding directly.
            isCustomisable ? Icons.tune : Icons.add,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class _UnknownRestaurant extends StatelessWidget {
  const _UnknownRestaurant();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
      body: Center(
        child: Text('Restaurant introuvable.', style: AppTextStyles.bodyMd),
      ),
    );
  }
}
