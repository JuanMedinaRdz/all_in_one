import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../../core/images/workspace_image_service.dart';
import '../data/note.dart';
import '../data/note_repository.dart';
import '../domain/note_enums.dart';

final noteImageServiceProvider = Provider<WorkspaceImageService>((ref) {
  return WorkspaceImageService(ref.watch(firebaseStorageProvider), folder: 'notes');
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(
    ref.watch(workspaceCollectionProvider('notes')),
    ref.watch(noteImageServiceProvider),
  );
});

/// Todas las notas, en tiempo real. Un solo listener para toda la sección.
final notesProvider = StreamProvider<List<Note>>((ref) async* {
  await ref.watch(anonymousSessionProvider.future);
  yield* ref.watch(noteRepositoryProvider).watchAll();
});

/// Filtro de relevancia activo. `null` = todas.
class NoteFilter extends Notifier<NoteStatus?> {
  @override
  NoteStatus? build() => null;

  /// Tocar el filtro activo lo desactiva: sirve de interruptor.
  void toggle(NoteStatus status) => state = state == status ? null : status;

  void clear() => state = null;
}

final noteFilterProvider =
    NotifierProvider<NoteFilter, NoteStatus?>(NoteFilter.new);

/// Una nota concreta, en vivo. La usa el editor para reflejar cambios hechos
/// desde otro dispositivo mientras la tienes abierta.
final noteProvider = StreamProvider.family<Note?, String>((ref, id) async* {
  await ref.watch(anonymousSessionProvider.future);
  yield* ref.watch(noteRepositoryProvider).watchOne(id);
});
