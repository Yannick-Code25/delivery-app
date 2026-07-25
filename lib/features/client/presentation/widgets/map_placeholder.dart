import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Stand-in for the map strips in ref/.../panier_babali_style and the live map in
/// ref/.../suivi_de_commande_en_direct.
///
/// The mockups use static map images. A real map needs the Google Maps (or
/// Mapbox) SDK plus an API key, so until those are configured this draws a
/// stylised street grid with the same markers and animated route — no network
/// call, no key, and it never renders as a broken image.
class MapPlaceholder extends StatefulWidget {
  const MapPlaceholder({
    this.showDestinationPin = false,
    this.showRoute = false,
    this.showCourier = false,
    this.showLiveBadge = false,
    super.key,
  });

  final bool showDestinationPin;
  final bool showRoute;
  final bool showCourier;
  final bool showLiveBadge;

  @override
  State<MapPlaceholder> createState() => _MapPlaceholderState();
}

class _MapPlaceholderState extends State<MapPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// Waypoints the courier walks through, as fractions of the map box — the
  /// reference moves its marker between five points on a loop.
  static const _courierPath = [
    Offset(0.65, 0.80),
    Offset(0.55, 0.66),
    Offset(0.45, 0.52),
    Offset(0.35, 0.40),
    Offset(0.28, 0.30),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );
    if (widget.showCourier || widget.showRoute) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _courierPosition(double t) {
    final scaled = t * (_courierPath.length - 1);
    final index = scaled.floor().clamp(0, _courierPath.length - 2);
    final local = scaled - index;
    return Offset.lerp(_courierPath[index], _courierPath[index + 1], local)!;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;

        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _StreetsPainter(
                  background: colorScheme.surfaceContainer,
                  streets: colorScheme.surfaceContainerLowest,
                  parks: colorScheme.tertiaryContainer.withValues(alpha: 0.35),
                ),
              ),
              if (widget.showRoute)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) => CustomPaint(
                    painter: _RoutePainter(
                      color: colorScheme.primary,
                      dashPhase: _controller.value * 20,
                      waypoints: _courierPath,
                    ),
                  ),
                ),
              if (widget.showDestinationPin)
                Align(
                  alignment: widget.showRoute
                      ? const Alignment(-0.45, -0.4)
                      : Alignment.center,
                  child: _Marker(
                    icon: Icons.home,
                    background: colorScheme.inverseSurface,
                    foreground: colorScheme.onInverseSurface,
                  ),
                ),
              if (widget.showCourier)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final position = _courierPosition(_controller.value);
                    return Positioned(
                      left: position.dx * size.width - 24,
                      top: position.dy * size.height - 24,
                      child: child!,
                    );
                  },
                  child: _PulsingMarker(
                    icon: Icons.directions_bike,
                    background: colorScheme.primary,
                    foreground: colorScheme.onPrimary,
                  ),
                ),
              if (widget.showLiveBadge)
                Positioned(
                  top: AppSpacing.gutter,
                  right: AppSpacing.gutter,
                  child: _LiveBadge(),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// A calm, abstract street grid: wide roads, a couple of blocks of greenery.
class _StreetsPainter extends CustomPainter {
  const _StreetsPainter({
    required this.background,
    required this.streets,
    required this.parks,
  });

  final Color background;
  final Color streets;
  final Color parks;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    final parkPaint = Paint()..color = parks;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.08, size.width * 0.26,
            size.height * 0.22),
        const Radius.circular(8),
      ),
      parkPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.68, size.height * 0.62, size.width * 0.26,
            size.height * 0.3),
        const Radius.circular(8),
      ),
      parkPaint,
    );

    final road = Paint()
      ..color = streets
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Verticals, then horizontals, at irregular spacing so it reads as a city.
    for (final entry in {0.18: 10.0, 0.42: 6.0, 0.62: 12.0, 0.85: 6.0}.entries) {
      road.strokeWidth = entry.value;
      canvas.drawLine(
        Offset(size.width * entry.key, 0),
        Offset(size.width * entry.key, size.height),
        road,
      );
    }
    for (final entry in {0.22: 8.0, 0.48: 12.0, 0.74: 6.0}.entries) {
      road.strokeWidth = entry.value;
      canvas.drawLine(
        Offset(0, size.height * entry.key),
        Offset(size.width, size.height * entry.key),
        road,
      );
    }
  }

  @override
  bool shouldRepaint(_StreetsPainter oldDelegate) =>
      oldDelegate.background != background || oldDelegate.streets != streets;
}

/// Dashed route with a marching-ants offset, like the reference's animated SVG.
class _RoutePainter extends CustomPainter {
  const _RoutePainter({
    required this.color,
    required this.dashPhase,
    required this.waypoints,
  });

  final Color color;
  final double dashPhase;
  final List<Offset> waypoints;

  @override
  void paint(Canvas canvas, Size size) {
    if (waypoints.length < 2) return;

    final path = Path()
      ..moveTo(waypoints.first.dx * size.width, waypoints.first.dy * size.height);
    for (var i = 1; i < waypoints.length; i++) {
      final point = Offset(waypoints[i].dx * size.width, waypoints[i].dy * size.height);
      final previous =
          Offset(waypoints[i - 1].dx * size.width, waypoints[i - 1].dy * size.height);
      // Curve through the waypoints so the route looks like a ridden path.
      final control = Offset(previous.dx, point.dy);
      path.quadraticBezierTo(control.dx, control.dy, point.dx, point.dy);
    }

    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      var distance = -dashPhase % 20;
      while (distance < metric.length) {
        final end = math.min(distance + 8, metric.length);
        if (end > 0) {
          canvas.drawPath(metric.extractPath(math.max(distance, 0), end), paint);
        }
        distance += 20;
      }
    }
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) => oldDelegate.dashPhase != dashPhase;
}

class _Marker extends StatelessWidget {
  const _Marker({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 20, color: foreground),
    );
  }
}

/// Courier marker with the reference's expanding halo.
class _PulsingMarker extends StatefulWidget {
  const _PulsingMarker({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  State<_PulsingMarker> createState() => _PulsingMarkerState();
}

class _PulsingMarkerState extends State<_PulsingMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Opacity(
              opacity: (1 - _controller.value) * 0.4,
              child: Container(
                width: 24 + _controller.value * 24,
                height: 24 + _controller.value * 24,
                decoration: BoxDecoration(
                  color: widget.background,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          _Marker(
            icon: widget.icon,
            background: widget.background,
            foreground: widget.foreground,
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.base,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: colorScheme.tertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.base),
          Text('En direct', style: AppTextStyles.labelMd),
        ],
      ),
    );
  }
}
