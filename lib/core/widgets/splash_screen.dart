import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'coffee_cup_painter.dart';

/// Pantalla de bienvenida: la taza de la app se sirve sola mientras arranca.
///
/// Reusa el mismo [CoffeeCupPainter] del modo concentración a propósito: la
/// taza llenándose es la firma visual de la app, y verla aquí y allá hace que
/// todo se sienta de la misma pieza.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Cuánto dura la animación completa. La app espera al menos esto antes de
  /// entrar, para que el gesto se disfrute en vez de parpadear.
  static const duration = Duration(milliseconds: 2100);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// Sirve el café: 0 → 1.
  late final AnimationController _pour;

  /// Mece la superficie y el vapor, en bucle.
  late final AnimationController _idle;

  late final Animation<double> _fill;

  @override
  void initState() {
    super.initState();
    _pour = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fill = CurvedAnimation(parent: _pour, curve: Curves.easeInOutCubic);
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Pequeña pausa antes de servir: da tiempo a que entre la taza.
    Future<void>.delayed(const Duration(milliseconds: 260), () {
      if (mounted) _pour.forward();
    });
  }

  @override
  void dispose() {
    _pour.dispose();
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 150,
              height: 168,
              child: AnimatedBuilder(
                animation: Listenable.merge([_pour, _idle]),
                builder: (context, _) => CustomPaint(
                  painter: CoffeeCupPainter(
                    fill: _fill.value,
                    wavePhase: _idle.value * 2 * 3.14159,
                    // Café cálido fijo: sigue siendo un vaso de café aunque el
                    // tema sea verde, un guiño cozy dentro de la app premium.
                    coffee: const Color(0xFF9C6B43),
                    cup: scheme.onSurface,
                    foam: AppColors.warning,
                    steam: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scaleXY(begin: 0.85, end: 1, duration: 700.ms, curve: Curves.easeOutBack),
            AppSpacing.gapXl,
            Text(
              'Todo en uno',
              style: theme.textTheme.headlineMedium,
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: 600.ms)
                .slideY(begin: 0.35, end: 0, curve: Curves.easeOutCubic),
            AppSpacing.gapSm,
            Text(
              'tu espacio, sin prisa',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ).animate().fadeIn(delay: 1100.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
