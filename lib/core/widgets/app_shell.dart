import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../features/todos/application/todo_providers.dart';
import '../../features/todos/domain/todo_status.dart';
import '../firebase/firebase_bootstrap.dart';
import '../layout/responsive.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'tacita.dart';

/// Envoltorio principal de la app: contiene la navegación entre las tres
/// secciones y se adapta al ancho disponible.
///
/// - Móvil (< 720 px): barra de navegación inferior.
/// - Escritorio (>= 720 px): riel lateral.
///
/// El cuerpo lo aporta `StatefulShellRoute`, que preserva el estado de cada
/// sección y aplica la transición fade-through.
///
/// Los iconos son Material Symbols en fuente *variable*: el mismo icono pasa de
/// contorno a relleno al seleccionarse (`fill` 0 → 1), sin necesitar dos assets.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = <_Destination>[
    _Destination(icon: Symbols.calendar_month_rounded, label: 'Calendario'),
    _Destination(icon: Symbols.wallet_rounded, label: 'Mensualidades'),
    _Destination(icon: Symbols.sticky_note_2_rounded, label: 'Notas'),
    _Destination(icon: Symbols.checklist_rounded, label: "To Do's"),
  ];

  void _select(int index) {
    // `initialLocation: true` solo si se re-toca la pestaña activa: vuelve a la
    // raíz de esa sección. Si no, conserva dónde estabas dentro de la sección.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(firebaseStatusProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= Breakpoints.medium;
        // En monitores grandes el riel se muestra "extendido" (con etiquetas al
        // lado del icono), como una app de escritorio de verdad.
        final extended = constraints.maxWidth >= Breakpoints.large;

        return Scaffold(
          body: Column(
            children: [
              if (status != FirebaseStatus.ready) const _FirebaseBanner(),
              Expanded(
                child: isWide
                    ? Row(
                        children: [
                          _SideRail(
                            destinations: _destinations,
                            currentIndex: navigationShell.currentIndex,
                            onSelect: _select,
                            extended: extended,
                          ),
                          Expanded(child: navigationShell),
                        ],
                      )
                    : navigationShell,
              ),
            ],
          ),
          bottomNavigationBar: isWide
              ? null
              : NavigationBar(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _select,
                  destinations: [
                    for (final d in _destinations)
                      NavigationDestination(
                        icon: Icon(d.icon, fill: 0),
                        selectedIcon: Icon(d.icon, fill: 1),
                        label: d.label,
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _Destination {
  const _Destination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Riel lateral para escritorio, con la marca de la app arriba (vectorial) y
/// Tacita al fondo (acompaña: enfocada si hay tareas en progreso).
class _SideRail extends ConsumerWidget {
  const _SideRail({
    required this.destinations,
    required this.currentIndex,
    required this.onSelect,
    this.extended = false,
  });

  final List<_Destination> destinations;
  final int currentIndex;
  final ValueChanged<int> onSelect;
  final bool extended;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final inProgress =
        (ref.watch(todoBoardProvider).value?.countOf(TodoStatus.doing) ?? 0) > 0;
    final mood = inProgress ? TacitaState.focus : TacitaState.idle;

    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onSelect,
      // Extendido muestra la etiqueta al lado; si no, debajo del icono.
      extended: extended,
      labelType:
          extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.coffee_rounded,
              fill: 1,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            if (extended) ...[
              AppSpacing.gapSm,
              Text('Todo en uno', style: theme.textTheme.titleMedium),
            ],
          ],
        ),
      ),
      // Tacita al fondo del riel.
      trailing: Expanded(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: _TacitaCard(mood: mood, extended: extended),
          ),
        ),
      ),
      destinations: [
        for (final d in destinations)
          NavigationRailDestination(
            icon: Icon(d.icon, fill: 0),
            selectedIcon: Icon(d.icon, fill: 1),
            label: Text(d.label),
          ),
      ],
    );
  }
}

/// Tarjetita de Tacita al fondo del riel. En modo extendido lleva un mensajito.
class _TacitaCard extends StatelessWidget {
  const _TacitaCard({required this.mood, required this.extended});

  final TacitaState mood;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!extended) {
      return TacitaMascot(state: mood, size: 48);
    }
    return Container(
      width: 180,
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppSpacing.brLg,
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TacitaMascot(state: mood, size: 64),
          AppSpacing.gapSm,
          Text('Un paso a la vez', style: theme.textTheme.titleSmall),
          Text(
            mood == TacitaState.focus
                ? 'Vas con todo. Sigue así ☕'
                : 'Elige algo pequeñito y empieza.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Aviso discreto cuando Firebase no está listo. La app sigue usable.
class _FirebaseBanner extends StatelessWidget {
  const _FirebaseBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const color = AppColors.danger;

    return Material(
      color: color.withValues(alpha: 0.14),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(Symbols.cloud_off_rounded, fill: 1, size: 16, color: color),
              AppSpacing.gapSm,
              Expanded(
                child: Text(
                  'Sin conexión con Firebase. Los cambios no se están guardando.',
                  style: theme.textTheme.bodySmall?.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppMotion.medium).slideY(begin: -0.5, end: 0);
  }
}
