import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Dibuja una taza de café que se llena conforme avanza la sesión Pomodoro.
///
/// [fill] va de 0 (vacía) a 1 (llena). El café tiene una superficie ondulada
/// que se mece suavemente según [wavePhase], y sale vapor por arriba. Todo
/// vectorial, en la paleta cálida de la app.
class CoffeeCupPainter extends CustomPainter {
  CoffeeCupPainter({
    required this.fill,
    required this.wavePhase,
    required this.coffee,
    required this.cup,
    required this.foam,
    required this.steam,
  });

  final double fill;
  final double wavePhase;
  final Color coffee;
  final Color cup;
  final Color foam;
  final Color steam;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Geometría de la taza: un vaso ligeramente troncocónico y su asa.
    final cupTop = h * 0.24;
    final cupBottom = h * 0.92;
    final cupHeight = cupBottom - cupTop;
    final topHalf = w * 0.30;
    final bottomHalf = w * 0.24;
    final cx = w * 0.46;

    Offset leftAt(double t) =>
        Offset(cx - (topHalf + (bottomHalf - topHalf) * t), cupTop + cupHeight * t);
    Offset rightAt(double t) =>
        Offset(cx + (topHalf + (bottomHalf - topHalf) * t), cupTop + cupHeight * t);

    final cupPath = Path()
      ..moveTo(leftAt(0).dx, leftAt(0).dy)
      ..lineTo(leftAt(1).dx, leftAt(1).dy)
      ..quadraticBezierTo(cx, cupBottom + h * 0.03, rightAt(1).dx, rightAt(1).dy)
      ..lineTo(rightAt(0).dx, rightAt(0).dy);

    // Asa.
    final handle = Path()
      ..moveTo(rightAt(0.12).dx, rightAt(0.12).dy)
      ..cubicTo(
        w * 0.92, cupTop + cupHeight * 0.05,
        w * 0.92, cupTop + cupHeight * 0.6,
        rightAt(0.55).dx, rightAt(0.55).dy,
      );
    canvas.drawPath(
      handle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.05
        ..strokeCap = StrokeCap.round
        ..color = cup,
    );

    // Café: se recorta a la silueta de la taza y se rellena de abajo hacia
    // arriba según `fill`, con una superficie ondulada.
    canvas.save();
    canvas.clipPath(cupPath);

    final level = cupBottom - cupHeight * fill.clamp(0.0, 1.0) * 0.98;
    final amp = h * 0.012 * (fill > 0.02 ? 1 : 0);
    final wave = Path()..moveTo(0, level);
    for (double x = 0; x <= w; x += 6) {
      final y = level + math.sin((x / w * 2 * math.pi) + wavePhase) * amp;
      wave.lineTo(x, y);
    }
    wave
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(wave, Paint()..color = coffee);

    // Brillito de la crema en la superficie.
    if (fill > 0.04) {
      canvas.drawPath(
        Path()
          ..addRect(Rect.fromLTWH(0, level - h * 0.012, w, h * 0.02)),
        Paint()..color = foam.withValues(alpha: 0.5),
      );
    }
    canvas.restore();

    // Contorno de la taza por encima del café.
    canvas.drawPath(
      cupPath..close(),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.035
        ..strokeJoin = StrokeJoin.round
        ..color = cup,
    );

    // Vapor: dos hilos que suben ondulando, más visibles con la taza llena.
    final steamOpacity = (0.25 + fill * 0.55).clamp(0.0, 0.8);
    for (final offset in [-w * 0.08, w * 0.08]) {
      final path = Path();
      final baseX = cx + offset;
      final baseY = cupTop - h * 0.02;
      path.moveTo(baseX, baseY);
      for (double t = 0; t <= 1; t += 0.1) {
        final y = baseY - t * h * 0.18;
        final x = baseX + math.sin(t * math.pi * 2 + wavePhase + offset) * w * 0.03;
        path.lineTo(x, y);
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.02
          ..strokeCap = StrokeCap.round
          ..color = steam.withValues(alpha: steamOpacity),
      );
    }
  }

  @override
  bool shouldRepaint(CoffeeCupPainter old) =>
      old.fill != fill || old.wavePhase != wavePhase;
}
