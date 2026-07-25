import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/pressable.dart';
import '../application/order_providers.dart';
import '../domain/payment_method.dart';

/// Payment methods, adapted from ref/.../moyens_de_paiement/code.html: a security
/// header, the saved methods with the active one checked, an add action and a
/// security tip.
///
/// One deliberate change: the mockup prints "Certifié PCI DSS Level 1". That is a
/// compliance claim the project does not hold, so it is replaced with what is
/// actually true — card details never reach this app or its backend, because
/// charging goes through the payment provider's SDK.
class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final methods = ref.watch(paymentMethodsProvider);
    final selected = ref.watch(selectedPaymentMethodProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text('Moyens de paiement', style: AppTextStyles.headlineMd),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile,
          AppSpacing.gutter,
          AppSpacing.marginMobile,
          AppSpacing.xl,
        ),
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 32, color: colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Paiement sécurisé', style: AppTextStyles.headlineLgMobile),
                    Text(
                      'Vos transactions sont chiffrées de bout en bout.',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Moyens enregistrés', style: AppTextStyles.headlineMd),
          const SizedBox(height: AppSpacing.sm),
          for (final method in methods) ...[
            _MethodRow(
              method: method,
              selected: method.id == selected.id,
              onTap: () {
                ref.read(selectedPaymentMethodProvider.notifier).state = method;
                context.pop();
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            // TODO: launch the provider's SDK sheet to register a new method.
            onPressed: () => ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                const SnackBar(content: Text('Ajout de moyen de paiement à venir')),
              ),
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Ajouter un moyen de paiement'),
          ),
          const SizedBox(height: AppSpacing.md),
          const _SecurityNote(),
        ],
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final PaymentMethod method;
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
          children: [
            Container(
              width: 44,
              height: 44,
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
                  Text(
                    method.label,
                    style: AppTextStyles.labelMd,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    method.details,
                    style: AppTextStyles.labelSm.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class _SecurityNote extends StatelessWidget {
  const _SecurityNote();

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lock_outline, size: 18, color: colorScheme.tertiary),
              const SizedBox(width: AppSpacing.base),
              Expanded(
                child: Text(
                  'Aucune donnée de carte n\'est stockée',
                  style: AppTextStyles.labelMd,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Les paiements passent directement par notre prestataire agréé : '
            'Dabali ne voit jamais votre numéro de carte.',
            style: AppTextStyles.labelSm.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
