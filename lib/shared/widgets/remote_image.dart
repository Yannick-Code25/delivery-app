import 'package:flutter/material.dart';

/// Network image with a themed placeholder for the loading and error states.
///
/// The mockups reference Google-hosted photos that may expire, so a failure must
/// degrade to something on-brand rather than a broken-image glyph.
class RemoteImage extends StatelessWidget {
  const RemoteImage({
    required this.url,
    this.fallbackIcon = Icons.restaurant,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String url;
  final IconData fallbackIcon;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _Placeholder(icon: fallbackIcon, showSpinner: true);
      },
      errorBuilder: (context, error, stackTrace) => _Placeholder(icon: fallbackIcon),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, this.showSpinner = false});

  final IconData icon;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerLow,
            colorScheme.surfaceContainerHigh,
          ],
        ),
      ),
      child: Center(
        child: showSpinner
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.primary.withValues(alpha: 0.4),
                ),
              )
            : Icon(
                icon,
                size: 40,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
      ),
    );
  }
}
