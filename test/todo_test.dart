import 'package:all_in_one/features/todos/application/todo_providers.dart';
import 'package:all_in_one/features/todos/data/todo.dart';
import 'package:all_in_one/features/todos/domain/todo_status.dart';
import 'package:flutter_test/flutter_test.dart';

Breakpoint bp(String title, {int min = 15, bool done = false}) =>
    Breakpoint(id: title, title: title, durationMinutes: min, done: done);

void main() {
  group('Todo · progreso por breakpoints', () {
    final todo = Todo(
      id: 't1',
      title: 'Preparar presentación',
      startMinutes: 9 * 60, // 9:00
      breakpoints: [
        bp('Reunir datos', min: 10, done: true),
        bp('Crear diapositivas', min: 20, done: true),
        bp('Revisar con equipo', min: 15),
        bp('', min: 5), // vacío: se ignora
      ],
    );

    test('cuenta pasos reales (ignora vacíos)', () {
      expect(todo.totalSteps, 3);
      expect(todo.doneSteps, 2);
    });

    test('progreso = hechos / total', () {
      expect(todo.progress, closeTo(2 / 3, 1e-9));
    });

    test('suma minutos totales y hechos', () {
      expect(todo.totalMinutes, 45); // 10 + 20 + 15
      expect(todo.doneMinutes, 30); // 10 + 20
    });

    test('siguiente breakpoint es el primero sin terminar', () {
      expect(todo.nextBreakpoint?.title, 'Revisar con equipo');
    });

    test('la hora de cada paso encadena las duraciones desde el inicio', () {
      expect(todo.breakpointClock(0), 9 * 60 + 10); // 9:10
      expect(todo.breakpointClock(1), 9 * 60 + 30); // 9:30
      expect(todo.breakpointClock(2), 9 * 60 + 45); // 9:45
    });

    test('sin hora de inicio no calcula reloj', () {
      final noStart = todo.copyWith(startMinutes: null);
      expect(noStart.breakpointClock(0), isNull);
    });
  });

  group('Todo · progreso sin breakpoints', () {
    test('usa el estado: hecho = 1, si no 0', () {
      expect(const Todo(id: 'a').progress, 0);
      expect(const Todo(id: 'b', status: TodoStatus.done).progress, 1);
    });
  });

  group('TodoBoard', () {
    final todos = [
      const Todo(id: '1', title: 'A', status: TodoStatus.todo),
      const Todo(id: '2', title: 'B', status: TodoStatus.doing),
      const Todo(id: '3', title: 'C', status: TodoStatus.done),
      const Todo(id: '4', title: 'D', status: TodoStatus.todo),
    ];

    test('agrupa por columna', () {
      final board = TodoBoard.from(todos);
      expect(board.countOf(TodoStatus.todo), 2);
      expect(board.countOf(TodoStatus.doing), 1);
      expect(board.countOf(TodoStatus.done), 1);
      expect(board.total, 4);
    });

    test('el buscador filtra por título y categoría', () {
      final board = TodoBoard.from([
        const Todo(id: '1', title: 'Llamar cliente', category: 'Trabajo'),
        const Todo(id: '2', title: 'Comprar regalo', category: 'Personal'),
      ], query: 'trab');
      expect(board.total, 1);
      expect(board.of(TodoStatus.todo).single.title, 'Llamar cliente');
    });

    test('ordena por sortIndex antes que por hora', () {
      final board = TodoBoard.from([
        const Todo(id: '1', title: 'Segunda', sortIndex: 2, startMinutes: 60),
        const Todo(id: '2', title: 'Primera', sortIndex: 1, startMinutes: 600),
      ]);
      final col = board.of(TodoStatus.todo);
      expect(col.map((t) => t.title).toList(), ['Primera', 'Segunda']);
    });
  });

  group('Todo · isBlank', () {
    test('vacía cuando no hay título, notas ni pasos', () {
      expect(const Todo(id: 'x').isBlank, isTrue);
      expect(const Todo(id: 'y', title: 'Algo').isBlank, isFalse);
    });
  });
}
