import 'package:cloud_firestore/cloud_firestore.dart';

import 'note_section.dart';

/// Acceso a las secciones de notas en `workspace/main/noteSections`.
class NoteSectionRepository {
  const NoteSectionRepository(this._sections, this._notes);

  final CollectionReference<Map<String, dynamic>> _sections;
  final CollectionReference<Map<String, dynamic>> _notes;

  /// Todas las secciones, ordenadas por `sortIndex` y luego por creación.
  /// El orden se hace en memoria (son pocas): sin índices de Firestore.
  Stream<List<NoteSection>> watchAll() {
    return _sections.snapshots().map((snap) {
      final list = snap.docs.map(NoteSection.fromDoc).toList()
        ..sort((a, b) {
          if (a.sortIndex != b.sortIndex) {
            return a.sortIndex.compareTo(b.sortIndex);
          }
          final ad = a.createdAt;
          final bd = b.createdAt;
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return ad.compareTo(bd);
        });
      return list;
    });
  }

  Future<void> save(NoteSection section) {
    return _sections
        .doc(section.id)
        .set(section.toMap(), SetOptions(merge: true));
  }

  /// Cambia solo el estado colapsado, con una escritura mínima.
  Future<void> setCollapsed(String id, {required bool collapsed}) {
    return _sections.doc(id).update({'collapsed': collapsed});
  }

  /// Borra la sección y deja sus notas "Sin sección" (no las borra), en un
  /// solo batch.
  Future<void> delete(String sectionId, {required List<String> noteIds}) {
    final batch = _sections.firestore.batch();
    batch.delete(_sections.doc(sectionId));
    for (final id in noteIds) {
      batch.update(_notes.doc(id), {'sectionId': null});
    }
    return batch.commit();
  }
}
