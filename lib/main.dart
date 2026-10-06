import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/firebase/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Formatos de fecha en español de México (nombres de meses, días, etc.).
  await initializeDateFormatting('es_MX');

  // No fatal: si Firebase no está configurado o falla, la app arranca igual
  // y muestra un aviso, en lugar de quedarse en pantalla negra.
  final firebaseStatus = await FirebaseBootstrap.init();

  runApp(
    ProviderScope(
      overrides: [
        firebaseStatusProvider.overrideWithValue(firebaseStatus),
      ],
      child: const AllInOneApp(),
    ),
  );
}
