import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../core/images/workspace_image_service.dart';
import '../data/pantry_state_repository.dart';
import '../data/recipe.dart';
import '../data/recipe_repository.dart';

final recipeImageServiceProvider = Provider<WorkspaceImageService>((ref) {
  return WorkspaceImageService(
    ref.watch(firebaseStorageProvider),
    folder: 'recipes',
  );
});

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepository(
    ref.watch(workspaceCollectionProvider('recipes')),
    ref.watch(recipeImageServiceProvider),
  );
});

/// Todas las recetas en tiempo real. Un solo listener para la sección.
final recipesProvider = StreamProvider<List<Recipe>>((ref) async* {
  await ref.watch(anonymousSessionProvider.future);
  yield* ref.watch(recipeRepositoryProvider).watchAll();
});

/// Una receta concreta en tiempo real (para el editor).
final recipeProvider = StreamProvider.family<Recipe?, String>((ref, id) async* {
  await ref.watch(anonymousSessionProvider.future);
  yield* ref.watch(recipeRepositoryProvider).watchOne(id);
});

// --- Lista de compras de la semana (derivada) ---

final pantryStateRepositoryProvider = Provider<PantryStateRepository>((ref) {
  return PantryStateRepository(ref.watch(workspaceCollectionProvider('pantry')));
});

/// Ingredientes que ya tienes en la despensa (marcados en la lista).
final pantryHaveProvider = StreamProvider<Set<String>>((ref) async* {
  await ref.watch(anonymousSessionProvider.future);
  yield* ref.watch(pantryStateRepositoryProvider).watch();
});

/// Un renglón de la lista de la semana: un ingrediente juntando cantidades y
/// las recetas donde aparece.
class WeeklyItem {
  const WeeklyItem({
    required this.key,
    required this.name,
    required this.emoji,
    required this.quantities,
    required this.recipes,
    required this.have,
  });

  final String key;
  final String name;
  final String emoji;
  final List<String> quantities;
  final List<String> recipes;
  final bool have;

  /// "2 tazas · 500 g", o vacío si nadie puso cantidad.
  String get quantityLabel => quantities.where((q) => q.trim().isNotEmpty).join(' · ');

  /// "Para: Pozole, Tacos".
  String get recipesLabel => recipes.join(', ');
}

/// La lista de compras de la semana ya lista para pintar.
class WeeklyList {
  const WeeklyList({required this.items});

  final List<WeeklyItem> items;

  bool get isEmpty => items.isEmpty;
  int get total => items.length;
  int get haveCount => items.where((i) => i.have).length;
  int get toBuy => total - haveCount;

  List<WeeklyItem> get pending => items.where((i) => !i.have).toList();
  List<WeeklyItem> get inCart => items.where((i) => i.have).toList();
}

/// Junta los ingredientes de todas las recetas marcadas "esta semana",
/// deduplicando por nombre y cruzando con lo que ya tienes. Todo en memoria:
/// la despensa depende de las recetas, no al revés.
final weeklyListProvider = Provider<WeeklyList>((ref) {
  final recipes = ref.watch(recipesProvider).value ?? const [];
  final have = ref.watch(pantryHaveProvider).value ?? const <String>{};

  // clave → datos acumulados, preservando el orden de aparición.
  final byKey = <String, ({String name, String emoji, List<String> qty, List<String> from})>{};
  for (final recipe in recipes.where((r) => r.plannedThisWeek)) {
    for (final ing in recipe.realIngredients) {
      final entry = byKey.putIfAbsent(
        ing.key,
        () => (name: ing.name.trim(), emoji: ing.displayEmoji, qty: [], from: []),
      );
      if (ing.quantity.trim().isNotEmpty) entry.qty.add(ing.quantity.trim());
      if (!entry.from.contains(recipe.displayName)) entry.from.add(recipe.displayName);
    }
  }

  final items = byKey.entries
      .map((e) => WeeklyItem(
            key: e.key,
            name: e.value.name,
            emoji: e.value.emoji,
            quantities: e.value.qty,
            recipes: e.value.from,
            have: have.contains(e.key),
          ))
      .toList()
    // Lo que falta comprar arriba; dentro, alfabético.
    ..sort((a, b) {
      if (a.have != b.have) return a.have ? 1 : -1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

  return WeeklyList(items: items);
});

/// Cuántas recetas están planeadas para esta semana (para el badge).
final plannedCountProvider = Provider<int>((ref) {
  final recipes = ref.watch(recipesProvider).value ?? const [];
  return recipes.where((r) => r.plannedThisWeek).length;
});
