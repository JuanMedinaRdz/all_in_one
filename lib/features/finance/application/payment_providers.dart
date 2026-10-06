import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../core/images/workspace_image_service.dart';
import '../data/payment.dart';
import '../data/payment_repository.dart';
import '../domain/payment_schedule.dart';
import 'finance_summary.dart';

final paymentImageServiceProvider = Provider<WorkspaceImageService>((ref) {
  return WorkspaceImageService(
    ref.watch(firebaseStorageProvider),
    folder: 'payments',
  );
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepository(
    ref.watch(workspaceCollectionProvider('payments')),
    ref.watch(paymentImageServiceProvider),
  );
});

/// Única fuente de verdad de los pagos, en tiempo real.
///
/// Es **un solo listener** para toda la app: la lista, el total, el desglose y
/// el calendario se alimentan de aquí. Al cambiar de pestaña la sección sigue
/// montada, así que el listener no se recrea y no se vuelve a leer todo.
///
/// Espera a que exista sesión anónima antes de suscribirse: sin ella las
/// reglas rechazarían la consulta. Mientras tanto la UI muestra "Cargando".
final paymentsProvider = StreamProvider<List<Payment>>((ref) async* {
  await ref.watch(anonymousSessionProvider.future);
  yield* ref.watch(paymentRepositoryProvider).watchAll();
});

/// Pagos ordenados por proximidad de cobro (el próximo, primero). Todo en
/// memoria: cero lecturas extra.
final upcomingPaymentsProvider = Provider<AsyncValue<List<UpcomingPayment>>>((ref) {
  return ref.watch(paymentsProvider).whenData(UpcomingPayment.schedule);
});

/// Resumen derivado de [paymentsProvider], calculado en memoria.
final financeSummaryProvider = Provider<AsyncValue<FinanceSummary>>((ref) {
  return ref.watch(paymentsProvider).whenData(FinanceSummary.from);
});
