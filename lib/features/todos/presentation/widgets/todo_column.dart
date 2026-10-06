import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/hover.dart';
import '../../../../core/widgets/tacita.dart';
import '../../data/todo.dart';
import '../../domain/todo_status.dart';
import 'todo_card.dart';

/// Una columna del tablero (Por hacer / En progreso / Hecho). Recibe tareas
/// arrastradas desde otras columnas (drag & drop) y las mueve a su estado.
class TodoColumn extends StatefulWidget {
  const TodoColumn({
    super.key,
    required this.status,
    required this.todos,
    required this.onTapTodo,
    required this.onAddTodo,
    required this.onMoveTodo,
    this.longPressToDrag = false,
  });

  final TodoStatus status;
  final List<Todo> todos;
  final ValueChanged<Todo> onTapTodo;
  final VoidCallback onAddTodo;
  final void Function(Todo todo, TodoStatus to) onMoveTodo;

  /// En móvil se arrastra con pulsación larga; en escritorio, directo.
  final bool longPressToDrag;

  @override
  State<TodoColumn> createState() => _TodoColumnState();
}

class _TodoColumnState extends State<TodoColumn> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final status = widget.status;

    return DragTarget<Todo>(
      onWillAcceptWithDetails: (details) {
        final incoming = details.data.status != status;
        if (incoming) setState(() => _hovering = true);
        return incoming;
      },
      onLeave: (_) => setState(() => _hovering = false),
      onAcceptWithDetails: (details) {
        setState(() => _hovering = false);
        widget.onMoveTodo(details.data, status);
      },
      builder: (context, candidate, rejected) {
        return AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: _hovering
                ? status.color.withValues(alpha: 0.10)
                : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: AppSpacing.brLg,
            border: Border.all(
              color: _hovering
                  ? status.color.withValues(alpha: 0.6)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado de la columna.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration:
                          BoxDecoration(color: status.color, shape: BoxShape.circle),
                    ),
                    AppSpacing.gapSm,
                    Text(status.label, style: theme.textTheme.titleSmall),
                    const Spacer(),
                    Text(
                      '${widget.todos.length}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: widget.todos.isEmpty
                    ? _EmptyHint(hovering: _hovering, status: status)
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        itemCount: widget.todos.length,
                        separatorBuilder: (_, __) => AppSpacing.gapMd,
                        itemBuilder: (context, i) =>
                            _draggable(widget.todos[i]),
                      ),
              ),
              AppSpacing.gapSm,
              TextButton.icon(
                onPressed: widget.onAddTodo,
                icon: const HoverRotateIcon(Symbols.add_rounded, size: 18),
                label: const Text('Agregar tarea'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _draggable(Todo todo) {
    final card = TodoCard(
      todo: todo,
      onTap: () => widget.onTapTodo(todo),
      showNext: false,
    );

    final feedback = Material(
      color: Colors.transparent,
      child: SizedBox(width: 260, child: Opacity(opacity: 0.95, child: card)),
    );

    final placeholder = Opacity(opacity: 0.35, child: card);

    if (widget.longPressToDrag) {
      return LongPressDraggable<Todo>(
        data: todo,
        feedback: feedback,
        childWhenDragging: placeholder,
        child: card,
      );
    }
    return Draggable<Todo>(
      data: todo,
      feedback: feedback,
      childWhenDragging: placeholder,
      child: card,
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.hovering, required this.status});

  final bool hovering;
  final TodoStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // La columna "Hecho" vacía: Tacita dormidita.
    final sleepy = status == TodoStatus.done && !hovering;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sleepy) ...[
              const TacitaMascot(state: TacitaState.sleep, size: 72),
              AppSpacing.gapSm,
            ],
            Text(
              hovering
                  ? 'Suelta aquí'
                  : status == TodoStatus.done
                      ? 'Aún nada hecho…\n¡pronto!'
                      : 'Arrastra tareas aquí',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    hovering ? status.color : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
