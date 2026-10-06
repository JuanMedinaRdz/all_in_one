import 'package:all_in_one/features/finance/data/payment.dart';
import 'package:all_in_one/features/finance/domain/payment_schedule.dart';
import 'package:flutter_test/flutter_test.dart';

Payment pay(String name, int day) =>
    Payment(id: name, name: name, amountMxn: 100, dayOfMonth: day);

void main() {
  group('PaymentSchedule.nextCharge', () {
    test('si el día de este mes aún no pasa, es este mes', () {
      final from = DateTime(2026, 7, 10);
      expect(PaymentSchedule.nextCharge(28, from: from), DateTime(2026, 7, 28));
    });

    test('el mismo día cuenta como próximo (no salta al mes siguiente)', () {
      final from = DateTime(2026, 7, 28);
      expect(PaymentSchedule.nextCharge(28, from: from), DateTime(2026, 7, 28));
    });

    test('si el día ya pasó, salta al mes siguiente', () {
      final from = DateTime(2026, 7, 29);
      expect(PaymentSchedule.nextCharge(28, from: from), DateTime(2026, 8, 28));
    });

    test('el día 31 se recorre al último día en meses cortos', () {
      // Desde el 1 de febrero de 2026 (28 días), un pago el 31 cae el 28.
      expect(
        PaymentSchedule.nextCharge(31, from: DateTime(2026, 2, 1)),
        DateTime(2026, 2, 28),
      );
    });

    test('cruza el fin de año correctamente', () {
      final from = DateTime(2026, 12, 20);
      expect(PaymentSchedule.nextCharge(5, from: from), DateTime(2027, 1, 5));
    });
  });

  group('PaymentSchedule.daysUntilNext', () {
    test('hoy = 0', () {
      expect(PaymentSchedule.daysUntilNext(15, from: DateTime(2026, 7, 15)), 0);
    });

    test('mañana = 1', () {
      expect(PaymentSchedule.daysUntilNext(16, from: DateTime(2026, 7, 15)), 1);
    });

    test('la hora del día no afecta el conteo', () {
      final from = DateTime(2026, 7, 15, 23, 59);
      expect(PaymentSchedule.daysUntilNext(20, from: from), 5);
    });
  });

  group('UpcomingPayment.schedule', () {
    test('ordena los pagos por proximidad de cobro', () {
      final from = DateTime(2026, 7, 10);
      final schedule = UpcomingPayment.schedule(
        [pay('Renta', 1), pay('Spotify', 28), pay('Netflix', 12)],
        from: from,
      );
      // Renta (día 1) ya pasó → agosto; Netflix (12) y Spotify (28) este mes.
      expect(
        schedule.map((u) => u.payment.name).toList(),
        ['Netflix', 'Spotify', 'Renta'],
      );
      expect(schedule.first.daysUntil, 2); // del 10 al 12
    });
  });
}
