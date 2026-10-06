import 'package:all_in_one/features/finance/application/finance_summary.dart';
import 'package:all_in_one/features/finance/data/payment.dart';
import 'package:flutter_test/flutter_test.dart';

Payment p(String name, double amount, String category) => Payment(
      id: name,
      name: name,
      amountMxn: amount,
      category: category,
      dayOfMonth: 1,
    );

void main() {
  group('FinanceSummary', () {
    test('sin pagos, todo en cero y sin dividir entre cero', () {
      final s = FinanceSummary.from([]);

      expect(s.totalMxn, 0);
      expect(s.byCategory, isEmpty);
      expect(s.biggest, isNull);
      expect(s.isEmpty, isTrue);
      expect(s.count, 0);
    });

    test('suma todos los pagos (ya no hay activos/inactivos)', () {
      final s = FinanceSummary.from([
        p('Netflix', 219, 'Streaming'),
        p('Spotify', 129, 'Streaming'),
        p('Gym', 500, 'Gimnasio'),
      ]);

      expect(s.totalMxn, 848);
      expect(s.count, 3);
      expect(s.yearlyMxn, 848 * 12);
    });

    test('agrupa por categoría (texto libre) y ordena de mayor a menor', () {
      final s = FinanceSummary.from([
        p('Netflix', 200, 'Streaming'),
        p('Spotify', 100, 'Streaming'),
        p('Renta', 600, 'Renta'),
        p('Luz', 100, 'Servicios'),
      ]);

      expect(s.totalMxn, 1000);
      expect(
        s.byCategory.map((c) => c.label).toList(),
        ['Renta', 'Streaming', 'Servicios'],
      );

      final renta = s.byCategory.first;
      expect(renta.totalMxn, 600);
      expect(renta.fraction, 0.6);
      expect(renta.count, 1);

      final streaming = s.byCategory[1];
      expect(streaming.totalMxn, 300);
      expect(streaming.count, 2);
    });

    test('categorías con distinta capitalización/espacios se unen', () {
      final s = FinanceSummary.from([
        p('Netflix', 200, 'Streaming'),
        p('Disney', 150, 'streaming '),
      ]);
      expect(s.byCategory.length, 1);
      expect(s.byCategory.single.totalMxn, 350);
    });

    test('una categoría vacía se etiqueta como "Sin categoría"', () {
      final s = FinanceSummary.from([p('Algo suelto', 100, '')]);
      expect(s.byCategory.single.displayLabel, 'Sin categoría');
    });

    test('identifica el pago más caro', () {
      final s = FinanceSummary.from([
        p('Netflix', 219, 'Streaming'),
        p('Renta', 8000, 'Renta'),
        p('Gym', 500, 'Gimnasio'),
      ]);
      expect(s.biggest?.name, 'Renta');
    });
  });
}
