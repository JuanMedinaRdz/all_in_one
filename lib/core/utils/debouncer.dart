import 'dart:async';

import 'package:flutter/foundation.dart';

/// Agrupa ráfagas de llamadas en una sola, tras un rato de calma.
///
/// Se usa al escribir notas: sin esto, cada tecla sería una escritura a
/// Firestore. Con 600 ms, escribir un párrafo completo cuesta **una**.
class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 600)});

  final Duration delay;
  Timer? _timer;
  VoidCallback? _pending;

  /// Programa [action], cancelando la anterior si aún no se ejecutaba.
  void run(VoidCallback action) {
    _pending = action;
    _timer?.cancel();
    _timer = Timer(delay, () {
      _pending?.call();
      _pending = null;
    });
  }

  /// Ejecuta ya lo que estuviera pendiente. Se llama al cerrar la pantalla:
  /// sin esto, lo último que escribiste se perdería si sales antes del plazo.
  void flush() {
    if (_timer?.isActive ?? false) {
      _timer!.cancel();
      _pending?.call();
      _pending = null;
    }
  }

  void dispose() {
    _timer?.cancel();
    _pending = null;
  }
}
