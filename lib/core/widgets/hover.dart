import 'package:flutter/widgets.dart';

import '../layout/motion.dart';
import '../theme/app_spacing.dart';

/// Ícono que gira 90° al pasar el cursor por encima (escritorio). En móvil (sin
/// cursor) no hace nada. Respeta "reducir movimiento".
///
/// Pensado para los botones "+" (Nueva tarea / Agregar). Se usa como `child` o
/// `icon` del botón; el giro ocurre cuando el puntero está sobre el ícono.
class HoverRotateIcon extends StatefulWidget {
  const HoverRotateIcon(this.icon, {super.key, this.size = 24, this.color, this.fill});

  final IconData icon;
  final double size;
  final Color? color;
  final double? fill;

  @override
  State<HoverRotateIcon> createState() => _HoverRotateIconState();
}

class _HoverRotateIconState extends State<HoverRotateIcon> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final rotate = _hovering && !reduceMotion(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedRotation(
        turns: rotate ? 0.25 : 0, // 90°
        duration: const Duration(milliseconds: 350),
        curve: AppMotion.gentle,
        child: Icon(
          widget.icon,
          size: widget.size,
          color: widget.color,
          fill: widget.fill,
        ),
      ),
    );
  }
}
