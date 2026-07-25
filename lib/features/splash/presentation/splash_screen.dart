import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/session/session_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/scooter_mark.dart';

/// Launch animation, played over the same yellow as the native splash so the
/// handoff from the system screen is invisible.
///
/// The scooter rides in, its trailing lines streak out, the wordmark rises, and
/// a ring expands past the edges before the app moves on. Tapping skips it.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  /// Total run time. Tests advance past this to reach the screen underneath.
  static const duration = Duration(milliseconds: 2200);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _ride;
  late final Animation<double> _speedLines;
  late final Animation<double> _wordmark;
  late final Animation<double> _ring;

  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: SplashScreen.duration);

    _ride = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.45, curve: Curves.easeOutCubic),
    );
    _speedLines = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
    );
    _wordmark = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
    );
    _ring = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1, curve: Curves.easeInOut),
    );

    _controller.forward().whenComplete(_goOn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// TODO: restore a saved session here once auth is backed by the API; the
  /// splash is the natural place to wait for it.
  void _goOn() {
    if (_leaving || !mounted) return;
    _leaving = true;

    final role = ref.read(currentRoleProvider);
    context.go(role?.homeRoute ?? AppRoutes.welcome);
  }

  void _skip() {
    if (_leaving) return;
    _controller.stop();
    _goOn();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _skip,
      child: Scaffold(
        // Matches flutter_native_splash's colour so nothing flashes between them.
        backgroundColor: AppColors.primaryContainer,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _RingPainter(
                      progress: _ring.value,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RidingScooter(
                      ride: _ride.value,
                      speedLines: _speedLines.value,
                      time: _controller.value,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Opacity(
                      opacity: _wordmark.value,
                      child: Transform.translate(
                        offset: Offset(0, (1 - _wordmark.value) * 16),
                        child: Column(
                          children: [
                            Text(
                              'Dabali',
                              style: AppTextStyles.headlineXl.copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              'LIVRAISON EXPRESS',
                              style: AppTextStyles.labelMd.copyWith(
                                color: AppColors.onPrimaryContainer,
                                letterSpacing: 2.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RidingScooter extends StatelessWidget {
  const _RidingScooter({
    required this.ride,
    required this.speedLines,
    required this.time,
  });

  /// 0 = off screen left, 1 = in place.
  final double ride;
  final double speedLines;

  /// Whole-animation progress, used for the idle bob.
  final double time;

  @override
  Widget build(BuildContext context) {
    // Bob only once the scooter has arrived, so the entry stays clean.
    final bob = math.sin(time * math.pi * 6) * 4 * ride;

    return Transform.translate(
      offset: Offset(-(1 - ride) * 220, bob),
      child: Transform(
        alignment: Alignment.center,
        // A touch of perspective, leaning back as it settles.
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0015)
          ..rotateY((1 - ride) * 0.5),
        child: SizedBox(
          width: 260,
          height: 160,
          child: ScooterMark(
            color: AppColors.onSurface,
            speedLineColor: AppColors.primary,
            speedLineProgress: speedLines,
          ),
        ),
      ),
    );
  }
}

/// Expanding outline that sweeps past the screen edges as the splash ends.
class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = size.center(Offset.zero);
    final maxRadius = size.longestSide * 0.9;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = color.withValues(alpha: (1 - progress) * 0.5);

    canvas.drawCircle(center, maxRadius * progress, paint);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.progress != progress;
}
