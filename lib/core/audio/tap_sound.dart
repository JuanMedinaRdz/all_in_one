import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reproduce el "thock" suave de tecla al tocar la app.
///
/// Mantiene un pequeño **pool** de reproductores y los va rotando: si tocas
/// rápido, cada toque suena en su propio canal en vez de cortar al anterior.
/// Se usa `PlayerMode.lowLatency`, pensado justo para efectos cortos de UI.
class TapSound {
  TapSound();

  // Grabaciones reales de teclado (set elegido por el usuario). Para cambiar de
  // set basta apuntar a otra carpeta `teclado_N` (ya están todas en los assets).
  static const _soundSet = 'teclado_1';
  static const _sources = [
    'sounds/$_soundSet/tecla_1.wav',
    'sounds/$_soundSet/tecla_2.wav',
    'sounds/$_soundSet/tecla_3.wav',
    'sounds/$_soundSet/tecla_4.wav',
    'sounds/$_soundSet/tecla_5.wav',
    'sounds/$_soundSet/tecla_6.wav',
  ];
  static const _poolSize = 6;

  /// Presente sin ser invasivo. Los WAV ya vienen normalizados, así que este
  /// número manda de verdad sobre qué tan fuerte se oye.
  static const _volume = 0.5;

  /// Al escribir, un pelín más bajo: el tecleo es más seguido y así no cansa.
  static const _keyVolume = 0.4;

  /// Dos toques más juntos que esto suenan a metralleta: se ignora el segundo.
  static const _minGap = Duration(milliseconds: 45);

  /// El tecleo va más rápido que los toques, así que su umbral es más corto
  /// para no "comerse" letras al escribir de corrido.
  static const _minKeyGap = Duration(milliseconds: 28);

  final _players = <AudioPlayer>[];
  final _random = math.Random();
  var _next = 0;
  DateTime _lastTap = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastKey = DateTime.fromMillisecondsSinceEpoch(0);
  var _ready = false;

  /// Permite silenciar los toques sin desmontar nada.
  var enabled = true;

  Future<void> init() async {
    // Si está silenciado no se monta nada (también sirve en tests, que no
    // tienen plataforma de audio).
    if (_ready || !enabled) return;
    try {
      for (var i = 0; i < _poolSize; i++) {
        final player = AudioPlayer()
          ..setReleaseMode(ReleaseMode.stop)
          ..setPlayerMode(PlayerMode.lowLatency);
        // Precargar evita el retardo de la primera reproducción.
        await player.setSource(AssetSource(_sources[i % _sources.length]));
        await player.setVolume(_volume);
        _players.add(player);
      }
      _ready = true;
    } catch (e) {
      // Sin audio la app funciona igual; no vale la pena tumbarla por esto.
      debugPrint('No pude preparar el sonido de toque: $e');
    }
  }

  /// Sonido de tocar/seleccionar algo (botón, tab, tarjeta...).
  void play() => _emit(volume: _volume, gate: _minGap, isKey: false);

  /// Sonido de escribir una tecla. Más bajo y con umbral más corto.
  void playKey() => _emit(volume: _keyVolume, gate: _minKeyGap, isKey: true);

  void _emit({
    required double volume,
    required Duration gate,
    required bool isKey,
  }) {
    if (!_ready || !enabled) return;

    final now = DateTime.now();
    // Toque y tecla llevan su propio reloj para no bloquearse entre sí.
    final last = isKey ? _lastKey : _lastTap;
    if (now.difference(last) < gate) return;
    if (isKey) {
      _lastKey = now;
    } else {
      _lastTap = now;
    }

    final player = _players[_next];
    _next = (_next + 1) % _players.length;

    // Alterna la variante al azar para que no se sienta un bucle.
    final source = _sources[_random.nextInt(_sources.length)];
    player.play(AssetSource(source), volume: volume).ignore();
  }

  Future<void> dispose() async {
    for (final p in _players) {
      await p.dispose();
    }
    _players.clear();
    _ready = false;
  }
}

final tapSoundProvider = Provider<TapSound>((ref) {
  final sound = TapSound();
  ref.onDispose(sound.dispose);
  return sound;
});

/// Envuelve la app para que **seleccionar** (tocar) y **escribir** suenen.
///
/// - Toques: escucha en la raíz, así no hay que tocar botón por botón. Se
///   dispara al bajar el dedo, que es cuando el oído espera el click.
/// - Tecleo: engancha el teclado físico ([HardwareKeyboard]) y suena una vez
///   por tecla escrita (letras, espacio, borrar, enter). Ignora las
///   repeticiones al dejar una tecla presionada para no sonar a metralleta.
///
/// Nota: en móvil el teclado en pantalla lo dibuja el sistema (fuera de la app),
/// así que ahí el sonido por tecla no se puede interceptar; sí suenan los toques
/// y selecciones. En PC (teclado físico) el sonido por tecla funciona pleno.
class TapSoundListener extends ConsumerStatefulWidget {
  const TapSoundListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<TapSoundListener> createState() => _TapSoundListenerState();
}

class _TapSoundListenerState extends ConsumerState<TapSoundListener> {
  @override
  void initState() {
    super.initState();
    // Se prepara tras el primer frame: no retrasa el arranque de la UI.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tapSoundProvider).init();
    });
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  /// Suena al escribir. Devuelve `false` para no consumir la tecla: solo
  /// escuchamos, no interferimos con el tecleo.
  bool _onKey(KeyEvent event) {
    // Solo el primer down de cada tecla (nada de repeticiones ni el "up").
    if (event is! KeyDownEvent) return false;

    final key = event.logicalKey;
    final char = event.character;
    final isPrintable =
        char != null && char.isNotEmpty && char.codeUnitAt(0) >= 32;
    final isEditKey = key == LogicalKeyboardKey.backspace ||
        key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.tab;

    if (isPrintable || isEditKey) {
      ref.read(tapSoundProvider).playKey();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => ref.read(tapSoundProvider).play(),
      child: widget.child,
    );
  }
}
