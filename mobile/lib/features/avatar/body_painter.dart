import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// A local, measurement-reactive mannequin. It is deliberately an illustration.
class BodyPainter extends CustomPainter {
  final double height, chest, waist, hip, inseam;
  final bool isSideView;
  final bool isFeminine;
  final String skinTone, hairStyle, hairColor;

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
    final h = size.height.clamp(180.0, 560.0), cx = size.width / 2;
    final hf = _map(height, 140, 200, .88, 1.12);
    final lf = _map(inseam, 60, 100, .88, 1.16);
    final cf = _map(chest, 70, 130, .88, 1.16);
    final wf = _map(waist, 55, 120, .86, 1.20);
    final hipf = _map(hip, 75, 140, .88, 1.20);
    final bodyH = h * .84 * hf;
    final legH = bodyH * (.47 * lf).clamp(.40, .57);
    final torsoH = bodyH - legH, top = (h - bodyH) / 2 + h * .025;
    final unit = (size.width * .23).clamp(26.0, 72.0), headR = unit * .38;
    final shoulder = unit * (isFeminine ? .88 : 1.02) * cf;
    final chestW = unit * (isFeminine ? .92 : 1.0) * cf;
    final waistW = unit * .72 * wf,
        hipW = unit * (isFeminine ? .98 : .88) * hipf;
    final shoulderY = top + torsoH * .22, waistY = top + torsoH * .62;
    final hipY = top + torsoH * .91,
        crotchY = top + torsoH,
        footY = top + bodyH;
    final skin = _skinColors[skinTone] ?? Colors.brown;
    final hair = _hairColors[hairColor] ?? Colors.black;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, footY + 3),
        width: unit * 1.9,
        height: 10,
      ),
      Paint()..color = Colors.black26,
    );
    if (isSideView) {
      _side(canvas, cx, shoulderY, hipY, crotchY, footY, unit, skin);
    } else {
      _legs(canvas, cx, crotchY, footY, unit, skin);
      _torso(canvas, cx, shoulderY, waistY, hipY, chestW, waistW, hipW, skin);
      _arms(canvas, cx, shoulderY, hipY, shoulder, unit, skin);
    }
    final head = Offset(cx, top + headR);
    canvas.drawOval(
      Rect.fromCenter(center: head, width: headR * 1.8, height: headR * 2.1),
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx - headR, head.dy),
          Offset(cx + headR, head.dy + headR * 2),
          [skin.shade200, skin.shade700],
        ),
    );
    canvas.drawRect(
      Rect.fromLTRB(
        cx - unit * .16,
        top + headR * 1.85,
        cx + unit * .16,
        shoulderY + 2,
      ),
      Paint()..color = skin.shade500,
    );
    _hair(canvas, head, headR, hair);
  }

  void _torso(
    Canvas c,
    double x,
    double sy,
    double wy,
    double hy,
    double cw,
    double ww,
    double hw,
    MaterialColor skin,
  ) {
    final p = Path()
      ..moveTo(x - cw, sy)
      ..cubicTo(x - cw * 1.05, sy + 22, x - ww * .95, wy - 18, x - ww, wy)
      ..cubicTo(x - ww * 1.04, wy + 22, x - hw * .98, hy - 22, x - hw, hy)
      ..cubicTo(
        x - hw * .94,
        hy + 20,
        x - hw * .72,
        hy + 28,
        x - hw * .68,
        hy + 36,
      )
      ..lineTo(x + hw * .68, hy + 36)
      ..quadraticBezierTo(x + hw * .94, hy + 20, x + hw, hy)
      ..cubicTo(x + hw * .98, hy - 22, x + ww * 1.04, wy + 22, x + ww, wy)
      ..cubicTo(x + ww * .95, wy - 18, x + cw * 1.05, sy + 22, x + cw, sy)
      ..close();
    c.drawPath(
      p,
      Paint()
        ..shader = ui.Gradient.linear(Offset(x - cw, sy), Offset(x + hw, hy), [
          skin.shade300,
          skin.shade600,
        ]),
    );
  }

  void _legs(
    Canvas c,
    double x,
    double cy,
    double fy,
    double u,
    MaterialColor skin,
  ) {
    final p = Paint()..color = skin.shade500, gap = u * .12, leg = u * .34;
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(x - gap - leg, cy, x - gap, fy),
        Radius.circular(leg / 2),
      ),
      p,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(x + gap, cy, x + gap + leg, fy),
        Radius.circular(leg / 2),
      ),
      p,
    );
    final fp = Paint()..color = skin.shade700;
    c.drawOval(
      Rect.fromCenter(
        center: Offset(x - gap - leg * .35, fy),
        width: leg * 1.45,
        height: leg * .34,
      ),
      fp,
    );
    c.drawOval(
      Rect.fromCenter(
        center: Offset(x + gap + leg * .35, fy),
        width: leg * 1.45,
        height: leg * .34,
      ),
      fp,
    );
  }

  void _arms(
    Canvas c,
    double x,
    double sy,
    double hy,
    double shoulder,
    double u,
    MaterialColor skin,
  ) {
    final p = Paint()..color = skin.shade500, arm = u * .23;
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          x - shoulder - arm,
          sy + 4,
          x - shoulder + arm * .15,
          hy + 6,
        ),
        Radius.circular(arm),
      ),
      p,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
          x + shoulder - arm * .15,
          sy + 4,
          x + shoulder + arm,
          hy + 6,
        ),
        Radius.circular(arm),
      ),
      p,
    );
  }

  void _side(
    Canvas c,
    double x,
    double sy,
    double hy,
    double cy,
    double fy,
    double u,
    MaterialColor skin,
  ) {
    final p = Paint()..color = skin.shade500;
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(x - u * .34, sy, x + u * .42, hy + 34),
        Radius.circular(u * .35),
      ),
      p,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(x - u * .22, cy, x + u * .08, fy),
        Radius.circular(u * .16),
      ),
      p,
    );
  }

  void _hair(Canvas c, Offset o, double r, Color color) {
    final p = Paint()..color = color;
    c.drawArc(
      Rect.fromCenter(
        center: Offset(o.dx, o.dy - r * .25),
        width: r * 2,
        height: r * 1.35,
      ),
      3.14159,
      3.14159,
      true,
      p,
    );
    if (hairStyle == 'long straight' ||
        hairStyle == 'wavy' ||
        hairStyle == 'curly') {
      c.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(o.dx - r, o.dy - r * .35, o.dx + r, o.dy + r * .95),
          Radius.circular(r * .35),
        ),
        p,
      );
    } else if (hairStyle == 'bun') {
      c.drawCircle(Offset(o.dx, o.dy - r * 1.05), r * .45, p);
    } else if (hairStyle == 'ponytail') {
      c.drawOval(
        Rect.fromCenter(
          center: Offset(o.dx + r * 1.05, o.dy - r * .15),
          width: r * .7,
          height: r * 1.4,
        ),
        p,
      );
    }
  }

  double _map(double v, double min, double max, double lo, double hi) =>
      ((v - min) / (max - min)).clamp(0.0, 1.0) * (hi - lo) + lo;
  @override
  bool shouldRepaint(covariant BodyPainter old) =>
      height != old.height ||
      chest != old.chest ||
      waist != old.waist ||
      hip != old.hip ||
      inseam != old.inseam ||
      isSideView != old.isSideView ||
      isFeminine != old.isFeminine ||
      skinTone != old.skinTone ||
      hairStyle != old.hairStyle ||
      hairColor != old.hairColor;
}

const _skinColors = <String, MaterialColor>{
  'fair': Colors.orange,
  'light': Colors.deepOrange,
  'medium': Colors.brown,
  'tan': Colors.brown,
  'deep': Colors.brown,
};
const _hairColors = <String, Color>{
  'black': Colors.black,
  'dark brown': Colors.brown,
  'brown': Colors.brown,
  'blonde': Colors.amber,
  'auburn': Colors.deepOrange,
  'gray': Colors.blueGrey,
};
