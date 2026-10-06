import 'dart:ui';

import '../../../core/theme/app_colors.dart';
import '../data/payment.dart';

/// Cuánto pesa una categoría dentro del gasto mensual.
class CategoryTotal {
  const CategoryTotal({
    required this.label,
    required this.color,
    required this.totalMxn,
    required this.fraction,
    required this.count,
  });

  /// Nombre de la categoría, tal como el usuario lo escribió. Vacío = "Sin
  /// categoría".
  final String label;

  /// Color del segmento. Estable por nombre de categoría, así el desglose se ve
  /// consistente aunque cada membresía tenga su color propio.
  final Color color;

  final double totalMxn;

  /// Proporción del total mensual (0–1). Ya viene calculada para que la UI
  /// no tenga que dividir (ni arriesgarse a dividir entre cero).
  final double fraction;

  final int count;

  String get displayLabel => label.isEmpty ? 'Sin categoría' : label;
}

/// Resumen del gasto mensual, derivado de la lista de pagos que ya tenemos
/// en memoria. No dispara ni una sola lectura extra a Firestore.
class FinanceSummary {
  const FinanceSummary({
    required this.totalMxn,
    required this.byCategory,
    required this.count,
    this.biggest,
  });

  /// Total a pagar cada mes.
  final double totalMxn;

  /// Categorías con gasto, de mayor a menor: responde "en qué se me va".
  final List<CategoryTotal> byCategory;

  /// Cuántas mensualidades hay.
  final int count;

  /// El pago individual más caro.
  final Payment? biggest;

  double get yearlyMxn => totalMxn * 12;

  bool get isEmpty => count == 0;

  factory FinanceSummary.from(List<Payment> payments) {
    final total = payments.fold<double>(0, (sum, p) => sum + p.amountMxn);

    // Agrupa por categoría ignorando mayúsculas y espacios, para que
    // "Streaming" y "streaming " no se separen. Se conserva el primer texto
    // original que apareció para mostrarlo tal cual.
    final totals = <String, ({String label, double sum, int count})>{};
    for (final p in payments) {
      final label = p.category.trim();
      final key = label.toLowerCase();
      final current = totals[key];
      totals[key] = current == null
          ? (label: label, sum: p.amountMxn, count: 1)
          : (
              label: current.label,
              sum: current.sum + p.amountMxn,
              count: current.count + 1,
            );
    }

    final byCategory = totals.entries
        .map((e) => CategoryTotal(
              label: e.value.label,
              // El color usa la clave normalizada: así no cambia por escribir
              // la categoría con otra capitalización.
              color: AppColors.forKey(e.key),
              totalMxn: e.value.sum,
              fraction: total == 0 ? 0 : e.value.sum / total,
              count: e.value.count,
            ))
        .toList()
      ..sort((a, b) => b.totalMxn.compareTo(a.totalMxn));

    return FinanceSummary(
      totalMxn: total,
      byCategory: byCategory,
      count: payments.length,
      biggest: payments.isEmpty
          ? null
          : payments.reduce((a, b) => a.amountMxn >= b.amountMxn ? a : b),
    );
  }
}
