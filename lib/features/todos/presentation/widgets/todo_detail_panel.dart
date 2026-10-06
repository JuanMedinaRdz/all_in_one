import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/tacita.dart';
import '../../application/todo_providers.dart';
import '../../data/todo.dart';
import '../../domain/todo_category.dart';
import '../../domain/todo_status.dart';
import 'breakpoint_track.dart';

/// Panel de "Detalles de tarea" del dashboard del calendario: muestra la tarea
/// enfocada con su progreso y breakpoints marcables, acompañada de Tacita (que
/// celebra al cerrar un paso). Para editar a fondo está el botón del editor.
class TodoDetailPanel extends ConsumerStatefulWidget {
  const TodoDetailPanel({
    super.key,
    required this.todo,
    required this.onOpen,
  });

  final Todo? todo;
  final VoidCallback onOpen;

  @override
  ConsumerState<TodoDetailPanel> createState() => _TodoDetailPanelState();
}

class _TodoDetailPanelState extends ConsumerState<TodoDetailPanel> {
  bool _celebrate = false;
  Timer? _celebrateTimer;

  @override
  void dispose() {
    _celebrateTimer?.cancel();
    super.dispose();
  }

  void _toggle(Todo t, String breakpointId) {
    // Si el paso pasa a "hecho", Tacita celebra un momento.
    final wasDone =
        t.breakpoints.firstWhere((b) => b.id == breakpointId).done;
    ref.read(todoRepositoryProvider).toggleBreakpoint(t, breakpointId);
    if (!wasDone) _party();
  }

  void _seek(Todo t, int done) {
    final before = t.doneSteps;
    var marked = 0;
    final list = [
      for (final b in t.breakpoints)
        if (b.isEmpty) b else b.copyWith(done: marked++ < done),
    ];
    ref.read(todoRepositoryProvider).save(t.copyWith(breakpoints: list));
    if (done > before) _party();
  }

  /// Dispara la celebración de Tacita por ~2 ciclos de hop y vuelve sola.
  void _party() {
    setState(() => _celebrate = true);
    _celebrateTimer?.cancel();
    _celebrateTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) setState(() => _celebrate = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = widget.todo;

    final mood = _celebrate
        ? TacitaState.celebrate
        : (t?.status == TodoStatus.doing ? TacitaState.focus : TacitaState.idle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (t != null) ...[
              TacitaMascot(state: mood, size: 36),
              AppSpacing.gapSm,
            ],
            Text('Detalles de tarea', style: theme.textTheme.titleMedium),
            const Spacer(),
            if (t != null)
              IconButton(
                onPressed: widget.onOpen,
                tooltip: 'Abrir en el editor',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Symbols.open_in_full_rounded, size: 18),
              ),
          ],
        ),
        AppSpacing.gapMd,
        Expanded(
          child: t == null
              ? _Placeholder()
              : _Body(
                  todo: t,
                  onToggle: (id) => _toggle(t, id),
                  onSeek: (done) => _seek(t, done),
                  onOpen: widget.onOpen,
                ),
        ),
      ],
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.todo,
    required this.onToggle,
    required this.onSeek,
    required this.onOpen,
  });

  final Todo todo;
  final ValueChanged<String> onToggle;
  final ValueChanged<int> onSeek;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = TodoCategory.colorFor(todo.category);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _Ring(done: todo.doneSteps, total: todo.totalSteps, color: accent),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.displayTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    AppSpacing.gapXs,
                    Row(
                      children: [
                        if (todo.category.trim().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm, vertical: 2),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.18),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusPill),
                            ),
                            child: Text(
                              todo.category.trim(),
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: accent),
                            ),
                          ),
                        if (todo.startMinutes != null) ...[
                          AppSpacing.gapSm,
                          Text(
                            Fmt.clock(todo.startMinutes!),
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (todo.totalSteps > 0) ...[
            AppSpacing.gapLg,
            BreakpointTrack(
              total: todo.totalSteps,
              done: todo.doneSteps,
              color: accent,
              onSeek: onSeek,
            ),
          ],
          AppSpacing.gapLg,
          Row(
            children: [
              Text('Breakpoints', style: theme.textTheme.titleSmall),
              AppSpacing.gapSm,
              if (todo.totalSteps > 0)
                Text('${todo.doneSteps}/${todo.totalSteps}',
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
          AppSpacing.gapSm,
          if (todo.totalSteps == 0)
            Text(
              'Esta tarea aún no tiene pasos. Ábrela para agregarlos.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            )
          else
            for (var i = 0; i < todo.breakpoints.length; i++)
              if (!todo.breakpoints[i].isEmpty)
                _BreakpointRow(
                  bp: todo.breakpoints[i],
                  clockMinutes: todo.breakpointClock(i),
                  accent: accent,
                  onToggle: () => onToggle(todo.breakpoints[i].id),
                ),
          if (todo.notes.trim().isNotEmpty) ...[
            AppSpacing.gapLg,
            Text('Notas', style: theme.textTheme.titleSmall),
            AppSpacing.gapSm,
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                borderRadius: AppSpacing.brMd,
              ),
              child: Text(todo.notes.trim(), style: theme.textTheme.bodySmall),
            ),
          ],
          AppSpacing.gapLg,
          FilledButton.tonalIcon(
            onPressed: onOpen,
            icon: const Icon(Symbols.edit_rounded, size: 18),
            label: const Text('Abrir en el editor'),
          ),
        ],
      ),
    );
  }
}

class _BreakpointRow extends StatelessWidget {
  const _BreakpointRow({
    required this.bp,
    required this.clockMinutes,
    required this.accent,
    required this.onToggle,
  });

  final Breakpoint bp;
  final int? clockMinutes;
  final Color accent;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onToggle,
      borderRadius: AppSpacing.brSm,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              bp.done
                  ? Symbols.check_circle_rounded
                  : Symbols.radio_button_unchecked_rounded,
              fill: bp.done ? 1 : 0,
              size: 20,
              color: bp.done ? accent : theme.colorScheme.outline,
            ),
            AppSpacing.gapSm,
            Expanded(
              child: Text(
                bp.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  decoration: bp.done ? TextDecoration.lineThrough : null,
                  color: bp.done ? theme.colorScheme.onSurfaceVariant : null,
                ),
              ),
            ),
            if (clockMinutes != null)
              Text(Fmt.clock(clockMinutes!),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.done, required this.total, required this.color});

  final int done;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = total == 0 ? 0.0 : done / total;
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              backgroundColor:
                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(total == 0 ? '0' : '$done/$total',
              style: theme.textTheme.labelSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Estado vacío con una taza de café humeante (toque de cafetería): cuando el
/// día elegido no tiene ninguna tarea agendada.
class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TacitaMascot(state: TacitaState.sleep, size: 96),
          AppSpacing.gapMd,
          Text(
            'Nada agendado este día',
            style: theme.textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          AppSpacing.gapXs,
          Text(
            'Tacita está descansando 😴\nElige un día con una tarea y su ficha\nse desplegará aquí.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
