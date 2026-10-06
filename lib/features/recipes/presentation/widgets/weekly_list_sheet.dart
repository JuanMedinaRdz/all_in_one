import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../application/recipe_providers.dart';

/// Lista de compras de la semana: los ingredientes de todas las recetas
/// marcadas "esta semana", juntados y sin repetir. Marcas lo que ya tienes y se
/// va al carrito; lo que falta queda arriba. La despensa se deriva de aquí.
class WeeklyListSheet extends ConsumerWidget {
  const WeeklyListSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const WeeklyListSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final list = ref.watch(weeklyListProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.md),
              child: Row(
                children: [
                  Text('🛒', style: theme.textTheme.headlineSmall),
                  AppSpacing.gapSm,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lista de la semana',
                            style: theme.textTheme.titleLarge),
                        Text(
                          list.isEmpty
                              ? 'Marca recetas para esta semana'
                              : '${list.toBuy} por comprar · ${list.haveCount} en el carrito',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (list.haveCount > 0)
                    TextButton.icon(
                      onPressed: () =>
                          ref.read(pantryStateRepositoryProvider).clear(),
                      icon: const Icon(Symbols.restart_alt_rounded, size: 18),
                      label: const Text('Reiniciar'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? _Empty()
                  : ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
                      children: [
                        for (final item in list.pending)
                          _WeeklyRow(
                            item: item,
                            onToggle: () => ref
                                .read(pantryStateRepositoryProvider)
                                .setHave(item.key, have: true),
                          ),
                        if (list.inCart.isNotEmpty) ...[
                          AppSpacing.gapLg,
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.sm),
                            child: Text(
                              'Ya lo tengo',
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          AppSpacing.gapSm,
                          for (final item in list.inCart)
                            _WeeklyRow(
                              item: item,
                              onToggle: () => ref
                                  .read(pantryStateRepositoryProvider)
                                  .setHave(item.key, have: false),
                            ),
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _WeeklyRow extends StatelessWidget {
  const _WeeklyRow({required this.item, required this.onToggle});

  final WeeklyItem item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = item.have;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: AppSpacing.brMd,
        child: InkWell(
          onTap: onToggle,
          borderRadius: AppSpacing.brMd,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Opacity(
                  opacity: muted ? 0.5 : 1,
                  child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          decoration: muted ? TextDecoration.lineThrough : null,
                          color: muted ? theme.colorScheme.onSurfaceVariant : null,
                        ),
                      ),
                      if (item.quantityLabel.isNotEmpty || item.recipes.length > 1)
                        Text(
                          [
                            if (item.quantityLabel.isNotEmpty) item.quantityLabel,
                            if (item.recipes.length > 1)
                              'Para: ${item.recipesLabel}',
                          ].join('  ·  '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                AppSpacing.gapSm,
                Icon(
                  muted
                      ? Symbols.check_circle_rounded
                      : Symbols.radio_button_unchecked_rounded,
                  fill: muted ? 1 : 0,
                  color: muted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🗓️', style: TextStyle(fontSize: 44)),
            AppSpacing.gapLg,
            Text('Nada planeado todavía', style: theme.textTheme.titleMedium),
            AppSpacing.gapSm,
            Text(
              'Marca la estrella en las recetas que\nvas a cocinar esta semana y su lista\nde compras aparecerá aquí.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
