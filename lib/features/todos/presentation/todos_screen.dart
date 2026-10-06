import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

import '../../../core/layout/responsive.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/hover.dart';
import '../../../core/widgets/section_placeholder.dart';
import '../application/todo_providers.dart';
import '../data/todo.dart';
import '../domain/todo_status.dart';
import 'widgets/time_lapse_strip.dart';
import 'widgets/todo_card.dart';
import 'widgets/todo_column.dart';

/// Vista activa dentro de To Do's: 0 = Tablero, 1 = Time Lapse.
class TodosView extends Notifier<int> {
  @override
  int build() => 0;
  void select(int i) => state = i;
}

final todosViewProvider = NotifierProvider<TodosView, int>(TodosView.new);

/// Columna seleccionada en la lista móvil.
class MobileStatus extends Notifier<TodoStatus> {
  @override
  TodoStatus build() => TodoStatus.todo;
  void select(TodoStatus s) => state = s;
}

final mobileStatusProvider =
    NotifierProvider<MobileStatus, TodoStatus>(MobileStatus.new);

/// Sección de tareas: tablero kanban con breakpoints y vista de time lapse.
class TodosScreen extends ConsumerWidget {
  const TodosScreen({super.key});

  /// Crea una tarea vacía (en la columna [status]) y abre su editor.
  static Future<void> createTodo(
    BuildContext context,
    WidgetRef ref, {
    TodoStatus status = TodoStatus.todo,
  }) async {
    final todo = Todo(id: const Uuid().v4(), status: status);
    await ref.read(todoRepositoryProvider).save(todo);
    if (context.mounted) context.go('${AppRoutes.todos}/${todo.id}');
  }

  void _openTodo(BuildContext context, Todo todo) =>
      context.go('${AppRoutes.todos}/${todo.id}');

  void _move(WidgetRef ref, Todo todo, TodoStatus to) {
    if (todo.status == to) return;
    ref.read(todoRepositoryProvider).setStatus(todo.id, to);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boardAsync = ref.watch(todoBoardProvider);
    final view = ref.watch(todosViewProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => createTodo(context, ref),
        tooltip: 'Nueva tarea',
        child: const HoverRotateIcon(Symbols.add_rounded, fill: 1),
      ),
      body: SectionScaffold(
        title: "To Do's",
        subtitle: 'Cada tarea, paso a paso',
        child: switch (boardAsync) {
          AsyncError(:final error) => _Error(error: error),
          AsyncLoading() => const _Loading(),
          AsyncData(value: final board) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Toolbar(
                  view: view,
                  onView: (i) => ref.read(todosViewProvider.notifier).select(i),
                ),
                AppSpacing.gapMd,
                TimeLapseStrip(
                  data: ref.watch(timeLapseProvider),
                  onTapTask: (t) => _openTodo(context, t),
                ),
                AppSpacing.gapLg,
                Expanded(
                  child: board.isEmpty
                      ? _Empty(onAdd: () => createTodo(context, ref))
                      : view == 1
                          ? _TimeLapseView(onTap: (t) => _openTodo(context, t))
                          : LayoutBuilder(
                              builder: (context, c) {
                                final wide =
                                    c.maxWidth >= Breakpoints.expanded;
                                return wide
                                    ? _DesktopBoard(
                                        board: board,
                                        onTap: (t) => _openTodo(context, t),
                                        onAdd: (s) =>
                                            createTodo(context, ref, status: s),
                                        onMove: (t, s) => _move(ref, t, s),
                                      )
                                    : _MobileBoard(
                                        board: board,
                                        onTap: (t) => _openTodo(context, t),
                                        onAdd: (s) =>
                                            createTodo(context, ref, status: s),
                                        onMove: (t, s) => _move(ref, t, s),
                                      );
                              },
                            ),
                ),
              ],
            ),
        },
      ),
    );
  }
}

/// Buscador + interruptor Tablero / Time Lapse.
class _Toolbar extends ConsumerStatefulWidget {
  const _Toolbar({required this.view, required this.onView});

  final int view;
  final ValueChanged<int> onView;

  @override
  ConsumerState<_Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends ConsumerState<_Toolbar> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(todoSearchProvider);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            onChanged: (v) => ref.read(todoSearchProvider.notifier).set(v),
            decoration: InputDecoration(
              hintText: 'Buscar tarea...',
              isDense: true,
              prefixIcon: const Icon(Symbols.search_rounded, size: 20),
              filled: true,
              fillColor:
                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        AppSpacing.gapMd,
        _Segmented(
          options: const ['Tablero', 'Time Lapse'],
          selected: widget.view,
          onSelect: widget.onView,
        ),
      ],
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  final List<String> options;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, label) in options.indexed)
            GestureDetector(
              onTap: () => onSelect(i),
              child: AnimatedContainer(
                duration: AppMotion.fast,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: selected == i ? theme.colorScheme.surface : null,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected == i
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Tablero de escritorio: tres columnas lado a lado con drag & drop.
class _DesktopBoard extends StatelessWidget {
  const _DesktopBoard({
    required this.board,
    required this.onTap,
    required this.onAdd,
    required this.onMove,
  });

  final TodoBoard board;
  final ValueChanged<Todo> onTap;
  final ValueChanged<TodoStatus> onAdd;
  final void Function(Todo, TodoStatus) onMove;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, status) in TodoStatus.values.indexed) ...[
          if (i > 0) AppSpacing.gapLg,
          Expanded(
            child: TodoColumn(
              status: status,
              todos: board.of(status),
              onTapTodo: onTap,
              onAddTodo: () => onAdd(status),
              onMoveTodo: onMove,
            ),
          ),
        ],
      ],
    );
  }
}

/// Lista móvil: segmentos por estado (también zonas para soltar) + una columna.
class _MobileBoard extends ConsumerWidget {
  const _MobileBoard({
    required this.board,
    required this.onTap,
    required this.onAdd,
    required this.onMove,
  });

  final TodoBoard board;
  final ValueChanged<Todo> onTap;
  final ValueChanged<TodoStatus> onAdd;
  final void Function(Todo, TodoStatus) onMove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(mobileStatusProvider);
    final todos = board.of(selected);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (final (i, s) in TodoStatus.values.indexed) ...[
              if (i > 0) AppSpacing.gapSm,
              Expanded(
                child: _StatusChip(
                  status: s,
                  count: board.countOf(s),
                  selected: selected == s,
                  onTap: () => ref.read(mobileStatusProvider.notifier).select(s),
                  onDrop: (todo) => onMove(todo, s),
                ),
              ),
            ],
          ],
        ),
        AppSpacing.gapLg,
        Expanded(
          child: todos.isEmpty
              ? Center(
                  child: Text(
                    'Nada en "${selected.label}".\nArrastra una tarea a otra columna\ndesde su chip de arriba.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: todos.length,
                  separatorBuilder: (_, __) => AppSpacing.gapMd,
                  itemBuilder: (context, i) {
                    final todo = todos[i];
                    final card = TodoCard(todo: todo, onTap: () => onTap(todo));
                    return LongPressDraggable<Todo>(
                      data: todo,
                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          width: MediaQuery.sizeOf(context).width - 48,
                          child: Opacity(opacity: 0.95, child: card),
                        ),
                      ),
                      childWhenDragging: Opacity(opacity: 0.35, child: card),
                      child: card,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatefulWidget {
  const _StatusChip({
    required this.status,
    required this.count,
    required this.selected,
    required this.onTap,
    required this.onDrop,
  });

  final TodoStatus status;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final ValueChanged<Todo> onDrop;

  @override
  State<_StatusChip> createState() => _StatusChipState();
}

class _StatusChipState extends State<_StatusChip> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = widget.status;

    return DragTarget<Todo>(
      onWillAcceptWithDetails: (d) {
        final incoming = d.data.status != s;
        if (incoming) setState(() => _hovering = true);
        return incoming;
      },
      onLeave: (_) => setState(() => _hovering = false),
      onAcceptWithDetails: (d) {
        setState(() => _hovering = false);
        widget.onDrop(d.data);
      },
      builder: (context, candidate, rejected) {
        final active = widget.selected || _hovering;
        return GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AppMotion.fast,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: _hovering
                  ? s.color.withValues(alpha: 0.18)
                  : widget.selected
                      ? s.color.withValues(alpha: 0.12)
                      : theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              border: Border.all(
                color: _hovering ? s.color : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  s.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: active ? s.color : theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${widget.count}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: active ? s.color : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Vista Time Lapse: las tareas con hora, en orden cronológico, con su hora al
/// lado (una agenda del día).
class _TimeLapseView extends ConsumerWidget {
  const _TimeLapseView({required this.onTap});

  final ValueChanged<Todo> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(timeLapseProvider);
    final theme = Theme.of(context);

    if (data.isEmpty) {
      return Center(
        child: Text(
          'Ninguna tarea con hora todavía.\nPonle hora a una tarea para verla en la agenda.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return ContentBounds(
      maxWidth: 720,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: data.tasks.length,
        separatorBuilder: (_, __) => AppSpacing.gapMd,
        itemBuilder: (context, i) {
          final todo = data.tasks[i];
          return TodoCard(todo: todo, onTap: () => onTap(todo))
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 40 * i),
                duration: AppMotion.medium,
              )
              .slideY(begin: 0.06, end: 0, curve: AppMotion.emphasized);
        },
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

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

class _Empty extends StatelessWidget {
  const _Empty({required this.onAdd});

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
              color:
                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: const Text('✅', style: TextStyle(fontSize: 40)),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1, end: 1.06, duration: 2400.ms, curve: Curves.easeInOut),
          AppSpacing.gapXl,
          Text('Sin tareas por ahora', style: theme.textTheme.titleMedium),
          AppSpacing.gapSm,
          Text(
            'Crea una tarea y divídela en breakpoints:\npasos con su hora y duración.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.gapXl,
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Symbols.add_rounded),
            label: const Text('Crear mi primera tarea'),
          ),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.error});

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
              Text('No pude cargar tus tareas', style: theme.textTheme.titleMedium),
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
