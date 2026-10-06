import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';

/// Rutas de las animaciones Lottie de la app, en un solo lugar.
abstract final class AppAnim {
  const AppAnim._();

  static const celebration = 'assets/lottie/celebration.json';
  static const financeEmpty = 'assets/lottie/finance_empty.json';
  static const notesEmpty = 'assets/lottie/notes_empty.json';
}

/// Envoltorio de una animación Lottie con tamaño fijo. Centraliza el manejo de
/// errores: si un asset falla al decodificar, no rompe la pantalla (muestra un
/// hueco), en vez de propagar la excepción.
class AppLottie extends StatelessWidget {
  const AppLottie(
    this.asset, {
    super.key,
    this.size = 160,
    this.repeat = true,
  });

  final String asset;
  final double size;
  final bool repeat;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        asset,
        repeat: repeat,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
