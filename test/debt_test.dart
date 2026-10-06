import 'package:all_in_one/features/finance/application/debt_providers.dart';
import 'package:all_in_one/features/finance/data/debt.dart';
import 'package:flutter_test/flutter_test.dart';

Debt card(String name, double balance, double limit) =>
    Debt(id: name, name: name, balance: balance, creditLimit: limit);

Debt loan(String name, double balance) =>
    Debt(id: name, name: name, balance: balance);

void main() {
  group('Debt', () {
    test('una tarjeta calcula el % de uso del límite', () {
      final d = card('Tarjeta', 4250, 7300);
      expect(d.isCard, isTrue);
      expect(d.utilization, closeTo(0.582, 0.001));
    });

    test('el uso se satura en 100% si el saldo supera el límite', () {
      expect(card('Sobregirada', 9000, 7000).utilization, 1.0);
    });

    test('un préstamo no es tarjeta y no tiene % de uso', () {
      final d = loan('Préstamo', 12800);
      expect(d.isCard, isFalse);
      expect(d.utilization, isNull);
    });

    test('límite en cero no cuenta como tarjeta (evita dividir entre cero)', () {
      expect(Debt(id: 'x', name: 'x', balance: 100, creditLimit: 0).isCard, isFalse);
    });
  });

  group('DebtSummary', () {
    test('suma el saldo de todas las deudas', () {
      final s = DebtSummary.from([
        card('Tarjeta', 4250, 7300),
        loan('Préstamo', 12800),
      ]);
      expect(s.totalBalance, 17050);
      expect(s.count, 2);
      expect(s.isEmpty, isFalse);
    });

    test('sin deudas, total en cero', () {
      final s = DebtSummary.from([]);
      expect(s.totalBalance, 0);
      expect(s.isEmpty, isTrue);
    });
  });
}
