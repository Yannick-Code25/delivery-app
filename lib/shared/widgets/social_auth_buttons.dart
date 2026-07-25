import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// Outlined provider button from the "OU CONTINUER AVEC" rows in
/// ref/.../connexion_3d_babali and ref/.../inscription_3d_babali.
class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;
  final Widget icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.input),
        textStyle: AppTextStyles.labelMd,
        foregroundColor: colorScheme.onSurface,
      ),
      // Two of these sit side by side, so the label must scale rather than clip.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(width: AppSpacing.base),
            Text(label),
          ],
        ),
      ),
    );
  }
}

/// Labelled separator, e.g. "OU CONTINUER AVEC".
class LabelledDivider extends StatelessWidget {
  const LabelledDivider({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final line = Expanded(
      child: Container(height: 1, color: colorScheme.outlineVariant),
    );

    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: colorScheme.secondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        line,
      ],
    );
  }
}

/// The four-colour Google glyph, standing in for the reference's inline SVG.
class GoogleMark extends StatelessWidget {
  const GoogleMark({this.size = 20, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleMarkPainter()),
    );
  }
}

class _GoogleMarkPainter extends CustomPainter {
  static const _blue = Color(0xFF4285F4);
  static const _green = Color(0xFF34A853);
  static const _yellow = Color(0xFFFBBC05);
  static const _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final stroke = size.width * 0.24;
    final rect = Rect.fromCircle(center: center, radius: size.width / 2 - stroke / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    // Four arcs around the ring, leaving the right side open for the bar.
    canvas.drawArc(rect, -math.pi * 0.10, math.pi * 0.42, false, paint..color = _green);
    canvas.drawArc(rect, math.pi * 0.32, math.pi * 0.50, false, paint..color = _yellow);
    canvas.drawArc(rect, math.pi * 0.82, math.pi * 0.52, false, paint..color = _red);
    canvas.drawArc(rect, math.pi * 1.34, math.pi * 0.52, false, paint..color = _blue);

    // Horizontal bar closing the "G".
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(size.width - stroke / 2, center.dy),
      Paint()
        ..color = _blue
        ..strokeWidth = stroke * 0.9,
    );
  }

  @override
  bool shouldRepaint(_GoogleMarkPainter oldDelegate) => false;
}
