import 'package:flutter/material.dart';

import '../layout/motion.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Tarjeta base de la app rediseñada: superficie elevada con **sombra cálida**
/// (no negra) y esquinas redondeadas, en vez de bordes duros. Es lo que hace
/// que todo se sienta mullido y premium.
///
/// En escritorio, al pasar el cursor se **eleva** un poco (translateY -3px +
/// sombra más marcada, 0.2s). En móvil no cambia. Respeta "reducir movimiento".
class SoftCard extends StatefulWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.radius = AppSpacing.brLg,
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderRadius radius;
  final Color? color;

  @override
  State<SoftCard> createState() => _SoftCardState();
}

class _SoftCardState extends State<SoftCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surface = widget.color ?? theme.colorScheme.surface;
    final lifted = _hovering && !reduceMotion(context);

    final content = Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: widget.radius,
        boxShadow: lifted
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ]
            : AppColors.softShadow(theme.brightness),
      ),
      child: widget.child,
    );

    Widget card = content;
    if (widget.onTap != null) {
      card = Material(
        color: Colors.transparent,
        borderRadius: widget.radius,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: widget.radius,
          // El ripple queda dentro del radio; la sombra vive en el contenedor.
          child: content,
        ),
      );
    }

    // La elevación al hover: translateY -3px, suave.
    card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: AppMotion.gentle,
      transform: Matrix4.translationValues(0, lifted ? -3 : 0, 0),
      transformAlignment: Alignment.center,
      child: card,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor:
          widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: card,
    );
  }
}

/// Tarjeta con degradado y el **brillo de "crema"** encima: una franja de luz
/// cálida en la esquina superior, como la espuma de un latte. La firma visual
/// de la app, reservada para los héroes (próximo pago, total, etc.).
class LatteCard extends StatelessWidget {
  const LatteCard({
    super.key,
    required this.child,
    required this.gradient,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.height,
    this.glowColor,
  });

  final Widget child;
  final Gradient gradient;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double? height;

  /// Color del resplandor bajo la tarjeta. Por defecto, tomado del degradado.
  final Color? glowColor;

  @override
  Widget build(BuildContext context) {
    final glow = glowColor ?? _firstColor(gradient);

    final content = Container(
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: AppSpacing.brLg,
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.32),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      // El sheen: luz difusa desde la esquina superior, como reflejo de cristal.
      foregroundDecoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x24FFFFFF), Color(0x00FFFFFF)],
          stops: [0, 0.55],
        ),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }

  static Color _firstColor(Gradient g) =>
      g.colors.isNotEmpty ? g.colors.first : const Color(0xFF6F4E37);
}
