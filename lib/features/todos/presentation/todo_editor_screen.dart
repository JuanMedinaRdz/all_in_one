import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/debouncer.dart';
import '../../../core/utils/formatters.dart';
import '../application/todo_providers.dart';
import '../data/todo.dart';
import '../domain/todo_category.dart';
import '../domain/todo_status.dart';
import 'widgets/breakpoint_tile.dart';
import 'widgets/breakpoint_track.dart';

/// Detalle y edición de una tarea: progreso, horario, breakpoints y notas.
/// Guarda con debounce (como el resto de la app). Si sales sin llenar nada, se
/// borra sola (se creó con el botón "+").
class TodoEditorScreen extends ConsumerStatefulWidget {
  const TodoEditorScreen({super.key, required this.todoId});

  final String todoId;

  @override
  ConsumerState<TodoEditorScreen> createState() => _TodoEditorScreenState();
}

class _TodoEditorScreenState extends ConsumerState<TodoEditorScreen> {
  final _debouncer = Debouncer();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();
  final _newBreakpointController = TextEditingController();

  Todo? _todo;
  bool _initialized = false;
  final _breakpointKeys = <Key>[];

  Todo? get _current => _todo ?? ref.read(todoProvider(widget.todoId)).value;

  @override
  void dispose() {
    _debouncer.flush();
    _debouncer.dispose();
    _titleController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    _newBreakpointController.dispose();
    super.dispose();
  }

  void _initFrom(Todo todo) {
    if (_initialized) return;
    _initialized = true;
    _titleController.text = todo.title;
    _categoryController.text = todo.category;
    _notesController.text = todo.notes;
    _breakpointKeys
      ..clear()
      ..addAll(List.generate(todo.breakpoints.length, (_) => UniqueKey()));
  }

  void _update(Todo updated, {bool immediate = false}) {
    setState(() => _todo = updated);
    final repo = ref.read(todoRepositoryProvider);
    if (immediate) {
      repo.save(updated);
    } else {
      _debouncer.run(() => repo.save(updated));
    }
  }

  // --- Breakpoints ---
  void _addBreakpoint([String title = '']) {
    final todo = _current;
    if (todo == null) return;
    setState(() => _breakpointKeys.add(UniqueKey()));
    _update(
      todo.copyWith(breakpoints: [
        ...todo.breakpoints,
        Breakpoint(id: const Uuid().v4(), title: title),
      ]),
      immediate: true,
    );
  }

  void _replaceBreakpoint(int index, Breakpoint value, {bool immediate = false}) {
    final todo = _current;
    if (todo == null) return;
    final list = [...todo.breakpoints];
    if (index >= list.length) return;
    list[index] = value;
    _update(todo.copyWith(breakpoints: list), immediate: immediate);
  }

  /// Marcar/desmarcar un paso: actualización inmediata (el check y la barra
  /// deben responder al instante).
  void _toggleDone(int index) {
    final todo = _current;
    if (todo == null || index >= todo.breakpoints.length) return;
    HapticFeedback.selectionClick();
    final b = todo.breakpoints[index];
    _replaceBreakpoint(index, b.copyWith(done: !b.done), immediate: true);
  }

  /// Arrastrar/tocar la barra: marca hechos los primeros [done] pasos (en
  /// orden) y deja el resto pendientes. Así la barra "crece" directamente.
  void _seekProgress(int done) {
    final todo = _current;
    if (todo == null) return;
    var marked = 0;
    final list = <Breakpoint>[
      for (final b in todo.breakpoints)
        if (b.isEmpty)
          b
        else
          b.copyWith(done: marked++ < done),
    ];
    HapticFeedback.selectionClick();
    _update(todo.copyWith(breakpoints: list), immediate: true);
  }

  void _removeBreakpoint(int index) {
    final todo = _current;
    if (todo == null) return;
    final list = [...todo.breakpoints]..removeAt(index);
    setState(() => _breakpointKeys.removeAt(index));
    _update(todo.copyWith(breakpoints: list), immediate: true);
  }

  void _reorderBreakpoints(int oldIndex, int newIndex) {
    final todo = _current;
    if (todo == null) return;
    // `onReorderItem` ya entrega el índice destino compensado.
    final list = [...todo.breakpoints];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    setState(() {
      final key = _breakpointKeys.removeAt(oldIndex);
      _breakpointKeys.insert(newIndex, key);
    });
    _update(todo.copyWith(breakpoints: list), immediate: true);
  }

  // --- Datos ---
  void _setStatus(TodoStatus s) {
    final todo = _current;
    if (todo != null) {
      HapticFeedback.selectionClick();
      _update(todo.copyWith(status: s), immediate: true);
    }
  }

  Future<void> _pickDate() async {
    final todo = _current;
    if (todo == null) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: todo.date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      locale: const Locale('es', 'MX'),
    );
    if (picked != null) {
      _update(todo.copyWith(date: DateTime(picked.year, picked.month, picked.day)),
          immediate: true);
    }
  }

  void _clearDate() {
    final todo = _current;
    if (todo != null) _update(todo.copyWith(date: null), immediate: true);
  }

  Future<void> _pickStart() async {
    final todo = _current;
    if (todo == null) return;
    final initial = todo.startMinutes ?? 9 * 60;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    );
    if (picked != null) {
      _update(todo.copyWith(startMinutes: picked.hour * 60 + picked.minute),
          immediate: true);
    }
  }

  Future<void> _confirmDelete() async {
    final todo = _current;
    if (todo == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar "${todo.displayTitle}"?'),
        content: const Text('No se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    _debouncer.dispose();
    await ref.read(todoRepositoryProvider).delete(todo.id);
    if (mounted) context.pop();
  }

  Future<void> _onExit() async {
    _debouncer.flush();
    final todo = _current;
    if (todo != null && todo.isBlank) {
      await ref.read(todoRepositoryProvider).delete(todo.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final async = ref.watch(todoProvider(widget.todoId));

    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('No pude abrir la tarea: $e')),
      ),
      data: (remote) {
        if (remote == null && _todo == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Esta tarea ya no existe.')),
          );
        }
        _initFrom(remote ?? _todo!);
        final todo = _current!;
        final accent = TodoCategory.colorFor(todo.category);

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) _onExit();
          },
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  title: Text(todo.status.label),
                  actions: [
                    IconButton(
                      onPressed: _confirmDelete,
                      icon: const Icon(Symbols.delete_rounded),
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
                  sliver: SliverList.list(
                    children: [
                      // Encabezado: progreso circular + título + horario.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ProgressRing(
                            done: todo.doneSteps,
                            total: todo.totalSteps,
                            color: accent,
                          ),
                          AppSpacing.gapLg,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _titleController,
                                  textCapitalization: TextCapitalization.sentences,
                                  style: theme.textTheme.titleLarge,
                                  decoration: const InputDecoration(
                                    hintText: 'Título de la tarea',
                                    isDense: true,
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (v) =>
                                      _update(todo.copyWith(title: v)),
                                ),
                                if (todo.startMinutes != null)
                                  Text(
                                    '${Fmt.clock(todo.startMinutes!)} — ${Fmt.clock(todo.endMinutes!)}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
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
                          height: 28,
                          onSeek: _seekProgress,
                        ),
                        AppSpacing.gapXs,
                        Text(
                          'Arrastra la barra o marca los pasos para avanzar',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      AppSpacing.gapLg,
                      // Estado (columna)
                      _StatusSelector(current: todo.status, onSelect: _setStatus),
                      AppSpacing.gapLg,
                      // Fecha (para que aparezca en el Calendario)
                      _MetaButton(
                        icon: Symbols.event_rounded,
                        label: 'Fecha (aparece en el calendario)',
                        value: todo.date == null
                            ? 'Sin fecha'
                            : Fmt.dayMonth(todo.date!),
                        onTap: _pickDate,
                        onClear: todo.date == null ? null : _clearDate,
                      ),
                      AppSpacing.gapMd,
                      // Horario
                      Row(
                        children: [
                          Expanded(
                            child: _MetaButton(
                              icon: Symbols.schedule_rounded,
                              label: 'Inicio',
                              value: todo.startMinutes == null
                                  ? 'Sin hora'
                                  : Fmt.clock(todo.startMinutes!),
                              onTap: _pickStart,
                            ),
                          ),
                          AppSpacing.gapMd,
                          Expanded(
                            child: _DurationButton(
                              value: todo.durationMinutes,
                              onSelected: (v) => _update(
                                  todo.copyWith(durationMinutes: v),
                                  immediate: true),
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.gapLg,
                      // Categoría
                      _CategoryField(
                        controller: _categoryController,
                        onChanged: (v) => _update(todo.copyWith(category: v)),
                        onPick: (label) {
                          _categoryController.text = label;
                          _update(todo.copyWith(category: label),
                              immediate: true);
                        },
                      ),
                      AppSpacing.gapXl,
                      // Breakpoints
                      Row(
                        children: [
                          Text('Breakpoints', style: theme.textTheme.titleMedium),
                          AppSpacing.gapSm,
                          if (todo.totalSteps > 0)
                            Text(
                              '${todo.doneSteps}/${todo.totalSteps}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          const Spacer(),
                          Text(
                            'Mantén presionado para mover',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.gapSm,
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: true,
                        itemCount: todo.breakpoints.length,
                        onReorderItem: _reorderBreakpoints,
                        itemBuilder: (context, i) => Padding(
                          key: _breakpointKeys[i],
                          padding: EdgeInsets.zero,
                          child: BreakpointTile(
                            value: todo.breakpoints[i],
                            clockMinutes: todo.breakpointClock(i),
                            accent: accent,
                            onToggleDone: () => _toggleDone(i),
                            onDurationChanged: (v) => _replaceBreakpoint(
                                i, todo.breakpoints[i].copyWith(durationMinutes: v),
                                immediate: true),
                            onTitleChanged: (v) => _replaceBreakpoint(
                                i, todo.breakpoints[i].copyWith(title: v)),
                            onDetailChanged: (v) => _replaceBreakpoint(
                                i, todo.breakpoints[i].copyWith(detail: v)),
                            onRemove: () => _removeBreakpoint(i),
                          ),
                        ),
                      ),
                      // Agregar breakpoint
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _newBreakpointController,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: const InputDecoration(
                                hintText: 'Agregar breakpoint o detalle...',
                                isDense: true,
                              ),
                              onSubmitted: (v) {
                                if (v.trim().isEmpty) return;
                                _addBreakpoint(v.trim());
                                _newBreakpointController.clear();
                              },
                            ),
                          ),
                          AppSpacing.gapSm,
                          IconButton.filledTonal(
                            onPressed: () {
                              final v = _newBreakpointController.text.trim();
                              _addBreakpoint(v);
                              _newBreakpointController.clear();
                            },
                            icon: const Icon(Symbols.add_rounded),
                          ),
                        ],
                      ),
                      AppSpacing.gapXl,
                      // Notas
                      Text('Notas', style: theme.textTheme.titleMedium),
                      AppSpacing.gapSm,
                      TextField(
                        controller: _notesController,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                        minLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Notas de la tarea...',
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.brMd,
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (v) => _update(todo.copyWith(notes: v)),
                      ),
                    ],
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

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.done, required this.total, required this.color});

  final int done;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = total == 0 ? 0.0 : done / total;
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 5,
              backgroundColor:
                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          Text(
            total == 0 ? '0' : '$done/$total',
            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({required this.current, required this.onSelect});

  final TodoStatus current;
  final ValueChanged<TodoStatus> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        children: [
          for (final s in TodoStatus.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(s),
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: current == s
                        ? s.color.withValues(alpha: 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    s.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: current == s
                          ? s.color
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MetaButton extends StatelessWidget {
  const _MetaButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  /// Si se da y hay valor, muestra una "x" para quitarlo (p. ej. la fecha).
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      borderRadius: AppSpacing.brMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.brMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              AppSpacing.gapSm,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                    Text(value, style: theme.textTheme.titleSmall),
                  ],
                ),
              ),
              if (onClear != null)
                InkWell(
                  onTap: onClear,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close_rounded,
                        size: 16, color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationButton extends StatelessWidget {
  const _DurationButton({required this.value, required this.onSelected});

  final int value;
  final ValueChanged<int> onSelected;

  static const _durations = [15, 30, 45, 60, 90, 120, 180, 240];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<int>(
      initialValue: value,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final d in _durations)
          PopupMenuItem(value: d, child: Text(Fmt.duration(d))),
      ],
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: AppSpacing.brMd,
        ),
        child: Row(
          children: [
            Icon(Symbols.timelapse_rounded,
                size: 18, color: theme.colorScheme.primary),
            AppSpacing.gapSm,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Duración',
                      style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
                  Text(Fmt.duration(value), style: theme.textTheme.titleSmall),
                ],
              ),
            ),
            Icon(Symbols.expand_more_rounded,
                size: 18, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.controller,
    required this.onChanged,
    required this.onPick,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: 'Categoría',
            isDense: true,
            filled: true,
            fillColor:
                theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            border: OutlineInputBorder(
              borderRadius: AppSpacing.brMd,
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: onChanged,
        ),
        AppSpacing.gapSm,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final c in TodoCategory.presets)
              GestureDetector(
                onTap: () => onPick(c.label),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 6),
                  decoration: BoxDecoration(
                    color: c.color.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text(
                    c.label,
                    style: TextStyle(
                        color: c.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
