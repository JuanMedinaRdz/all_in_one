import 'package:intl/intl.dart';

/// Formatos de la app en un solo lugar, siempre en español de México.
abstract final class Fmt {
  const Fmt._();

  static final _mxn = NumberFormat.currency(
    locale: 'es_MX',
    symbol: r'$',
    decimalDigits: 2,
  );

  static final _mxnCompact = NumberFormat.currency(
    locale: 'es_MX',
    symbol: r'$',
    decimalDigits: 0,
  );

  /// `$1,234.50` — para montos donde importan los centavos.
  static String mxn(double value) => _mxn.format(value);

  /// `$1,235` — para totales grandes, donde los centavos son ruido.
  static String mxnCompact(double value) => _mxnCompact.format(value);

  /// `15` → `día 15`. Para el día de cobro de una mensualidad.
  static String dayOfMonth(int day) => 'día $day';

  /// Porcentaje entero: `0.324` → `32%`.
  static String percent(double fraction) =>
      '${(fraction * 100).round()}%';

  /// Días que faltan, en lenguaje humano: `Hoy`, `Mañana`, `En 3 días`.
  static String relativeDays(int days) => switch (days) {
        <= 0 => 'Hoy',
        1 => 'Mañana',
        _ => 'En $days días',
      };

  /// `28 de julio`. Fecha larga sin año, para lo cercano.
  static String dayMonth(DateTime date) =>
      DateFormat("d 'de' MMMM", 'es_MX').format(date);

  /// Minutos desde medianoche → hora de reloj: `540` → `9:00`.
  static String clock(int minutesFromMidnight) {
    final m = minutesFromMidnight % (24 * 60);
    final h = m ~/ 60;
    final mm = (m % 60).toString().padLeft(2, '0');
    return '$h:$mm';
  }

  /// Duración humana: `45` → `45 min`, `60` → `1 h`, `90` → `1 h 30 min`.
  static String duration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? '$h h' : '$h h $m min';
  }
}
