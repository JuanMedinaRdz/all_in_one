import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';

/// Categorías de un pago mensual.
///
/// Es un conjunto cerrado a propósito: evita erratas ("Streaming" vs
/// "streaming") que romperían los totales, y permite color-coding e iconos
/// estables sin guardar nada de eso en la base.
///
/// El `name` de cada valor es lo que se persiste en Firestore.
enum PaymentCategory {
  streaming('Streaming', Symbols.play_circle_rounded),
  software('Software', Symbols.terminal_rounded),
  servicios('Servicios', Symbols.bolt_rounded),
  renta('Renta', Symbols.home_rounded),
  transporte('Transporte', Symbols.directions_car_rounded),
  comida('Comida', Symbols.restaurant_rounded),
  salud('Salud', Symbols.favorite_rounded),
  educacion('Educación', Symbols.school_rounded),
  gimnasio('Gimnasio', Symbols.fitness_center_rounded),
  compras('Compras', Symbols.shopping_bag_rounded),
  mascotas('Mascotas', Symbols.pets_rounded),
  otros('Otros', Symbols.more_horiz_rounded);

  const PaymentCategory(this.label, this.icon);

  final String label;
  final IconData icon;

  /// Color estable: siempre el mismo para una categoría dada.
  Color get color =>
      AppColors.categoryPalette[index % AppColors.categoryPalette.length];

  /// Lee la categoría guardada en Firestore. Si el valor no se reconoce
  /// (por ejemplo, una categoría vieja ya eliminada), cae en [otros] en vez
  /// de reventar.
  static PaymentCategory fromName(String? name) => values.firstWhere(
        (c) => c.name == name,
        orElse: () => PaymentCategory.otros,
      );
}
