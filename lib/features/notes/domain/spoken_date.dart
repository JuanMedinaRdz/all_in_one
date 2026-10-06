/// Detecta una fecha mencionada en texto libre en español ("mañana", "el
/// viernes", "el 28 de julio", "en 3 días"...) y la convierte en un día
/// concreto para el recordatorio del calendario.
///
/// Es un parser propio, puro y sin dependencias: no llama a ningún servicio ni
/// hace peticiones. Prioriza precisión sobre cobertura — ante la duda, no
/// inventa una fecha (mejor no poner recordatorio que poner uno equivocado).
class SpokenDate {
  const SpokenDate({required this.date, required this.matchedText});

  /// Día detectado, normalizado a medianoche.
  final DateTime date;

  /// El trozo de texto que disparó la detección (para poder avisar al usuario
  /// qué se entendió: "detecté 'el viernes'").
  final String matchedText;

  static const _months = {
    'enero': 1, 'febrero': 2, 'marzo': 3, 'abril': 4, 'mayo': 5, 'junio': 6,
    'julio': 7, 'agosto': 8, 'septiembre': 9, 'setiembre': 9, 'octubre': 10,
    'noviembre': 11, 'diciembre': 12,
  };

  /// Días de la semana: nombre -> weekday de DateTime (lunes = 1).
  static const _weekdays = {
    'lunes': 1, 'martes': 2, 'miercoles': 3, 'miércoles': 3, 'jueves': 4,
    'viernes': 5, 'sabado': 6, 'sábado': 6, 'domingo': 7,
  };

  static const _numberWords = {
    'un': 1, 'una': 1, 'uno': 1, 'dos': 2, 'tres': 3, 'cuatro': 4, 'cinco': 5,
    'seis': 6, 'siete': 7, 'ocho': 8, 'nueve': 9, 'diez': 10, 'once': 11,
    'doce': 12, 'trece': 13, 'catorce': 14, 'quince': 15,
  };

  /// Intenta extraer una fecha de [text]. `null` si no encuentra ninguna.
  ///
  /// [now] permite fijar "hoy" en los tests; por defecto es la fecha actual.
  static SpokenDate? parse(String text, {DateTime? now}) {
    final today = _atMidnight(now ?? DateTime.now());
    final lower = text.toLowerCase();

    // El orden importa: primero las expresiones más específicas y menos
    // ambiguas, para que "pasado mañana" no lo capture "mañana".
    return _relativeWords(lower, today) ??
        _inNDays(lower, today) ??
        _dayWithMonth(lower, today) ??
        _weekday(lower, today) ??
        _dayOfMonthOnly(lower, today);
  }

  // "hoy", "mañana", "pasado mañana"
  static SpokenDate? _relativeWords(String text, DateTime today) {
    if (RegExp(r'pasado\s+ma[ñn]ana').hasMatch(text)) {
      return SpokenDate(
          date: today.add(const Duration(days: 2)),
          matchedText: 'pasado mañana');
    }

    // "mañana" es delicado: también significa "morning". Si viene precedido de
    // "la"/"esta" ("por la mañana", "esta mañana") es la parte del día, no el
    // día siguiente, así que no se toma como recordatorio.
    final manana = RegExp(r'\bma[ñn]ana\b').firstMatch(text);
    if (manana != null) {
      final before = text.substring(0, manana.start).trimRight();
      final isMorning = before.endsWith('la') || before.endsWith('esta');
      if (!isMorning) {
        return SpokenDate(
            date: today.add(const Duration(days: 1)), matchedText: 'mañana');
      }
    }

    if (RegExp(r'\bhoy\b').hasMatch(text)) {
      return SpokenDate(date: today, matchedText: 'hoy');
    }
    return null;
  }

  // "en 3 días", "en dos semanas", "en una semana"
  static SpokenDate? _inNDays(String text, DateTime today) {
    final m = RegExp(r'en\s+(\d+|' +
            _numberWords.keys.join('|') +
            r')\s+(d[íi]as?|semanas?)')
        .firstMatch(text);
    if (m == null) return null;

    final n = int.tryParse(m.group(1)!) ?? _numberWords[m.group(1)];
    if (n == null) return null;
    final isWeeks = m.group(2)!.startsWith('semana');
    return SpokenDate(
      date: today.add(Duration(days: isWeeks ? n * 7 : n)),
      matchedText: m.group(0)!,
    );
  }

  // "28 de julio", "el 3 de marzo" (con o sin año)
  static SpokenDate? _dayWithMonth(String text, DateTime today) {
    final m = RegExp(r'(\d{1,2})\s+de\s+(' + _months.keys.join('|') + r')' +
            r'(?:\s+de(?:l)?\s+(\d{4}))?')
        .firstMatch(text);
    if (m == null) return null;

    final day = int.parse(m.group(1)!);
    final month = _months[m.group(2)]!;
    if (day < 1 || day > _daysInMonth(today.year, month)) return null;

    final year = m.group(3) != null ? int.parse(m.group(3)!) : today.year;
    var date = DateTime(year, month, day);
    // Sin año explícito y ya pasó: se entiende el del año que viene.
    if (m.group(3) == null && date.isBefore(today)) {
      date = DateTime(year + 1, month, day);
    }
    return SpokenDate(date: date, matchedText: m.group(0)!);
  }

  // "el viernes", "este lunes", "el próximo martes"
  static SpokenDate? _weekday(String text, DateTime today) {
    final m = RegExp(r'(pr[óo]ximo\s+|este\s+|el\s+)?(' +
            _weekdays.keys.join('|') +
            r')\b')
        .firstMatch(text);
    if (m == null) return null;

    final target = _weekdays[m.group(2)]!;
    // Próxima ocurrencia de ese día. Si hoy ya es ese día, se toma el de la
    // semana siguiente (decir "el viernes" un viernes casi siempre es "el que
    // viene").
    var delta = (target - today.weekday) % 7;
    if (delta == 0) delta = 7;
    return SpokenDate(
      date: today.add(Duration(days: delta)),
      matchedText: m.group(0)!.trim(),
    );
  }

  // "el 28", "el día 15" (día del mes, sin nombre de mes)
  static SpokenDate? _dayOfMonthOnly(String text, DateTime today) {
    final m = RegExp(r'\bel\s+(?:d[íi]a\s+)?(\d{1,2})\b').firstMatch(text);
    if (m == null) return null;

    // Si al número le sigue "de <mes>", es parte de una fecha con mes que ya
    // se evaluó (y se descartó por inválida, p. ej. "30 de febrero"): no se
    // reinterpreta como día suelto del mes actual.
    final rest = text.substring(m.end).trimLeft();
    if (RegExp(r'^de\s+(' + _months.keys.join('|') + r')').hasMatch(rest)) {
      return null;
    }

    final day = int.parse(m.group(1)!);
    if (day < 1 || day > 31) return null;

    // Este mes si aún no pasa; si ya pasó, el mes que viene.
    var year = today.year;
    var month = today.month;
    if (day > _daysInMonth(year, month) || DateTime(year, month, day).isBefore(today)) {
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
      // Si el mes siguiente tampoco tiene ese día (p.ej. 31), no arriesga.
      if (day > _daysInMonth(year, month)) return null;
    }
    return SpokenDate(date: DateTime(year, month, day), matchedText: m.group(0)!);
  }

  static DateTime _atMidnight(DateTime d) => DateTime(d.year, d.month, d.day);

  static int _daysInMonth(int year, int month) =>
      DateTime(year, month + 1, 0).day;
}
