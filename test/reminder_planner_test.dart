import 'package:all_in_one/core/notifications/reminder_planner.dart';
import 'package:all_in_one/features/finance/data/debt.dart';
import 'package:all_in_one/features/finance/data/payment.dart';
import 'package:all_in_one/features/notes/data/note.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReminderPlanner.plan', () {
    final from = DateTime(2026, 7, 10);

    test('un pago genera dos avisos: el día (9h) y la tarde anterior (18h)', () {
      final reminders = ReminderPlanner.plan(
        from: from,
        payments: [
          Payment(id: 'p1', name: 'Netflix', amountMxn: 219, dayOfMonth: 15),
        ],
        debts: const [],
        notes: const [],
      );

      expect(reminders.length, 2);
      final day = reminders.firstWhere((r) => r.when.hour == 9);
      final prev = reminders.firstWhere((r) => r.when.hour == 18);
      expect(day.when, DateTime(2026, 7, 15, 9));
      expect(prev.when, DateTime(2026, 7, 14, 18));
      expect(day.title, contains('Netflix'));
    });

    test('una deuda sin fecha no genera avisos; con fecha, sí', () {
      final base = {
        'payments': <Payment>[],
        'notes': <Note>[],
      };
      final sinFecha = ReminderPlanner.plan(
        from: from,
        payments: base['payments'] as List<Payment>,
        notes: base['notes'] as List<Note>,
        debts: [Debt(id: 'd1', name: 'Tarjeta', balance: 4250)],
      );
      expect(sinFecha, isEmpty);

      final conFecha = ReminderPlanner.plan(
        from: from,
        payments: const [],
        notes: const [],
        debts: [
          Debt(
            id: 'd1',
            name: 'Tarjeta',
            balance: 4250,
            dueDate: DateTime(2026, 7, 20),
          ),
        ],
      );
      expect(conFecha.length, 2);
    });

    test('una nota con fecha genera un aviso el día', () {
      final reminders = ReminderPlanner.plan(
        from: from,
        payments: const [],
        debts: const [],
        notes: [
          Note(id: 'n1', title: 'Dentista', reminderDate: DateTime(2026, 7, 12)),
        ],
      );
      expect(reminders.length, 1);
      expect(reminders.single.when, DateTime(2026, 7, 12, 9));
      expect(reminders.single.title, contains('Dentista'));
    });

    test('los ids son únicos dentro del lote', () {
      final reminders = ReminderPlanner.plan(
        from: from,
        payments: [
          Payment(id: 'p1', name: 'A', amountMxn: 1, dayOfMonth: 15),
          Payment(id: 'p2', name: 'B', amountMxn: 1, dayOfMonth: 16),
        ],
        debts: [
          Debt(id: 'd1', name: 'C', balance: 1, dueDate: DateTime(2026, 7, 20)),
        ],
        notes: [
          Note(id: 'n1', title: 'D', reminderDate: DateTime(2026, 7, 18)),
        ],
      );
      final ids = reminders.map((r) => r.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });
}
