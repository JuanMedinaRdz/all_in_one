import 'package:cloud_firestore/cloud_firestore.dart';

/// Guarda qué ingredientes ya tienes, para la lista de compras de la semana.
///
/// La lista se **deriva** de las recetas planeadas; lo único propio que hay que
/// recordar es qué ya está en tu despensa. Se guarda como un mapa
/// `{ claveIngrediente: true }` en un único documento `workspace/main/pantry/state`,
/// así marcar/desmarcar cuesta una escritura mínima y no crea un doc por ítem.
class PantryStateRepository {
  const PantryStateRepository(this._collection);

  final CollectionReference<Map<String, dynamic>> _collection;

  DocumentReference<Map<String, dynamic>> get _doc => _collection.doc('state');

  /// Claves de los ingredientes marcados como "ya lo tengo".
  Stream<Set<String>> watch() {
    return _doc.snapshots().map((snap) {
      final have = (snap.data()?['have'] as Map<String, dynamic>?) ?? const {};
      return have.entries
          .where((e) => e.value == true)
          .map((e) => e.key)
          .toSet();
    });
  }

  /// Marca/desmarca un ingrediente. Usa notación de punto para tocar una sola
  /// clave del mapa sin reescribir todo.
  Future<void> setHave(String key, {required bool have}) {
    return _doc.set({'have': {key: have}}, SetOptions(merge: true));
  }

  /// Reinicia la despensa (al empezar una semana nueva, por ejemplo).
  Future<void> clear() => _doc.set({'have': <String, dynamic>{}});
}
