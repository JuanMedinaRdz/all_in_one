import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../layout/responsive.dart';
import '../theme/app_spacing.dart';

/// Andamio común de una sección: encabezado grande + contenido.
/// Mantiene el mismo ritmo visual en toda la app (sin incongruencias entre
/// secciones) y anima la entrada del contenido de forma suave.
class SectionScaffold extends StatelessWidget {
  const SectionScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Más aire lateral en pantallas anchas; y el contenido se centra con
          // un ancho máximo para no estirarse de borde a borde en un monitor.
          final hPad = constraints.maxWidth >= Breakpoints.expanded
              ? AppSpacing.xl
              : AppSpacing.lg;

          return ContentBounds(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.gapXl,
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: theme.textTheme.headlineMedium),
                            AppSpacing.gapXs,
                            Text(
                              subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  )
                      .animate()
                      .fadeIn(duration: AppMotion.medium)
                      .slideY(begin: -0.15, end: 0, curve: AppMotion.emphasized),
                  AppSpacing.gapXl,
                  Expanded(
                    child: child
                        .animate()
                        .fadeIn(delay: 80.ms, duration: AppMotion.medium)
                        .slideY(begin: 0.06, end: 0, curve: AppMotion.emphasized),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Estado vacío / "en construcción" de una sección todavía sin implementar.
class SectionPlaceholder extends StatelessWidget {
  const SectionPlaceholder({
    super.key,
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 44, color: theme.colorScheme.primary),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1, end: 1.04, duration: 2600.ms, curve: Curves.easeInOut),
          AppSpacing.gapXl,
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
