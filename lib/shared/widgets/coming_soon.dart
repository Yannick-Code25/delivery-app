import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Placeholder for a tab whose real screen has not been built yet. Names the
/// mockup it will be based on so the remaining work stays visible in the app.
class ComingSoon extends StatelessWidget {
  const ComingSoon({
    required this.title,
    required this.icon,
    required this.sourceMockup,
    this.actions = const [],
    super.key,
  });

  final String title;
  final IconData icon;
  final String sourceMockup;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(title, style: AppTextStyles.headlineMd)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: colorScheme.primary.withValues(alpha: 0.6)),
              const SizedBox(height: AppSpacing.md),
              Text('Écran à venir', style: AppTextStyles.headlineMd),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'D\'après la maquette « $sourceMockup ».',
                style: AppTextStyles.bodyMd.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                ...actions,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
