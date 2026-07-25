import 'package:flutter/material.dart';

/// Soft coloured glow behind the auth screens, from the "Background
/// Atmospheric Effect" block in ref/.../connexion_3d_babali/code.html.
///
/// The reference blurs two tinted circles by 100-120px. A real blur that wide is
/// costly per frame, so the same effect is drawn with radial gradients that fade
/// to transparent — visually equivalent, and free to composite.
class AuthAtmosphere extends StatelessWidget {
  const AuthAtmosphere({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned(
          top: -120,
          right: -120,
          child: _Glow(size: 500, color: colorScheme.primaryContainer),
        ),
        Positioned(
          bottom: -100,
          left: -100,
          child: _Glow(size: 400, color: colorScheme.secondaryContainer),
        ),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.30),
              color.withValues(alpha: 0.10),
              color.withValues(alpha: 0),
            ],
            stops: const [0, 0.55, 1],
          ),
        ),
      ),
    );
  }
}
