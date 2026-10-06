import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';

/// Catálogo de iconos y colores que el usuario puede elegir para una membresía.
///
/// Los iconos se guardan por su **clave de texto** (no por code point), para
/// que sigan funcionando aunque la fuente cambie de versión. Si una clave
/// guardada ya no existe, se resuelve a un icono por defecto en vez de reventar.
abstract final class PaymentIcons {
  const PaymentIcons._();

  static const IconData fallback = Symbols.subscriptions_rounded;

  /// Clave -> icono. El orden es el que se ve en el selector.
  static const Map<String, IconData> catalog = {
    'subscriptions': Symbols.subscriptions_rounded,
    'play_circle': Symbols.play_circle_rounded,
    'movie': Symbols.movie_rounded,
    'live_tv': Symbols.live_tv_rounded,
    'tv': Symbols.tv_rounded,
    'music_note': Symbols.music_note_rounded,
    'headphones': Symbols.headphones_rounded,
    'sports_esports': Symbols.sports_esports_rounded,
    'cloud': Symbols.cloud_rounded,
    'code': Symbols.code_rounded,
    'terminal': Symbols.terminal_rounded,
    'design_services': Symbols.design_services_rounded,
    'brush': Symbols.brush_rounded,
    'palette': Symbols.palette_rounded,
    'photo_camera': Symbols.photo_camera_rounded,
    'bolt': Symbols.bolt_rounded,
    'water_drop': Symbols.water_drop_rounded,
    'wifi': Symbols.wifi_rounded,
    'router': Symbols.router_rounded,
    'phone_iphone': Symbols.phone_iphone_rounded,
    'home': Symbols.home_rounded,
    'apartment': Symbols.apartment_rounded,
    'directions_car': Symbols.directions_car_rounded,
    'local_gas_station': Symbols.local_gas_station_rounded,
    'directions_bus': Symbols.directions_bus_rounded,
    'train': Symbols.train_rounded,
    'pedal_bike': Symbols.pedal_bike_rounded,
    'flight': Symbols.flight_rounded,
    'restaurant': Symbols.restaurant_rounded,
    'local_cafe': Symbols.local_cafe_rounded,
    'cake': Symbols.cake_rounded,
    'shopping_bag': Symbols.shopping_bag_rounded,
    'shopping_cart': Symbols.shopping_cart_rounded,
    'card_giftcard': Symbols.card_giftcard_rounded,
    'favorite': Symbols.favorite_rounded,
    'fitness_center': Symbols.fitness_center_rounded,
    'sports_soccer': Symbols.sports_soccer_rounded,
    'sports_basketball': Symbols.sports_basketball_rounded,
    'self_improvement': Symbols.self_improvement_rounded,
    'spa': Symbols.spa_rounded,
    'medical_services': Symbols.medical_services_rounded,
    'medication': Symbols.medication_rounded,
    'school': Symbols.school_rounded,
    'menu_book': Symbols.menu_book_rounded,
    'work': Symbols.work_rounded,
    'business_center': Symbols.business_center_rounded,
    'language': Symbols.language_rounded,
    'public': Symbols.public_rounded,
    'pets': Symbols.pets_rounded,
    'child_care': Symbols.child_care_rounded,
    'savings': Symbols.savings_rounded,
    'credit_card': Symbols.credit_card_rounded,
    'account_balance': Symbols.account_balance_rounded,
    'star': Symbols.star_rounded,
    'bookmark': Symbols.bookmark_rounded,
    'key': Symbols.key_rounded,
    'celebration': Symbols.celebration_rounded,
    'receipt_long': Symbols.receipt_long_rounded,
  };

  static List<String> get keys => catalog.keys.toList();

  /// Resuelve una clave guardada a su icono. Nunca falla.
  static IconData resolve(String? key) => catalog[key] ?? fallback;
}

/// Paleta de colores para elegir, cálida y coherente con el tema.
abstract final class PaymentColors {
  const PaymentColors._();

  /// Reusa la paleta de categorías del tema y añade algunos tonos más para dar
  /// margen a la personalización.
  static const List<Color> swatches = [
    ...AppColors.categoryPalette,
    Color(0xFFA8674F), // canela
    Color(0xFF6D8B74), // eucalipto
    Color(0xFFC9A227), // ocre
    Color(0xFF8E7CC3), // lavanda apagada
    Color(0xFF5B8A9A), // azul pizarra
    Color(0xFFBF6D6D), // rosa viejo
  ];

  static int toValue(Color c) => c.toARGB32();

  static Color fromValue(int value) => Color(value);
}
