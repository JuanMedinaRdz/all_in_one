import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../application/todo_providers.dart';
import '../../data/todo.dart';
import '../../domain/todo_category.dart';

/// La franja "Time lapse de hoy": las tareas con hora, colocadas en un eje del
/// día como bloques de color, con la línea de "ahora" y cuánto falta.
class TimeLapseStrip extends StatelessWidget {
  const TimeLapseStrip({
    super.key,
    required this.data,
    required this.onTapTask,
  });

  final TimeLapse data;
  final ValueChanged<Todo> onTapTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    final nowInRange = nowMin >= data.startMin && nowMin <= data.endMin;

    return SoftCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      radius: AppSpacing.brMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Time lapse de hoy', style: theme.textTheme.titleSmall),
              const Spacer(),
              if (data.remainingMinutes > 0)
                Text(
                  'Restante ${Fmt.duration(data.remainingMinutes)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          AppSpacing.gapMd,
          if (data.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(
                'Pon hora a tus tareas para verlas aquí en el día.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else ...[
            SizedBox(
              height: 40,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  double x(int minute) =>
                      ((minute - data.startMin) / data.span * w).clamp(0.0, w);

                  return Stack(
                    children: [
                      // Fondo del eje.
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: AppSpacing.brSm,
                          ),
                        ),
                      ),
                      // Bloques de tareas.
                      for (final t in data.tasks)
                        Positioned(
                          left: x(t.startMinutes!) + 2,
                          top: 4,
                          bottom: 4,
                          width: (x(t.endMinutes!) - x(t.startMinutes!) - 4)
                              .clamp(6.0, w),
                          child: _Block(todo: t, onTap: () => onTapTask(t)),
                        ),
                      // Línea de "ahora".
                      if (nowInRange)
                        Positioned(
                          left: x(nowMin),
                          top: -2,
                          bottom: -2,
                          child: Container(
                            width: 2,
                            color: theme.colorScheme.error,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            AppSpacing.gapSm,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(Fmt.clock(data.startMin),
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                if (nowInRange)
                  Text('Ahora ${Fmt.clock(nowMin)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w600)),
                Text(Fmt.clock(data.endMin),
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.todo, required this.onTap});

  final Todo todo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = TodoCategory.colorFor(todo.category);
    return Material(
      color: color.withValues(alpha: 0.9),
      borderRadius: AppSpacing.brSm,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              todo.displayTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
