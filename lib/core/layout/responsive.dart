import 'package:flutter/widgets.dart';

/// Puntos de quiebre y utilidades para adaptar la app a ventanas anchas (PC,
/// tablet en horizontal, web). La app nació para móvil; esto la deja cómoda
/// también en pantallas grandes sin estirar el contenido de borde a borde.
abstract final class Breakpoints {
  const Breakpoints._();

  /// A partir de aquí conviene mostrar el riel lateral en vez de la barra
  /// inferior (lo decide el shell).
  static const double medium = 720;

  /// A partir de aquí las secciones pasan a varias columnas.
  static const double expanded = 960;

  /// Riel lateral extendido (con más aire) en monitores grandes.
  static const double large = 1360;

  /// Ancho máximo del contenido: más allá, se centra y deja márgenes en vez de
  /// estirar líneas y tarjetas hasta lo incómodo.
  static const double maxContent = 1200;

  static bool isWide(double width) => width >= medium;
  static bool isExpanded(double width) => width >= expanded;

  /// Número de columnas para una cuadrícula, según el ancho disponible y el
  /// ancho objetivo de cada tarjeta.
  static int columnsFor(double width, {double target = 360, int max = 4}) {
    final n = (width / target).floor();
    return n.clamp(1, max);
  }
}

/// Centra a su hijo y le pone un ancho máximo cómodo. Es lo que evita que en un
/// monitor grande el contenido se estire de lado a lado.
class ContentBounds extends StatelessWidget {
  const ContentBounds({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContent,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
