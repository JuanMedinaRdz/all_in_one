import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';

/// Columna del tablero de To Do's: en qué punto está la tarea.
enum TodoStatus {
  todo('Por hacer', Symbols.radio_button_unchecked_rounded, AppColors.warning),
  doing('En progreso', Symbols.pending_rounded, AppColors.lightSecondary),
  done('Hecho', Symbols.check_circle_rounded, AppColors.success);

  const TodoStatus(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  /// Siguiente estado al avanzar: por hacer → en progreso → hecho → …
  TodoStatus get next => values[(index + 1) % values.length];

  static TodoStatus fromName(String? name) => values.firstWhere(
        (s) => s.name == name,
        orElse: () => TodoStatus.todo,
      );
}
