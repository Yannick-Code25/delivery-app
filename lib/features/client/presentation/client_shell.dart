import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/money.dart';
import '../application/cart_providers.dart';

/// Bottom navigation shell for the client space, from the BottomNavBar and the
/// floating "Voir le panier" button in ref/.../accueil_babali_style/code.html.
class ClientShell extends ConsumerWidget {
  const ClientShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    _Tab(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Accueil'),
    _Tab(icon: Icons.search, activeIcon: Icons.search, label: 'Recherche'),
    _Tab(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Commandes'),
    _Tab(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      body: navigationShell,
      // The cart button only exists while there is something to check out.
      floatingActionButton: cart.isEmpty ? null : _CartButton(total: cart.subtotal),
      bottomNavigationBar: _NavBar(
        tabs: _tabs,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          // Tapping the active tab returns it to its first screen.
          initialLocation: index == navigationShell.currentIndex,
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab({required this.icon, required this.activeIcon, required this.label});

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavBar extends StatelessWidget {
  const _NavBar({required this.tabs, required this.currentIndex, required this.onTap});

  final List<_Tab> tabs;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (var index = 0; index < tabs.length; index++)
                _NavItem(
                  tab: tabs[index],
                  selected: index == currentIndex,
                  onTap: () => onTap(index),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.tab, required this.selected, required this.onTap});

  final _Tab tab;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = selected ? colorScheme.onPrimaryContainer : colorScheme.secondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.pill,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primaryContainer : Colors.transparent,
            borderRadius: AppRadius.pill,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? tab.activeIcon : tab.icon, color: color, size: 24),
              Text(
                tab.label,
                style: AppTextStyles.labelSm.copyWith(color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartButton extends StatelessWidget {
  const _CartButton({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FloatingActionButton.extended(
      onPressed: () => context.push(AppRoutes.clientCart),
      backgroundColor: colorScheme.primaryContainer,
      foregroundColor: colorScheme.onPrimaryContainer,
      icon: const Icon(Icons.shopping_bag_outlined),
      label: Text(
        'Voir le panier • ${Money.format(total)}',
        style: AppTextStyles.labelMd.copyWith(color: colorScheme.onPrimaryContainer),
      ),
    );
  }
}
