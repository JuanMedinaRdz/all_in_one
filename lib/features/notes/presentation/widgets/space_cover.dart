import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/layout/motion.dart';

/// Portada ilustrada de un espacio: fondo teñido con el color del espacio, un
/// sol tenue, dos colinas y unos destellos que titilan. Vectorial y animada,
/// con el mismo lenguaje de las referencias (viewBox 170×64). Respeta "reducir
/// movimiento" (se queda quieta).
class SpaceCover extends StatefulWidget {
  const SpaceCover({
    super.key,
    required this.color,
    this.height = 58,
    this.seed = 0,
  });

  final Color color;
  final double height;

  /// Variación del patrón (para que dos espacios no se vean idénticos).
  final int seed;

  @override
  State<SpaceCover> createState() => _SpaceCoverState();
}

class _SpaceCoverState extends State<SpaceCover>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _ticker?.stop();
      return;
    }
    _ticker ??= createTicker((d) => setState(() => _elapsed = d));
    if (!_ticker!.isActive) _ticker!.start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = reduceMotion(context) ? 0.0 : _elapsed.inMicroseconds / 1e6;
    return SizedBox(
      width: double.infinity,
      height: widget.height,
      child: CustomPaint(painter: _CoverPainter(widget.color, t, widget.seed)),
    );
  }
}

class _CoverPainter extends CustomPainter {
  _CoverPainter(this.color, this.t, this.seed);

  final Color color;
  final double t;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 170;
    canvas.save();
    canvas.scale(s, size.height / 64);

    // Fondo: color del espacio mezclado con el fondo oscuro de la app.
    final bg = ui.Color.alphaBlend(
        color.withValues(alpha: 0.16), const Color(0xFF0E1116));
    canvas.drawRect(const Rect.fromLTWH(0, 0, 170, 64), Paint()..color = bg);

    // Sol tenue arriba a la derecha.
    canvas.drawCircle(const Offset(142, 18), 10,
        Paint()..color = color.withValues(alpha: 0.18));

    // Destellos que titilan (2, desfasados).
    for (var i = 0; i < 2; i++) {
      final phase = ((t - i * 0.7) / 2.2) % 1;
      final k = 0.5 - 0.5 * math.cos(2 * math.pi * (phase < 0 ? phase + 1 : phase));
      final op = (0.25 + 0.75 * k).clamp(0.0, 1.0);
      final cx = 96.0 + ((seed * 37 + i * 53) % 44);
      final cy = 10.0 + ((seed * 19 + i * 29) % 16);
      _star(canvas, Offset(cx, cy), 2.0 + 1.2 * k, color.withValues(alpha: op));
    }

    // Dos colinas (curvas del spec), más claras conforme al frente.
    final hill1 = Path()
      ..moveTo(0, 46)
      ..quadraticBezierTo(40, 26, 85, 40)
      ..quadraticBezierTo(130, 54, 170, 34)
      ..lineTo(170, 64)
      ..lineTo(0, 64)
      ..close();
    canvas.drawPath(hill1, Paint()..color = color.withValues(alpha: 0.22));
    final hill2 = Path()
      ..moveTo(0, 56)
      ..quadraticBezierTo(50, 42, 100, 52)
      ..quadraticBezierTo(150, 60, 170, 48)
      ..lineTo(170, 64)
      ..lineTo(0, 64)
      ..close();
    canvas.drawPath(hill2, Paint()..color = color.withValues(alpha: 0.45));

    canvas.restore();
  }

  void _star(Canvas canvas, Offset c, double r, Color color) {
    final p = Path()
      ..moveTo(c.dx, c.dy - r)
      ..lineTo(c.dx + r * 0.32, c.dy - r * 0.32)
      ..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx + r * 0.32, c.dy + r * 0.32)
      ..lineTo(c.dx, c.dy + r)
      ..lineTo(c.dx - r * 0.32, c.dy + r * 0.32)
      ..lineTo(c.dx - r, c.dy)
      ..lineTo(c.dx - r * 0.32, c.dy - r * 0.32)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CoverPainter old) => old.t != t || old.color != color;
}
