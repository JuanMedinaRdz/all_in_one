/// Lógica pura de los pagos compartidos: clave de mes, rotación "en orden" y
/// reparto de "quién pone cuánto". Sin dependencias de UI ni Firestore, para
/// poder probarla fácil.
abstract final class PaymentSharing {
  const PaymentSharing._();

  /// Clave de mes estable: 2026-10 (año-mes con cero a la izquierda).
  static String monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  /// Devuelve una fecha a partir de una clave de mes (día 1).
  static DateTime monthFromKey(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]));
  }

  /// A quién le toca en [key] según las asignaciones (modo "turns"). `null` si
  /// nadie asignado.
  static String? assignedFor(Map<String, String> assignments, String key) =>
      assignments[key];

  /// Rellena [months] meses a partir de [start] repartiendo [participantIds] en
  /// orden cíclico. Devuelve un mapa mesKey → personId.
  static Map<String, String> fillInOrder(
    List<String> participantIds,
    DateTime start,
    int months,
  ) {
    if (participantIds.isEmpty) return const {};
    final out = <String, String>{};
    var m = DateTime(start.year, start.month);
    for (var i = 0; i < months; i++) {
      out[monthKey(m)] = participantIds[i % participantIds.length];
      m = DateTime(m.year, m.month + 1);
    }
    return out;
  }

  /// Un ítem facturable compartido para repartir en un mes.
  /// [assigned] es a quién le toca ese mes (solo importa en "turns").
  /// Reparte [amount]: en "split" se divide entre participantes; en "turns" va
  /// completo a [assigned].
  static void _applyItem(
    Map<String, double> out, {
    required double amount,
    required List<String> participantIds,
    required String rotationMode,
    required String? assigned,
  }) {
    if (participantIds.isEmpty || amount <= 0) return;
    if (rotationMode == 'split') {
      final each = amount / participantIds.length;
      for (final p in participantIds) {
        out[p] = (out[p] ?? 0) + each;
      }
    } else {
      if (assigned != null) out[assigned] = (out[assigned] ?? 0) + amount;
    }
  }

  /// Reparte una lista de ítems (ya resueltos para el mes) en totales por
  /// persona. Cada ítem es (amount, participantIds, rotationMode, assigned).
  static Map<String, double> contributions(
    Iterable<
            ({
              double amount,
              List<String> participantIds,
              String rotationMode,
              String? assigned,
            })>
        items,
  ) {
    final out = <String, double>{};
    for (final it in items) {
      _applyItem(
        out,
        amount: it.amount,
        participantIds: it.participantIds,
        rotationMode: it.rotationMode,
        assigned: it.assigned,
      );
    }
    return out;
  }
}
