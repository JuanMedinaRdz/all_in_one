import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/debt.dart';
import '../data/debt_repository.dart';

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepository(ref.watch(workspaceCollectionProvider('debts')));
});

/// Todas las deudas, en tiempo real. Un solo listener.
final debtsProvider = StreamProvider<List<Debt>>((ref) async* {
  await ref.watch(anonymousSessionProvider.future);
  yield* ref.watch(debtRepositoryProvider).watchAll();
});

/// Resumen de deudas, derivado en memoria: total adeudado y cuántas hay.
class DebtSummary {
  const DebtSummary({required this.totalBalance, required this.count});

  final double totalBalance;
  final int count;

  bool get isEmpty => count == 0;

  factory DebtSummary.from(List<Debt> debts) => DebtSummary(
        totalBalance: debts.fold(0, (sum, d) => sum + d.balance),
        count: debts.length,
      );
}

final debtSummaryProvider = Provider<DebtSummary>((ref) {
  final debts = ref.watch(debtsProvider).value ?? const [];
  return DebtSummary.from(debts);
});
