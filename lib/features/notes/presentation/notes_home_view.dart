import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/layout/responsive.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/tacita.dart';
import '../application/folder_providers.dart';
import '../application/note_providers.dart';
import '../application/notes_ui_providers.dart';
import '../data/note.dart';
import '../data/note_folder.dart';
import 'widgets/folder_editor_sheet.dart';
import 'widgets/space_cover.dart';
import 'widgets/voice_capture_sheet.dart';

/// Inicio del apartado de Notas: buscador global, aviso de pendientes con
/// Tacita, "Seguir donde lo dejaste" y la cuadrícula de espacios.
class NotesHomeView extends ConsumerWidget {
  const NotesHomeView({super.key});

  Future<void> _createSpace(BuildContext context, WidgetRef ref) async {
    final folder = await FolderEditorSheet.show(context);
    if (folder == null) return;
    await ref.read(noteFolderRepositoryProvider).save(folder);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notesAsync = ref.watch(notesProvider);
    final foldersAsync = ref.watch(foldersProvider);
    final query = ref.watch(notesSearchProvider).trim();

    final error = notesAsync.error ?? foldersAsync.error;
    if (error != null) {
      return _Message('No pude cargar tus notas.\n$error');
    }
    final notes = notesAsync.value;
    final folders = foldersAsync.value;
    if (notes == null || folders == null) return const _Loading();

    // Pendientes (items de checklist sin marcar) por espacio y en total.
    final pendingByFolder = <String?, int>{};
    var totalPending = 0;
    for (final n in notes) {
      final p = n.pendingCount;
      if (p == 0) continue;
      totalPending += p;
      pendingByFolder[n.folderId] = (pendingByFolder[n.folderId] ?? 0) + p;
    }
    final counts = ref.watch(notesPerFolderProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        _SearchField(),
        if (query.isNotEmpty) ...[
          AppSpacing.gapLg,
          _SearchResults(query: query, notes: notes, folders: folders),
        ] else ...[
          if (totalPending > 0) ...[
            AppSpacing.gapLg,
            _TacitaPending(count: totalPending),
          ],
          _ContinueSection(notes: notes),
          AppSpacing.gapXl,
          _SpacesHeader(),
          AppSpacing.gapMd,
          _SpacesGrid(
            folders: folders,
            counts: counts,
            pendingByFolder: pendingByFolder,
            unfiledCount: counts[null] ?? 0,
            onNewSpace: () => _createSpace(context, ref),
          ),
        ],
        if (folders.isEmpty && notes.isEmpty && query.isEmpty) ...[
          AppSpacing.gapXl,
          _EmptyEverything(),
        ],
        AppSpacing.gapSm,
        Text('', style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// Buscador global con botón de dictado.
class _SearchField extends ConsumerStatefulWidget {
  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(notesSearchProvider);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dictate() async {
    final text = await VoiceCaptureSheet.show(context);
    if (text == null || text.trim().isEmpty) return;
    _controller.text = text.trim();
    ref.read(notesSearchProvider.notifier).set(text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: _controller,
      onChanged: (v) => ref.read(notesSearchProvider.notifier).set(v),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar notas, espacios, #etiquetas…',
        prefixIcon: const Icon(Symbols.search_rounded, size: 20),
        filled: true,
        fillColor: theme.colorScheme.surface,
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 6),
          child: IconButton(
            onPressed: _dictate,
            tooltip: 'Dictar',
            icon: const Icon(Symbols.mic_rounded, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.18),
              foregroundColor: theme.colorScheme.secondary,
            ),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.brMd,
          borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.brMd,
          borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}

/// Aviso de pendientes con Tacita + botón "A To Do's".
class _TacitaPending extends StatelessWidget {
  const _TacitaPending({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppSpacing.brMd,
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const TacitaMascot(state: TacitaState.idle, size: 46),
          AppSpacing.gapSm,
          Expanded(
            child: Text.rich(
              TextSpan(
                style: theme.textTheme.bodyMedium,
                children: [
                  const TextSpan(text: 'Encontré '),
                  TextSpan(
                    text: count == 1 ? '1 pendiente' : '$count pendientes',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const TextSpan(text: ' escritos en tus notas.'),
                ],
              ),
            ),
          ),
          AppSpacing.gapSm,
          FilledButton.tonal(
            onPressed: () => context.go(AppRoutes.todos),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.2),
              foregroundColor: theme.colorScheme.secondary,
              visualDensity: VisualDensity.compact,
            ),
            child: const Text("A To Do's"),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppMotion.medium);
  }
}

/// "Seguir donde lo dejaste": carrusel de notas abiertas recientemente.
class _ContinueSection extends StatelessWidget {
  const _ContinueSection({required this.notes});

  final List<Note> notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recent = [...notes]..sort((a, b) {
        final ad = a.lastOpenedAt ?? a.updatedAt;
        final bd = b.lastOpenedAt ?? b.updatedAt;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
    final items = recent.take(6).where((n) => !n.isBlank).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSpacing.gapXl,
        Text('Seguir donde lo dejaste', style: theme.textTheme.titleMedium),
        AppSpacing.gapMd,
        SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => AppSpacing.gapMd,
            itemBuilder: (context, i) => _ContinueCard(note: items[i]),
          ),
        ),
      ],
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = note.taskProgress;
    return SizedBox(
      width: 210,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: AppSpacing.brMd,
        child: InkWell(
          onTap: () => context.go('${AppRoutes.notes}/${note.id}'),
          borderRadius: AppSpacing.brMd,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: AppSpacing.brMd,
              border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.icon.isNotEmpty ? '${note.icon}  ' : '',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  note.title.trim().isEmpty ? 'Sin título' : note.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800, height: 1.2),
                ),
                const Spacer(),
                if (progress != null)
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusPill),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      AppSpacing.gapSm,
                      Text('${(progress * 100).round()}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          )),
                    ],
                  )
                else
                  Text(
                    note.preview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpacesHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final grid = ref.watch(homeSpacesGridProvider);
    return Row(
      children: [
        Text('Espacios', style: theme.textTheme.titleMedium),
        const Spacer(),
        _ViewToggleButton(
          icon: Symbols.grid_view_rounded,
          selected: grid,
          onTap: () => ref.read(homeSpacesGridProvider.notifier).set(true),
        ),
        AppSpacing.gapXs,
        _ViewToggleButton(
          icon: Symbols.view_agenda_rounded,
          selected: !grid,
          onTap: () => ref.read(homeSpacesGridProvider.notifier).set(false),
        ),
      ],
    );
  }
}

class _ViewToggleButton extends StatelessWidget {
  const _ViewToggleButton(
      {required this.icon, required this.selected, required this.onTap});

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: 18),
      style: IconButton.styleFrom(
        backgroundColor: selected
            ? theme.colorScheme.surfaceContainerHighest
            : Colors.transparent,
        foregroundColor:
            selected ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _SpacesGrid extends ConsumerWidget {
  const _SpacesGrid({
    required this.folders,
    required this.counts,
    required this.pendingByFolder,
    required this.unfiledCount,
    required this.onNewSpace,
  });

  final List<NoteFolder> folders;
  final Map<String?, int> counts;
  final Map<String?, int> pendingByFolder;
  final int unfiledCount;
  final VoidCallback onNewSpace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grid = ref.watch(homeSpacesGridProvider);
    final scope = ref.read(notesScopeProvider.notifier);

    final cards = <Widget>[
      for (final f in folders)
        _SpaceCard(
          folder: f,
          notes: counts[f.id] ?? 0,
          pending: pendingByFolder[f.id] ?? 0,
          onTap: () => scope.openFolder(f.id),
        ),
      if (unfiledCount > 0)
        _UnfiledCard(
          notes: unfiledCount,
          pending: pendingByFolder[null] ?? 0,
          onTap: scope.openUnfiled,
        ),
      _NewSpaceCard(onTap: onNewSpace),
    ];

    if (!grid) {
      return Column(
        children: [
          for (final c in cards) ...[c, AppSpacing.gapMd],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = Breakpoints.columnsFor(constraints.maxWidth, target: 200, max: 4);
        const spacing = AppSpacing.md;
        final w = (constraints.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [for (final c in cards) SizedBox(width: w, child: c)],
        );
      },
    );
  }
}

/// Tarjeta de espacio: portada ilustrada + icono + nombre + conteos.
class _SpaceCard extends StatelessWidget {
  const _SpaceCard({
    required this.folder,
    required this.notes,
    required this.pending,
    required this.onTap,
  });

  final NoteFolder folder;
  final int notes;
  final int pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = folder.color;
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: AppSpacing.brLg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: AppSpacing.brLg,
            border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SpaceCover(color: color, seed: folder.id.hashCode),
                  Positioned(
                    left: AppSpacing.md,
                    bottom: -16,
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: AppSpacing.brSm,
                        border: Border.all(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.6)),
                      ),
                      child: Text(folder.emoji,
                          style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, 24, AppSpacing.md, AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      folder.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    AppSpacing.gapXs,
                    Row(
                      children: [
                        Text('$notes ${notes == 1 ? 'nota' : 'notas'}',
                            style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                        AppSpacing.gapSm,
                        if (pending > 0)
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                      color: color, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    '$pending pend.',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                        color: color,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Text('Al día',
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnfiledCard extends StatelessWidget {
  const _UnfiledCard(
      {required this.notes, required this.pending, required this.onTap});

  final int notes;
  final int pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: AppSpacing.brLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.brLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          height: 112,
          decoration: BoxDecoration(
            borderRadius: AppSpacing.brLg,
            border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Symbols.folder_off_rounded,
                  color: theme.colorScheme.onSurfaceVariant),
              const Spacer(),
              Text('Sin espacio',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800)),
              Text('$notes ${notes == 1 ? 'nota' : 'notas'}',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewSpaceCard extends StatelessWidget {
  const _NewSpaceCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: AppSpacing.brLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.brLg,
        child: Container(
          height: 112,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: AppSpacing.brLg,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.6),
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Symbols.add_rounded, color: theme.colorScheme.primary),
              AppSpacing.gapXs,
              Text('Nuevo espacio',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Resultados del buscador global: notas, espacios y etiquetas.
class _SearchResults extends ConsumerWidget {
  const _SearchResults(
      {required this.query, required this.notes, required this.folders});

  final String query;
  final List<Note> notes;
  final List<NoteFolder> folders;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final q = query.toLowerCase();
    final isTag = q.startsWith('#');
    final tagQuery = isTag ? q.substring(1) : q;

    final matchedFolders = [
      for (final f in folders)
        if (f.name.toLowerCase().contains(q)) f,
    ];
    final matchedNotes = [
      for (final n in notes)
        if (!n.isBlank &&
            (n.title.toLowerCase().contains(q) ||
                n.preview.toLowerCase().contains(q) ||
                n.tags.any((t) => t.toLowerCase().contains(tagQuery)))) n,
    ];

    if (matchedFolders.isEmpty && matchedNotes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xl),
        child: Center(
          child: Text('Nada coincide con "$query".',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (matchedFolders.isNotEmpty) ...[
          Text('Espacios', style: theme.textTheme.labelLarge),
          AppSpacing.gapSm,
          for (final f in matchedFolders)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Text(f.emoji, style: const TextStyle(fontSize: 20)),
              title: Text(f.name),
              onTap: () => ref.read(notesScopeProvider.notifier).openFolder(f.id),
            ),
          AppSpacing.gapMd,
        ],
        if (matchedNotes.isNotEmpty) ...[
          Text('Notas', style: theme.textTheme.labelLarge),
          AppSpacing.gapSm,
          for (final n in matchedNotes.take(30))
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Symbols.sticky_note_2_rounded,
                  color: theme.colorScheme.onSurfaceVariant),
              title: Text(n.title.trim().isEmpty ? 'Sin título' : n.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(n.preview,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              onTap: () => context.go('${AppRoutes.notes}/${n.id}'),
            ),
        ],
      ],
    );
  }
}

class _EmptyEverything extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        children: [
          const TacitaMascot(state: TacitaState.sleep, size: 110),
          AppSpacing.gapMd,
          Text('Tu segundo cerebro, en blanco',
              style: theme.textTheme.titleMedium),
          AppSpacing.gapSm,
          Text(
            'Crea tu primer espacio o una nota con el botón +.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ).animate().fadeIn(delay: 250.ms, duration: AppMotion.medium);
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: AppSpacing.screen,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
