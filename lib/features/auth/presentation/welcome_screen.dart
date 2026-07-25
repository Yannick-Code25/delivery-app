import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Onboarding/splash screen, adapted from ref/.../bienvenue_sur_babali/code.html.
/// TODO: swap the icon placeholder below for the real courier illustration asset.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.marginMobile,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ..._buildPulseRings(colorScheme),
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLowest,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.electric_scooter,
                          size: 96,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
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
                    child: Text(
                      'FAST & RELIABLE',
                      style: AppTextStyles.labelMd.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  Text.rich(
                    TextSpan(
                      style: AppTextStyles.headlineLgMobile,
                      children: [
                        const TextSpan(text: 'Dabali\n'),
                        TextSpan(
                          text: 'La livraison qui pulse',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.base),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Text(
                      "Vivez l'expérience d'une livraison urbaine ultra-rapide, "
                      'pensée pour votre rythme de vie.',
                      style: AppTextStyles.bodyMd.copyWith(color: colorScheme.secondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PaginationDot(active: true, colorScheme: colorScheme),
                  const SizedBox(width: AppSpacing.xs),
                  _PaginationDot(active: false, colorScheme: colorScheme),
                  const SizedBox(width: AppSpacing.xs),
                  _PaginationDot(active: false, colorScheme: colorScheme),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/signup'),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Commencer'),
                      SizedBox(width: AppSpacing.base),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/login'),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPulseRings(ColorScheme colorScheme) {
    return [0.0, 0.5].map((delay) {
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final t = (_pulseController.value + delay) % 1.0;
          return Opacity(
            opacity: (1 - t).clamp(0.0, 1.0) * 0.35,
            child: Container(
              width: 140 + (t * 220),
              height: 140 + (t * 220),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.primary, width: 1),
              ),
            ),
          );
        },
      );
    }).toList();
  }
}

class _PaginationDot extends StatelessWidget {
  const _PaginationDot({required this.active, required this.colorScheme});

  final bool active;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: active ? 32 : 8,
      decoration: BoxDecoration(
        color: active ? colorScheme.primary : colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.pill,
      ),
    );
  }
}
