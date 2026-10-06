import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/finance/application/debt_providers.dart';
import '../../features/finance/application/payment_providers.dart';
import '../../features/notes/application/note_providers.dart';
import '../utils/debouncer.dart';
import 'notification_service.dart';
import 'reminder_planner.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Mantiene las notificaciones sincronizadas con los datos.
///
/// Observa pagos, deudas y notas; cuando algo cambia, replanifica todos los
/// recordatorios (cancela lo viejo y reprograma lo vigente). Va alto en el
/// árbol para vivir mientras la app esté abierta. El trabajo se hace en
/// memoria a partir de los streams que ya existen: no abre listeners nuevos.
class ReminderScheduler extends ConsumerStatefulWidget {
  const ReminderScheduler({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ReminderScheduler> createState() => _ReminderSchedulerState();
}

class _ReminderSchedulerState extends ConsumerState<ReminderScheduler> {
  final _debouncer = Debouncer(delay: const Duration(seconds: 1));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationServiceProvider).init();
    });
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  void _sync() {
    final payments = ref.read(paymentsProvider).value;
    final debts = ref.read(debtsProvider).value;
    final notes = ref.read(notesProvider).value;
    // Espera a que las tres fuentes estén listas para no borrar avisos por un
    // estado de carga transitorio.
    if (payments == null || debts == null || notes == null) return;

    final reminders =
        ReminderPlanner.plan(payments: payments, debts: debts, notes: notes);
    ref.read(notificationServiceProvider).reschedule(reminders);
  }

  @override
  Widget build(BuildContext context) {
    // Cualquier cambio en los datos replanifica, con un pequeño respiro para
    // agrupar ráfagas (p. ej. varias ediciones seguidas).
    ref.listen(paymentsProvider, (_, __) => _debouncer.run(_sync));
    ref.listen(debtsProvider, (_, __) => _debouncer.run(_sync));
    ref.listen(notesProvider, (_, __) => _debouncer.run(_sync));
    return widget.child;
  }
}
