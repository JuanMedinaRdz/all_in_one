import 'package:all_in_one/core/widgets/tacita.dart';
import 'package:all_in_one/features/calendar/presentation/widgets/day_landscape.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Envuelve con un MediaQuery que activa/desactiva "reducir movimiento".
Widget _wrap({required bool reduce, required Widget child}) => MediaQuery(
      data: MediaQueryData(disableAnimations: reduce),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: child),
      ),
    );

void main() {
  testWidgets(
      'con "reducir movimiento" no quedan tickers corriendo (Tacita + paisaje)',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        reduce: true,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TacitaMascot(state: TacitaState.idle, size: 60),
            SizedBox(width: 300, child: DayLandscape()),
          ],
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 60));

    // Sin animaciones => nadie programa frames.
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('sin "reducir movimiento" Tacita sí anima (hay un ticker activo)',
      (tester) async {
    await tester.pumpWidget(
      _wrap(
        reduce: false,
        child: const TacitaMascot(state: TacitaState.idle, size: 60),
      ),
    );
    await tester.pump(const Duration(milliseconds: 60));

    expect(tester.binding.transientCallbackCount, greaterThan(0));

    // Limpieza: desmonta para que el ticker se libere y no truene el test.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
