import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/images/workspace_image_service.dart';
import '../domain/note_enums.dart';
import 'note.dart';

/// Acceso a las notas en `workspace/main/notes`.
class NoteRepository {
  const NoteRepository(this._collection, this._images);

  final CollectionReference<Map<String, dynamic>> _collection;
  final WorkspaceImageService _images;

  /// Stream en tiempo real de todas las notas, la más reciente primero.
  ///
  /// El orden se hace en memoria: son pocas y así Firestore no exige índices.
  /// Las notas sin `updatedAt` (recién creadas, con el timestamp todavía
  /// pendiente del servidor) se van arriba, que es donde el usuario espera
  /// ver lo que acaba de crear.
  Stream<List<Note>> watchAll() {
    return _collection.snapshots().map((snap) {
      final notes = snap.docs.map(Note.fromDoc).toList()
        ..sort((a, b) {
          final aDate = a.updatedAt;
          final bDate = b.updatedAt;
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return -1;
          if (bDate == null) return 1;
          return bDate.compareTo(aDate);
        });
      return notes;
    });
  }

  Stream<Note?> watchOne(String id) {
    return _collection.doc(id).snapshots().map(
          (doc) => doc.exists ? Note.fromDoc(doc) : null,
        );
  }

  /// Guarda la nota completa. Es una sola escritura, aunque tenga 20 bloques.
  Future<void> save(Note note) {
    return _collection.doc(note.id).set(note.toMap(), SetOptions(merge: true));
  }

  /// Cambia solo la relevancia. Un campo, una escritura mínima.
  Future<void> setStatus(String id, NoteStatus status) {
    return _collection.doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Persiste las posiciones del drag & drop en un solo `WriteBatch`.
  ///
  /// Normalmente el mapa trae **una** entrada (la nota movida, con su índice
  /// fraccional); solo al reindexar trae la lista completa. A propósito NO toca
  /// `updatedAt`: reordenar no debe hacer pasar una nota por "recién editada".
  Future<void> setSortIndexes(Map<String, double> indexById) {
    if (indexById.isEmpty) return Future.value();
    final batch = _collection.firestore.batch();
    for (final entry in indexById.entries) {
      batch.update(_collection.doc(entry.key), {'sortIndex': entry.value});
    }
    return batch.commit();
  }

  /// Borra la nota y, con ella, sus imágenes en Storage.
  ///
  /// Si no borráramos las imágenes quedarían huérfanas: invisibles en la app
  /// pero ocupando (y cobrando) espacio para siempre.
  Future<void> delete(Note note) async {
    await _images.deleteAll(note.imageUrls);
    await _collection.doc(note.id).delete();
  }
}
