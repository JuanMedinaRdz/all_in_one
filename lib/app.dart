import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/audio/tap_sound.dart';
import 'core/notifications/reminder_scheduler.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_spacing.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/splash_screen.dart';

/// Raíz de la app: tema único (claro/oscuro), router y localización es-MX.
///
/// Envuelve todo en [TapSoundListener] para que cualquier toque suene, y
/// muestra el splash animado antes de entrar.
class AllInOneApp extends ConsumerWidget {
  const AllInOneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Todo en uno',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Arranca en oscuro: es el look premium de la referencia. El claro queda
      // como variante coherente por si algún día se ofrece el cambio.
      themeMode: ThemeMode.dark,
      routerConfig: router,
      locale: const Locale('es', 'MX'),
      supportedLocales: const [Locale('es', 'MX'), Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // El splash se pone encima del router (no en una ruta) para que la app
      // ya esté montada y lista detrás cuando el café termina de servirse.
      builder: (context, child) => ReminderScheduler(
        child: TapSoundListener(
          child: _SplashGate(child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}

/// Muestra [SplashScreen] al arrancar y luego lo funde con la app.
class _SplashGate extends StatefulWidget {
  const _SplashGate({required this.child});

  final Widget child;

  /// Solo el primer arranque del proceso lo ve: volver del segundo plano no
  /// vuelve a mostrar el splash.
  static bool _alreadyShown = false;

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  late bool _showSplash = !_SplashGate._alreadyShown;

  @override
  void initState() {
    super.initState();
    if (_showSplash) {
      _SplashGate._alreadyShown = true;
      Future<void>.delayed(SplashScreen.duration, () {
        if (mounted) setState(() => _showSplash = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.slow,
      child: _showSplash
          ? const SplashScreen(key: ValueKey('splash'))
          : KeyedSubtree(key: const ValueKey('app'), child: widget.child),
    );
  }
}
