import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/pressable.dart';
import '../application/order_providers.dart';
import '../domain/delivery_address.dart';
import 'widgets/map_placeholder.dart';

/// Saved addresses, adapted from ref/.../mes_adresses_de_livraison/code.html:
/// an intro, a "current position" strip, the saved list with a default badge,
/// and an add action. Selecting one makes it the delivery address.
class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final addresses = ref.watch(addressesProvider);
    final selected = ref.watch(selectedAddressProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text('Mes adresses', style: AppTextStyles.headlineMd),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile,
          AppSpacing.gutter,
          AppSpacing.marginMobile,
          AppSpacing.xl,
        ),
        children: [
          Text('Où livrons-nous ?', style: AppTextStyles.headlineLgMobile),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Gérez vos lieux préférés pour des livraisons encore plus rapides.',
            style: AppTextStyles.bodyMd.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          const _CurrentPositionCard(),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Text('Vos adresses', style: AppTextStyles.headlineMd)),
              Text(
                '${addresses.length} adresse${addresses.length > 1 ? 's' : ''}',
                style: AppTextStyles.labelMd.copyWith(color: colorScheme.secondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (addresses.isEmpty)
            _EmptyAddresses()
          else
            for (final address in addresses) ...[
              _AddressRow(
                address: address,
                selected: address.id == selected.id,
                onTap: () {
                  ref.read(selectedAddressProvider.notifier).state = address;
                  context.pop();
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            // TODO: open an address form backed by the places API.
            onPressed: () => ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                const SnackBar(content: Text('Ajout d\'adresse bientôt disponible')),
              ),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Ajouter une nouvelle adresse'),
          ),
        ],
      ),
    );
  }
}

class _CurrentPositionCard extends StatelessWidget {
  const _CurrentPositionCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const SizedBox(height: 120, child: MapPlaceholder(showDestinationPin: true)),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Icon(Icons.location_on, color: colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Position actuelle', style: AppTextStyles.labelMd),
                      Text(
                        // TODO: resolve the device location once permissions are wired.
                        'Localisation non activée',
                        style: AppTextStyles.labelSm.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Pressable(
                  onTap: () => ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      const SnackBar(content: Text('Géolocalisation bientôt disponible')),
                    ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.base,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: AppRadius.pill,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.gps_fixed,
                          size: 16,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Épingler ici',
                          style: AppTextStyles.labelSm.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  final DeliveryAddress address;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Pressable(
      onTap: onTap,
      pressedScale: 0.99,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.surfaceContainer,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(address.icon, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(address.label, style: AppTextStyles.labelMd)),
                      if (address.isDefault) ...[
                        const SizedBox(width: AppSpacing.base),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.base,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.tertiaryContainer,
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            'Par défaut',
                            style: AppTextStyles.labelSm.copyWith(
                              color: colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${address.line1}, ${address.city}',
                    style: AppTextStyles.labelSm.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (address.line2 != null)
                    Text(
                      '« ${address.line2} »',
                      style: AppTextStyles.labelSm.copyWith(
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: colorScheme.primary)
            else
              Icon(Icons.more_vert, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _EmptyAddresses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        children: [
          Text('Aucune adresse ?', style: AppTextStyles.headlineMd),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Ajoutez votre premier lieu de livraison pour commencer.',
            style: AppTextStyles.bodyMd.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
