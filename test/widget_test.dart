import 'package:all_in_one/app.dart';
import 'package:all_in_one/core/audio/tap_sound.dart';
import 'package:all_in_one/core/firebase/firebase_bootstrap.dart';
import 'package:all_in_one/core/widgets/splash_screen.dart';
import 'package:all_in_one/features/calendar/presentation/calendar_screen.dart';
import 'package:all_in_one/features/finance/presentation/finance_screen.dart';
import 'package:all_in_one/features/notes/presentation/notes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    // Sin descargas de fuentes en tests: usa el fallback local.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          firebaseStatusProvider.overrideWithValue(FirebaseStatus.ready),
          // Sin audio en tests: no hay plataforma que lo reproduzca.
          tapSoundProvider.overrideWithValue(TapSound()..enabled = false),
        ],
        child: const AllInOneApp(),
      ),
    );
    // Las animaciones corren en bucle, así que `pumpAndSettle` nunca
    // terminaría: avanzamos el tiempo a mano, primero más allá del splash.
    await tester.pump();
    await tester.pump(SplashScreen.duration + const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 800)); // fundido a la app
  }

  testWidgets('arranca en Calendario con las tres secciones disponibles',
      (tester) async {
    await pumpApp(tester);

    expect(find.byType(CalendarScreen), findsOneWidget);
    // Las otras dos están montadas pero fuera de escena (conservan su estado).
    expect(find.byType(FinanceScreen), findsNothing);
    expect(find.byType(NotesScreen), findsNothing);
  });

  testWidgets('navega entre secciones desde el riel lateral', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900)); // escritorio
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester);
    expect(find.byType(NavigationRail), findsOneWidget);

    await tester.tap(find.text('Mensualidades'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(FinanceScreen), findsOneWidget);
    expect(find.byType(CalendarScreen), findsNothing);
  });

  testWidgets('en pantalla angosta usa la barra inferior', (tester) async {
    await tester.binding.setSurfaceSize(const Size(420, 900)); // móvil
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await pumpApp(tester);

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });
}
