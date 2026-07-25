import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Floating pseudo-3D delivery bag, ported from the three.js scene in
/// ref/.../connexion_3d_babali/code.html (ANIMATION_24).
///
/// The reference uses a real WebGL renderer; here the same look is built from
/// Flutter transforms so it stays cheap on mid-range phones. The bag floats on
/// a sine wave and tilts toward the user's drag — the touch equivalent of the
/// reference's mousemove handler.
class DeliveryBag3D extends StatefulWidget {
  const DeliveryBag3D({this.unit = 50, super.key});

  /// Pixels per three.js scene unit. The reference box is 2 x 2.5 x 0.5 units.
  final double unit;

  @override
  State<DeliveryBag3D> createState() => _DeliveryBag3DState();
}

class _DeliveryBag3DState extends State<DeliveryBag3D> with SingleTickerProviderStateMixin {
  // Matches the reference: rotation eases 5% per frame toward the pointer.
  static const _easing = 0.05;
  static const _maxRotationY = 0.5;
  static const _maxRotationX = 0.3;
  static const _floatPeriod = Duration(milliseconds: 3141); // 2*pi / 0.002

  late final AnimationController _controller;

  double _rotationY = 0;
  double _rotationX = 0;
  double _targetRotationY = 0;
  double _targetRotationX = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _floatPeriod)
      ..addListener(_ease)
      ..repeat();
  }

  void _ease() {
    _rotationY += (_targetRotationY - _rotationY) * _easing;
    _rotationX += (_targetRotationX - _rotationX) * _easing;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, Size size) {
    setState(() {
      _targetRotationY =
          (_targetRotationY + details.delta.dx / size.width).clamp(-_maxRotationY, _maxRotationY);
      _targetRotationX =
          (_targetRotationX - details.delta.dy / size.height).clamp(-_maxRotationX, _maxRotationX);
    });
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.unit;
    final bagWidth = 2 * unit;
    final bagHeight = 2.5 * unit;
    final strapRadius = 0.8 * unit;
    final strapThickness = 0.2 * unit;

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;

        return GestureDetector(
          onPanUpdate: (details) => _onPanUpdate(details, size),
          behavior: HitTestBehavior.opaque,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Reference: group.position.y = sin(t * 0.002) * 0.2
              final floatOffset = math.sin(_controller.value * 2 * math.pi) * 0.2 * unit;

              return Transform.translate(
                offset: Offset(0, -floatOffset),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001) // perspective
                    ..rotateY(_rotationY)
                    ..rotateX(_rotationX),
                  child: child,
                ),
              );
            },
            child: Center(
              child: SizedBox(
                width: bagWidth,
                height: bagHeight + strapRadius,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 0,
                      child: CustomPaint(
                        size: Size(strapRadius * 2 + strapThickness, strapRadius + strapThickness),
                        painter: _StrapPainter(thickness: strapThickness),
                      ),
                    ),
                    Positioned(
                      top: strapRadius,
                      child: _BagBody(width: bagWidth, height: bagHeight),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The bag's carry strap — the reference's half TorusGeometry in brown.
class _StrapPainter extends CustomPainter {
  const _StrapPainter({required this.thickness});

  static const _strapColor = Color(0xFF8B5E34); // reference: 0x8b5e34

  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (size.width - thickness) / 2;
    final center = Offset(size.width / 2, size.height);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFA97346), _strapColor],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Upper half only, mirroring the reference's Math.PI arc.
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_StrapPainter oldDelegate) => oldDelegate.thickness != thickness;
}

/// The bag body. The gradient stands in for the reference's MeshPhongMaterial
/// specular highlight so the shape still reads as lit from the upper left.
class _BagBody extends StatelessWidget {
  const _BagBody({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(width * 0.06),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(colorScheme.primaryContainer, Colors.white, 0.35)!,
            colorScheme.primaryContainer,
            Color.lerp(colorScheme.primaryContainer, colorScheme.primary, 0.25)!,
          ],
          stops: const [0, 0.55, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
    );
  }
}
