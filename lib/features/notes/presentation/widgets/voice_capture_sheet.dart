import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/voice_note.dart';

/// Captura de una nota hablando: micrófono grande y pulsante, ondas que
/// reaccionan a tu voz, frases que acompañan y el texto apareciendo en vivo.
///
/// Pensada para capturar ideas al vuelo (TDAH-friendly): un toque, hablas,
/// listo. Puedes pausar y retomar cuantas veces quieras; cada fragmento se va
/// acumulando. Devuelve el texto final, o `null` si se canceló.
class VoiceCaptureSheet extends StatefulWidget {
  const VoiceCaptureSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      isDismissible: false, // que un roce no tire el dictado a la basura
      builder: (_) => const VoiceCaptureSheet(),
    );
  }

  @override
  State<VoiceCaptureSheet> createState() => _VoiceCaptureSheetState();
}

class _VoiceCaptureSheetState extends State<VoiceCaptureSheet> {
  static const _phrases = [
    'Te escucho... ☕',
    'Suéltalo todo 🎙️',
    'Sin prisa, aquí ando 🌿',
    'Sigue, sigue... ✨',
    'Lo estoy apuntando 📝',
  ];

  final _speech = SpeechToText();
  final _scrollController = ScrollController();

  bool _initializing = true;
  bool _available = false;
  bool _listening = false;

  /// Fragmentos ya confirmados por el motor.
  String _accepted = '';

  /// Lo que el motor cree que estás diciendo ahora mismo.
  String _partial = '';

  /// Niveles de sonido recientes, para las barras que bailan.
  final List<double> _levels = List.filled(24, 0);
  int _phraseIndex = 0;
  Timer? _phraseTimer;

  String get _transcript => VoiceNote.join(_accepted, _partial);

  @override
  void initState() {
    super.initState();
    _init();
    _phraseTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted && _listening) {
        setState(() => _phraseIndex = (_phraseIndex + 1) % _phrases.length);
      }
    });
  }

  Future<void> _init() async {
    // initialize() pide el permiso de micrófono la primera vez.
    final ok = await _speech.initialize(
      onStatus: (status) {
        // El motor se detiene solo tras un silencio largo: se refleja en la
        // UI para que el mic invite a retomar.
        if (!mounted) return;
        if (status == 'done' || status == 'notListening') {
          setState(() => _listening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (!mounted) return;
    setState(() {
      _available = ok;
      _initializing = false;
    });
    if (ok) await _start();
  }

  Future<void> _start() async {
    HapticFeedback.mediumImpact();
    setState(() => _listening = true);
    await _speech.listen(
      onResult: _onResult,
      onSoundLevelChange: _onSoundLevel,
      listenOptions: SpeechListenOptions(
        localeId: 'es_MX',
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
        // Margen generoso para pensar sin que corte a media idea.
        pauseFor: const Duration(seconds: 8),
        listenFor: const Duration(minutes: 3),
      ),
    );
  }

  Future<void> _pause() async {
    HapticFeedback.mediumImpact();
    await _speech.stop(); // dispara el resultado final del fragmento
    if (mounted) setState(() => _listening = false);
  }

  void _onResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() {
      if (result.finalResult) {
        _accepted = VoiceNote.join(_accepted, result.recognizedWords);
        _partial = '';
      } else {
        _partial = result.recognizedWords;
      }
    });
    // Autoscroll al final: siempre se ve lo último dicho.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _onSoundLevel(double level) {
    if (!mounted) return;
    setState(() {
      _levels.removeAt(0);
      // El nivel llega en dB relativos (~ -2 a 10); normalizado a 0-1.
      _levels.add(((level + 2) / 12).clamp(0.0, 1.0));
    });
  }

  Future<void> _finish() async {
    if (_listening) await _speech.stop();
    // Pequeña espera para que llegue el resultado final del último fragmento.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(_transcript.trim());
  }

  void _cancel() {
    _speech.cancel();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _phraseTimer?.cancel();
    _speech.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasText = _transcript.trim().isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
            ),
            AppSpacing.gapLg,
            // Frase acompañante (o estado, si algo no va bien).
            AnimatedSwitcher(
              duration: AppMotion.medium,
              child: Text(
                key: ValueKey('$_listening-$_phraseIndex-$_available'),
                _initializing
                    ? 'Preparando el micrófono...'
                    : !_available
                        ? 'Tu dispositivo no tiene reconocimiento de voz 😞'
                        : _listening
                            ? _phrases[_phraseIndex]
                            : hasText
                                ? '¿Algo más? Toca el mic para seguir'
                                : 'Toca el micrófono y habla',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            AppSpacing.gapXl,
            _SoundBars(levels: _levels, active: _listening),
            AppSpacing.gapXl,
            _MicButton(
              listening: _listening,
              enabled: _available && !_initializing,
              onTap: _listening ? _pause : _start,
            ),
            AppSpacing.gapXl,
            // El texto reconocido, en vivo.
            AnimatedContainer(
              duration: AppMotion.medium,
              constraints: const BoxConstraints(minHeight: 64, maxHeight: 160),
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: AppSpacing.brMd,
              ),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: hasText
                    ? Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: _accepted),
                            if (_partial.isNotEmpty)
                              TextSpan(
                                text: _accepted.isEmpty
                                    ? _partial
                                    : ' $_partial',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                        style: theme.textTheme.bodyLarge,
                      )
                    : Text(
                        'Aquí aparecerá lo que digas...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            AppSpacing.gapLg,
            Row(
              children: [
                TextButton(
                  onPressed: _cancel,
                  child: const Text('Cancelar'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: hasText ? _finish : null,
                  icon: const Icon(Symbols.check_rounded),
                  label: const Text('Guardar nota'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// El micrófono: grande, con degradado café→terracota y anillos que pulsan
/// mientras escucha. El centro de la diversión.
class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.listening,
    required this.enabled,
    required this.onTap,
  });

  final bool listening;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget mic = Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: enabled
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [scheme.primary, scheme.secondary],
              )
            : null,
        color: enabled ? null : scheme.surfaceContainerHighest,
        boxShadow: listening
            ? [
                BoxShadow(
                  color: scheme.secondary.withValues(alpha: 0.45),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Icon(
        listening ? Symbols.graphic_eq_rounded : Symbols.mic_rounded,
        fill: 1,
        size: 36,
        color: enabled ? scheme.onPrimary : scheme.onSurfaceVariant,
      ),
    );

    if (listening) {
      // Respira mientras escucha: pulso suave, nada estridente.
      mic = mic
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(begin: 1, end: 1.08, duration: 900.ms, curve: Curves.easeInOut);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Anillos que se expanden y desvanecen, como ondas de sonido.
        if (listening)
          for (final delay in [0.ms, 600.ms])
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: scheme.secondary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .scaleXY(begin: 1, end: 1.9, duration: 1800.ms, delay: delay)
                .fadeOut(duration: 1800.ms, delay: delay),
        InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const CircleBorder(),
          child: mic,
        ),
      ],
    );
  }
}

/// Barras que bailan con tu voz. Cuando no hay dictado, descansan abajo.
class _SoundBars extends StatelessWidget {
  const _SoundBars({required this.levels, required this.active});

  final List<double> levels;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          for (final (i, level) in levels.indexed)
            AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              curve: Curves.easeOut,
              width: 5,
              // Un seno sutil por posición para que incluso el silencio tenga
              // un ritmo visual agradable, tipo ecualizador lo-fi.
              height: active
                  ? 6 +
                      level * 36 +
                      math.sin(i * 0.9).abs() * 4
                  : 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Color.lerp(
                  scheme.primary.withValues(alpha: 0.35),
                  scheme.secondary,
                  level,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
              ),
            ),
        ],
      ),
    );
  }
}
