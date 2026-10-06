import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../../core/layout/motion.dart';

/// Paisaje cozy para el panel del día cuando hay pocas tareas: 2 nubes que se
/// mecen, un sol tenue, colinas verdes y 2 flores que se bambolean. Vectorial,
/// con los paths y colores del spec (viewBox 350×96). Respeta "reducir
/// movimiento" (se queda quieto).
class DayLandscape extends StatefulWidget {
  const DayLandscape({super.key, this.height = 92});

  final double height;

  @override
  State<DayLandscape> createState() => _DayLandscapeState();
}

class _DayLandscapeState extends State<DayLandscape>
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: widget.height,
        child: CustomPaint(painter: _LandscapePainter(t)),
      ),
    );
  }
}

class _LandscapePainter extends CustomPainter {
  _LandscapePainter(this.t);

  final double t;

  static const _cloud1 = Color(0xFF222A35);
  static const _cloud2 = Color(0xFF1E252F);
  static const _sun = Color(0xFFF5C542);
  static const _hill1 = Color(0xFF1A2A24);
  static const _hill2 = Color(0xFF183327);
  static const _stem = Color(0xFF2ECC8F);
  static const _petalPurple = Color(0xFFA78BFA);
  static const _petalPink = Color(0xFFFF8FA3);
  static const _flowerCore = Color(0xFFF5C542);

  @override
  void paint(Canvas canvas, Size size) {
    // Escala uniforme para encajar el ancho; alto fijo (viewBox 350×96).
    final s = size.width / 350;
    canvas.save();
    canvas.scale(s);
    final vh = size.height / s; // alto en unidades del viewBox

    // Cielo de fondo (sutil).
    canvas.drawRect(Rect.fromLTWH(0, 0, 350, vh), Paint()..color = const Color(0xFF12161C));

    // Sol tenue.
    canvas.drawCircle(const Offset(290, 50), 10, Paint()..color = _sun.withValues(alpha: 0.5));

    // Nubes (se mecen en X). 0 → 18 → 0.
    final dx1 = 9 * (1 - math.cos(2 * math.pi * ((t / 16) % 1)));
    final p2 = ((t + 7) / 21) % 1;
    final dx2 = 9 * (1 - math.cos(2 * math.pi * p2));
    _cloud(canvas, dx1, Path()
      ..moveTo(40, 40)
      ..relativeArcToPoint(const Offset(26, -6), radius: const Radius.circular(14), clockwise: true)
      ..relativeArcToPoint(const Offset(18, 10), radius: const Radius.circular(11), clockwise: true)
      ..lineTo(40, 40)
      ..close(), _cloud1);
    _cloud(canvas, dx2, Path()
      ..moveTo(220, 26)
      ..relativeArcToPoint(const Offset(22, -5), radius: const Radius.circular(12), clockwise: true)
      ..relativeArcToPoint(const Offset(15, 8), radius: const Radius.circular(9), clockwise: true)
      ..lineTo(220, 26)
      ..close(), _cloud2);

    // Colinas.
    final hill1 = Path()
      ..moveTo(0, 80)
      ..relativeQuadraticBezierTo(70, -20, 140, -6)
      ..relativeQuadraticBezierTo(60, 14, 130, -4)
      ..relativeQuadraticBezierTo(70, -18, 80, -8)
      ..lineTo(350, vh)
      ..lineTo(0, vh)
      ..close();
    canvas.drawPath(hill1, Paint()..color = _hill1);
    final hill2 = Path()
      ..moveTo(0, 88)
      ..relativeQuadraticBezierTo(80, -14, 175, -2)
      ..relativeQuadraticBezierTo(95, 10, 175, -4)
      ..lineTo(350, vh)
      ..lineTo(0, vh)
      ..close();
    canvas.drawPath(hill2, Paint()..color = _hill2);

    // Flores (se bambolean: rotación -8°..8° con el origen en la base del tallo).
    final wag = (8 * math.sin(2 * math.pi * ((t / 1.6) % 1))) * math.pi / 180;
    final wag2 =
        (8 * math.sin(2 * math.pi * (((t - 0.6) / 1.6) % 1))) * math.pi / 180;
    _flower(canvas, const Offset(150, 58), wag, stemTop: 8, stemLen: 18,
        stemX: 8, width: 2.4, petal: _petalPurple, petalR: 5, core: true);
    _flower(canvas, const Offset(176, 66), wag2, stemTop: 6, stemLen: 14,
        stemX: 6, width: 2.2, petal: _petalPink, petalR: 4, core: false);

    canvas.restore();
  }

  void _cloud(Canvas canvas, double dx, Path path, Color color) {
    canvas.save();
    canvas.translate(dx, 0);
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  void _flower(
    Canvas canvas,
    Offset origin,
    double angle, {
    required double stemTop,
    required double stemLen,
    required double stemX,
    required double width,
    required Color petal,
    required double petalR,
    required bool core,
  }) {
    canvas.save();
    // Origen en la base del tallo (abajo) para que el bamboleo gire desde ahí.
    final baseY = stemTop + stemLen;
    canvas.translate(origin.dx + stemX, origin.dy + baseY);
    canvas.rotate(angle);
    // Tallo.
    canvas.drawLine(
      Offset.zero,
      Offset(0, -stemLen),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..color = _stem,
    );
    // Flor.
    final flowerC = Offset(0, -stemLen - (stemTop - 2));
    canvas.drawCircle(flowerC, petalR, Paint()..color = petal);
    if (core) {
      canvas.drawCircle(flowerC, 2, Paint()..color = _flowerCore);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_LandscapePainter old) => old.t != t;
}
