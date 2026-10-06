import 'package:cloud_firestore/cloud_firestore.dart';

import 'note_folder.dart';

/// Acceso a las carpetas de notas en `workspace/main/noteFolders`.
class NoteFolderRepository {
  const NoteFolderRepository(this._folders, this._notes);

  final CollectionReference<Map<String, dynamic>> _folders;
  final CollectionReference<Map<String, dynamic>> _notes;

  /// Todas las carpetas, por orden de creación (estable y predecible).
  /// El orden se hace en memoria: son pocas, sin índices de Firestore.
  Stream<List<NoteFolder>> watchAll() {
    return _folders.snapshots().map((snap) {
      final folders = snap.docs.map(NoteFolder.fromDoc).toList()
        ..sort((a, b) {
          final ad = a.createdAt;
          final bd = b.createdAt;
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1; // recién creada: al final, con las nuevas
          if (bd == null) return -1;
          return ad.compareTo(bd);
        });
      return folders;
    });
  }

  Future<void> save(NoteFolder folder) {
    return _folders.doc(folder.id).set(folder.toMap(), SetOptions(merge: true));
  }

  /// Borra la carpeta y deja sus notas "sin carpeta", todo en un solo batch.
  ///
  /// Las notas NO se borran a propósito: perder una carpeta por accidente es
  /// recuperable; perder las notas que contenía, no.
  Future<void> delete(String folderId, {required List<String> noteIds}) {
    final batch = _folders.firestore.batch();
    batch.delete(_folders.doc(folderId));
    for (final id in noteIds) {
      batch.update(_notes.doc(id), {'folderId': null});
    }
    return batch.commit();
  }
}
