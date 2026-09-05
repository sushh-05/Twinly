import 'package:flutter/material.dart';

class BodyPainter extends CustomPainter {
  final double height; // in cm
  final double chest; // in cm
  final double waist; // in cm
  final double hip; // in cm
  final double inseam; // in cm
  final bool isSideView;

  BodyPainter({
    required this.height,
    required this.chest,
    required this.waist,
    required this.hip,
    required this.inseam,
    required this.isSideView,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFFFFD7C2) // skin tone
      ..style = PaintingStyle.fill;

    final stroke = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Scale: use height to map cm to pixels. 200cm = full height of canvas
    final maxCm = 200.0;
    final scale = size.height / maxCm;

    final cx = size.width / 2;

    // Normalize measurements to a reasonable range
    // (for visual purposes only, real avatar is 3D later)
    final headHeight = 22.0 * scale; // fixed head size
    final neckHeight = 5.0 * scale;
    final torsoHeight = (height * 0.30) * scale; // ~30% of height
    final legHeight = inseam * scale;
    final bodyTopY = 20.0;
    final headY = bodyTopY;
    final neckY = headY + headHeight;
    final shoulderY = neckY + neckHeight;
    final chestY = shoulderY + torsoHeight * 0.3;
    final waistY = shoulderY + torsoHeight * 0.6;
    final hipY = shoulderY + torsoHeight;
    final crotchY = hipY + 5 * scale;
    final kneeY = crotchY + legHeight * 0.5;
    final ankleY = crotchY + legHeight;

    // Body widths (normalized around 100cm = reference)
    final refChest = 100.0;
    final refWaist = 80.0;
    final refHip = 100.0;
    final shoulderWidth = (chest / refChest) * 60.0 * scale;
    final chestWidth = (chest / refChest) * 70.0 * scale;
    final waistWidth = (waist / refWaist) * 55.0 * scale;
    final hipWidth = (hip / refHip) * 75.0 * scale;
    final headWidth = 26.0 * scale;
    final limbWidth = 18.0 * scale;
    final ankleWidth = 12.0 * scale;

    if (isSideView) {
      // Side view: draw a profile silhouette
      _drawSideView(
        canvas,
        paint,
        stroke,
        cx,
        bodyTopY,
        headY,
        neckY,
        shoulderY,
        chestY,
        waistY,
        hipY,
        crotchY,
        kneeY,
        ankleY,
        headWidth,
        shoulderWidth,
        chestWidth,
        waistWidth,
        hipWidth,
        limbWidth,
        ankleWidth,
      );
    } else {
      // Front view
      _drawFrontView(
        canvas,
        paint,
        stroke,
        cx,
        bodyTopY,
        headY,
        neckY,
        shoulderY,
        chestY,
        waistY,
        hipY,
        crotchY,
        kneeY,
        ankleY,
        headWidth,
        shoulderWidth,
        chestWidth,
        waistWidth,
        hipWidth,
        limbWidth,
        ankleWidth,
      );
    }

    // Draw measurement labels
    _drawLabel(canvas, 'H: ${height.round()}cm', cx, headY - 5);
    _drawLabel(canvas, 'C: ${chest.round()}', cx, chestY);
    _drawLabel(canvas, 'W: ${waist.round()}', cx, waistY);
    _drawLabel(canvas, 'Hip: ${hip.round()}', cx, hipY);
  }

  void _drawFrontView(
    Canvas canvas,
    Paint paint,
    Paint stroke,
    double cx,
    double bodyTopY,
    double headY,
    double neckY,
    double shoulderY,
    double chestY,
    double waistY,
    double hipY,
    double crotchY,
    double kneeY,
    double ankleY,
    double headWidth,
    double shoulderWidth,
    double chestWidth,
    double waistWidth,
    double hipWidth,
    double limbWidth,
    double ankleWidth,
  ) {
    // Head
    canvas.drawCircle(
      Offset(cx, headY + 11 * (headWidth / 26)),
      headWidth / 2,
      paint,
    );
    canvas.drawCircle(
      Offset(cx, headY + 11 * (headWidth / 26)),
      headWidth / 2,
      stroke,
    );

    // Neck
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, neckY + 2.5), width: 12, height: 5),
      paint,
    );

    // Torso (path: shoulder -> chest -> waist -> hip)
    final torsoPath = Path()
      ..moveTo(cx - shoulderWidth / 2, shoulderY)
      ..quadraticBezierTo(
        cx - chestWidth / 2,
        chestY,
        cx - chestWidth / 2,
        chestY,
      )
      ..lineTo(cx - waistWidth / 2, waistY)
      ..lineTo(cx - hipWidth / 2, hipY)
      ..lineTo(cx + hipWidth / 2, hipY)
      ..lineTo(cx + waistWidth / 2, waistY)
      ..lineTo(cx + chestWidth / 2, chestY)
      ..quadraticBezierTo(
        cx + shoulderWidth / 2,
        shoulderY,
        cx + shoulderWidth / 2,
        shoulderY,
      )
      ..close();
    canvas.drawPath(torsoPath, paint);
    canvas.drawPath(torsoPath, stroke);

    // Arms (simple lines from shoulder to wrist)
    final armY = ankleY - 30;
    canvas.drawLine(
      Offset(cx - shoulderWidth / 2, shoulderY + 5),
      Offset(cx - shoulderWidth / 2 - 5, armY),
      stroke,
    );
    canvas.drawLine(
      Offset(cx + shoulderWidth / 2, shoulderY + 5),
      Offset(cx + shoulderWidth / 2 + 5, armY),
      stroke,
    );

    // Legs
    final leftLegPath = Path()
      ..moveTo(cx - hipWidth / 2 + 5, hipY)
      ..lineTo(cx - limbWidth / 2, kneeY)
      ..lineTo(cx - ankleWidth / 2, ankleY)
      ..lineTo(cx - 5, ankleY)
      ..lineTo(cx - 5, hipY)
      ..close();
    canvas.drawPath(leftLegPath, paint);
    canvas.drawPath(leftLegPath, stroke);

    final rightLegPath = Path()
      ..moveTo(cx + hipWidth / 2 - 5, hipY)
      ..lineTo(cx + limbWidth / 2, kneeY)
      ..lineTo(cx + ankleWidth / 2, ankleY)
      ..lineTo(cx + 5, ankleY)
      ..lineTo(cx + 5, hipY)
      ..close();
    canvas.drawPath(rightLegPath, paint);
    canvas.drawPath(rightLegPath, stroke);
  }

  void _drawSideView(
    Canvas canvas,
    Paint paint,
    Paint stroke,
    double cx,
    double bodyTopY,
    double headY,
    double neckY,
    double shoulderY,
    double chestY,
    double waistY,
    double hipY,
    double crotchY,
    double kneeY,
    double ankleY,
    double headWidth,
    double shoulderWidth,
    double chestWidth,
    double waistWidth,
    double hipWidth,
    double limbWidth,
    double ankleWidth,
  ) {
    // Head (slight oval for side)
    canvas.drawCircle(
      Offset(cx, headY + 11 * (headWidth / 26)),
      headWidth / 2,
      paint,
    );
    canvas.drawCircle(
      Offset(cx, headY + 11 * (headWidth / 26)),
      headWidth / 2,
      stroke,
    );

    // Neck
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, neckY + 2.5), width: 12, height: 5),
      paint,
    );

    // Torso (side view, slight S-curve)
    final torsoPath = Path()
      ..moveTo(cx - shoulderWidth / 2 + 5, shoulderY)
      ..quadraticBezierTo(
        cx - chestWidth / 2,
        chestY,
        cx - chestWidth / 2,
        chestY,
      )
      ..lineTo(cx - waistWidth / 2 + 10, waistY)
      ..lineTo(cx - hipWidth / 2 + 5, hipY)
      ..lineTo(cx + hipWidth / 2, hipY)
      ..lineTo(cx + waistWidth / 2, waistY)
      ..lineTo(cx + chestWidth / 2, shoulderY)
      ..quadraticBezierTo(
        cx + shoulderWidth / 2 - 5,
        shoulderY,
        cx + shoulderWidth / 2 - 5,
        shoulderY,
      )
      ..close();
    canvas.drawPath(torsoPath, paint);
    canvas.drawPath(torsoPath, stroke);

    // Single visible arm (back arm hidden)
    final armY = ankleY - 30;
    canvas.drawLine(
      Offset(cx - shoulderWidth / 2 + 5, shoulderY + 5),
      Offset(cx - shoulderWidth / 2, armY),
      stroke,
    );

    // Legs (side view, slight offset)
    final legPath = Path()
      ..moveTo(cx - 5, hipY)
      ..lineTo(cx - limbWidth / 2, kneeY)
      ..lineTo(cx - ankleWidth / 2, ankleY)
      ..lineTo(cx + 5, ankleY)
      ..lineTo(cx + 10, hipY)
      ..close();
    canvas.drawPath(legPath, paint);
    canvas.drawPath(legPath, stroke);
  }

  void _drawLabel(Canvas canvas, String text, double x, double y) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant BodyPainter oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.chest != chest ||
        oldDelegate.waist != waist ||
        oldDelegate.hip != hip ||
        oldDelegate.inseam != inseam ||
        oldDelegate.isSideView != isSideView;
  }
}
