import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../firebase_options.dart';

/// Estado de la conexión con Firebase al arrancar.
enum FirebaseStatus {
  /// Firebase quedó inicializado y listo para usarse.
  ready,

  /// Se intentó inicializar pero hubo un error (plataforma no soportada,
  /// configuración inválida...). La app arranca igual, con un aviso.
  error,
}

/// Inicializa Firebase de forma **no fatal**: si falla, la app arranca igual
/// mostrando un aviso, en vez de quedarse en pantalla negra.
///
/// A propósito **no** inicia sesión aquí: `signInAnonymously()` es una llamada
/// de red, y esperarla antes de `runApp()` dejaba la app en el splash varios
/// segundos en la primera instalación. La sesión la resuelve
/// `anonymousSessionProvider`, ya con la UI en pantalla.
abstract final class FirebaseBootstrap {
  const FirebaseBootstrap._();

  static Future<FirebaseStatus> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Persistencia offline: al recargar, la UI se sirve del caché local y los
      // listeners solo traen deltas. Evita re-lecturas completas de Firestore.
      // Debe quedar fijado antes del primer uso de Firestore.
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      return FirebaseStatus.ready;
    } catch (e, st) {
      debugPrint('Firebase init falló: $e\n$st');
      return FirebaseStatus.error;
    }
  }
}

/// Expone el estado de Firebase a la UI. Se sobrescribe en `main()` con el
/// resultado real de `FirebaseBootstrap.init()`.
final firebaseStatusProvider = Provider<FirebaseStatus>(
  (ref) => throw UnimplementedError('Sobrescribir en main() con ProviderScope'),
);
