import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/user_role.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/session/session_providers.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/auth_atmosphere.dart';
import '../../../shared/widgets/auth_field.dart';
import '../../../shared/widgets/delivery_bag_3d.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/social_auth_buttons.dart';

/// Sign-in screen, adapted from ref/.../connexion_3d_babali/code.html.
///
/// The reference is the admin portal; this screen serves all three roles, so the
/// admin-specific copy ("Admin Portal", "Email professionnel", "Contacter le
/// support") is generalised while the layout and 3D hero are kept as designed.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// TODO: replace with the real API call once the backend exists. Until then the
  /// role is derived from the email prefix so all three spaces stay reachable.
  UserRole _roleForEmail(String email) {
    final normalized = email.trim().toLowerCase();
    if (normalized.startsWith('admin')) return UserRole.admin;
    if (normalized.startsWith('livreur')) return UserRole.livreur;
    return UserRole.client;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final role = _roleForEmail(_emailController.text);
    ref.read(currentRoleProvider.notifier).state = role;
    context.go(role.homeRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthAtmosphere(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginMobile,
              vertical: AppSpacing.md,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    const _Hero(),
                    _FormCard(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      rememberMe: _rememberMe,
                      onToggleObscure: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onToggleRemember: (value) =>
                          setState(() => _rememberMe = value ?? false),
                      onSubmit: _submit,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _Footer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hero panel: floating 3D bag with the branding laid over its lower edge.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 256, // ref: h-64
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.shell),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.lg),
              child: DeliveryBag3D(unit: 38),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Dabali', style: AppTextStyles.headlineXl),
                  Text(
                    'LIVRAISON EXPRESS',
                    style: AppTextStyles.labelMd.copyWith(
                      color: colorScheme.secondary,
                      letterSpacing: 2.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.onToggleObscure,
    required this.onToggleRemember,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool?> onToggleRemember;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.shell),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Content de vous revoir',
            style: AppTextStyles.headlineMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Connectez-vous pour continuer',
            style: AppTextStyles.bodyMd.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthField(
                  label: 'Email',
                  hintText: 'vous@exemple.com',
                  icon: Icons.mail_outlined,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: (value) {
                    final email = (value ?? '').trim();
                    if (email.isEmpty) return 'Renseigne ton email';
                    if (!email.contains('@') || !email.contains('.')) return 'Email invalide';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AuthField(
                  label: 'Mot de passe',
                  hintText: '••••••••',
                  icon: Icons.lock_outline,
                  controller: passwordController,
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => onSubmit(),
                  trailingLabel: GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Oublié ?',
                      style: AppTextStyles.labelMd.copyWith(color: colorScheme.primary),
                    ),
                  ),
                  suffix: IconButton(
                    onPressed: onToggleObscure,
                    tooltip: obscurePassword ? 'Afficher' : 'Masquer',
                    icon: Icon(
                      obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                  ),
                  validator: (value) =>
                      (value ?? '').isEmpty ? 'Renseigne ton mot de passe' : null,
                ),
                const SizedBox(height: AppSpacing.base),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: rememberMe,
                        onChanged: onToggleRemember,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.base),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onToggleRemember(!rememberMe),
                        child: Text(
                          'Rester connecté pendant 30 jours',
                          style: AppTextStyles.labelSm.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                  label: 'Se connecter',
                  icon: Icons.arrow_forward,
                  onPressed: onSubmit,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const LabelledDivider(label: 'OU CONTINUER AVEC'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: SocialAuthButton(
                  label: 'Google',
                  icon: const GoogleMark(),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: SocialAuthButton(
                  label: 'SSO',
                  icon: const Icon(Icons.badge_outlined, size: 20),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Pas encore de compte ? ',
              style: AppTextStyles.bodyMd.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            GestureDetector(
              onTap: () => context.push(AppRoutes.signup),
              child: Text(
                "S'inscrire",
                style: AppTextStyles.labelMd.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.base,
          children: [
            for (final label in ['Politique de confidentialité', 'CGU', 'Aide'])
              Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
