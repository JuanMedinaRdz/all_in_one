import 'package:all_in_one/features/notes/domain/spoken_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // "Hoy" fijo: miércoles 15 de julio de 2026.
  final now = DateTime(2026, 7, 15);
  DateTime? dateOf(String text) => SpokenDate.parse(text, now: now)?.date;

  group('relativas', () {
    test('hoy', () {
      expect(dateOf('llamar al doctor hoy'), DateTime(2026, 7, 15));
    });

    test('mañana', () {
      expect(dateOf('mañana tengo dentista'), DateTime(2026, 7, 16));
    });

    test('pasado mañana', () {
      expect(dateOf('pasado mañana entrego el trabajo'), DateTime(2026, 7, 17));
    });

    test('"por la mañana" NO es tomorrow (es parte del día)', () {
      expect(SpokenDate.parse('el viernes por la mañana', now: now)?.matchedText,
          'el viernes');
      expect(dateOf('el viernes por la mañana'), DateTime(2026, 7, 17));
    });

    test('"esta mañana" tampoco se toma como tomorrow', () {
      // Sin otra fecha, "esta mañana" no dispara recordatorio.
      expect(dateOf('esta mañana fui al gym'), isNull);
    });
  });

  group('en N días / semanas', () {
    test('en 3 días', () {
      expect(dateOf('en 3 días reviso esto'), DateTime(2026, 7, 18));
    });

    test('en número escrito con letra', () {
      expect(dateOf('en dos días'), DateTime(2026, 7, 17));
    });

    test('en una semana', () {
      expect(dateOf('nos vemos en una semana'), DateTime(2026, 7, 22));
    });
  });

  group('día con mes', () {
    test('28 de julio (este año, aún no pasa)', () {
      expect(dateOf('pagar el 28 de julio'), DateTime(2026, 7, 28));
    });

    test('un mes ya pasado rueda al año siguiente', () {
      // Enero ya pasó respecto a julio 2026.
      expect(dateOf('cumple el 5 de enero'), DateTime(2027, 1, 5));
    });

    test('con año explícito se respeta', () {
      expect(dateOf('el 3 de marzo de 2030'), DateTime(2030, 3, 3));
    });

    test('un día imposible (30 de febrero) no inventa fecha', () {
      expect(dateOf('el 30 de febrero'), isNull);
    });
  });

  group('día de la semana', () {
    test('el viernes (próximo, desde miércoles)', () {
      expect(dateOf('el viernes hay junta'), DateTime(2026, 7, 17));
    });

    test('decir el día en que estamos apunta a la próxima semana', () {
      // Hoy es miércoles; "el miércoles" => el que viene.
      expect(dateOf('el miércoles toca'), DateTime(2026, 7, 22));
    });

    test('el lunes (envuelve a la siguiente semana)', () {
      expect(dateOf('el lunes empiezo'), DateTime(2026, 7, 20));
    });
  });

  group('día del mes suelto', () {
    test('el 28 (este mes, aún no pasa)', () {
      expect(dateOf('el 28 pago la renta'), DateTime(2026, 7, 28));
    });

    test('un día ya pasado del mes rueda al siguiente', () {
      // Hoy 15; "el 3" ya pasó => agosto 3.
      expect(dateOf('el 3 junta'), DateTime(2026, 8, 3));
    });

    test('"el día 20"', () {
      expect(dateOf('el día 20 es la fecha'), DateTime(2026, 7, 20));
    });
  });

  group('sin fecha', () {
    test('texto sin ninguna referencia temporal', () {
      expect(SpokenDate.parse('comprar leche y pan', now: now), isNull);
    });

    test('expone qué texto disparó la detección', () {
      expect(SpokenDate.parse('recordar mañana', now: now)?.matchedText,
          'mañana');
    });
  });
}
