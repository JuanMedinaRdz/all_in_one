import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/todo_status.dart';
import 'todo.dart';

/// Acceso a las tareas en `workspace/main/todos`.
class TodoRepository {
  const TodoRepository(this._collection);

  final CollectionReference<Map<String, dynamic>> _collection;

  /// Stream en tiempo real de todas las tareas. El orden y la agrupación por
  /// columna se hacen en memoria (son pocas): así Firestore no exige índices.
  Stream<List<Todo>> watchAll() {
    return _collection.snapshots().map(
          (snap) => snap.docs.map(Todo.fromDoc).toList(),
        );
  }

  Stream<Todo?> watchOne(String id) {
    return _collection.doc(id).snapshots().map(
          (doc) => doc.exists ? Todo.fromDoc(doc) : null,
        );
  }

  /// Guarda la tarea completa en una sola escritura.
  Future<void> save(Todo todo) {
    return _collection.doc(todo.id).set(todo.toMap(), SetOptions(merge: true));
  }

  /// Mueve una tarea de columna (drag & drop), opcionalmente fijando su posición.
  Future<void> setStatus(String id, TodoStatus status, {double? sortIndex}) {
    return _collection.doc(id).update({
      'status': status.name,
      if (sortIndex != null) 'sortIndex': sortIndex,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Marca/desmarca un breakpoint concreto sin reescribir toda la tarea.
  Future<void> toggleBreakpoint(Todo todo, String breakpointId) {
    final updated = [
      for (final b in todo.breakpoints)
        if (b.id == breakpointId) b.copyWith(done: !b.done) else b,
    ];
    return _collection.doc(todo.id).update({
      'breakpoints': updated.map((b) => b.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> delete(String id) => _collection.doc(id).delete();
}
