import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Instancias de Firebase inyectadas vía Riverpod: un solo punto de acceso,
/// fáciles de sustituir en tests.
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firebaseStorageProvider = Provider<FirebaseStorage>(
  (ref) => FirebaseStorage.instance,
);

/// Sesión anónima invisible (nunca hay pantalla de login).
///
/// Las reglas de seguridad exigen sesión, así que la capa de datos espera este
/// provider antes de consultar nada. Es un `FutureProvider` y no algo que se
/// resuelva en `main()` para que la UI se pinte de inmediato: solo la primera
/// instalación paga la llamada de red; después la sesión ya está en el
/// dispositivo y `currentUser` responde al instante.
final anonymousSessionProvider = FutureProvider<User>((ref) async {
  final auth = ref.watch(firebaseAuthProvider);

  final existing = auth.currentUser;
  if (existing != null) return existing;

  final credential = await auth.signInAnonymously();
  return credential.user!;
});

/// Documento raíz compartido. TODOS tus dispositivos leen/escriben bajo
/// `workspace/main`, de modo que los datos se sincronizan aunque cada
/// dispositivo tenga un UID anónimo distinto (no hay login).
final workspaceRefProvider = Provider<DocumentReference<Map<String, dynamic>>>(
  (ref) => ref.watch(firestoreProvider).doc('workspace/main'),
);

/// Colección dentro del workspace compartido. Se usa desde cada feature
/// (p. ej. `ref.watch(workspaceCollectionProvider('payments'))`).
final workspaceCollectionProvider =
    Provider.family<CollectionReference<Map<String, dynamic>>, String>(
  (ref, name) => ref.watch(workspaceRefProvider).collection(name),
);
