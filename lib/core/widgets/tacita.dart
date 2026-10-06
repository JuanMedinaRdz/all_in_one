import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../layout/motion.dart';

/// Estado de ánimo de la mascota "Tacita" (una tacita de café con carita).
enum TacitaState {
  /// Tranquila: vapor, parpadeo y flota (bob). Por defecto.
  idle,

  /// Enfocada: hay ≥1 tarea en progreso. Vapor naranja rápido + relojito.
  focus,

  /// Celebrando: al cerrar un paso/tarea. Salta, ojos ^^ y destellos.
  celebrate,

  /// Dormida: estados vacíos. Cuerpo oscuro, ojos cerrados, "z z z".
  sleep,
}

/// La mascota "Tacita", dibujada con [CustomPainter] a partir de los paths del
/// spec (viewBox 64×64). Se anima sola con un [Ticker]; si el sistema pide
/// **reducir movimiento**, pinta el frame base quieto y no arranca el ticker.
///
/// Es solo presentación: el [state] lo decide quien la use.
class TacitaMascot extends StatefulWidget {
  const TacitaMascot({super.key, required this.state, this.size = 72});

  final TacitaState state;
  final double size;

  @override
  State<TacitaMascot> createState() => _TacitaMascotState();
}

class _TacitaMascotState extends State<TacitaMascot>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;
  Duration _elapsed = Duration.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  /// Arranca o detiene el ticker según "reducir movimiento".
  void _sync() {
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
    final reduce = reduceMotion(context);
    final t = reduce ? 0.0 : _elapsed.inMicroseconds / 1e6;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _TacitaPainter(state: widget.state, t: t),
        isComplex: true,
      ),
    );
  }
}

double _lerp(double a, double b, double x) => a + (b - a) * x.clamp(0.0, 1.0);

class _TacitaPainter extends CustomPainter {
  _TacitaPainter({required this.state, required this.t});

  final TacitaState state;
  final double t;

  // --- Paleta exacta del spec ---
  static const _green = Color(0xFF2ECC8F);
  static const _greenLip = Color(0xFF5FE0AD);
  static const _sleepBody = Color(0xFF2A8F69);
  static const _sleepLip = Color(0xFF3FB386);
  static const _dark = Color(0xFF0E1116);
  static const _steamGray = Color(0xFFC3CAD3);
  static const _orange = Color(0xFFF0A43A);
  static const _pink = Color(0xFFFF8FA3);
  static const _yellow = Color(0xFFF5C542);
  static const _purple = Color(0xFFA78BFA);
  static const _zzzGray = Color(0xFF8B95A3);
  static const _clockBg = Color(0xFF161B23);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 64;
    canvas.save();
    canvas.scale(s);

    // Desplazamiento vertical del conjunto (bob en idle, hop en celebrate).
    canvas.translate(0, _bodyOffsetY());

    _drawSteam(canvas);
    _drawCup(canvas);
    _drawFace(canvas);
    _drawExtras(canvas);

    canvas.restore();
  }

  double _bodyOffsetY() {
    switch (state) {
      case TacitaState.idle:
        final p = (t / 3.2) % 1;
        return -1.5 * (1 - math.cos(2 * math.pi * p)); // 0 → -3 → 0
      case TacitaState.celebrate:
        final p = (t / 1.4) % 1;
        if (p < .30) return _lerp(0, -10, p / .30);
        if (p < .60) return _lerp(-10, 0, (p - .30) / .30);
        if (p < .75) return _lerp(0, -4, (p - .60) / .15);
        return _lerp(-4, 0, (p - .75) / .25);
      case TacitaState.focus:
      case TacitaState.sleep:
        return 0;
    }
  }

  // --- Taza ---
  void _drawCup(Canvas canvas) {
    final sleeping = state == TacitaState.sleep;
    final body = sleeping ? _sleepBody : _green;
    final lip = sleeping ? _sleepLip : _greenLip;

    final cup = Path()
      ..moveTo(12, 22)
      ..relativeLineTo(36, 0)
      ..relativeLineTo(0, 12)
      ..relativeArcToPoint(const Offset(-16, 16),
          radius: const Radius.circular(16), clockwise: true)
      ..relativeLineTo(-4, 0)
      ..relativeArcToPoint(const Offset(-16, -16),
          radius: const Radius.circular(16), clockwise: true)
      ..close();
    canvas.drawPath(cup, Paint()..color = body);

    // Asa.
    final handle = Path()
      ..moveTo(48, 27)
      ..relativeLineTo(3, 0)
      ..relativeArcToPoint(const Offset(0, 14),
          radius: const Radius.circular(7), clockwise: true)
      ..relativeLineTo(-4, 0);
    canvas.drawPath(
      handle,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..color = body,
    );

    // Labio superior.
    canvas.drawRRect(
      RRect.fromLTRBR(10, 19, 50, 24, const Radius.circular(2.5)),
      Paint()..color = lip,
    );
  }

  // --- Vapor ---
  void _drawSteam(Canvas canvas) {
    final (color, period, xs) = switch (state) {
      TacitaState.idle => (_steamGray, 2.8, const [24.0, 31.0, 38.0]),
      TacitaState.focus => (_orange, 1.4, const [24.0, 31.0]),
      _ => (_steamGray, 2.8, const <double>[]), // celebrate/sleep: sin vapor
    };
    if (xs.isEmpty) return;

    const delays = [0.0, 0.9, 1.8];
    for (var i = 0; i < xs.length; i++) {
      var p = ((t - delays[i]) / period) % 1;
      if (p < 0) p += 1;
      final dy = _lerp(4, -7, p);
      final op = p < .4 ? _lerp(0, .75, p / .4) : _lerp(.75, 0, (p - .4) / .6);
      final x = xs[i];
      final path = Path()
        ..moveTo(x, 16)
        ..relativeCubicTo(-3, -4, 3, -6, 0, -11);
      canvas.save();
      canvas.translate(0, dy);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: op.clamp(0.0, 1.0)),
      );
      canvas.restore();
    }
  }

  // --- Cara ---
  void _drawFace(Canvas canvas) {
    switch (state) {
      case TacitaState.idle:
        _idleFace(canvas);
      case TacitaState.focus:
        _focusFace(canvas);
      case TacitaState.celebrate:
        _celebrateFace(canvas);
      case TacitaState.sleep:
        _sleepFace(canvas);
    }
  }

  Paint get _darkStroke => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2
    ..strokeCap = StrokeCap.round
    ..color = _dark;

  void _cheeks(Canvas canvas, double cy, double opacity) {
    final p = Paint()..color = _pink.withValues(alpha: opacity);
    canvas.drawOval(Rect.fromCenter(center: Offset(19, cy), width: 5.6, height: 3.4), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(41, cy), width: 5.6, height: 3.4), p);
  }

  void _idleFace(Canvas canvas) {
    // Parpadeo: escala vertical de los ojos.
    final bp = (t / 4.6) % 1;
    double blink;
    if (bp >= .92 && bp < .95) {
      blink = _lerp(1, .1, (bp - .92) / .03);
    } else if (bp >= .95 && bp < .98) {
      blink = _lerp(.1, 1, (bp - .95) / .03);
    } else {
      blink = 1;
    }
    final eye = Paint()..color = _dark;
    for (final cx in [24.0, 36.0]) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, 33), width: 5, height: 5 * blink),
        eye,
      );
    }
    // Boca sonriente: M27 38.5 q3 3 6 0
    canvas.drawPath(
      Path()
        ..moveTo(27, 38.5)
        ..quadraticBezierTo(30, 41.5, 33, 38.5),
      _darkStroke,
    );
    _cheeks(canvas, 37.5, .75);
  }

  void _focusFace(Canvas canvas) {
    final brow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = _dark;
    canvas.drawLine(const Offset(21, 31), const Offset(26, 32), brow);
    canvas.drawLine(const Offset(39, 31), const Offset(34, 32), brow);

    final eye = Paint()..color = _dark;
    canvas.drawCircle(const Offset(24, 34), 2.3, eye);
    canvas.drawCircle(const Offset(36, 34), 2.3, eye);

    // Boca recta.
    canvas.drawLine(const Offset(27, 39.5), const Offset(33, 39.5), _darkStroke);

    // Relojito arriba a la derecha, con la manecilla girando (6s).
    const center = Offset(52, 12);
    canvas.drawCircle(center, 7, Paint()..color = _clockBg);
    canvas.drawCircle(
      center,
      7,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = _orange,
    );
    final angle = 2 * math.pi * ((t / 6) % 1);
    final hand = Offset(center.dx + 4.5 * math.sin(angle), center.dy - 4.5 * math.cos(angle));
    canvas.drawLine(
      center,
      hand,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = _orange,
    );
  }

  void _celebrateFace(Canvas canvas) {
    final eyes = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _dark;
    canvas.drawPath(
      Path()
        ..moveTo(21, 34)
        ..relativeLineTo(3, -3)
        ..relativeLineTo(3, 3),
      eyes,
    );
    canvas.drawPath(
      Path()
        ..moveTo(33, 34)
        ..relativeLineTo(3, -3)
        ..relativeLineTo(3, 3),
      eyes,
    );
    // Boca abierta (semicírculo).
    canvas.drawPath(
      Path()
        ..moveTo(26, 38)
        ..relativeLineTo(8, 0)
        ..relativeArcToPoint(const Offset(-8, 0),
            radius: const Radius.circular(4), clockwise: true)
        ..close(),
      Paint()..color = _dark,
    );
    _cheeks(canvas, 38, .85);

    // Destellos (twinkle): dos estrellas que laten.
    _twinkleStar(canvas, const Offset(8, 10), _starSmall(), _yellow, 0);
    _twinkleStar(canvas, const Offset(54, 6), _starSmall(scale: .85), _purple, .6);
  }

  void _sleepFace(Canvas canvas) {
    // Ojos cerrados.
    canvas.drawPath(
      Path()
        ..moveTo(21, 33)
        ..quadraticBezierTo(24, 35.4, 27, 33),
      _darkStroke,
    );
    canvas.drawPath(
      Path()
        ..moveTo(33, 33)
        ..quadraticBezierTo(36, 35.4, 39, 33),
      _darkStroke,
    );
    // Naricita.
    canvas.drawCircle(const Offset(30, 40), 1.6, Paint()..color = _dark);
    _cheeks(canvas, 37.5, .6);

    // "z z z" subiendo, arriba a la derecha.
    _drawZzz(canvas);
  }

  void _drawExtras(Canvas canvas) {
    // (Reservado: por ahora los extras por estado se dibujan dentro de la cara.)
  }

  // --- Destellos ---
  Path _starSmall({double scale = 1}) {
    // Estrella pequeña centrada en (0,0), ~7u de diámetro.
    final p = Path()
      ..moveTo(0, -3.5 * scale)
      ..relativeLineTo(1 * scale, 2.2 * scale)
      ..relativeLineTo(2.2 * scale, .9 * scale)
      ..relativeLineTo(-2.2 * scale, .9 * scale)
      ..relativeLineTo(-1 * scale, 2.2 * scale)
      ..relativeLineTo(-1 * scale, -2.2 * scale)
      ..relativeLineTo(-2.2 * scale, -.9 * scale)
      ..relativeLineTo(2.2 * scale, -.9 * scale)
      ..close();
    return p;
  }

  void _twinkleStar(
      Canvas canvas, Offset at, Path star, Color color, double delay) {
    var p = ((t - delay) / 1.8) % 1;
    if (p < 0) p += 1;
    final k = .5 - .5 * math.cos(2 * math.pi * p); // 0 → 1 → 0
    final scale = _lerp(.55, 1, k);
    final op = _lerp(.25, 1, k);
    canvas.save();
    canvas.translate(at.dx, at.dy);
    canvas.scale(scale);
    canvas.drawPath(star, Paint()..color = color.withValues(alpha: op));
    canvas.restore();
  }

  void _drawZzz(Canvas canvas) {
    const delays = [0.0, 1.1, 2.2];
    const sizes = [9.0, 7.0, 6.0];
    for (var i = 0; i < 3; i++) {
      var p = ((t - delays[i]) / 3.2) % 1;
      if (p < 0) p += 1;
      final op = p < .3 ? _lerp(0, .85, p / .3) : _lerp(.85, 0, (p - .3) / .7);
      if (op <= 0.01) continue;
      final scale = _lerp(.8, 1.1, p);
      final tp = TextPainter(
        text: TextSpan(
          text: 'z',
          style: TextStyle(
            color: _zzzGray.withValues(alpha: op.clamp(0.0, 1.0)),
            fontSize: sizes[i] * scale,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(44 + 10 * p, 10 - 22 * p));
    }
  }

  @override
  bool shouldRepaint(_TacitaPainter old) => old.t != t || old.state != state;
}
