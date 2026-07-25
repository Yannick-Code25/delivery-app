import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/money.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/remote_image.dart';
import '../application/cart_providers.dart';
import '../data/mock_menus.dart';
import '../domain/menu_item.dart';

/// Product customisation, adapted from
/// ref/.../d_tails_personnalisation_produit/code.html: photo hero, overlapping
/// info card, size grid, optional extras, free-text note, and a floating footer
/// holding the quantity stepper next to the running total.
class ProductCustomizationScreen extends ConsumerStatefulWidget {
  const ProductCustomizationScreen({
    required this.restaurantId,
    required this.itemId,
    super.key,
  });

  final String restaurantId;
  final String itemId;

  @override
  ConsumerState<ProductCustomizationScreen> createState() =>
      _ProductCustomizationScreenState();
}

class _ProductCustomizationScreenState extends ConsumerState<ProductCustomizationScreen> {
  static const _heroHeight = 320.0; // ref: h-[320px]

  final _noteController = TextEditingController();
  final _selectedExtraIds = <String>{};

  String? _selectedSizeId;
  int _quantity = 1;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  int _basePrice(MenuItem item) {
    if (item.sizes.isEmpty) return item.price;
    final sizeId = _selectedSizeId ?? item.sizes.first.id;
    return item.sizes.firstWhere((size) => size.id == sizeId).price;
  }

  List<CartExtra> _chosenExtras(MenuItem item) => item.extras
      .where((extra) => _selectedExtraIds.contains(extra.id))
      .map((extra) => CartExtra(label: extra.label, price: extra.price))
      .toList();

  int _total(MenuItem item) {
    final extras = _chosenExtras(item).fold(0, (sum, extra) => sum + extra.price);
    return (_basePrice(item) + extras) * _quantity;
  }

  void _addToCart(MenuItem item) {
    final sizeLabel = item.sizes.isEmpty
        ? null
        : item.sizes
            .firstWhere((size) => size.id == (_selectedSizeId ?? item.sizes.first.id))
            .label;
    final note = _noteController.text.trim();

    final keptCart = ref.read(cartProvider.notifier).add(
          CartItem(
            menuItemId: item.id,
            name: item.name,
            basePrice: _basePrice(item),
            sizeLabel: sizeLabel,
            extras: _chosenExtras(item),
            note: note.isEmpty ? null : note,
            quantity: _quantity,
          ),
          restaurantId: widget.restaurantId,
        );

    if (!mounted) return;
    if (!keptCart) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Panier remplacé : il ne peut contenir qu\'un seul restaurant'),
          ),
        );
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final item = menuItemById(widget.restaurantId, widget.itemId);
    if (item == null) {
      return Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
        body: Center(child: Text('Produit introuvable.', style: AppTextStyles.bodyMd)),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Hero(imageUrl: item.imageUrl),
                Transform.translate(
                  offset: const Offset(0, -48),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.marginMobile,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _InfoCard(item: item),
                        const SizedBox(height: AppSpacing.md),
                        if (item.sizes.isNotEmpty) ...[
                          _SectionTitle(icon: Icons.straighten, label: 'Choisir la taille'),
                          const SizedBox(height: AppSpacing.sm),
                          _SizeGrid(
                            sizes: item.sizes,
                            selectedId: _selectedSizeId ?? item.sizes.first.id,
                            onSelect: (id) => setState(() => _selectedSizeId = id),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        if (item.extras.isNotEmpty) ...[
                          Row(
                            children: [
                              Expanded(
                                child: _SectionTitle(
                                  icon: Icons.add_circle_outline,
                                  label: 'Suppléments',
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainer,
                                  borderRadius: AppRadius.pill,
                                ),
                                child: Text(
                                  'Facultatif',
                                  style: AppTextStyles.labelSm.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          for (final extra in item.extras) ...[
                            _ExtraRow(
                              extra: extra,
                              selected: _selectedExtraIds.contains(extra.id),
                              onToggle: () => setState(() {
                                if (!_selectedExtraIds.remove(extra.id)) {
                                  _selectedExtraIds.add(extra.id);
                                }
                              }),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          const SizedBox(height: AppSpacing.md),
                        ],
                        _SectionTitle(icon: Icons.notes, label: 'Notes spéciales'),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _noteController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Ex : sans basilic, pâte bien cuite…',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.gutter),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _CircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => context.pop(),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _FooterBar(
              quantity: _quantity,
              total: _total(item),
              onDecrease: () => setState(() {
                if (_quantity > 1) _quantity--;
              }),
              onIncrease: () => setState(() => _quantity++),
              onAdd: () => _addToCart(item),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: _ProductCustomizationScreenState._heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            RemoteImage(url: imageUrl!)
          else
            ColoredBox(color: colorScheme.surfaceContainerHigh),
          // Fades the photo into the page background, as in the reference.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [colorScheme.surface, Colors.transparent],
                stops: const [0, 0.6],
              ),
            ),
          ),
        ],
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
          color: colorScheme.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: colorScheme.onSurface),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.item});

  final MenuItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(item.name, style: AppTextStyles.headlineLgMobile),
              ),
              if (item.rating != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    borderRadius: AppRadius.pill,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star, size: 16, color: colorScheme.onTertiaryContainer),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        item.rating!.toStringAsFixed(1),
                        style: AppTextStyles.labelMd.copyWith(
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            item.description,
            style: AppTextStyles.bodyMd.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, color: colorScheme.primary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(child: Text(label, style: AppTextStyles.headlineMd)),
      ],
    );
  }
}

class _SizeGrid extends StatelessWidget {
  const _SizeGrid({
    required this.sizes,
    required this.selectedId,
    required this.onSelect,
  });

  final List<MenuItemSize> sizes;
  final String selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final size in sizes) ...[
          Expanded(
            child: _SizeOption(
              size: size,
              selected: size.id == selectedId,
              onTap: () => onSelect(size.id),
            ),
          ),
          if (size != sizes.last) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _SizeOption extends StatelessWidget {
  const _SizeOption({required this.size, required this.selected, required this.onTap});

  final MenuItemSize size;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = selected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHigh,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: selected ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(size.icon, size: 32 * size.iconScale, color: foreground),
            const SizedBox(height: AppSpacing.xs),
            Text(
              size.label,
              style: AppTextStyles.labelMd.copyWith(color: foreground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                Money.format(size.price),
                style: AppTextStyles.headlineMd.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExtraRow extends StatelessWidget {
  const _ExtraRow({
    required this.extra,
    required this.selected,
    required this.onToggle,
  });

  final MenuItemExtra extra;
  final bool selected;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Pressable(
      onTap: onToggle,
      pressedScale: 0.99,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: AppRadius.card,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              clipBehavior: Clip.antiAlias,
              child: extra.imageUrl != null
                  ? RemoteImage(url: extra.imageUrl!, fallbackIcon: Icons.restaurant)
                  : Icon(
                      Icons.add,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(extra.label, style: AppTextStyles.labelMd),
                  Text(
                    '+ ${Money.format(extra.price)}',
                    style: AppTextStyles.labelSm.copyWith(color: colorScheme.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: selected ? colorScheme.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? colorScheme.primary : colorScheme.outlineVariant,
                  width: 2,
                ),
              ),
              child: selected
                  ? Icon(Icons.check, size: 14, color: colorScheme.onPrimary)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterBar extends StatelessWidget {
  const _FooterBar({
    required this.quantity,
    required this.total,
    required this.onDecrease,
    required this.onIncrease,
    required this.onAdd,
  });

  final int quantity;
  final int total;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.base),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLowest,
            borderRadius: AppRadius.pill,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              _StepperButton(
                icon: Icons.remove,
                onTap: quantity > 1 ? onDecrease : null,
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '$quantity',
                  style: AppTextStyles.headlineMd,
                  textAlign: TextAlign.center,
                ),
              ),
              _StepperButton(icon: Icons.add, onTap: onIncrease),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Pressable(
                  onTap: onAdd,
                  child: Container(
                    height: 48,
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
                            'Ajouter',
                            style: AppTextStyles.labelMd.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            Money.format(total),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;

    return Pressable(
      onTap: onTap,
      pressedScale: 0.9,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled
              ? colorScheme.onSurface
              : colorScheme.onSurface.withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
