import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/layout/motion.dart';
import '../../../core/layout/responsive.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/section_placeholder.dart';
import '../../finance/application/debt_providers.dart';
import '../../finance/application/payment_providers.dart';
import '../../finance/presentation/debts_view.dart';
import '../../finance/presentation/widgets/payment_editor_sheet.dart';
import '../../todos/application/todo_providers.dart';
import '../../todos/data/todo.dart';
import '../../todos/presentation/widgets/todo_detail_panel.dart';
import '../application/calendar_providers.dart';
import '../domain/calendar_event.dart';
import 'widgets/day_events_panel.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  Future<void> _openEvent(
    BuildContext context,
    WidgetRef ref,
    CalendarEvent event,
  ) async {
    if (event.kind == CalendarEventKind.note) {
      context.go('${AppRoutes.notes}/${event.sourceId}');
      return;
    }

    if (event.kind == CalendarEventKind.todo) {
      context.go('${AppRoutes.todos}/${event.sourceId}');
      return;
    }

    if (event.kind == CalendarEventKind.debt) {
      final debt = (ref.read(debtsProvider).value ?? const [])
          .where((d) => d.id == event.sourceId)
          .firstOrNull;
      if (debt != null && context.mounted) {
        await DebtsView.openEditor(context, ref, existing: debt);
      }
      return;
    }

    // Un cobro abre su editor, para poder ajustarlo sin ir a la otra sección.
    final payments = ref.read(paymentsProvider).value ?? const [];
    final payment = payments.where((p) => p.id == event.sourceId).firstOrNull;
    if (payment == null) return;

    final suggestions = <String>{
      for (final p in payments)
        if (p.category.trim().isNotEmpty) p.category.trim(),
    }.toList();

    final result = await PaymentEditorSheet.show(
      context,
      existing: payment,
      categorySuggestions: suggestions,
    );
    if (result == null) return;

    final repo = ref.read(paymentRepositoryProvider);
    switch (result) {
      case SavePayment(:final payment):
        await repo.save(payment);
      case DeletePayment(:final payment):
        await repo.delete(payment);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(calendarDataProvider);
    final selectedDay = ref.watch(selectedDayProvider);
    final focusedMonth = ref.watch(focusedMonthProvider);

    return SectionScaffold(
      title: 'Calendario',
      subtitle: 'Tus pagos y notas, en un solo vistazo',
      child: switch (dataAsync) {
        AsyncError(:final error) => _ErrorState(error: error),
        AsyncLoading() => const _LoadingState(),
        AsyncData(value: final data) => LayoutBuilder(
            builder: (context, constraints) {
              final calendar = _Calendar(
                data: data,
                selectedDay: selectedDay,
                focusedMonth: focusedMonth,
                onSelect: (day, focused) {
                  ref.read(selectedDayProvider.notifier).select(day);
                  ref.read(focusedMonthProvider.notifier).focus(focused);
                },
                onPageChanged: (focused) =>
                    ref.read(focusedMonthProvider.notifier).focus(focused),
              );
              final panel = DayEventsPanel(
                day: selectedDay,
                events: data.eventsFor(selectedDay),
                total: data.totalFor(selectedDay),
                onTapEvent: (e) => _openEvent(context, ref, e),
              );

              // Monitor grande: dashboard completo (calendario + agenda + detalle
              // de tarea arriba, tablero de To Do's abajo).
              if (constraints.maxWidth >= 1100) {
                return _Dashboard(
                  calendar: SingleChildScrollView(child: calendar),
                  data: data,
                  selectedDay: selectedDay,
                  onOpenEvent: (e) => _openEvent(context, ref, e),
                );
              }

              // Ancho medio: calendario a la izquierda, agenda a la derecha.
              if (constraints.maxWidth >= Breakpoints.expanded) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 420,
                      child: SingleChildScrollView(child: calendar),
                    ),
                    AppSpacing.gapXl,
                    Expanded(child: panel),
                  ],
                );
              }

              // Angosto (móvil): apilados.
              return Column(
                children: [
                  calendar,
                  AppSpacing.gapLg,
                  Expanded(child: panel),
                ],
              );
            },
          ),
      },
    );
  }
}

class _Calendar extends StatelessWidget {
  const _Calendar({
    required this.data,
    required this.selectedDay,
    required this.focusedMonth,
    required this.onSelect,
    required this.onPageChanged,
  });

  final CalendarData data;
  final DateTime selectedDay;
  final DateTime focusedMonth;
  final void Function(DateTime day, DateTime focused) onSelect;
  final ValueChanged<DateTime> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppSpacing.brLg,
        border: Border.all(color: scheme.outline.withValues(alpha: 0.4)),
      ),
      child: TableCalendar<CalendarEvent>(
        locale: 'es_MX',
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2035, 12, 31),
        focusedDay: focusedMonth,
        currentDay: DateTime.now(),
        selectedDayPredicate: (day) => isSameDay(day, selectedDay),
        onDaySelected: onSelect,
        onPageChanged: onPageChanged,
        // Los eventos se calculan en memoria por día: no hay consulta detrás.
        eventLoader: data.eventsFor,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableGestures: AvailableGestures.horizontalSwipe,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: theme.textTheme.titleMedium ?? const TextStyle(),
          leftChevronIcon: const Icon(Symbols.chevron_left_rounded),
          rightChevronIcon: const Icon(Symbols.chevron_right_rounded),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ) ??
              const TextStyle(),
          weekendStyle: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ) ??
              const TextStyle(),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          defaultTextStyle: theme.textTheme.bodyMedium ?? const TextStyle(),
          weekendTextStyle: theme.textTheme.bodyMedium ?? const TextStyle(),
          todayDecoration: BoxDecoration(
            color: scheme.primary.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          todayTextStyle: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.bold,
              ) ??
              const TextStyle(),
          selectedDecoration: BoxDecoration(
            color: scheme.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.bold,
              ) ??
              const TextStyle(),
          markersMaxCount: 4,
        ),
        calendarBuilders: CalendarBuilders<CalendarEvent>(
          // Hoy: círculo verde con un aro que late detrás (pulse). Si hoy es
          // además el día seleccionado, deja el estilo de "seleccionado".
          todayBuilder: (context, day, focused) {
            if (isSameDay(day, selectedDay)) return null;
            return _PulseToday(day: day);
          },
          // Marcadores con el color real de cada cosa: de un vistazo sabes si
          // ese día hay un cobro (terracota) o una nota (ámbar/verde).
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return null;
            return Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final e in events.take(4))
                    Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: e.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(duration: AppMotion.medium);
  }
}

/// El día de hoy: círculo verde suave con un aro que late detrás (pulse 2.4s).
/// Con "reducir movimiento" solo queda el círculo, sin latido.
class _PulseToday extends StatefulWidget {
  const _PulseToday({required this.day});

  final DateTime day;

  @override
  State<_PulseToday> createState() => _PulseTodayState();
}

class _PulseTodayState extends State<_PulseToday>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final pulse = !reduceMotion(context);
    // No dejamos el controlador en bucle si se pidió reducir movimiento.
    if (pulse) {
      if (!_c.isAnimating) _c.repeat();
    } else if (_c.isAnimating) {
      _c.stop();
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (pulse)
            AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final v = _c.value;
                return Transform.scale(
                  scale: 1 + v * 0.75, // 1 → 1.75
                  child: Opacity(
                    opacity: (0.55 * (1 - v)).clamp(0.0, 1.0),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              },
            ),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${widget.day.day}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashboard del calendario para monitores grandes: calendario + agenda del día
/// + la ficha de la tarea del día seleccionado, que se despliega con animación.
///
/// Las tareas (To Do's) viven en su propia sección; aquí el calendario solo las
/// *muestra*: al elegir un día con tarea, su ficha se despliega a la derecha.
class _Dashboard extends ConsumerWidget {
  const _Dashboard({
    required this.calendar,
    required this.data,
    required this.selectedDay,
    required this.onOpenEvent,
  });

  final Widget calendar;
  final CalendarData data;
  final DateTime selectedDay;
  final void Function(CalendarEvent) onOpenEvent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todosProvider).value ?? const <Todo>[];
    final focusedId = ref.watch(focusedTodoProvider);

    // Tareas agendadas ese día, ordenadas por hora.
    final key = dayKey(selectedDay);
    final dayTodos = [
      for (final t in todos)
        if (t.date != null && dayKey(t.date!) == key) t,
    ]..sort((a, b) =>
        (a.startMinutes ?? 1 << 30).compareTo(b.startMinutes ?? 1 << 30));

    // La ficha muestra: la tarea enfocada (si es de ese día), o la primera del
    // día. Al cambiar de día, la enfocada de otro día deja de aplicar.
    Todo? detail;
    for (final t in dayTodos) {
      if (t.id == focusedId) {
        detail = t;
        break;
      }
    }
    detail ??= dayTodos.isNotEmpty ? dayTodos.first : null;
    final d = detail;

    final dayPanel = DayEventsPanel(
      day: selectedDay,
      events: data.eventsFor(selectedDay),
      total: data.totalFor(selectedDay),
      onTapEvent: (e) {
        // Una tarea se enfoca aquí mismo (despliega su ficha); lo demás abre su
        // editor como siempre.
        if (e.kind == CalendarEventKind.todo && e.sourceId != null) {
          ref.read(focusedTodoProvider.notifier).select(e.sourceId);
        } else {
          onOpenEvent(e);
        }
      },
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: 380, child: calendar),
        AppSpacing.gapLg,
        Expanded(child: _panel(context, child: dayPanel)),
        AppSpacing.gapLg,
        SizedBox(
          width: 360,
          child: _panel(
            context,
            // La `key` hace que la ficha se re-anime al cambiar de día o tarea.
            child: _AnimatedDetail(
              key: ValueKey('$key-${d?.id ?? 'empty'}'),
              todo: d,
              onOpen:
                  d == null ? () {} : () => context.go('${AppRoutes.todos}/${d.id}'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _panel(BuildContext context, {required Widget child}) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppSpacing.brLg,
        border: Border.all(color: scheme.outline.withValues(alpha: 0.4)),
      ),
      child: child,
    );
  }
}

/// La ficha de detalle con su animación de "despliegue": se abre desde arriba
/// (escala vertical) con un fundido y un leve deslizamiento. Al cambiar la
/// `key` (otro día u otra tarea) la animación vuelve a correr.
class _AnimatedDetail extends StatelessWidget {
  const _AnimatedDetail({super.key, required this.todo, required this.onOpen});

  final Todo? todo;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final panel = TodoDetailPanel(todo: todo, onOpen: onOpen);
    // Con "reducir movimiento" la ficha aparece sin el despliegue.
    if (reduceMotion(context)) return panel;
    return panel
        .animate()
        .fadeIn(duration: 420.ms, curve: Curves.easeOut)
        .scale(
          begin: const Offset(1, 0.85),
          end: const Offset(1, 1),
          alignment: Alignment.topCenter,
          duration: 460.ms,
          curve: Curves.easeOutBack,
        )
        .slideY(begin: -0.03, end: 0, curve: AppMotion.emphasized);
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

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

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Scroll + recorte del detalle: un error largo no debe romper el layout.
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
              Text('No pude cargar el calendario',
                  style: theme.textTheme.titleMedium),
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
