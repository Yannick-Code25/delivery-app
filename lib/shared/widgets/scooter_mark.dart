import 'package:flutter/material.dart';

/// The Dabali scooter mark, drawn to match the launcher icon.
///
/// The geometry mirrors tools/generate_branding.py on the same 1024-unit grid,
/// so the icon on the home screen and the mark inside the app stay identical.
/// Keep the two in step when either changes.
class ScooterMark extends StatelessWidget {
  const ScooterMark({
    this.color,
    this.speedLineColor,
    this.speedLineProgress = 1,
    super.key,
  });

  /// Scooter colour; defaults to the theme's onSurface, as in the icon.
  final Color? color;

  /// Trailing lines; defaults to the brand primary.
  final Color? speedLineColor;

  /// 0 hides the trailing lines, 1 draws them fully. Animating this reads as
  /// speed without moving the scooter itself.
  final double speedLineProgress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomPaint(
      painter: _ScooterPainter(
        color: color ?? colorScheme.onSurface,
        speedLineColor: speedLineColor ?? colorScheme.primary,
        speedLineProgress: speedLineProgress.clamp(0, 1),
      ),
    );
  }
}

class _ScooterPainter extends CustomPainter {
  const _ScooterPainter({
    required this.color,
    required this.speedLineColor,
    required this.speedLineProgress,
  });

  // Design grid shared with the icon generator.
  static const _wheelRadius = 100.0;
  static const _rearWheel = Offset(355, 690);
  static const _frontWheel = Offset(765, 690);

  /// Ink bounds of the full mark, used to centre it in any box.
  static const _inkBounds = Rect.fromLTRB(100, 309, 886, 790);

  final Color color;
  final Color speedLineColor;
  final double speedLineProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = (size.width / _inkBounds.width)
        .clamp(0.0, size.height / _inkBounds.height);

    canvas.save();
    // Centre the ink, not the grid, so the mark never sits off to one side.
    canvas.translate(
      (size.width - _inkBounds.width * scale) / 2 - _inkBounds.left * scale,
      (size.height - _inkBounds.height * scale) / 2 - _inkBounds.top * scale,
    );
    canvas.scale(scale);

    _paintSpeedLines(canvas);
    _paintScooter(canvas);

    canvas.restore();
  }

  void _paintSpeedLines(Canvas canvas) {
    if (speedLineProgress <= 0) return;

    final paint = Paint()
      ..color = speedLineColor
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Each line grows from its trailing end, so they streak outward.
    const lines = [
      (Offset(285, 545), Offset(150, 545)),
      (Offset(235, 650), Offset(115, 650)),
      (Offset(275, 755), Offset(165, 755)),
    ];

    for (final (start, end) in lines) {
      canvas.drawLine(start, Offset.lerp(start, end, speedLineProgress)!, paint);
    }
  }

  void _paintScooter(Canvas canvas) {
    final stroke = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Deck between the tyres, then the column and handlebar.
    stroke.strokeWidth = 46;
    canvas.drawLine(
      Offset(_rearWheel.dx + _wheelRadius, _rearWheel.dy),
      Offset(_frontWheel.dx - _wheelRadius, _frontWheel.dy),
      stroke,
    );
    canvas.drawLine(
      Offset(_frontWheel.dx, _frontWheel.dy - _wheelRadius),
      const Offset(800, 345),
      stroke,
    );

    stroke.strokeWidth = 42;
    canvas.drawLine(const Offset(690, 330), const Offset(865, 330), stroke);

    stroke.strokeWidth = 46;
    canvas.drawCircle(_rearWheel, _wheelRadius - 23, stroke);
    canvas.drawCircle(_frontWheel, _wheelRadius - 23, stroke);
  }

  @override
  bool shouldRepaint(_ScooterPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.speedLineColor != speedLineColor ||
      oldDelegate.speedLineProgress != speedLineProgress;
}
