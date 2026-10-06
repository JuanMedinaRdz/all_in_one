import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/todo.dart';
import '../data/todo_repository.dart';
import '../domain/todo_status.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository(ref.watch(workspaceCollectionProvider('todos')));
});

/// Todas las tareas en tiempo real. Un solo listener para la sección.
final todosProvider = StreamProvider<List<Todo>>((ref) async* {
  await ref.watch(anonymousSessionProvider.future);
  yield* ref.watch(todoRepositoryProvider).watchAll();
});

/// Una tarea concreta en tiempo real (para el editor/detalle).
final todoProvider = StreamProvider.family<Todo?, String>((ref, id) async* {
  await ref.watch(anonymousSessionProvider.future);
  yield* ref.watch(todoRepositoryProvider).watchOne(id);
});

/// Texto del buscador de tareas.
class TodoSearch extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
}

final todoSearchProvider = NotifierProvider<TodoSearch, String>(TodoSearch.new);

/// Categorías ya usadas, para sugerirlas al crear una tarea.
final todoUsedCategoriesProvider = Provider<List<String>>((ref) {
  final todos = ref.watch(todosProvider).value ?? const [];
  final seen = <String>{};
  final result = <String>[];
  for (final t in todos) {
    final c = t.category.trim();
    if (c.isNotEmpty && seen.add(c.toLowerCase())) result.add(c);
  }
  return result;
});

/// El tablero listo para pintar: tareas agrupadas por columna y ordenadas.
class TodoBoard {
  const TodoBoard({required this.byStatus});

  final Map<TodoStatus, List<Todo>> byStatus;

  List<Todo> of(TodoStatus s) => byStatus[s] ?? const [];
  int countOf(TodoStatus s) => of(s).length;
  int get total => byStatus.values.fold(0, (sum, l) => sum + l.length);
  bool get isEmpty => total == 0;

  factory TodoBoard.from(List<Todo> todos, {String query = ''}) {
    final q = query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? todos
        : todos
            .where((t) =>
                t.title.toLowerCase().contains(q) ||
                t.category.toLowerCase().contains(q))
            .toList();

    int cmp(Todo a, Todo b) {
      // Posición manual primero; luego por hora; luego por recencia.
      final ai = a.sortIndex, bi = b.sortIndex;
      if (ai != null && bi != null && ai != bi) return ai.compareTo(bi);
      if (ai != null && bi == null) return -1;
      if (ai == null && bi != null) return 1;
      final as = a.startMinutes, bs = b.startMinutes;
      if (as != null && bs != null && as != bs) return as.compareTo(bs);
      if (as != null && bs == null) return -1;
      if (as == null && bs != null) return 1;
      final ad = a.createdAt, bd = b.createdAt;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad);
    }

    return TodoBoard(
      byStatus: {
        for (final s in TodoStatus.values)
          s: (filtered.where((t) => t.status == s).toList()..sort(cmp)),
      },
    );
  }
}

final todoBoardProvider = Provider<AsyncValue<TodoBoard>>((ref) {
  final query = ref.watch(todoSearchProvider);
  return ref
      .watch(todosProvider)
      .whenData((todos) => TodoBoard.from(todos, query: query));
});

/// Vista "Time lapse de hoy": las tareas con hora, ordenadas, más cuánto falta.
class TimeLapse {
  const TimeLapse({
    required this.tasks,
    required this.startMin,
    required this.endMin,
    required this.remainingMinutes,
  });

  /// Tareas con hora asignada, ordenadas por inicio.
  final List<Todo> tasks;

  /// Rango del eje (minutos desde medianoche) que cubre el día.
  final int startMin;
  final int endMin;

  /// Minutos por hacer (suma de duraciones de tareas no terminadas).
  final int remainingMinutes;

  bool get isEmpty => tasks.isEmpty;
  int get span => (endMin - startMin).clamp(1, 24 * 60);
}

final timeLapseProvider = Provider<TimeLapse>((ref) {
  final todos = ref.watch(todosProvider).value ?? const [];
  final scheduled = todos.where((t) => t.startMinutes != null).toList()
    ..sort((a, b) => a.startMinutes!.compareTo(b.startMinutes!));

  if (scheduled.isEmpty) {
    return const TimeLapse(
        tasks: [], startMin: 8 * 60, endMin: 20 * 60, remainingMinutes: 0);
  }

  var minStart = scheduled.first.startMinutes!;
  var maxEnd = scheduled.first.endMinutes!;
  for (final t in scheduled) {
    if (t.startMinutes! < minStart) minStart = t.startMinutes!;
    final e = t.endMinutes!;
    if (e > maxEnd) maxEnd = e;
  }
  // Redondea el eje a horas completas para que se lea limpio.
  final startMin = (minStart ~/ 60) * 60;
  final endMin = ((maxEnd + 59) ~/ 60) * 60;

  final remaining = scheduled
      .where((t) => t.status != TodoStatus.done)
      .fold(0, (sum, t) => sum + t.durationMinutes);

  return TimeLapse(
    tasks: scheduled,
    startMin: startMin,
    endMin: endMin,
    remainingMinutes: remaining,
  );
});

/// Tarea "enfocada" en el dashboard del calendario (su id). `null` = ninguna
/// elegida a mano, así que el panel muestra una por defecto.
class FocusedTodo extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? id) => state = id;
}

final focusedTodoProvider =
    NotifierProvider<FocusedTodo, String?>(FocusedTodo.new);
