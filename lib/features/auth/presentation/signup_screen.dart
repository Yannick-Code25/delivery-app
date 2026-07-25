import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/user_role.dart';
import '../../../core/session/session_providers.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/auth_atmosphere.dart';
import '../../../shared/widgets/auth_field.dart';
import '../../../shared/widgets/delivery_bag_3d.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/social_auth_buttons.dart';

/// Sign-up screen, adapted from ref/.../inscription_3d_babali/code.html.
///
/// As with the sign-in screen, the reference targets restaurant admins; the copy
/// here is generalised because every role registers through this screen.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  bool _termsError = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    final formValid = _formKey.currentState!.validate();
    setState(() => _termsError = !_acceptedTerms);
    if (!formValid || !_acceptedTerms) return;

    FocusScope.of(context).unfocus();

    // TODO: call the real registration endpoint. New sign-ups are clients until
    // the backend can issue livreur/admin accounts.
    ref.read(currentRoleProvider.notifier).state = UserRole.client;
    context.go(UserRole.client.homeRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthAtmosphere(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.gutter),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  children: [
                    const _Hero(),
                    const SizedBox(height: AppSpacing.md),
                    _FormCard(
                      formKey: _formKey,
                      nameController: _nameController,
                      emailController: _emailController,
                      phoneController: _phoneController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      acceptedTerms: _acceptedTerms,
                      termsError: _termsError,
                      onToggleObscure: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onToggleTerms: (value) => setState(() {
                        _acceptedTerms = value ?? false;
                        if (_acceptedTerms) _termsError = false;
                      }),
                      onSubmit: _submit,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '© 2026 Dabali. Tous droits réservés.',
                      style: AppTextStyles.labelSm.copyWith(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
                      ),
                    ),
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

/// 3D hero with the dark scrim and white headline from the reference.
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 224, // ref: h-56
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.lg),
            child: DeliveryBag3D(unit: 32),
          ),
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rejoignez Dabali',
                    style: AppTextStyles.headlineLgMobile.copyWith(color: Colors.white),
                  ),
                  Text(
                    'La livraison urbaine, à votre rythme.',
                    style: AppTextStyles.labelMd.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
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
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.obscurePassword,
    required this.acceptedTerms,
    required this.termsError,
    required this.onToggleObscure,
    required this.onToggleTerms,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool acceptedTerms;
  final bool termsError;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool?> onToggleTerms;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        // ref: .glass-card — translucent white over the atmospheric glow.
        color: Colors.white.withValues(alpha: 0.8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthField(
                  label: 'Nom complet',
                  hintText: 'Jean Dupont',
                  icon: Icons.person_outline,
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Renseigne ton nom' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AuthField(
                  label: 'Email',
                  hintText: 'jean@exemple.com',
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
                  label: 'Numéro de téléphone',
                  hintText: '+33 6 12 34 56 78',
                  icon: Icons.phone_outlined,
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  validator: (value) {
                    final phone = (value ?? '').replaceAll(RegExp(r'[\s-]'), '');
                    if (phone.isEmpty) return 'Renseigne ton numéro';
                    if (phone.length < 8) return 'Numéro trop court';
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
                  autofillHints: const [AutofillHints.newPassword],
                  onFieldSubmitted: (_) => onSubmit(),
                  suffix: IconButton(
                    onPressed: onToggleObscure,
                    tooltip: obscurePassword ? 'Afficher' : 'Masquer',
                    icon: Icon(
                      obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: colorScheme.secondary,
                      size: 20,
                    ),
                  ),
                  validator: (value) {
                    final password = value ?? '';
                    if (password.isEmpty) return 'Choisis un mot de passe';
                    if (password.length < 8) return 'Au moins 8 caractères';
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _TermsCheckbox(
            accepted: acceptedTerms,
            showError: termsError,
            onChanged: onToggleTerms,
          ),
          const SizedBox(height: AppSpacing.sm),
          PrimaryButton(label: 'Créer mon compte', onPressed: onSubmit),
          const SizedBox(height: AppSpacing.lg),
          const LabelledDivider(label: "OU S'INSCRIRE AVEC"),
          const SizedBox(height: AppSpacing.md),
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
                  label: 'Apple',
                  icon: const Icon(Icons.apple, size: 22),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Déjà membre ? ',
                style: AppTextStyles.bodyMd.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              GestureDetector(
                onTap: () => context.pop(),
                child: Text(
                  'Se connecter',
                  style: AppTextStyles.labelMd.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({
    required this.accepted,
    required this.showError,
    required this.onChanged,
  });

  final bool accepted;
  final bool showError;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final linkStyle = AppTextStyles.labelSm.copyWith(color: colorScheme.primary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: accepted,
                onChanged: onChanged,
                visualDensity: VisualDensity.compact,
                isError: showError,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(!accepted),
                child: Text.rich(
                  TextSpan(
                    style: AppTextStyles.labelSm.copyWith(color: colorScheme.onSurfaceVariant),
                    children: [
                      const TextSpan(text: "J'accepte les "),
                      TextSpan(text: "Conditions d'Utilisation", style: linkStyle),
                      const TextSpan(text: ' et la '),
                      TextSpan(text: 'Politique de Confidentialité', style: linkStyle),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.xl),
            child: Text(
              'Tu dois accepter les conditions pour continuer',
              style: AppTextStyles.labelSm.copyWith(color: colorScheme.error),
            ),
          ),
      ],
    );
  }
}
