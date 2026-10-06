/// Detecta un emoji para un ingrediente a partir de su nombre en español.
///
/// ¿Por qué no una API de iconos? Las que existen (TheMealDB, iconos de comida)
/// devuelven PNG, esperan nombres en inglés, requieren llave o CORS y cobran o
/// se caen. Para una app personal en español, un diccionario local es más
/// rápido (instantáneo, sin red), más confiable y encaja con el lenguaje visual
/// de emojis que ya usa la app. Si algún día quieres un icono que no está aquí,
/// lo eliges a mano en el editor y se respeta.
abstract final class IngredientIcons {
  const IngredientIcons._();

  /// Palabra clave (en minúsculas, sin acentos) → emoji.
  ///
  /// El match es por palabra completa (con plurales simples) o, para las claves
  /// con espacio, por subcadena. Las claves se prueban de la más larga a la más
  /// corta, así "aceite de oliva" gana sobre "aceite" y "salmón" sobre "sal".
  static const _map = <String, String>{
    // --- Proteínas ---
    'pollo': '🍗', 'pechuga': '🍗', 'muslo': '🍗', 'pavo': '🍗',
    'carne': '🥩', 'res': '🥩', 'bistec': '🥩', 'molida': '🥩', 'filete': '🥩',
    'cerdo': '🥓', 'puerco': '🥓', 'tocino': '🥓', 'costilla': '🥓',
    'jamon': '🍖', 'chorizo': '🌭', 'salchicha': '🌭',
    'salmon': '🐟', 'pescado': '🐟', 'atun': '🐟', 'tilapia': '🐟', 'mojarra': '🐟',
    'camaron': '🦐', 'gamba': '🦐', 'pulpo': '🐙', 'marisco': '🦐',
    'huevo': '🥚', 'huevos': '🥚',
    // --- Lácteos ---
    'leche': '🥛', 'yogur': '🥛', 'yoghurt': '🥛', 'crema': '🥛',
    'queso': '🧀', 'mantequilla': '🧈', 'margarina': '🧈',
    // --- Verduras ---
    'jitomate': '🍅', 'tomate': '🍅',
    'cebolla': '🧅', 'ajo': '🧄',
    'papa': '🥔', 'patata': '🥔', 'camote': '🍠',
    'zanahoria': '🥕', 'brocoli': '🥦', 'coliflor': '🥦',
    'lechuga': '🥬', 'espinaca': '🥬', 'acelga': '🥬', 'apio': '🥬', 'kale': '🥬',
    'pepino': '🥒', 'calabaza': '🎃', 'calabacita': '🥒',
    'chile': '🌶️', 'pimiento': '🫑', 'jalapeno': '🌶️', 'morron': '🫑',
    'elote': '🌽', 'maiz': '🌽',
    'champinon': '🍄', 'hongo': '🍄', 'seta': '🍄',
    'aguacate': '🥑', 'berenjena': '🍆', 'ejote': '🫛', 'chicharo': '🫛',
    // --- Frutas ---
    'manzana': '🍎', 'platano': '🍌', 'banana': '🍌',
    'limon': '🍋', 'naranja': '🍊', 'mandarina': '🍊', 'toronja': '🍊',
    'fresa': '🍓', 'uva': '🍇', 'pina': '🍍', 'mango': '🥭',
    'sandia': '🍉', 'melon': '🍈', 'durazno': '🍑', 'cereza': '🍒',
    'coco': '🥥', 'kiwi': '🥝', 'pera': '🍐', 'ciruela': '🍑', 'papaya': '🍈',
    // --- Granos y carbohidratos ---
    'arroz': '🍚', 'pasta': '🍝', 'espagueti': '🍝', 'fideo': '🍝', 'macarron': '🍝',
    'pan': '🍞', 'bolillo': '🥖', 'baguette': '🥖', 'tortilla': '🫓',
    'harina': '🌾', 'avena': '🌾', 'trigo': '🌾', 'cereal': '🥣', 'quinoa': '🌾',
    // --- Leguminosas ---
    'frijol': '🫘', 'frijoles': '🫘', 'lenteja': '🫘', 'garbanzo': '🫘', 'haba': '🫘',
    // --- Condimentos y básicos ---
    'sal': '🧂', 'pimienta': '🧂', 'azucar': '🍬',
    'aceite de oliva': '🫒', 'aceite': '🫒', 'oliva': '🫒',
    'salsa': '🥫', 'catsup': '🍅', 'ketchup': '🍅', 'mostaza': '🌭', 'mayonesa': '🥚',
    'vinagre': '🍶', 'caldo': '🍲', 'consome': '🍲',
    // --- Hierbas y especias ---
    'cilantro': '🌿', 'perejil': '🌿', 'albahaca': '🌿', 'oregano': '🌿',
    'comino': '🌿', 'laurel': '🌿', 'hierbabuena': '🌿', 'romero': '🌿',
    'jengibre': '🫚', 'canela': '🌰',
    // --- Otros / despensa ---
    'cafe': '☕', 'te': '🍵', 'chocolate': '🍫', 'cocoa': '🍫', 'cacao': '🍫',
    'miel': '🍯', 'nuez': '🥜', 'cacahuate': '🥜', 'almendra': '🥜', 'nuez de la india': '🥜',
    'galleta': '🍪', 'agua': '💧', 'refresco': '🥤', 'jugo': '🧃',
    'cerveza': '🍺', 'vino': '🍷', 'hielo': '🧊',
    'levadura': '🍞', 'gelatina': '🍮', 'flan': '🍮', 'helado': '🍨',
  };

  /// Claves ordenadas de la más larga a la más corta (multi-palabra primero).
  static final List<String> _sortedKeys = _map.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));

  /// Emoji sugerido para [name], o `null` si no reconocemos el ingrediente.
  static String? emojiFor(String name) {
    final full = _normalize(name);
    if (full.isEmpty) return null;

    final words = full
        .split(RegExp(r'[^a-z0-9]+'))
        .where((w) => w.isNotEmpty)
        .toList();

    for (final key in _sortedKeys) {
      if (key.contains(' ')) {
        if (full.contains(key)) return _map[key];
      } else {
        for (final w in words) {
          // Palabra exacta o plural simple (tomate/tomates, frijol/frijoles).
          if (w == key || w == '${key}s' || w == '${key}es') return _map[key];
        }
      }
    }
    return null;
  }

  /// Emoji para [name] con respaldo: si no lo reconoce, un plato genérico.
  static String emojiOrDefault(String name) => emojiFor(name) ?? '🥄';

  /// Minúsculas, sin acentos ni signos. "Jitomate Guaje" → "jitomate guaje".
  static String _normalize(String input) {
    var s = input.trim().toLowerCase();
    const from = 'áàäâãéèëêíìïîóòöôõúùüûñ';
    const to = 'aaaaaeeeeiiiiooooouuuun';
    final buffer = StringBuffer();
    for (final rune in s.runes) {
      final ch = String.fromCharCode(rune);
      final idx = from.indexOf(ch);
      buffer.write(idx >= 0 ? to[idx] : ch);
    }
    return buffer.toString();
  }
}
