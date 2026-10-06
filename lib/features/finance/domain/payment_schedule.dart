import '../data/payment.dart';

/// Cálculo de cuándo se cobra un pago. Puro y testeable; sin dependencias de UI
/// ni de Firestore.
abstract final class PaymentSchedule {
  const PaymentSchedule._();

  /// Día real de cobro en un mes concreto.
  ///
  /// Un pago el 31 no existe en febrero, así que se recorre al último día del
  /// mes. Sin esto, esos pagos desaparecerían en los meses cortos.
  static int chargeDay(int year, int month, int dayOfMonth) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return dayOfMonth > lastDay ? lastDay : dayOfMonth;
  }

  /// Fecha de cobro que ocurre en el mismo mes que [reference].
  static DateTime chargeInMonth(DateTime reference, int dayOfMonth) {
    final day = chargeDay(reference.year, reference.month, dayOfMonth);
    return DateTime(reference.year, reference.month, day);
  }

  /// Próxima fecha de cobro a partir de [from] (incluido el propio día).
  ///
  /// Si el cobro de este mes ya pasó, salta al del mes siguiente.
  static DateTime nextCharge(int dayOfMonth, {DateTime? from}) {
    final today = _atMidnight(from ?? DateTime.now());
    final thisMonth = chargeInMonth(today, dayOfMonth);
    if (!thisMonth.isBefore(today)) return thisMonth;

    final nextMonthRef = DateTime(today.year, today.month + 1, 1);
    return chargeInMonth(nextMonthRef, dayOfMonth);
  }

  /// Días que faltan para el próximo cobro (0 = hoy).
  static int daysUntilNext(int dayOfMonth, {DateTime? from}) {
    final today = _atMidnight(from ?? DateTime.now());
    return nextCharge(dayOfMonth, from: today).difference(today).inDays;
  }

  static DateTime _atMidnight(DateTime d) => DateTime(d.year, d.month, d.day);
}

/// Un pago junto con su próxima fecha de cobro, para ordenarlos por proximidad.
class UpcomingPayment {
  const UpcomingPayment({
    required this.payment,
    required this.nextDate,
    required this.daysUntil,
  });

  final Payment payment;
  final DateTime nextDate;
  final int daysUntil;

  factory UpcomingPayment.of(Payment payment, {DateTime? from}) {
    return UpcomingPayment(
      payment: payment,
      nextDate: PaymentSchedule.nextCharge(payment.dayOfMonth, from: from),
      daysUntil: PaymentSchedule.daysUntilNext(payment.dayOfMonth, from: from),
    );
  }

  /// Ordena por fecha; a igualdad de día, el más barato primero (arbitrario
  /// pero estable, para que la lista no baile entre reconstrucciones).
  static int compare(UpcomingPayment a, UpcomingPayment b) {
    final byDate = a.nextDate.compareTo(b.nextDate);
    if (byDate != 0) return byDate;
    return a.payment.amountMxn.compareTo(b.payment.amountMxn);
  }

  /// Ordena una lista de pagos por proximidad de cobro.
  static List<UpcomingPayment> schedule(Iterable<Payment> payments, {DateTime? from}) {
    return [for (final p in payments) UpcomingPayment.of(p, from: from)]
      ..sort(compare);
  }
}
