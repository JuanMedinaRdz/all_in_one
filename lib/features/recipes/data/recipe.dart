import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/ingredient_icons.dart';

part 'recipe.freezed.dart';

/// Un ingrediente de una receta: qué es, cuánto y con qué emoji se muestra.
///
/// El emoji se detecta solo del nombre ([IngredientIcons]); si guardas uno a
/// mano, se respeta. La cantidad es texto libre ("2 tazas", "500 g", "al gusto").
@freezed
abstract class RecipeIngredient with _$RecipeIngredient {
  const RecipeIngredient._();

  const factory RecipeIngredient({
    required String name,
    @Default('') String quantity,

    /// Emoji elegido a mano. Vacío = se usa el detectado del nombre.
    @Default('') String emoji,
  }) = _RecipeIngredient;

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) => RecipeIngredient(
        name: (map['name'] as String?) ?? '',
        quantity: (map['quantity'] as String?) ?? '',
        emoji: (map['emoji'] as String?) ?? '',
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'quantity': quantity,
        'emoji': emoji,
      };

  /// Emoji a mostrar: el manual si hay, si no el detectado del nombre.
  String get displayEmoji => emoji.isNotEmpty ? emoji : IngredientIcons.emojiOrDefault(name);

  bool get isEmpty => name.trim().isEmpty;

  /// Clave para deduplicar en la lista de la semana (mismo ingrediente escrito
  /// distinto): minúsculas y sin espacios de más.
  String get key => name.trim().toLowerCase();
}

/// Una receta: foto de portada, ingredientes (con icono) y pasos.
///
/// Todo va embebido en un solo documento (como las notas): se lee y escribe
/// entera con una sola operación. La bandera [plannedThisWeek] es la que
/// alimenta la lista de compras de la semana: la despensa se deriva de lo que
/// planeas cocinar, no al revés.
@freezed
abstract class Recipe with _$Recipe {
  const Recipe._();

  const factory Recipe({
    required String id,
    @Default('') String name,

    /// Foto de portada en Firebase Storage. `null` = sin foto (se usa un
    /// degradado con emoji).
    String? coverImageUrl,

    /// Nota libre: de dónde salió, para cuántos rinde bien, tips.
    @Default('') String description,

    /// Porciones que rinde. `null` = sin especificar.
    int? servings,

    /// Minutos de preparación. `null` = sin especificar.
    int? minutes,

    /// Planeada para esta semana: entra a la lista de compras.
    @Default(false) bool plannedThisWeek,

    @Default(<RecipeIngredient>[]) List<RecipeIngredient> ingredients,

    /// Pasos de preparación, en orden.
    @Default(<String>[]) List<String> steps,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Recipe;

  factory Recipe.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Recipe(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      coverImageUrl: data['coverImageUrl'] as String?,
      description: (data['description'] as String?) ?? '',
      servings: (data['servings'] as num?)?.toInt(),
      minutes: (data['minutes'] as num?)?.toInt(),
      plannedThisWeek: (data['plannedThisWeek'] as bool?) ?? false,
      ingredients: ((data['ingredients'] as List<dynamic>?) ?? const [])
          .map((i) => RecipeIngredient.fromMap(Map<String, dynamic>.from(i as Map)))
          .toList(),
      steps: ((data['steps'] as List<dynamic>?) ?? const [])
          .map((s) => s as String)
          .toList(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'coverImageUrl': coverImageUrl,
        'description': description,
        'servings': servings,
        'minutes': minutes,
        'plannedThisWeek': plannedThisWeek,
        'ingredients': ingredients.map((i) => i.toMap()).toList(),
        'steps': steps,
        'updatedAt': FieldValue.serverTimestamp(),
        if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
      };

  /// Ingredientes con nombre real (ignora filas vacías del editor).
  List<RecipeIngredient> get realIngredients =>
      ingredients.where((i) => !i.isEmpty).toList();

  /// Pasos con texto real.
  List<String> get realSteps =>
      steps.where((s) => s.trim().isNotEmpty).toList();

  List<String> get imageUrls => [if (coverImageUrl != null) coverImageUrl!];

  /// `true` si la receta está en blanco (para auto-borrar las creadas por
  /// accidente al salir del editor sin escribir nada).
  bool get isBlank =>
      name.trim().isEmpty &&
      description.trim().isEmpty &&
      coverImageUrl == null &&
      realIngredients.isEmpty &&
      realSteps.isEmpty;

  String get displayName => name.trim().isEmpty ? 'Receta sin nombre' : name.trim();
}
