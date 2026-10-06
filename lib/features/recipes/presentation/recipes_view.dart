import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

import '../../../core/layout/responsive.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../application/recipe_providers.dart';
import '../data/recipe.dart';
import 'widgets/recipe_card.dart';
import 'widgets/weekly_list_sheet.dart';

/// Filtro activo de la lista de recetas.
class RecipesFilter extends Notifier<bool> {
  @override
  bool build() => false; // false = todas, true = solo esta semana
  void toggle(bool onlyWeek) => state = onlyWeek;
}

final recipesFilterProvider = NotifierProvider<RecipesFilter, bool>(RecipesFilter.new);

/// Contenido del sub-apartado "Recetas": el recetario, con acceso a la lista de
/// compras de la semana.
class RecipesView extends ConsumerWidget {
  const RecipesView({super.key});

  /// Crea una receta vacía y abre el editor: escribir es lo primero que querrás
  /// hacer. Si sales sin llenar nada, el editor la borra sola.
  static Future<void> createRecipe(BuildContext context, WidgetRef ref) async {
    final recipe = Recipe(id: const Uuid().v4());
    await ref.read(recipeRepositoryProvider).save(recipe);
    if (context.mounted) context.go('${AppRoutes.notes}/receta/${recipe.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipesProvider);
    final onlyWeek = ref.watch(recipesFilterProvider);

    return switch (recipesAsync) {
      AsyncError(:final error) => _ErrorState(error: error),
      AsyncLoading() => const _LoadingState(),
      AsyncData(value: final all) => all.isEmpty
          ? _EmptyState(onAdd: () => createRecipe(context, ref))
          : _Loaded(all: all, onlyWeek: onlyWeek),
    };
  }
}

class _Loaded extends ConsumerWidget {
  const _Loaded({required this.all, required this.onlyWeek});

  final List<Recipe> all;
  final bool onlyWeek;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planned = ref.watch(plannedCountProvider);
    final weekly = ref.watch(weeklyListProvider);
    final shown = onlyWeek ? all.where((r) => r.plannedThisWeek).toList() : all;

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        _WeekBanner(
          plannedCount: planned,
          toBuy: weekly.toBuy,
          onTap: () => WeeklyListSheet.show(context),
        ),
        AppSpacing.gapLg,
        _FilterBar(
          onlyWeek: onlyWeek,
          allCount: all.length,
          weekCount: planned,
          onSelect: (w) => ref.read(recipesFilterProvider.notifier).toggle(w),
        ),
        AppSpacing.gapLg,
        if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxl),
            child: Center(
              child: Text(
                'Nada marcado para esta semana.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              RecipeCard cardFor(Recipe recipe) => RecipeCard(
                    recipe: recipe,
                    onTap: () =>
                        context.go('${AppRoutes.notes}/receta/${recipe.id}'),
                    onTogglePlanned: () => ref
                        .read(recipeRepositoryProvider)
                        .setPlanned(recipe.id, planned: !recipe.plannedThisWeek),
                  );

              Widget animated(int i, Widget card) => card
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 40 * i),
                    duration: AppMotion.medium,
                  )
                  .slideY(begin: 0.08, end: 0, curve: AppMotion.emphasized);

              final cols =
                  Breakpoints.columnsFor(constraints.maxWidth, target: 400, max: 3);

              // Una columna: tarjetas a lo ancho (como en móvil).
              if (cols == 1) {
                return Column(
                  children: [
                    for (final (i, recipe) in shown.indexed) ...[
                      animated(i, cardFor(recipe)),
                      AppSpacing.gapLg,
                    ],
                  ],
                );
              }

              // Varias columnas: cuadrícula con Wrap (tarjetas de ancho fijo).
              const spacing = AppSpacing.lg;
              final cardWidth =
                  (constraints.maxWidth - spacing * (cols - 1)) / cols;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final (i, recipe) in shown.indexed)
                    SizedBox(
                      width: cardWidth,
                      child: animated(i, cardFor(recipe)),
                    ),
                ],
              );
            },
          ),
      ],
    );
  }
}

/// Banner de la semana: atajo a la lista de compras, con cuántas recetas hay
/// planeadas y cuántos ingredientes faltan.
class _WeekBanner extends StatelessWidget {
  const _WeekBanner({
    required this.plannedCount,
    required this.toBuy,
    required this.onTap,
  });

  final int plannedCount;
  final int toBuy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.brLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.brLg,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withValues(alpha: 0.24),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Text('🛒', style: theme.textTheme.headlineSmall),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lista de la semana',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      plannedCount == 0
                          ? 'Marca recetas para armar tu lista'
                          : toBuy == 0
                              ? '$plannedCount recetas · todo comprado'
                              : '$plannedCount recetas · faltan $toBuy ingredientes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Symbols.chevron_right_rounded,
                  color: theme.colorScheme.onPrimary),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppMotion.medium).slideY(begin: 0.06, end: 0);
  }
}

/// Segmento Todas / Esta semana.
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.onlyWeek,
    required this.allCount,
    required this.weekCount,
    required this.onSelect,
  });

  final bool onlyWeek;
  final int allCount;
  final int weekCount;
  final ValueChanged<bool> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Chip(
          label: 'Todas ($allCount)',
          selected: !onlyWeek,
          onTap: () => onSelect(false),
        ),
        AppSpacing.gapSm,
        _Chip(
          label: 'Esta semana ($weekCount)',
          selected: onlyWeek,
          onTap: () => onSelect(true),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primary
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ).animate().fadeIn(delay: 250.ms, duration: AppMotion.medium);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

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
            child: const Text('🍳', style: TextStyle(fontSize: 40)),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1, end: 1.06, duration: 2400.ms, curve: Curves.easeInOut),
          AppSpacing.gapXl,
          Text('Tu recetario está vacío', style: theme.textTheme.titleMedium),
          AppSpacing.gapSm,
          Text(
            'Guarda tus recetas con foto e ingredientes,\ny arma tu lista de compras de la semana.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.gapXl,
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Symbols.add_rounded),
            label: const Text('Crear mi primera receta'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Symbols.cloud_off_rounded,
                  size: 40, color: theme.colorScheme.error),
              AppSpacing.gapLg,
              Text('No pude cargar tus recetas',
                  style: theme.textTheme.titleMedium),
              AppSpacing.gapSm,
              Text(
                '$error',
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
