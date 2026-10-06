import 'package:flutter/material.dart';

import '../../../../core/layout/motion.dart';
import '../../../../core/theme/app_spacing.dart';

/// La barra de progreso "por pasos", firma visual de las tareas: una línea con
/// un punto por cada breakpoint (un hito), que se rellena conforme los marcas
/// hechos. Si se le pasa [onSeek], se vuelve interactiva: tocar o arrastrar la
/// barra marca los pasos hasta ahí (una forma directa de "hacerla crecer").
class BreakpointTrack extends StatelessWidget {
  const BreakpointTrack({
    super.key,
    required this.total,
    required this.done,
    required this.color,
    this.height = 24,
    this.onSeek,
  });

  final int total;
  final int done;
  final Color color;
  final double height;

  /// Si no es null, la barra deja arrastrar/tocar para fijar cuántos pasos van
  /// hechos (0..total). Se usa en el detalle; en las tarjetas va de solo lectura.
  final ValueChanged<int>? onSeek;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trackColor =
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.9);
    final fraction = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final cy = height / 2;
          const dotR = 4.0;
          const thumbR = 8.0;
          // Deja aire a los lados para que el tirador no se salga.
          final usable = w - thumbR * 2;
          double px(double f) => thumbR + usable * f;

          void seekTo(double dx) {
            if (onSeek == null || total == 0) return;
            final f = ((dx - thumbR) / usable).clamp(0.0, 1.0);
            onSeek!((f * total).round().clamp(0, total));
          }

          final bar = Stack(
            clipBehavior: Clip.none,
            children: [
              // Riel base.
              Positioned(
                left: 0,
                right: 0,
                top: cy - 2,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: trackColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
              ),
              // Relleno hasta el progreso (animado).
              Positioned(
                left: 0,
                top: cy - 2,
                child: AnimatedContainer(
                  duration: AppMotion.medium,
                  curve: AppMotion.emphasized,
                  height: 4,
                  width: px(fraction).clamp(0.0, w),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                ),
              ),
              // Brillo (shimmer) barriendo el relleno.
              if (!reduceMotion(context) && fraction > 0)
                Positioned(
                  left: 0,
                  top: cy - 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    child: SizedBox(
                      width: px(fraction).clamp(0.0, w),
                      height: 4,
                      child: const _Shimmer(),
                    ),
                  ),
                ),
              // Un punto por breakpoint, al final de cada tramo.
              for (var i = 0; i < total; i++)
                Positioned(
                  left: px((i + 1) / total) - dotR,
                  top: cy - dotR,
                  child: Container(
                    width: dotR * 2,
                    height: dotR * 2,
                    decoration: BoxDecoration(
                      color: i < done ? color : trackColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              // Tirador en la posición actual (animado).
              AnimatedPositioned(
                duration: AppMotion.medium,
                curve: AppMotion.emphasized,
                left: px(fraction) - thumbR,
                top: cy - thumbR,
                child: Container(
                  width: thumbR * 2,
                  height: thumbR * 2,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 3),
                    boxShadow: onSeek != null
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.35),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ],
          );

          if (onSeek == null) return bar;

          // Interactiva: tocar o arrastrar fija el progreso.
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => seekTo(d.localPosition.dx),
            onHorizontalDragUpdate: (d) => seekTo(d.localPosition.dx),
            child: bar,
          );
        },
      ),
    );
  }
}

/// Un brillo blanco que barre de izquierda a derecha sobre el relleno (2.8s).
class _Shimmer extends StatefulWidget {
  const _Shimmer();

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        const band = 60.0;
        return AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            // Barre desde fuera por la izquierda hasta pasarse por la derecha.
            final x = -band + (_c.value * (w + band));
            return Transform.translate(
              offset: Offset(x, 0),
              child: Container(
                width: band,
                height: 4,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0x00FFFFFF),
                      Color(0x80FFFFFF),
                      Color(0x00FFFFFF),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
