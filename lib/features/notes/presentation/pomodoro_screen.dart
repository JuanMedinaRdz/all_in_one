import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_lottie.dart';
import '../../../core/widgets/coffee_cup_painter.dart';

/// Resultado de una sesión Pomodoro.
class PomodoroResult {
  const PomodoroResult({required this.minutes, required this.markDone});

  /// Minutos con los que se corrió (se guardan en el bloque).
  final int minutes;

  /// El usuario marcó la tarea como hecha al terminar.
  final bool markDone;
}

/// Sesión de concentración estilo Pomodoro para una tarea.
///
/// La animación central es una taza de café que se llena poco a poco conforme
/// avanza el tiempo: verla llenarse es el "premio" visual de aguantar la
/// sesión. Va a pantalla completa para ayudar a concentrarse sin distracciones.
class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({
    super.key,
    required this.activity,
    required this.initialMinutes,
  });

  final String activity;
  final int initialMinutes;

  static Future<PomodoroResult?> show(
    BuildContext context, {
    required String activity,
    required int initialMinutes,
  }) {
    return Navigator.of(context).push<PomodoroResult>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => PomodoroScreen(
          activity: activity,
          initialMinutes: initialMinutes,
        ),
      ),
    );
  }

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

enum _Phase { setup, running, paused, done }

class _PomodoroScreenState extends State<PomodoroScreen>
    with SingleTickerProviderStateMixin {
  static const _presets = [5, 10, 15, 25, 45];

  late final AnimationController _ticker;
  final _stopwatch = Stopwatch();

  _Phase _phase = _Phase.setup;
  late int _minutes = widget.initialMinutes.clamp(1, 180);

  Duration get _total => Duration(minutes: _minutes);

  @override
  void initState() {
    super.initState();
    // Controlador continuo: mece las ondas del café y redibuja ~60 fps para
    // que el llenado y la cuenta regresiva se vean fluidos.
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(_onTick);
  }

  void _onTick() {
    if (_phase != _Phase.running) return;
    if (_stopwatch.elapsed >= _total) {
      _finish();
    } else {
      setState(() {}); // redibuja la cuenta y el llenado
    }
  }

  Future<void> _start() async {
    HapticFeedback.mediumImpact();
    _stopwatch
      ..reset()
      ..start();
    _ticker.repeat();
    setState(() => _phase = _Phase.running);
  }

  void _pause() {
    HapticFeedback.lightImpact();
    _stopwatch.stop();
    setState(() => _phase = _Phase.paused);
  }

  void _resume() {
    HapticFeedback.lightImpact();
    _stopwatch.start();
    setState(() => _phase = _Phase.running);
  }

  void _reset() {
    _stopwatch
      ..stop()
      ..reset();
    _ticker.stop();
    setState(() => _phase = _Phase.setup);
  }

  void _finish() {
    _stopwatch.stop();
    _ticker.stop();
    HapticFeedback.heavyImpact();
    setState(() => _phase = _Phase.done);
  }

  void _close({required bool markDone}) {
    Navigator.of(context).pop(
      PomodoroResult(minutes: _minutes, markDone: markDone),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double get _fill {
    if (_phase == _Phase.done) return 1;
    if (_phase == _Phase.setup) return 0;
    return (_stopwatch.elapsed.inMilliseconds / _total.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  String get _remainingLabel {
    final remaining = _total - _stopwatch.elapsed;
    final secs = remaining.inSeconds.clamp(0, _total.inSeconds);
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Symbols.close_rounded),
          tooltip: 'Salir',
        ),
        title: const Text('Modo concentración'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Text(
                widget.activity.trim().isEmpty
                    ? 'Tu sesión'
                    : widget.activity,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const Spacer(),
              // La taza, con fuegos artificiales encima al terminar.
              SizedBox(
                width: 260,
                height: 240,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 220,
                      child: CustomPaint(
                        painter: CoffeeCupPainter(
                          fill: _fill,
                          wavePhase: _ticker.value * 2 * 3.14159,
                          coffee: const Color(0xFF9C6B43), // café cálido fijo
                          cup: scheme.onSurface,
                          foam: AppColors.warning,
                          steam: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (_phase == _Phase.done)
                      const AppLottie(
                        AppAnim.celebration,
                        size: 260,
                        repeat: false,
                      ),
                  ],
                ),
              ),
              AppSpacing.gapXl,
              if (_phase == _Phase.setup)
                _Setup(
                  minutes: _minutes,
                  presets: _presets,
                  onMinutes: (m) => setState(() => _minutes = m),
                )
              else
                Text(
                  _phase == _Phase.done ? '¡Listo! ☕' : _remainingLabel,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ).animate(target: _phase == _Phase.done ? 1 : 0).scaleXY(
                      begin: 1,
                      end: 1.05,
                      duration: AppMotion.medium,
                    ),
              const Spacer(),
              _Controls(
                phase: _phase,
                onStart: _start,
                onPause: _pause,
                onResume: _resume,
                onReset: _reset,
                onDone: () => _close(markDone: true),
                onCloseNoDone: () => _close(markDone: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selector de tiempo antes de empezar: presets + ajuste fino con +/-.
class _Setup extends StatelessWidget {
  const _Setup({
    required this.minutes,
    required this.presets,
    required this.onMinutes,
  });

  final int minutes;
  final List<int> presets;
  final ValueChanged<int> onMinutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          alignment: WrapAlignment.center,
          children: [
            for (final p in presets)
              ChoiceChip(
                label: Text('$p min'),
                selected: minutes == p,
                onSelected: (_) => onMinutes(p),
              ),
          ],
        ),
        AppSpacing.gapLg,
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              onPressed:
                  minutes > 1 ? () => onMinutes((minutes - 5).clamp(1, 180)) : null,
              icon: const Icon(Symbols.remove_rounded),
            ),
            SizedBox(
              width: 120,
              child: Text(
                '$minutes min',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
            ),
            IconButton.filledTonal(
              onPressed: minutes < 180
                  ? () => onMinutes((minutes + 5).clamp(1, 180))
                  : null,
              icon: const Icon(Symbols.add_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.phase,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onReset,
    required this.onDone,
    required this.onCloseNoDone,
  });

  final _Phase phase;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onReset;
  final VoidCallback onDone;
  final VoidCallback onCloseNoDone;

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case _Phase.setup:
        return SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Symbols.play_arrow_rounded, fill: 1),
            label: const Text('Comenzar'),
          ),
        );
      case _Phase.running:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Symbols.restart_alt_rounded),
              label: const Text('Reiniciar'),
            ),
            AppSpacing.gapMd,
            FilledButton.icon(
              onPressed: onPause,
              icon: const Icon(Symbols.pause_rounded, fill: 1),
              label: const Text('Pausar'),
            ),
          ],
        );
      case _Phase.paused:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Symbols.restart_alt_rounded),
              label: const Text('Reiniciar'),
            ),
            AppSpacing.gapMd,
            FilledButton.icon(
              onPressed: onResume,
              icon: const Icon(Symbols.play_arrow_rounded, fill: 1),
              label: const Text('Seguir'),
            ),
          ],
        );
      case _Phase.done:
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onDone,
                icon: const Icon(Symbols.check_rounded),
                label: const Text('Marcar como hecho'),
              ),
            ),
            AppSpacing.gapSm,
            TextButton(
              onPressed: onCloseNoDone,
              child: const Text('Cerrar'),
            ),
          ],
        );
    }
  }
}
