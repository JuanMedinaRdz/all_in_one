import '../../features/finance/data/debt.dart';
import '../../features/finance/data/payment.dart';
import '../../features/finance/domain/payment_schedule.dart';
import '../../features/notes/data/note.dart';
import '../utils/formatters.dart';
import 'notification_service.dart';

/// Arma la lista de recordatorios a programar a partir de los datos. Puro y
/// testeable: no toca el plugin de notificaciones ni Firestore.
abstract final class ReminderPlanner {
  const ReminderPlanner._();

  /// Hora del aviso "del día".
  static const _dayOfHour = 9;

  /// Hora del aviso "un día antes" (por la tarde).
  static const _dayBeforeHour = 18;

  static List<Reminder> plan({
    required List<Payment> payments,
    required List<Debt> debts,
    required List<Note> notes,
    DateTime? from,
  }) {
    final now = from ?? DateTime.now();
    final reminders = <Reminder>[];

    for (final p in payments) {
      final date = PaymentSchedule.nextCharge(p.dayOfMonth, from: now);
      _addMoney(
        reminders,
        key: 'pay_${p.id}',
        emoji: '💳',
        name: p.name,
        amount: p.amountMxn,
        date: date,
        verbToday: 'Hoy toca pagar',
      );
    }

    for (final d in debts) {
      final date = d.dueDate;
      if (date == null) continue;
      _addMoney(
        reminders,
        key: 'debt_${d.id}',
        emoji: '💰',
        name: d.name,
        amount: d.balance,
        date: date,
        verbToday: 'Vence hoy',
      );
    }

    for (final n in notes) {
      final date = n.reminderDate;
      if (date == null) continue;
      final title = n.title.trim().isEmpty ? 'Recordatorio' : n.title.trim();
      reminders.add(Reminder(
        id: _id('note_${n.id}_day'),
        title: '📌 $title',
        body: 'Tienes un recordatorio para hoy.',
        when: _at(date, _dayOfHour),
      ));
    }

    return reminders;
  }

  /// Agrega dos avisos para un pago/deuda: uno el día (9:00) y otro la tarde
  /// anterior (18:00), para que dé tiempo de prepararlo.
  static void _addMoney(
    List<Reminder> out, {
    required String key,
    required String emoji,
    required String name,
    required double amount,
    required DateTime date,
    required String verbToday,
  }) {
    out.add(Reminder(
      id: _id('${key}_day'),
      title: '$emoji $name',
      body: '$verbToday · ${Fmt.mxn(amount)}',
      when: _at(date, _dayOfHour),
    ));
    out.add(Reminder(
      id: _id('${key}_prev'),
      title: '$emoji $name — mañana',
      body: 'Prepáralo: ${Fmt.mxn(amount)}',
      when: _at(date, _dayBeforeHour).subtract(const Duration(days: 1)),
    ));
  }

  static DateTime _at(DateTime day, int hour) =>
      DateTime(day.year, day.month, day.day, hour);

  /// Id entero estable y positivo a partir de una clave de texto.
  static int _id(String key) => key.hashCode & 0x7fffffff;
}
