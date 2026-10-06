import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/note.dart';
import '../data/note_folder.dart';
import '../data/note_folder_repository.dart';
import '../data/note_section.dart';
import '../data/note_section_repository.dart';
import 'note_providers.dart';

final noteFolderRepositoryProvider = Provider<NoteFolderRepository>((ref) {
  return NoteFolderRepository(
    ref.watch(workspaceCollectionProvider('noteFolders')),
    ref.watch(workspaceCollectionProvider('notes')),
  );
});

/// Todas las carpetas, en tiempo real. Un solo listener.
final foldersProvider = StreamProvider<List<NoteFolder>>((ref) async* {
  await ref.watch(anonymousSessionProvider.future);
  yield* ref.watch(noteFolderRepositoryProvider).watchAll();
});

final noteSectionRepositoryProvider = Provider<NoteSectionRepository>((ref) {
  return NoteSectionRepository(
    ref.watch(workspaceCollectionProvider('noteSections')),
    ref.watch(workspaceCollectionProvider('notes')),
  );
});

/// Todas las secciones (de todos los espacios), en tiempo real.
final sectionsProvider = StreamProvider<List<NoteSection>>((ref) async* {
  await ref.watch(anonymousSessionProvider.future);
  yield* ref.watch(noteSectionRepositoryProvider).watchAll();
});

/// Secciones de un espacio concreto, ya ordenadas.
final sectionsForFolderProvider =
    Provider.family<List<NoteSection>, String>((ref, folderId) {
  final all = ref.watch(sectionsProvider).value ?? const <NoteSection>[];
  return [for (final s in all) if (s.folderId == folderId) s];
});

/// Conteo de notas por sección (clave `null` = sin sección).
final notesPerSectionProvider = Provider<Map<String?, int>>((ref) {
  final notes = ref.watch(notesProvider).value ?? const <Note>[];
  final counts = <String?, int>{};
  for (final n in notes) {
    counts[n.sectionId] = (counts[n.sectionId] ?? 0) + 1;
  }
  return counts;
});

/// Dónde estás dentro del apartado de notas.
///
/// No son rutas: es navegación interna de la pestaña, así el hub (Notas |
/// Despensa) y la barra inferior no se mueven, y al volver del editor
/// regresas exactamente a donde estabas.
sealed class NotesScope {
  const NotesScope();
}

/// El home: carpetas + recientes.
final class NotesScopeHome extends NotesScope {
  const NotesScopeHome();
}

/// Todas las notas, sin importar carpeta.
final class NotesScopeAll extends NotesScope {
  const NotesScopeAll();
}

/// Solo las notas que no están en ninguna carpeta.
final class NotesScopeUnfiled extends NotesScope {
  const NotesScopeUnfiled();
}

/// Las notas de una carpeta concreta.
final class NotesScopeFolder extends NotesScope {
  const NotesScopeFolder(this.folderId);

  final String folderId;

  @override
  bool operator ==(Object other) =>
      other is NotesScopeFolder && other.folderId == folderId;

  @override
  int get hashCode => folderId.hashCode;
}

class NotesScopeNotifier extends Notifier<NotesScope> {
  @override
  NotesScope build() => const NotesScopeHome();

  void openHome() => state = const NotesScopeHome();
  void openAll() => state = const NotesScopeAll();
  void openUnfiled() => state = const NotesScopeUnfiled();
  void openFolder(String folderId) => state = NotesScopeFolder(folderId);
}

final notesScopeProvider =
    NotifierProvider<NotesScopeNotifier, NotesScope>(NotesScopeNotifier.new);

/// Filtra las notas que pertenecen a un scope. Pura y testeable; en memoria,
/// sin consultas nuevas.
List<Note> notesInScope(NotesScope scope, List<Note> all) => switch (scope) {
      NotesScopeHome() || NotesScopeAll() => all,
      NotesScopeUnfiled() => [
          for (final n in all)
            if (n.folderId == null) n,
        ],
      NotesScopeFolder(:final folderId) => [
          for (final n in all)
            if (n.folderId == folderId) n,
        ],
    };

/// Conteo de notas por carpeta (y las sin carpeta bajo la clave `null`),
/// derivado del stream de notas que ya existe.
final notesPerFolderProvider = Provider<Map<String?, int>>((ref) {
  final notes = ref.watch(notesProvider).value ?? const <Note>[];
  final counts = <String?, int>{};
  for (final n in notes) {
    counts[n.folderId] = (counts[n.folderId] ?? 0) + 1;
  }
  return counts;
});
