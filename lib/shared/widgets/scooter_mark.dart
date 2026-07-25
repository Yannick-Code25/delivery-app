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
  static const _wheelRadius = 92.0;
  static const _wheelStroke = 44.0;
  static const _rearWheel = Offset(350, 730);
  static const _frontWheel = Offset(770, 730);

  /// Ink bounds of the full mark, used to centre it in any box.
  static const _inkBounds = Rect.fromLTRB(56, 400, 884, 844);

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

    paint.strokeWidth = 28;

    // Each line grows from its trailing end, so they streak outward.
    const lines = [
      (Offset(215, 470), Offset(105, 470)),
      (Offset(185, 585), Offset(70, 585)),
      (Offset(205, 700), Offset(115, 700)),
    ];

    for (final (start, end) in lines) {
      canvas.drawLine(start, Offset.lerp(start, end, speedLineProgress)!, paint);
    }
  }

  void _paintScooter(Canvas canvas) {
    final stroke = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final fill = Paint()..color = color;

    // Chassis as one polyline: rear shock, under the seat, along the footboard,
    // then up the leg shield.
    const chassis = [
      Offset(350, 638), // top of the rear wheel
      Offset(355, 620),
      Offset(455, 605),
      Offset(505, 690),
      Offset(630, 690),
      Offset(700, 500),
    ];
    final path = Path()..moveTo(chassis.first.dx, chassis.first.dy);
    for (final point in chassis.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    stroke.strokeWidth = 52;
    canvas.drawPath(path, stroke);

    // Front fork down to the wheel.
    stroke.strokeWidth = 46;
    canvas.drawLine(
      const Offset(695, 515),
      Offset(_frontWheel.dx, _frontWheel.dy - _wheelRadius),
      stroke,
    );

    // Handlebar.
    stroke.strokeWidth = 40;
    canvas.drawLine(const Offset(650, 470), const Offset(775, 445), stroke);

    // Seat, then the delivery box on the rack — the detail that says "delivery".
    canvas.drawRRect(
      RRect.fromLTRBR(300, 560, 480, 615, const Radius.circular(27)),
      fill,
    );
    canvas.drawRRect(
      RRect.fromLTRBR(225, 400, 385, 550, const Radius.circular(26)),
      fill,
    );

    stroke.strokeWidth = _wheelStroke;
    final tyreRadius = _wheelRadius - _wheelStroke / 2;
    canvas.drawCircle(_rearWheel, tyreRadius, stroke);
    canvas.drawCircle(_frontWheel, tyreRadius, stroke);
  }

  @override
  bool shouldRepaint(_ScooterPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.speedLineColor != speedLineColor ||
      oldDelegate.speedLineProgress != speedLineProgress;
}
