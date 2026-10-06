import 'package:cloud_firestore/cloud_firestore.dart';

import 'debt.dart';

/// Acceso a las deudas en `workspace/main/debts`.
class DebtRepository {
  const DebtRepository(this._collection);

  final CollectionReference<Map<String, dynamic>> _collection;

  /// Stream en tiempo real de todas las deudas, la de mayor saldo primero.
  /// El orden se hace en memoria: son pocas, sin índices de Firestore.
  Stream<List<Debt>> watchAll() {
    return _collection.snapshots().map((snap) {
      final debts = snap.docs.map(Debt.fromDoc).toList()
        ..sort((a, b) => b.balance.compareTo(a.balance));
      return debts;
    });
  }

  Future<void> save(Debt debt) {
    return _collection.doc(debt.id).set(debt.toMap(), SetOptions(merge: true));
  }

  Future<void> delete(String id) => _collection.doc(id).delete();
}
