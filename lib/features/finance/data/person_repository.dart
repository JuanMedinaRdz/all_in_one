import 'package:cloud_firestore/cloud_firestore.dart';

import 'person.dart';

/// Acceso al roster de personas en `workspace/main/people`.
class PersonRepository {
  const PersonRepository(this._collection);

  final CollectionReference<Map<String, dynamic>> _collection;

  Stream<List<Person>> watchAll() {
    return _collection.snapshots().map((snap) {
      final list = snap.docs.map(Person.fromDoc).toList()
        ..sort((a, b) {
          if (a.sortIndex != b.sortIndex) {
            return a.sortIndex.compareTo(b.sortIndex);
          }
          final ad = a.createdAt, bd = b.createdAt;
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return ad.compareTo(bd);
        });
      return list;
    });
  }

  Future<void> save(Person person) {
    return _collection.doc(person.id).set(person.toMap(), SetOptions(merge: true));
  }

  Future<void> delete(String id) => _collection.doc(id).delete();
}
