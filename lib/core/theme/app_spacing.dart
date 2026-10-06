import 'package:flutter/widgets.dart';

/// Escala de espaciado y radios única para toda la app.
/// Espaciado generoso y esquinas muy redondeadas = sensación cozy / lo-fi.
abstract final class AppSpacing {
  const AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  // Radios de esquina. Generosos a propósito: es lo que da el look "inflado"
  // y cozy de la referencia (tarjetas muy redondeadas, nada de esquinas duras).
  static const double radiusSm = 14;
  static const double radiusMd = 20;
  static const double radiusLg = 28;
  static const double radiusPill = 999;

  static const BorderRadius brSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius brMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius brLg = BorderRadius.all(Radius.circular(radiusLg));

  /// Padding horizontal estándar de las pantallas.
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: lg);

  // Gaps reutilizables para no repetir SizedBox por todos lados.
  static const gapXs = SizedBox(height: xs, width: xs);
  static const gapSm = SizedBox(height: sm, width: sm);
  static const gapMd = SizedBox(height: md, width: md);
  static const gapLg = SizedBox(height: lg, width: lg);
  static const gapXl = SizedBox(height: xl, width: xl);
}

/// Duraciones y curvas de animación coherentes en toda la app.
/// Transiciones suaves (nada brusco) para un feel chill y amigable con TDAH.
abstract final class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration medium = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 520);

  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve gentle = Curves.easeInOut;
}
