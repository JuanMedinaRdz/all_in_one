import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../data/todo.dart';
import '../../domain/todo_category.dart';
import 'breakpoint_track.dart';

/// Tarjeta de una tarea: categoría, horario, la barra de breakpoints y el
/// progreso por pasos. Se usa igual en el tablero (escritorio) y en la lista
/// (móvil).
class TodoCard extends StatelessWidget {
  const TodoCard({
    super.key,
    required this.todo,
    required this.onTap,
    this.showNext = true,
  });

  final Todo todo;
  final VoidCallback onTap;

  /// Muestra "siguiente: el paso" bajo la barra (útil en la lista móvil).
  final bool showNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = TodoCategory.colorFor(todo.category);
    final next = todo.nextBreakpoint;

    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      radius: AppSpacing.brMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            todo.displayTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          AppSpacing.gapSm,
          Row(
            children: [
              if (todo.category.trim().isNotEmpty) ...[
                _CategoryChip(label: todo.category.trim(), color: accent),
                AppSpacing.gapSm,
              ],
              if (todo.startMinutes != null)
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Symbols.schedule_rounded,
                          size: 13, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          '${Fmt.clock(todo.startMinutes!)} · ${Fmt.duration(todo.durationMinutes)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (todo.totalSteps > 0) ...[
            AppSpacing.gapMd,
            BreakpointTrack(
              total: todo.totalSteps,
              done: todo.doneSteps,
              color: accent,
            ),
            AppSpacing.gapSm,
            Row(
              children: [
                Expanded(
                  child: Text(
                    showNext && next != null
                        ? '${todo.doneSteps} de ${todo.totalSteps} · sig: ${next.title}'
                        : '${todo.doneSteps} de ${todo.totalSteps} pasos',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  '${todo.doneMinutes}/${todo.totalMinutes} min',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
