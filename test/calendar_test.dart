import 'package:all_in_one/features/calendar/application/calendar_providers.dart';
import 'package:all_in_one/features/calendar/domain/calendar_event.dart';
import 'package:all_in_one/features/finance/data/debt.dart';
import 'package:all_in_one/features/finance/data/payment.dart';
import 'package:all_in_one/features/notes/data/note.dart';
import 'package:all_in_one/features/notes/domain/note_enums.dart';
import 'package:all_in_one/features/todos/data/todo.dart';
import 'package:flutter_test/flutter_test.dart';

Payment pay(
  String name,
  double amount,
  int day, {
  String category = 'Streaming',
}) =>
    Payment(
      id: name,
      name: name,
      amountMxn: amount,
      category: category,
      dayOfMonth: day,
    );

CalendarData dataWith({
  List<Payment> payments = const [],
  List<Note> notes = const [],
  List<Debt> debts = const [],
  List<Todo> todos = const [],
}) {
  final byDay = <DateTime, List<Note>>{};
  for (final n in notes) {
    if (n.reminderDate == null) continue;
    byDay.putIfAbsent(dayKey(n.reminderDate!), () => []).add(n);
  }
  final debtsByDay = <DateTime, List<Debt>>{};
  for (final d in debts) {
    if (d.dueDate == null) continue;
    debtsByDay.putIfAbsent(dayKey(d.dueDate!), () => []).add(d);
  }
  final todosByDay = <DateTime, List<Todo>>{};
  for (final t in todos) {
    if (t.date == null) continue;
    todosByDay.putIfAbsent(dayKey(t.date!), () => []).add(t);
  }
  return CalendarData(
    payments: payments,
    notesByDay: byDay,
    debtsByDay: debtsByDay,
    todosByDay: todosByDay,
  );
}

void main() {
  group('CalendarData.chargeDay', () {
    test('un día normal se respeta', () {
      expect(CalendarData.chargeDay(2026, 7, 28), 28);
    });

    test('el día 31 se recorre al último día en meses cortos', () {
      // Sin esto, un pago el 31 desaparecería del calendario en febrero.
      expect(CalendarData.chargeDay(2026, 2, 31), 28);
      expect(CalendarData.chargeDay(2026, 4, 31), 30); // abril tiene 30
      expect(CalendarData.chargeDay(2026, 1, 31), 31); // enero sí tiene 31
    });

    test('respeta los años bisiestos', () {
      expect(CalendarData.chargeDay(2028, 2, 30), 29); // 2028 es bisiesto
      expect(CalendarData.chargeDay(2026, 2, 30), 28);
    });
  });

  group('CalendarData.eventsFor', () {
    test('un pago aparece su día de cobro, mes tras mes', () {
      final data = dataWith(payments: [pay('Spotify', 239, 28)]);

      for (final month in [7, 8, 9]) {
        final events = data.eventsFor(DateTime(2026, month, 28));
        expect(events.length, 1, reason: 'debe repetirse cada mes');
        expect(events.single.title, 'Spotify');
        expect(events.single.subtitle, contains('Streaming'));
        expect(events.single.amountMxn, 239);
      }
    });

    test('el pago no aparece otros días', () {
      final data = dataWith(payments: [pay('Spotify', 239, 28)]);
      expect(data.eventsFor(DateTime(2026, 7, 27)), isEmpty);
      expect(data.eventsFor(DateTime(2026, 7, 29)), isEmpty);
    });

    test('conviven varios pagos y notas el mismo día', () {
      final data = dataWith(
        payments: [
          pay('Spotify', 239, 28),
          pay('Renta', 8000, 28, category: 'Renta'),
        ],
        notes: [
          Note(
            id: 'n1',
            title: 'Ir al dentista',
            reminderDate: DateTime(2026, 7, 28),
          ),
        ],
      );

      final events = data.eventsFor(DateTime(2026, 7, 28));
      expect(events.length, 3);
      // Los cobros van primero; la nota al final.
      expect(events.map((e) => e.title), ['Renta', 'Spotify', 'Ir al dentista']);
      expect(events.last.kind, CalendarEventKind.note);
      expect(events.last.sourceId, 'n1');
    });

    test('una deuda con fecha aparece el día que vence', () {
      final data = dataWith(
        debts: [
          Debt(
            id: 'd1',
            name: 'Tarjeta',
            balance: 4250,
            dueDate: DateTime(2026, 7, 15),
          ),
        ],
      );
      final events = data.eventsFor(DateTime(2026, 7, 15));
      expect(events.single.kind, CalendarEventKind.debt);
      expect(events.single.title, 'Tarjeta');
      // No cuenta para el total de cobros del día (eso son mensualidades).
      expect(data.totalFor(DateTime(2026, 7, 15)), 0);
      expect(data.eventsFor(DateTime(2026, 7, 16)), isEmpty);
    });

    test('el total del día suma solo los cobros, no las notas', () {
      final data = dataWith(
        payments: [pay('Spotify', 239, 28), pay('Netflix', 219, 28)],
        notes: [
          Note(id: 'n1', title: 'Despensa', reminderDate: DateTime(2026, 7, 28)),
        ],
      );

      expect(data.totalFor(DateTime(2026, 7, 28)), 458);
      expect(data.totalFor(DateTime(2026, 7, 27)), 0);
    });

    test('la nota sin fecha nunca aparece en el calendario', () {
      final data = dataWith(notes: [const Note(id: 'n1', title: 'Apunte suelto')]);
      expect(data.eventsFor(DateTime(2026, 7, 28)), isEmpty);
    });

    test('una tarea con fecha aparece ese día y abre su editor', () {
      final data = dataWith(todos: [
        Todo(
          id: 't1',
          title: 'Mejorar calendario',
          category: 'Trabajo',
          startMinutes: 9 * 60,
          date: DateTime(2026, 7, 20),
        ),
      ]);
      final event = data.eventsFor(DateTime(2026, 7, 20)).single;
      expect(event.kind, CalendarEventKind.todo);
      expect(event.title, 'Mejorar calendario');
      expect(event.sourceId, 't1');
      expect(event.subtitle, contains('9:00'));
      // No cuenta para el total de cobros del día.
      expect(data.totalFor(DateTime(2026, 7, 20)), 0);
    });

    test('la tarea sin fecha nunca aparece en el calendario', () {
      final data = dataWith(todos: [const Todo(id: 't1', title: 'Suelta')]);
      expect(data.eventsFor(DateTime(2026, 7, 20)), isEmpty);
    });

    test('la nota usa el color de su relevancia', () {
      final data = dataWith(notes: [
        Note(
          id: 'n1',
          title: 'Despensa',
          status: NoteStatus.inProgress,
          reminderDate: DateTime(2026, 7, 28),
        ),
      ]);

      final event = data.eventsFor(DateTime(2026, 7, 28)).single;
      expect(event.color, NoteStatus.inProgress.color);
      expect(event.subtitle, 'En progreso');
    });

    test('la hora de la fecha no afecta: compara por día', () {
      final data = dataWith(notes: [
        Note(
          id: 'n1',
          title: 'Dentista',
          reminderDate: DateTime(2026, 7, 28, 15, 30),
        ),
      ]);

      expect(data.eventsFor(DateTime(2026, 7, 28)).length, 1);
      expect(data.eventsFor(DateTime(2026, 7, 28, 9)).length, 1);
    });
  });

  group('dayKey', () {
    test('normaliza a medianoche', () {
      expect(dayKey(DateTime(2026, 7, 28, 23, 59)), DateTime(2026, 7, 28));
    });
  });
}
