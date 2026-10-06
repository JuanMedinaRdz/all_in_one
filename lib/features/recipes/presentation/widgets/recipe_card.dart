import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/recipe.dart';

/// Tarjeta de una receta: foto de portada ancha con velo, nombre encima y una
/// fila de metadatos (tiempo, porciones, ingredientes). Si está planeada para
/// la semana, lleva una insignia.
class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onTogglePlanned,
  });

  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback onTogglePlanned;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = AppColors.forKey(recipe.displayName.toLowerCase());
    final ingredients = recipe.realIngredients;
    // Emojis de los primeros ingredientes, como "sabores" de la receta.
    final taste = ingredients.take(4).map((i) => i.displayEmoji).join(' ');

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: AppSpacing.brLg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppSpacing.brLg,
            boxShadow: AppColors.softShadow(theme.brightness),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Portada ---
              SizedBox(
                height: 150,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _Cover(url: recipe.coverImageUrl, accent: accent),
                    // Velo para que el texto blanco se lea sobre cualquier foto.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54, Colors.black87],
                          stops: [0.35, 0.75, 1],
                        ),
                      ),
                    ),
                    // Botón "esta semana" (estrella) arriba a la derecha.
                    Positioned(
                      top: AppSpacing.sm,
                      right: AppSpacing.sm,
                      child: _PlanButton(
                        planned: recipe.plannedThisWeek,
                        onTap: onTogglePlanned,
                      ),
                    ),
                    // Nombre + sabores abajo.
                    Positioned(
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (taste.isNotEmpty)
                            Text(taste, style: const TextStyle(fontSize: 15)),
                          if (taste.isNotEmpty) AppSpacing.gapXs,
                          Text(
                            recipe.displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // --- Metadatos ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    if (recipe.minutes != null) ...[
                      _Meta(icon: Symbols.timer_rounded, label: '${recipe.minutes} min'),
                      AppSpacing.gapMd,
                    ],
                    if (recipe.servings != null) ...[
                      _Meta(
                        icon: Symbols.restaurant_rounded,
                        label: '${recipe.servings}',
                      ),
                      AppSpacing.gapMd,
                    ],
                    _Meta(
                      icon: Symbols.grocery_rounded,
                      label: ingredients.length == 1
                          ? '1 ingr.'
                          : '${ingredients.length} ingr.',
                    ),
                    const Spacer(),
                    if (recipe.plannedThisWeek)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                        ),
                        child: Text(
                          'Esta semana',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Portada: la foto, o un degradado con un emoji de cocina si no hay.
class _Cover extends StatelessWidget {
  const _Cover({required this.url, required this.accent});

  final String? url;
  final Color accent;

  Widget _fallback() => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent.withValues(alpha: 0.9), accent.withValues(alpha: 0.5)],
          ),
        ),
        child: const Center(child: Text('🍳', style: TextStyle(fontSize: 40))),
      );

  @override
  Widget build(BuildContext context) {
    if (url == null) return _fallback();
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      // Si Storage no responde (p. ej. facturación pausada), degradado.
      errorWidget: (_, __, ___) => _fallback(),
      placeholder: (_, __) => _fallback(),
    );
  }
}

/// Estrella para planear/quitar de la semana, sobre la foto.
class _PlanButton extends StatelessWidget {
  const _PlanButton({required this.planned, required this.onTap});

  final bool planned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: planned
          ? Theme.of(context).colorScheme.primary
          : Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            planned ? Symbols.bookmark_rounded : Symbols.bookmark_add_rounded,
            fill: planned ? 1 : 0,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        AppSpacing.gapXs,
        Text(label, style: theme.textTheme.labelMedium?.copyWith(color: color)),
      ],
    );
  }
}
