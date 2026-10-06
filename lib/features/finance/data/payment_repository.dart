import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/images/workspace_image_service.dart';
import 'payment.dart';

/// Acceso a los pagos mensuales en `workspace/main/payments`.
///
/// Todas las escrituras son quirúrgicas: se toca el documento concreto y, en
/// las ediciones, solo los campos que cambian. Nunca se reescribe la colección.
class PaymentRepository {
  const PaymentRepository(this._collection, this._images);

  final CollectionReference<Map<String, dynamic>> _collection;
  final WorkspaceImageService _images;

  /// Stream en tiempo real de todos los pagos.
  ///
  /// Con la persistencia offline activada, el primer evento sale del caché
  /// local (instantáneo, sin red) y después solo llegan los deltas.
  ///
  /// El orden se hace en memoria y no con `orderBy` a propósito: son pocos
  /// documentos, y así evitamos que Firestore exija un índice compuesto.
  Stream<List<Payment>> watchAll() {
    return _collection.snapshots().map((snap) {
      final payments = snap.docs.map(Payment.fromDoc).toList()
        ..sort((a, b) => b.amountMxn.compareTo(a.amountMxn));
      return payments;
    });
  }

  /// Crea o actualiza un pago. `merge: true` conserva los campos que no
  /// mandamos (como `createdAt` en las ediciones).
  Future<void> save(Payment payment) {
    return _collection.doc(payment.id).set(
          payment.toMap(),
          SetOptions(merge: true),
        );
  }

  /// Borra el pago y, con él, su foto de portada en Storage (si tenía), para
  /// no dejar archivos huérfanos ocupando espacio.
  Future<void> delete(Payment payment) async {
    await _images.deleteAll(payment.imageUrls);
    await _collection.doc(payment.id).delete();
  }
}
