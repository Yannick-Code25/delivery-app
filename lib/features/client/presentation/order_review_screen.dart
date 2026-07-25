import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/pressable.dart';
import '../../../shared/widgets/primary_button.dart';
import '../application/order_providers.dart';

/// Post-delivery review, adapted from ref/.../noter_ma_commande/code.html:
/// a success header, a rating for the food, a rating for the courier with quick
/// compliment tags, a free-text note, then a submit that switches to a thank-you.
class OrderReviewScreen extends ConsumerStatefulWidget {
  const OrderReviewScreen({required this.orderId, super.key});

  final String orderId;

  @override
  ConsumerState<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends ConsumerState<OrderReviewScreen> {
  static const _courierTags = ['Poli & Souriant', 'Rapide', 'Attentionné'];

  final _commentController = TextEditingController();
  final _selectedTags = <String>{};

  int _foodRating = 0;
  int _courierRating = 0;
  bool _submitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_foodRating == 0) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Note ton repas pour continuer')));
      return;
    }

    setState(() => _submitting = true);
    // TODO: POST the review; this delay stands in for the request.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    ref.read(orderProvider.notifier).attachRating(_foodRating);
    setState(() {
      _submitting = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final order = ref.watch(orderProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (_submitted) return const _ThankYou();

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text('Noter ma commande', style: AppTextStyles.headlineMd),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile,
          AppSpacing.md,
          AppSpacing.marginMobile,
          AppSpacing.xl,
        ),
        children: [
          Icon(Icons.check_circle, size: 96, color: colorScheme.primary),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Votre commande est arrivée !',
            style: AppTextStyles.headlineLgMobile,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Bon appétit ! Partagez votre expérience avec la communauté Dabali.',
            style: AppTextStyles.bodyMd.copyWith(color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          _RatingBlock(
            title: order?.restaurantName ?? 'Votre restaurant',
            question: 'Comment était votre repas ?',
            icon: Icons.restaurant,
            rating: _foodRating,
            onRate: (value) => setState(() => _foodRating = value),
          ),
          const SizedBox(height: AppSpacing.md),
          _RatingBlock(
            title: '${order?.courierName ?? 'Votre livreur'}, votre livreur',
            question: 'Comment s\'est passée la livraison ?',
            icon: Icons.delivery_dining,
            rating: _courierRating,
            onRate: (value) => setState(() => _courierRating = value),
            child: Wrap(
              spacing: AppSpacing.base,
              runSpacing: AppSpacing.base,
              children: [
                for (final tag in _courierTags)
                  _TagChip(
                    label: tag,
                    selected: _selectedTags.contains(tag),
                    onTap: () => setState(() {
                      if (!_selectedTags.remove(tag)) _selectedTags.add(tag);
                    }),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Un petit mot pour nous ?', style: AppTextStyles.headlineMd),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _commentController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Compliments ou remarques sur votre expérience…',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_submitting)
            const Center(child: CircularProgressIndicator())
          else
            PrimaryButton(
              label: 'Envoyer mon avis',
              icon: Icons.send,
              onPressed: _submit,
            ),
        ],
      ),
    );
  }
}

class _RatingBlock extends StatelessWidget {
  const _RatingBlock({
    required this.title,
    required this.question,
    required this.icon,
    required this.rating,
    required this.onRate,
    this.child,
  });

  final String title;
  final String question;
  final IconData icon;
  final int rating;
  final ValueChanged<int> onRate;
  final Widget? child;

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
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: colorScheme.onSecondaryContainer),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelMd,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      question,
                      style: AppTextStyles.labelSm.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _StarRow(rating: rating, onRate: onRate),
          if (child != null) ...[
            const SizedBox(height: AppSpacing.sm),
            child!,
          ],
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, required this.onRate});

  final int rating;
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var star = 1; star <= 5; star++)
          Pressable(
            onTap: () => onRate(star),
            pressedScale: 0.85,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: Icon(
                star <= rating ? Icons.star : Icons.star_border,
                size: 32,
                color: star <= rating ? colorScheme.primary : colorScheme.outline,
                semanticLabel: '$star étoile${star > 1 ? 's' : ''}',
              ),
            ),
          ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Pressable(
      onTap: onTap,
      pressedScale: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.base,
        ),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHigh,
          borderRadius: AppRadius.pill,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: selected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ThankYou extends StatelessWidget {
  const _ThankYou();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 96, color: colorScheme.tertiary),
              const SizedBox(height: AppSpacing.md),
              Text('Merci !', style: AppTextStyles.headlineLg),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Votre avis aide toute la communauté Dabali.',
                style: AppTextStyles.bodyMd.copyWith(color: colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Retour à l\'accueil',
                onPressed: () => context.go(AppRoutes.client),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
