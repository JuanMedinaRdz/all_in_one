import 'package:all_in_one/features/recipes/data/recipe.dart';
import 'package:all_in_one/features/recipes/domain/ingredient_icons.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IngredientIcons.emojiFor', () {
    test('reconoce ingredientes comunes en español', () {
      expect(IngredientIcons.emojiFor('Tomate'), '🍅');
      expect(IngredientIcons.emojiFor('pollo'), '🍗');
      expect(IngredientIcons.emojiFor('Leche'), '🥛');
      expect(IngredientIcons.emojiFor('arroz'), '🍚');
    });

    test('ignora acentos y mayúsculas', () {
      expect(IngredientIcons.emojiFor('LIMÓN'), '🍋');
      expect(IngredientIcons.emojiFor('jalapeño'), '🌶️');
    });

    test('entiende plurales simples', () {
      expect(IngredientIcons.emojiFor('tomates'), '🍅');
      expect(IngredientIcons.emojiFor('frijoles'), '🫘');
      expect(IngredientIcons.emojiFor('huevos'), '🥚');
    });

    test('lo específico gana sobre lo general (salmón vs sal)', () {
      expect(IngredientIcons.emojiFor('salmón'), '🐟');
      expect(IngredientIcons.emojiFor('sal'), '🧂');
    });

    test('claves de varias palabras (aceite de oliva)', () {
      expect(IngredientIcons.emojiFor('aceite de oliva'), '🫒');
    });

    test('no confunde subcadenas (salsa no es sal)', () {
      expect(IngredientIcons.emojiFor('salsa de tomate'), isNotNull);
      expect(IngredientIcons.emojiFor('salsa'), '🥫');
    });

    test('un ingrediente desconocido no truena y cae en el genérico', () {
      expect(IngredientIcons.emojiFor('unobtanium'), isNull);
      expect(IngredientIcons.emojiOrDefault('unobtanium'), '🥄');
    });
  });

  group('RecipeIngredient', () {
    test('displayEmoji usa el manual si hay, si no el detectado', () {
      const auto = RecipeIngredient(name: 'pollo');
      expect(auto.displayEmoji, '🍗');

      const manual = RecipeIngredient(name: 'pollo', emoji: '🔥');
      expect(manual.displayEmoji, '🔥');
    });

    test('key normaliza para deduplicar', () {
      expect(const RecipeIngredient(name: '  Tomate ').key, 'tomate');
    });
  });

  group('Recipe', () {
    test('realIngredients ignora filas vacías', () {
      const recipe = Recipe(
        id: 'r1',
        name: 'Prueba',
        ingredients: [
          RecipeIngredient(name: 'Pollo'),
          RecipeIngredient(name: ''),
          RecipeIngredient(name: '  '),
          RecipeIngredient(name: 'Arroz'),
        ],
      );
      expect(recipe.realIngredients.length, 2);
    });

    test('isBlank detecta una receta recién creada sin contenido', () {
      const blank = Recipe(id: 'r1');
      expect(blank.isBlank, isTrue);

      const withName = Recipe(id: 'r2', name: 'Pozole');
      expect(withName.isBlank, isFalse);
    });

    test('displayName cae en un nombre por defecto', () {
      expect(const Recipe(id: 'r1').displayName, 'Receta sin nombre');
      expect(const Recipe(id: 'r2', name: '  Tacos ').displayName, 'Tacos');
    });
  });
}
