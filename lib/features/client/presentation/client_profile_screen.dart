import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/session/session_providers.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/pressable.dart';

/// Profile, adapted from ref/.../profil_utilisateur_babali_style/code.html:
/// identity header with a membership badge, a referral card with a copyable code,
/// then the settings rows. Copy is translated, the mockup being in English.
class ClientProfileScreen extends ConsumerWidget {
  const ClientProfileScreen({super.key});

  /// TODO: read the signed-in profile and referral code from the API.
  static const _name = 'Alex Diop';
  static const _membership = 'Membre Gold';
  static const _referralCode = 'ALEXGOLD';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Profil', style: AppTextStyles.headlineMd)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile,
          AppSpacing.gutter,
          AppSpacing.marginMobile,
          AppSpacing.xl,
        ),
        children: [
          _Identity(name: _name, membership: _membership),
          const SizedBox(height: AppSpacing.md),
          _ReferralCard(code: _referralCode),
          const SizedBox(height: AppSpacing.md),
          _SettingsGroup(
            rows: [
              _SettingsRow(
                icon: Icons.person_outline,
                label: 'Informations du compte',
                onTap: () => _notImplemented(context),
              ),
              _SettingsRow(
                icon: Icons.location_on_outlined,
                label: 'Mes adresses',
                onTap: () => context.push(AppRoutes.clientAddresses),
              ),
              _SettingsRow(
                icon: Icons.payments_outlined,
                label: 'Moyens de paiement',
                onTap: () => context.push(AppRoutes.clientPaymentMethods),
              ),
              _SettingsRow(
                icon: Icons.sell_outlined,
                label: 'Promotions',
                onTap: () => _notImplemented(context),
              ),
              _SettingsRow(
                icon: Icons.help_outline,
                label: 'Assistance',
                onTap: () => _notImplemented(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Pressable(
            onTap: () => ref.read(currentRoleProvider.notifier).state = null,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.gutter),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: AppRadius.card,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: colorScheme.onErrorContainer),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Se déconnecter',
                    style: AppTextStyles.labelMd.copyWith(
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _notImplemented(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(const SnackBar(content: Text('Écran à venir')));
  }
}

class _Identity extends StatelessWidget {
  const _Identity({required this.name, required this.membership});

  final String name;
  final String membership;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                name.characters.first,
                style: AppTextStyles.headlineLg.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 2),
                ),
                child: Icon(Icons.verified, size: 16, color: colorScheme.onTertiary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(name, style: AppTextStyles.headlineLgMobile),
        const SizedBox(height: AppSpacing.xs),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.workspace_premium,
                size: 16,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                membership,
                style: AppTextStyles.labelSm.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReferralCard extends StatelessWidget {
  const _ReferralCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.celebration, color: colorScheme.onSecondaryContainer),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Invitez vos amis', style: AppTextStyles.headlineMd),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Gagnez 2 000 FCFA pour chaque ami qui rejoint Dabali.',
            style: AppTextStyles.bodyMd.copyWith(color: colorScheme.onSecondaryContainer),
          ),
          const SizedBox(height: AppSpacing.sm),
          Pressable(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: code));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context)
                ..clearSnackBars()
                ..showSnackBar(const SnackBar(content: Text('Code copié')));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: AppRadius.input,
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      code,
                      style: AppTextStyles.labelMd.copyWith(letterSpacing: 1.5),
                    ),
                  ),
                  Icon(Icons.content_copy, size: 18, color: colorScheme.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.rows});

  final List<_SettingsRow> rows;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: AppRadius.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final row in rows) ...[
            row,
            if (row != rows.last) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.gutter,
          vertical: AppSpacing.gutter,
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(label, style: AppTextStyles.bodyMd)),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
