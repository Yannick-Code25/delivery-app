import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/user_role.dart';
import '../../../core/session/session_providers.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Placeholder login screen — real UI will follow ref/.../connexion_3d_babali.
/// For now it lets you pick a role to exercise the role-based routing.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Connexion', style: AppTextStyles.headlineLg),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Choisis un profil pour tester la navigation (temporaire).',
                style: AppTextStyles.bodyMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final role in UserRole.values) ...[
                ElevatedButton(
                  onPressed: () {
                    ref.read(currentRoleProvider.notifier).state = role;
                    context.go(role.homeRoute);
                  },
                  child: Text('Continuer en tant que ${role.name}'),
                ),
                const SizedBox(height: AppSpacing.base),
              ],
              TextButton(
                onPressed: () => context.push('/signup'),
                child: const Text("Pas de compte ? S'inscrire"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
