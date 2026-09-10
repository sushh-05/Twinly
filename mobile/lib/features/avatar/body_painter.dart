import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A local fashion mannequin. It is an illustration, not a scan or
/// reconstruction of a person's body.
class BodyPainter extends CustomPainter {
  final double height;
  final double chest;
  final double waist;
  final double hip;
  final double inseam;
  final bool isSideView;
  final bool isFeminine;
  final String skinTone;
  final String hairStyle;
  final String hairColor;

  BodyPainter({
    required this.height,
    required this.chest,
    required this.waist,
    required this.hip,
    required this.inseam,
    required this.isSideView,
    this.isFeminine = true,
    this.skinTone = 'medium',
    this.hairStyle = 'short',
    this.hairColor = 'black',
  });

  @override
  void paint(Canvas canvas, Size size) {
    final canvasHeight = size.height.clamp(180.0, 560.0);
    final centerX = size.width / 2;
    final unit = (size.width * .215).clamp(30.0, 64.0);
    final heightScale = _map(height, 140, 200, .90, 1.10);
    final legScale = _map(inseam, 60, 100, .88, 1.14);
    final chestScale = _map(chest, 70, 130, .90, 1.13);
    final waistScale = _map(waist, 55, 120, .88, 1.16);
    final hipScale = _map(hip, 75, 140, .90, 1.16);
    final totalHeight = canvasHeight * .82 * heightScale;
    final legHeight = (totalHeight * (.48 * legScale)).clamp(
      totalHeight * .42,
      totalHeight * .57,
    );
    final torsoHeight = totalHeight - legHeight;
    final top = ((canvasHeight - totalHeight) / 2).clamp(10.0, 50.0);
    final headHeight = unit * .98;
    final headWidth = unit * .78;
    final shoulderY = top + headHeight + torsoHeight * .18;
    final waistY = top + headHeight + torsoHeight * .59;
    final hipY = top + headHeight + torsoHeight * .91;
    final crotchY = top + headHeight + torsoHeight;
    final footY = top + totalHeight;
    final shoulderHalf = unit * (isFeminine ? .82 : .94) * chestScale;
    final chestHalf = unit * (isFeminine ? .76 : .86) * chestScale;
    final waistHalf = unit * .57 * waistScale;
    final hipHalf = unit * (isFeminine ? .82 : .73) * hipScale;
    final skin = _skinColors[skinTone] ?? _skinColors['medium']!;
    final hair = _hairColors[hairColor] ?? _hairColors['black']!;

    // Hair that falls behind the head and shoulders is drawn first.
    _drawBackHair(canvas, centerX, top + headHeight * .48, unit, hair);
    _drawFloorShadow(canvas, centerX, footY, unit);

    if (isSideView) {
      _drawSideSilhouette(
        canvas,
        centerX,
        shoulderY,
        hipY,
        crotchY,
        footY,
        unit,
      );
    } else {
      _drawLegs(canvas, centerX, crotchY, footY, unit);
      _drawTorso(
        canvas,
        centerX,
        shoulderY,
        waistY,
        hipY,
        chestHalf,
        waistHalf,
        hipHalf,
        shoulderHalf,
      );
      _drawArms(canvas, centerX, shoulderY, hipY, shoulderHalf, unit, skin);
    }

    final headCenter = Offset(centerX, top + headHeight * .52);
    final headPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(centerX - headWidth / 2, headCenter.dy),
        Offset(centerX + headWidth / 2, headCenter.dy + headHeight),
        [skin.lighten(.06), skin.darken(.08)],
      );
    canvas.drawOval(
      Rect.fromCenter(center: headCenter, width: headWidth, height: headHeight),
      headPaint,
    );
    _drawNeck(canvas, centerX, top + headHeight * .86, shoulderY, unit, skin);
    _drawFrontHair(canvas, headCenter, headWidth, headHeight, unit, hair);
  }

  void _drawFloorShadow(Canvas canvas, double x, double y, double unit) {
    final shadow = Paint()
      ..shader = ui.Gradient.radial(Offset(x, y), unit * 1.05, [
        Colors.black.withValues(alpha: .25),
        Colors.transparent,
      ]);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(x, y + 3), width: unit * 1.85, height: 12),
      shadow,
    );
  }

  void _drawTorso(
    Canvas canvas,
    double x,
    double shoulderY,
    double waistY,
    double hipY,
    double chestHalf,
    double waistHalf,
    double hipHalf,
    double shoulderHalf,
  ) {
    final path = Path()
      ..moveTo(x - shoulderHalf, shoulderY)
      ..cubicTo(
        x - shoulderHalf * 1.02,
        shoulderY + 16,
        x - chestHalf * 1.08,
        shoulderY + 34,
        x - chestHalf,
        shoulderY + 48,
      )
      ..cubicTo(
        x - chestHalf * .98,
        waistY - 30,
        x - waistHalf * 1.06,
        waistY - 12,
        x - waistHalf,
        waistY,
      )
      ..cubicTo(
        x - waistHalf * 1.02,
        waistY + 20,
        x - hipHalf * 1.04,
        hipY - 34,
        x - hipHalf,
        hipY,
      )
      ..cubicTo(
        x - hipHalf * 1.02,
        hipY + 18,
        x - hipHalf * .82,
        hipY + 30,
        x - hipHalf * .65,
        hipY + 36,
      )
      ..cubicTo(
        x - hipHalf * .35,
        hipY + 41,
        x - hipHalf * .22,
        hipY + 44,
        x,
        hipY + 44,
      )
      ..cubicTo(
        x + hipHalf * .22,
        hipY + 44,
        x + hipHalf * .35,
        hipY + 41,
        x + hipHalf * .65,
        hipY + 36,
      )
      ..cubicTo(
        x + hipHalf * .82,
        hipY + 30,
        x + hipHalf * 1.02,
        hipY + 18,
        x + hipHalf,
        hipY,
      )
      ..cubicTo(
        x + hipHalf * 1.04,
        hipY - 34,
        x + waistHalf * 1.02,
        waistY + 20,
        x + waistHalf,
        waistY,
      )
      ..cubicTo(
        x + waistHalf * 1.06,
        waistY - 12,
        x + chestHalf * .98,
        waistY - 30,
        x + chestHalf,
        shoulderY + 48,
      )
      ..cubicTo(
        x + chestHalf * 1.08,
        shoulderY + 34,
        x + shoulderHalf * 1.02,
        shoulderY + 16,
        x + shoulderHalf,
        shoulderY,
      )
      ..quadraticBezierTo(x, shoulderY - 10, x - shoulderHalf, shoulderY)
      ..close();
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(x - shoulderHalf, shoulderY),
        Offset(x + hipHalf, hipY),
        [const Color(0xff42494b), const Color(0xff24292b)],
      );
    canvas.drawPath(path, paint);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: .09),
    );
  }

  void _drawNeck(
    Canvas canvas,
    double x,
    double neckTop,
    double shoulderY,
    double unit,
    Color skin,
  ) {
    final path = Path()
      ..moveTo(x - unit * .18, neckTop)
      ..cubicTo(
        x - unit * .19,
        neckTop + 13,
        x - unit * .25,
        shoulderY - 9,
        x - unit * .42,
        shoulderY,
      )
      ..lineTo(x + unit * .42, shoulderY)
      ..cubicTo(
        x + unit * .25,
        shoulderY - 9,
        x + unit * .19,
        neckTop + 13,
        x + unit * .18,
        neckTop,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = skin);
  }

  void _drawArms(
    Canvas canvas,
    double x,
    double shoulderY,
    double hipY,
    double shoulderHalf,
    double unit,
    Color skin,
  ) {
    final armWidth = unit * .24;
    final armBottom = hipY + unit * .08;
    for (final side in [-1.0, 1.0]) {
      final outer = x + side * (shoulderHalf + armWidth * .75);
      final inner = x + side * (shoulderHalf - armWidth * .25);
      final path = Path()
        ..moveTo(inner, shoulderY + 5)
        ..cubicTo(
          inner - side * armWidth * .05,
          shoulderY + 26,
          inner - side * armWidth * .08,
          hipY - 18,
          inner - side * armWidth * .15,
          armBottom - 6,
        )
        ..cubicTo(
          inner - side * armWidth * .18,
          armBottom + 4,
          outer - side * armWidth * .04,
          armBottom + 5,
          outer,
          armBottom - 4,
        )
        ..cubicTo(
          outer + side * armWidth * .05,
          hipY - 18,
          outer + side * armWidth * .08,
          shoulderY + 25,
          outer,
          shoulderY + 5,
        )
        ..quadraticBezierTo(
          x + side * shoulderHalf,
          shoulderY - 3,
          inner,
          shoulderY + 5,
        )
        ..close();
      canvas.drawPath(path, Paint()..color = const Color(0xff303638));
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(inner + side * armWidth * .02, armBottom),
          width: armWidth * .66,
          height: armWidth * .48,
        ),
        Paint()..color = skin,
      );
    }
  }

  void _drawLegs(
    Canvas canvas,
    double x,
    double crotchY,
    double footY,
    double unit,
  ) {
    final gap = unit * .10;
    final thigh = unit * .38;
    final calf = unit * .29;
    final kneeY = crotchY + (footY - crotchY) * .52;
    for (final side in [-1.0, 1.0]) {
      final center = x + side * (gap + thigh * .48);
      final path = Path()
        ..moveTo(center - thigh * .54, crotchY)
        ..cubicTo(
          center - thigh * .62,
          crotchY + 22,
          center - thigh * .50,
          kneeY - 16,
          center - calf * .52,
          kneeY,
        )
        ..cubicTo(
          center - calf * .48,
          kneeY + 20,
          center - calf * .55,
          footY - 22,
          center - calf * .50,
          footY - 8,
        )
        ..cubicTo(
          center - calf * .25,
          footY - 2,
          center + calf * .32,
          footY - 2,
          center + calf * .58,
          footY - 8,
        )
        ..cubicTo(
          center + calf * .56,
          footY - 25,
          center + calf * .48,
          kneeY + 18,
          center + calf * .42,
          kneeY,
        )
        ..cubicTo(
          center + thigh * .48,
          kneeY - 18,
          center + thigh * .58,
          crotchY + 22,
          center + thigh * .54,
          crotchY,
        )
        ..quadraticBezierTo(center, crotchY - 8, center - thigh * .54, crotchY)
        ..close();
      canvas.drawPath(path, Paint()..color = const Color(0xff2f3537));
      final foot = Path()
        ..moveTo(center - calf * .49, footY - 11)
        ..cubicTo(
          center - calf * .60,
          footY - 2,
          center - calf * .82,
          footY + 3,
          center - calf * .76,
          footY + 8,
        )
        ..cubicTo(
          center - calf * .30,
          footY + 12,
          center + calf * .56,
          footY + 9,
          center + calf * .67,
          footY + 2,
        )
        ..cubicTo(
          center + calf * .58,
          footY - 5,
          center + calf * .46,
          footY - 9,
          center + calf * .40,
          footY - 12,
        )
        ..close();
      canvas.drawPath(foot, Paint()..color = const Color(0xff1c2021));
    }
  }

  void _drawSideSilhouette(
    Canvas canvas,
    double x,
    double shoulderY,
    double hipY,
    double crotchY,
    double footY,
    double unit,
  ) {
    final path = Path()
      ..moveTo(x - unit * .28, shoulderY)
      ..cubicTo(
        x - unit * .44,
        shoulderY + 38,
        x - unit * .36,
        hipY - 18,
        x - unit * .16,
        hipY + 34,
      )
      ..cubicTo(
        x - unit * .08,
        crotchY,
        x - unit * .18,
        footY - 40,
        x - unit * .05,
        footY,
      )
      ..lineTo(x + unit * .25, footY)
      ..cubicTo(
        x + unit * .18,
        footY - 50,
        x + unit * .28,
        crotchY,
        x + unit * .31,
        hipY + 30,
      )
      ..cubicTo(
        x + unit * .50,
        hipY - 20,
        x + unit * .45,
        shoulderY + 28,
        x + unit * .20,
        shoulderY,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xff303638));
  }

  void _drawBackHair(
    Canvas canvas,
    double x,
    double headY,
    double unit,
    Color color,
  ) {
    final paint = Paint()..color = color;
    final side = unit * .42;
    switch (hairStyle) {
      case 'long straight':
        canvas.drawPath(_longHairPath(x, headY, unit, side), paint);
      case 'wavy':
        canvas.drawPath(_wavyHairPath(x, headY, unit, side), paint);
      case 'curly':
        _drawCurlClusters(canvas, x, headY, unit, color);
      case 'bun':
        canvas.drawPath(_bunPath(x, headY, unit), paint);
      case 'ponytail':
        canvas.drawPath(_ponytailPath(x, headY, unit), paint);
    }
  }

  void _drawFrontHair(
    Canvas canvas,
    Offset head,
    double width,
    double height,
    double unit,
    Color color,
  ) {
    final paint = Paint()..color = color;
    final cap = Path()
      ..moveTo(head.dx - width * .50, head.dy - height * .03)
      ..cubicTo(
        head.dx - width * .48,
        head.dy - height * .60,
        head.dx - width * .22,
        head.dy - height * .58,
        head.dx,
        head.dy - height * .59,
      )
      ..cubicTo(
        head.dx + width * .28,
        head.dy - height * .58,
        head.dx + width * .48,
        head.dy - height * .44,
        head.dx + width * .50,
        head.dy - height * .02,
      )
      ..cubicTo(
        head.dx + width * .38,
        head.dy - height * .17,
        head.dx + width * .25,
        head.dy - height * .22,
        head.dx + width * .12,
        head.dy - height * .16,
      )
      ..cubicTo(
        head.dx - width * .05,
        head.dy - height * .24,
        head.dx - width * .22,
        head.dy - height * .19,
        head.dx - width * .34,
        head.dy - height * .05,
      )
      ..close();
    canvas.drawPath(cap, paint);
    if (hairStyle == 'long straight' ||
        hairStyle == 'wavy' ||
        hairStyle == 'curly') {
      final lock = Paint()..color = color;
      canvas.drawPath(
        _frontLock(head.dx - width * .45, head.dy, unit, -1),
        lock,
      );
      canvas.drawPath(
        _frontLock(head.dx + width * .45, head.dy, unit, 1),
        lock,
      );
    }
  }

  Path _longHairPath(double x, double y, double u, double s) => Path()
    ..moveTo(x - s, y - u * .25)
    ..cubicTo(
      x - u * .82,
      y + u * .10,
      x - u * .70,
      y + u * 1.10,
      x - u * .58,
      y + u * 1.55,
    )
    ..cubicTo(
      x - u * .38,
      y + u * 1.65,
      x - u * .25,
      y + u * 1.50,
      x - s * .35,
      y + u * .82,
    )
    ..lineTo(x - s * .25, y - u * .20)
    ..close()
    ..moveTo(x + s, y - u * .25)
    ..cubicTo(
      x + u * .82,
      y + u * .10,
      x + u * .70,
      y + u * 1.10,
      x + u * .58,
      y + u * 1.55,
    )
    ..cubicTo(
      x + u * .38,
      y + u * 1.65,
      x + u * .25,
      y + u * 1.50,
      x + s * .35,
      y + u * .82,
    )
    ..lineTo(x + s * .25, y - u * .20)
    ..close();

  Path _wavyHairPath(double x, double y, double u, double s) => Path()
    ..moveTo(x - s, y - u * .18)
    ..cubicTo(
      x - u * .95,
      y + u * .25,
      x - u * .45,
      y + u * .48,
      x - u * .72,
      y + u * .78,
    )
    ..cubicTo(
      x - u * .95,
      y + u * 1.08,
      x - u * .40,
      y + u * 1.20,
      x - u * .64,
      y + u * 1.58,
    )
    ..cubicTo(
      x - u * .45,
      y + u * 1.68,
      x - u * .30,
      y + u * 1.35,
      x - s * .27,
      y + u * .78,
    )
    ..lineTo(x - s * .22, y - u * .20)
    ..close()
    ..moveTo(x + s, y - u * .18)
    ..cubicTo(
      x + u * .95,
      y + u * .25,
      x + u * .45,
      y + u * .48,
      x + u * .72,
      y + u * .78,
    )
    ..cubicTo(
      x + u * .95,
      y + u * 1.08,
      x + u * .40,
      y + u * 1.20,
      x + u * .64,
      y + u * 1.58,
    )
    ..cubicTo(
      x + u * .45,
      y + u * 1.68,
      x + u * .30,
      y + u * 1.35,
      x + s * .27,
      y + u * .78,
    )
    ..lineTo(x + s * .22, y - u * .20)
    ..close();

  Path _frontLock(double x, double y, double u, double side) => Path()
    ..moveTo(x, y - u * .30)
    ..cubicTo(
      x + side * u * .20,
      y + u * .18,
      x + side * u * .10,
      y + u * .58,
      x + side * u * .04,
      y + u * .90,
    )
    ..cubicTo(
      x - side * u * .02,
      y + u * 1.08,
      x - side * u * .15,
      y + u * .98,
      x - side * u * .16,
      y + u * .72,
    )
    ..cubicTo(
      x - side * u * .18,
      y + u * .34,
      x - side * u * .12,
      y + u * .04,
      x,
      y - u * .30,
    )
    ..close();

  Path _bunPath(double x, double y, double u) => Path()
    ..moveTo(x + u * .05, y - u * .35)
    ..cubicTo(
      x + u * .12,
      y - u * 1.05,
      x + u * .72,
      y - u * 1.12,
      x + u * .76,
      y - u * .55,
    )
    ..cubicTo(
      x + u * .82,
      y - u * .20,
      x + u * .50,
      y - u * .05,
      x + u * .05,
      y - u * .35,
    )
    ..close();

  Path _ponytailPath(double x, double y, double u) => Path()
    ..moveTo(x + u * .32, y - u * .18)
    ..cubicTo(
      x + u * 1.08,
      y - u * .18,
      x + u * 1.18,
      y + u * .60,
      x + u * .82,
      y + u * 1.15,
    )
    ..cubicTo(
      x + u * .65,
      y + u * 1.35,
      x + u * .42,
      y + u * 1.18,
      x + u * .58,
      y + u * .72,
    )
    ..cubicTo(
      x + u * .72,
      y + u * .28,
      x + u * .52,
      y + u * .04,
      x + u * .32,
      y - u * .18,
    )
    ..close();

  void _drawCurlClusters(
    Canvas canvas,
    double x,
    double y,
    double u,
    Color color,
  ) {
    final paint = Paint()..color = color;
    for (final side in [-1.0, 1.0]) {
      for (var i = 0; i < 4; i++) {
        final dx = x + side * (u * (.48 + (i.isEven ? .04 : -.02)));
        final dy = y + u * (.12 + i * .34);
        canvas.drawCircle(Offset(dx, dy), u * .22, paint);
      }
    }
  }

  double _map(
    double value,
    double min,
    double max,
    double outMin,
    double outMax,
  ) {
    final t = ((value - min) / (max - min)).clamp(0.0, 1.0);
    return outMin + (outMax - outMin) * t;
  }

  @override
  bool shouldRepaint(covariant BodyPainter oldDelegate) {
    return height != oldDelegate.height ||
        chest != oldDelegate.chest ||
        waist != oldDelegate.waist ||
        hip != oldDelegate.hip ||
        inseam != oldDelegate.inseam ||
        isSideView != oldDelegate.isSideView ||
        isFeminine != oldDelegate.isFeminine ||
        skinTone != oldDelegate.skinTone ||
        hairStyle != oldDelegate.hairStyle ||
        hairColor != oldDelegate.hairColor;
  }
}

extension on Color {
  Color lighten(double amount) => Color.lerp(this, Colors.white, amount)!;

  Color darken(double amount) => Color.lerp(this, Colors.black, amount)!;
}

const _skinColors = <String, Color>{
  'fair': Color(0xfff6d3c0),
  'light': Color(0xffe5b58e),
  'medium': Color(0xffc98c67),
  'tan': Color(0xffa96f4f),
  'deep': Color(0xff704936),
};

const _hairColors = <String, Color>{
  'black': Color(0xff1c1715),
  'dark brown': Color(0xff34231d),
  'brown': Color(0xff6a4634),
  'blonde': Color(0xffc9a15c),
  'auburn': Color(0xff884a32),
  'gray': Color(0xff8a8580),
};
