import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/utils/formatters.dart';
import '../../finance/application/debt_providers.dart';
import '../../finance/application/payment_providers.dart';
import '../../finance/data/debt.dart';
import '../../finance/data/payment.dart';
import '../../finance/domain/payment_schedule.dart';
import '../../notes/application/note_providers.dart';
import '../../notes/data/note.dart';
import '../../todos/application/todo_providers.dart';
import '../../todos/data/todo.dart';
import '../../todos/domain/todo_category.dart';
import '../domain/calendar_event.dart';

/// Todo lo que el calendario necesita, ya listo para consultar por día.
class CalendarData {
  const CalendarData({
    required this.payments,
    required this.notesByDay,
    required this.debtsByDay,
    required this.todosByDay,
  });

  final List<Payment> payments;
  final Map<DateTime, List<Note>> notesByDay;
  final Map<DateTime, List<Debt>> debtsByDay;
  final Map<DateTime, List<Todo>> todosByDay;

  /// Eventos de un día: los cobros que caen ahí, las notas con esa fecha y las
  /// deudas que vencen ese día.
  List<CalendarEvent> eventsFor(DateTime day) {
    final key = dayKey(day);

    final events = <CalendarEvent>[
      for (final p in payments)
        if (chargeDay(key.year, key.month, p.dayOfMonth) == key.day)
          CalendarEvent(
            id: 'payment_${p.id}_${key.month}_${key.year}',
            title: p.name,
            subtitle: p.category.trim().isEmpty
                ? Fmt.mxn(p.amountMxn)
                : '${p.category} · ${Fmt.mxn(p.amountMxn)}',
            icon: p.displayIcon,
            color: p.displayColor,
            kind: CalendarEventKind.payment,
            amountMxn: p.amountMxn,
            sourceId: p.id,
            imageUrl: p.coverImageUrl,
          ),
      for (final d in debtsByDay[key] ?? const <Debt>[])
        CalendarEvent(
          id: 'debt_${d.id}',
          title: d.name,
          subtitle: 'Deuda · ${Fmt.mxn(d.balance)}',
          icon: d.displayIcon,
          color: d.displayColor,
          kind: CalendarEventKind.debt,
          sourceId: d.id,
        ),
      for (final n in notesByDay[key] ?? const <Note>[])
        CalendarEvent(
          id: 'note_${n.id}',
          title: n.title.trim().isEmpty ? 'Sin título' : n.title,
          subtitle: n.status.label,
          icon: Symbols.sticky_note_2_rounded,
          color: n.status.color,
          kind: CalendarEventKind.note,
          sourceId: n.id,
        ),
      for (final t in todosByDay[key] ?? const <Todo>[])
        CalendarEvent(
          id: 'todo_${t.id}',
          title: t.displayTitle,
          subtitle: t.startMinutes != null
              ? '${Fmt.clock(t.startMinutes!)} · ${t.status.label}'
              : 'To Do · ${t.status.label}',
          icon: Symbols.checklist_rounded,
          color: TodoCategory.colorFor(t.category),
          kind: CalendarEventKind.todo,
          sourceId: t.id,
        ),
    ];

    // Cobros y deudas primero (tienen dinero de por medio); notas y tareas al
    // final.
    int rank(CalendarEvent e) =>
        (e.kind == CalendarEventKind.note || e.kind == CalendarEventKind.todo)
            ? 1
            : 0;
    events.sort((a, b) {
      final byRank = rank(a).compareTo(rank(b));
      return byRank != 0 ? byRank : a.title.compareTo(b.title);
    });
    return events;
  }

  /// Cuánto se cobra un día concreto.
  double totalFor(DateTime day) => eventsFor(day)
      .where((e) => e.isPayment)
      .fold(0, (sum, e) => sum + (e.amountMxn ?? 0));

  /// Qué día cae realmente un cobro en un mes dado (delega en [PaymentSchedule],
  /// la única fuente de verdad del calendario de cobros).
  static int chargeDay(int year, int month, int dayOfMonth) =>
      PaymentSchedule.chargeDay(year, month, dayOfMonth);
}

/// Une pagos y notas. **No abre ningún listener nuevo**: reusa los streams que
/// ya alimentan las otras dos secciones, así que el calendario le cuesta cero
/// lecturas a Firestore.
final calendarDataProvider = Provider<AsyncValue<CalendarData>>((ref) {
  final paymentsAsync = ref.watch(paymentsProvider);
  final notesAsync = ref.watch(notesProvider);
  final debtsAsync = ref.watch(debtsProvider);
  final todosAsync = ref.watch(todosProvider);

  final error = paymentsAsync.error ??
      notesAsync.error ??
      debtsAsync.error ??
      todosAsync.error;
  if (error != null) {
    return AsyncError(
      error,
      paymentsAsync.stackTrace ??
          notesAsync.stackTrace ??
          debtsAsync.stackTrace ??
          todosAsync.stackTrace ??
          StackTrace.current,
    );
  }

  final payments = paymentsAsync.value;
  final notes = notesAsync.value;
  final debts = debtsAsync.value;
  final todos = todosAsync.value;
  if (payments == null || notes == null || debts == null || todos == null) {
    return const AsyncLoading();
  }

  final notesByDay = <DateTime, List<Note>>{};
  for (final n in notes) {
    final date = n.reminderDate;
    if (date == null) continue;
    notesByDay.putIfAbsent(dayKey(date), () => []).add(n);
  }

  final debtsByDay = <DateTime, List<Debt>>{};
  for (final d in debts) {
    final date = d.dueDate;
    if (date == null) continue;
    debtsByDay.putIfAbsent(dayKey(date), () => []).add(d);
  }

  final todosByDay = <DateTime, List<Todo>>{};
  for (final t in todos) {
    final date = t.date;
    if (date == null) continue;
    todosByDay.putIfAbsent(dayKey(date), () => []).add(t);
  }

  return AsyncData(CalendarData(
    payments: payments,
    notesByDay: notesByDay,
    debtsByDay: debtsByDay,
    todosByDay: todosByDay,
  ));
});

/// Día seleccionado en el calendario.
class SelectedDay extends Notifier<DateTime> {
  @override
  DateTime build() => dayKey(DateTime.now());

  void select(DateTime day) => state = dayKey(day);
}

final selectedDayProvider =
    NotifierProvider<SelectedDay, DateTime>(SelectedDay.new);

/// Mes que se está mostrando (para el encabezado y el resumen mensual).
class FocusedMonth extends Notifier<DateTime> {
  @override
  DateTime build() => dayKey(DateTime.now());

  void focus(DateTime day) => state = day;
}

final focusedMonthProvider =
    NotifierProvider<FocusedMonth, DateTime>(FocusedMonth.new);
