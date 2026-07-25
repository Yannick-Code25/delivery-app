import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Full-width primary action button.
///
/// The label is scaled down rather than clipped, so a long label or a large
/// system font scale never overflows the button.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (icon != null) ...[
              const SizedBox(width: AppSpacing.base),
              Icon(icon),
            ],
          ],
        ),
      ),
    );
  }
}
