import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Categoría sugerida para una tarea. Igual que en el resto de la app, la
/// categoría que se guarda es **texto libre**; estos presets solo dan atajos con
/// un color bonito y consistente. Si escribes una categoría nueva, también sirve
/// (toma un color estable derivado de su nombre).
class TodoCategory {
  const TodoCategory(this.label, this.color);

  final String label;
  final Color color;

  static const presets = <TodoCategory>[
    TodoCategory('Trabajo', Color(0xFF46C08A)),
    TodoCategory('Estudio', Color(0xFFE07AAE)),
    TodoCategory('Personal', Color(0xFFE89A3C)),
    TodoCategory('Salud', Color(0xFF3FB6C9)),
    TodoCategory('Finanzas', Color(0xFF4C82F7)),
    TodoCategory('Hogar', Color(0xFF9B7ED9)),
  ];

  /// Color para una categoría cualquiera: el del preset si coincide, o uno
  /// estable derivado del texto.
  static Color colorFor(String label) {
    final lower = label.trim().toLowerCase();
    if (lower.isEmpty) return AppColors.categoryPalette.first;
    for (final p in presets) {
      if (p.label.toLowerCase() == lower) return p.color;
    }
    return AppColors.forKey(lower);
  }
}
