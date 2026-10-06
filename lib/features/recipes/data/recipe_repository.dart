import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/images/workspace_image_service.dart';
import 'recipe.dart';

/// Acceso a las recetas en `workspace/main/recipes`.
class RecipeRepository {
  const RecipeRepository(this._collection, this._images);

  final CollectionReference<Map<String, dynamic>> _collection;
  final WorkspaceImageService _images;

  /// Stream en tiempo real de todas las recetas, la más reciente primero.
  /// El orden se hace en memoria (son pocas): así Firestore no exige índices.
  Stream<List<Recipe>> watchAll() {
    return _collection.snapshots().map((snap) {
      final recipes = snap.docs.map(Recipe.fromDoc).toList()
        ..sort((a, b) {
          final ad = a.updatedAt;
          final bd = b.updatedAt;
          if (ad == null && bd == null) return 0;
          if (ad == null) return -1; // recién creada arriba
          if (bd == null) return 1;
          return bd.compareTo(ad);
        });
      return recipes;
    });
  }

  Stream<Recipe?> watchOne(String id) {
    return _collection.doc(id).snapshots().map(
          (doc) => doc.exists ? Recipe.fromDoc(doc) : null,
        );
  }

  /// Guarda la receta completa en una sola escritura.
  Future<void> save(Recipe recipe) {
    return _collection.doc(recipe.id).set(recipe.toMap(), SetOptions(merge: true));
  }

  /// Cambia solo la bandera "esta semana" con una escritura mínima.
  Future<void> setPlanned(String id, {required bool planned}) {
    return _collection.doc(id).update({'plannedThisWeek': planned});
  }

  /// Borra la receta y, con ella, su foto en Storage (si no, quedaría huérfana
  /// ocupando espacio para siempre).
  Future<void> delete(Recipe recipe) async {
    await _images.deleteAll(recipe.imageUrls);
    await _collection.doc(recipe.id).delete();
  }
}
