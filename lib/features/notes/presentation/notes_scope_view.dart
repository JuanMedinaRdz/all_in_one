import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_lottie.dart';
import '../application/folder_providers.dart';
import '../application/note_providers.dart';
import '../application/notes_ui_providers.dart';
import '../data/note.dart';
import '../data/note_folder.dart';
import '../data/note_section.dart';
import 'widgets/folder_editor_sheet.dart';
import 'widgets/space_cover.dart';

/// Vista de un scope de notas. Para un **espacio** (carpeta) muestra el diseño
/// completo (portada, métricas, fijadas y secciones); para "Todas" / "Sin
/// espacio" muestra una lista simple.
class NotesScopeView extends ConsumerWidget {
  const NotesScopeView({super.key, required this.scope});

  final NotesScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (scope) {
      NotesScopeFolder(:final folderId) => _SpaceScreen(folderId: folderId),
      _ => _FlatList(scope: scope),
    };
  }
}

// ===================== ESPACIO =====================

class _SpaceScreen extends ConsumerWidget {
  const _SpaceScreen({required this.folderId});

  final String folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final folders = ref.watch(foldersProvider).value ?? const <NoteFolder>[];
    final folder = folders.where((f) => f.id == folderId).firstOrNull;
    final notesAsync = ref.watch(notesProvider);
    final sections = ref.watch(sectionsForFolderProvider(folderId));
    final sort = ref.watch(spaceSortProvider);

    if (folder == null) {
      // El espacio se borró: vuelve al inicio.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(notesScopeProvider.notifier).openHome();
      });
      return const SizedBox.shrink();
    }

    final allNotes = notesAsync.value ?? const <Note>[];
    final spaceNotes = [for (final n in allNotes) if (n.folderId == folderId) n];
    final pinned = [for (final n in spaceNotes) if (n.pinned) n]..sort(_cmp(sort));
    final pending = spaceNotes.fold(0, (a, n) => a + n.pendingCount);

    // Agrupa las no fijadas por sección (null = "Sin sección").
    final bySection = <String?, List<Note>>{};
    for (final n in spaceNotes) {
      if (n.pinned) continue;
      bySection.putIfAbsent(n.sectionId, () => []).add(n);
    }
    for (final l in bySection.values) {
      l.sort(_cmp(sort));
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        _Cover(folder: folder),
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(folder.name, style: theme.textTheme.headlineSmall),
              if (folder.description.isNotEmpty) ...[
                AppSpacing.gapXs,
                Text(folder.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
              AppSpacing.gapLg,
              _Metrics(
                  notes: spaceNotes.length, pending: pending, spaceNotes: spaceNotes),
              AppSpacing.gapLg,
              _Toolbar(folderId: folderId),
              AppSpacing.gapLg,
              if (notesAsync.isLoading && spaceNotes.isEmpty)
                const Center(child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ))
              else if (spaceNotes.isEmpty)
                _EmptySpace()
              else ...[
                if (pinned.isNotEmpty) ...[
                  _SectionLabel(
                      icon: Symbols.push_pin_rounded, text: 'FIJADA'.toUpperCase()),
                  AppSpacing.gapSm,
                  for (final n in pinned) _NoteRow(note: n, folder: folder),
                  AppSpacing.gapLg,
                ],
                // Secciones declaradas (en orden), luego "Sin sección".
                for (final sec in sections)
                  _SectionBlock(
                    folder: folder,
                    section: sec,
                    notes: bySection[sec.id] ?? const [],
                  ),
                if ((bySection[null] ?? const []).isNotEmpty)
                  _SectionBlock(
                    folder: folder,
                    section: null,
                    notes: bySection[null]!,
                  ),
                AppSpacing.gapMd,
                _AddSectionButton(folderId: folderId),
              ],
            ],
          ),
        ),
      ],
    );
  }

  int Function(Note, Note) _cmp(SpaceSort sort) => (a, b) => switch (sort) {
        SpaceSort.name => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        SpaceSort.pending => b.pendingCount.compareTo(a.pendingCount),
        SpaceSort.recent => () {
            final ad = a.updatedAt, bd = b.updatedAt;
            if (ad == null && bd == null) return 0;
            if (ad == null) return 1;
            if (bd == null) return -1;
            return bd.compareTo(ad);
          }(),
      };
}

/// Portada con back + opciones e icono superpuesto.
class _Cover extends ConsumerWidget {
  const _Cover({required this.folder});

  final NoteFolder folder;

  Future<void> _options(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Symbols.edit_rounded),
              title: const Text('Editar espacio'),
              onTap: () => Navigator.of(context).pop('edit'),
            ),
            ListTile(
              leading: Icon(Symbols.delete_rounded,
                  color: Theme.of(context).colorScheme.error),
              title: Text('Eliminar espacio',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () => Navigator.of(context).pop('delete'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    if (action == 'edit') {
      final edited = await FolderEditorSheet.show(context, existing: folder);
      if (edited != null) {
        await ref.read(noteFolderRepositoryProvider).save(edited);
      }
    } else if (action == 'delete') {
      final notes = ref.read(notesProvider).value ?? const <Note>[];
      final contained = [for (final n in notes) if (n.folderId == folder.id) n];
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('¿Eliminar "${folder.name}"?'),
          content: Text(contained.isEmpty
              ? 'El espacio está vacío.'
              : 'Sus ${contained.length} nota(s) quedarán sin espacio (no se borran).'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              child: const Text('Eliminar'),
            ),
          ],
        ),
      );
      if (ok != true) return;
      await ref
          .read(noteFolderRepositoryProvider)
          .delete(folder.id, noteIds: [for (final n in contained) n.id]);
      ref.read(notesScopeProvider.notifier).openHome();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SpaceCover(color: folder.color, height: 140, seed: folder.id.hashCode),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  _CircleBtn(
                    icon: Symbols.arrow_back_rounded,
                    onTap: () => ref.read(notesScopeProvider.notifier).openHome(),
                  ),
                  const Spacer(),
                  _CircleBtn(
                    icon: Symbols.more_horiz_rounded,
                    onTap: () => _options(context, ref),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.lg,
          bottom: -22,
          child: Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppSpacing.brMd,
              border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.6)),
            ),
            child: Text(folder.emoji, style: const TextStyle(fontSize: 26)),
          ),
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

class _Metrics extends StatelessWidget {
  const _Metrics(
      {required this.notes, required this.pending, required this.spaceNotes});

  final int notes;
  final int pending;
  final List<Note> spaceNotes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Actividad de 7 días: notas actualizadas por día.
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bars = List<int>.filled(7, 0);
    for (final n in spaceNotes) {
      final d = n.updatedAt;
      if (d == null) continue;
      final day = DateTime(d.year, d.month, d.day);
      final diff = today.difference(day).inDays;
      if (diff >= 0 && diff < 7) bars[6 - diff]++;
    }
    final maxBar = (bars.fold(0, (a, b) => b > a ? b : a)).clamp(1, 999);

    Widget card(Widget child) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppSpacing.brMd,
              border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            ),
            child: child,
          ),
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        card(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$notes', style: theme.textTheme.titleLarge),
            Text('notas',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        )),
        AppSpacing.gapSm,
        card(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$pending',
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: theme.colorScheme.secondary)),
            Text('pendientes',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        )),
        AppSpacing.gapSm,
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: AppSpacing.brMd,
              border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < 7; i++) ...[
                        if (i > 0) const SizedBox(width: 3),
                        Expanded(
                          child: Container(
                            height: 4 + 20 * (bars[i] / maxBar),
                            decoration: BoxDecoration(
                              color: bars[i] == 0
                                  ? theme.colorScheme.surfaceContainerHighest
                                  : theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AppSpacing.gapXs,
                Text('actividad 7 días',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Selector de vista (tarjetas/lista/tablero) + orden.
class _Toolbar extends ConsumerWidget {
  const _Toolbar({required this.folderId});

  final String folderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final view = ref.watch(spaceViewProvider);
    final sort = ref.watch(spaceSortProvider);

    Widget seg(SpaceView v, IconData icon) {
      final sel = view == v;
      return InkWell(
        onTap: () => ref.read(spaceViewProvider.notifier).set(v),
        borderRadius: AppSpacing.brSm,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: sel ? theme.colorScheme.surfaceContainerHighest : null,
            borderRadius: AppSpacing.brSm,
          ),
          child: Icon(icon,
              size: 18,
              color: sel
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: AppSpacing.brSm,
            border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            seg(SpaceView.cards, Symbols.grid_view_rounded),
            seg(SpaceView.list, Symbols.view_agenda_rounded),
            seg(SpaceView.board, Symbols.view_week_rounded),
          ]),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () =>
              ref.read(spaceSortProvider.notifier).set(sort.next),
          icon: const Icon(Symbols.swap_vert_rounded, size: 16),
          label: Text(sort.label),
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: theme.colorScheme.onSurfaceVariant,
            side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        AppSpacing.gapXs,
        Text(text,
            style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4)),
      ],
    );
  }
}

/// Una sección colapsable con sus notas. Si [section] es null, es "Sin sección".
class _SectionBlock extends ConsumerWidget {
  const _SectionBlock(
      {required this.folder, required this.section, required this.notes});

  final NoteFolder folder;
  final NoteSection? section;
  final List<Note> notes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final sec = section;
    final collapsed = sec?.collapsed ?? false;
    final name = sec?.name ?? 'Sin sección';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: sec == null
              ? null
              : () => ref
                  .read(noteSectionRepositoryProvider)
                  .setCollapsed(sec.id, collapsed: !collapsed),
          borderRadius: AppSpacing.brSm,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Row(
              children: [
                Icon(
                  collapsed
                      ? Symbols.chevron_right_rounded
                      : Symbols.expand_more_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                AppSpacing.gapXs,
                Text(name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                AppSpacing.gapSm,
                Text('${notes.length}',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
        if (!collapsed)
          for (final n in notes) _NoteRow(note: n, folder: folder),
        AppSpacing.gapSm,
      ],
    );
  }
}

class _AddSectionButton extends ConsumerWidget {
  const _AddSectionButton({required this.folderId});

  final String folderId;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva sección'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nombre de la sección'),
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Crear')),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    final sections = ref.read(sectionsForFolderProvider(folderId));
    await ref.read(noteSectionRepositoryProvider).save(NoteSection(
          id: const Uuid().v4(),
          folderId: folderId,
          name: name.trim(),
          sortIndex: sections.length.toDouble(),
        ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _add(context, ref),
        icon: const Icon(Symbols.add_rounded, size: 18),
        label: const Text('Agregar sección'),
      ),
    );
  }
}

/// Fila de nota dentro de un espacio (icono + título + preview + etiquetas +
/// pendientes). Mantener presionado abre acciones (fijar, mover, borrar...).
class _NoteRow extends ConsumerWidget {
  const _NoteRow({required this.note, required this.folder});

  final Note note;
  final NoteFolder folder;

  Future<void> _actions(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(noteRepositoryProvider);
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(note.pinned
                  ? Symbols.keep_off_rounded
                  : Symbols.push_pin_rounded),
              title: Text(note.pinned ? 'Dejar de fijar' : 'Fijar arriba'),
              onTap: () => Navigator.of(context).pop('pin'),
            ),
            ListTile(
              leading: Icon(note.favorite
                  ? Symbols.star_rounded
                  : Symbols.star_outline_rounded),
              title: Text(note.favorite ? 'Quitar favorita' : 'Marcar favorita'),
              onTap: () => Navigator.of(context).pop('fav'),
            ),
            ListTile(
              leading: const Icon(Symbols.drive_file_move_rounded),
              title: const Text('Mover a sección'),
              onTap: () => Navigator.of(context).pop('move'),
            ),
            ListTile(
              leading: Icon(Symbols.delete_rounded,
                  color: Theme.of(context).colorScheme.error),
              title: Text('Eliminar',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () => Navigator.of(context).pop('delete'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    switch (action) {
      case 'pin':
        await repo.save(note.copyWith(pinned: !note.pinned));
      case 'fav':
        await repo.save(note.copyWith(favorite: !note.favorite));
      case 'move':
        await _moveToSection(context, ref);
      case 'delete':
        final ok = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
                '¿Borrar "${note.title.trim().isEmpty ? 'Sin título' : note.title}"?'),
            content: const Text('No se puede deshacer.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar')),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error),
                child: const Text('Borrar'),
              ),
            ],
          ),
        );
        if (ok == true) await repo.delete(note);
    }
  }

  Future<void> _moveToSection(BuildContext context, WidgetRef ref) async {
    final sections = ref.read(sectionsForFolderProvider(folder.id));
    final chosen = await showModalBottomSheet<String?>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Symbols.folder_off_rounded),
              title: const Text('Sin sección'),
              onTap: () => Navigator.of(context).pop('__none__'),
            ),
            for (final s in sections)
              ListTile(
                leading: const Icon(Symbols.folder_rounded),
                title: Text(s.name),
                onTap: () => Navigator.of(context).pop(s.id),
              ),
          ],
        ),
      ),
    );
    if (chosen == null) return;
    await ref
        .read(noteRepositoryProvider)
        .save(note.copyWith(sectionId: chosen == '__none__' ? null : chosen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = folder.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: AppSpacing.brMd,
        child: InkWell(
          onTap: () => context.go('${AppRoutes.notes}/${note.id}'),
          onLongPress: () => _actions(context, ref),
          borderRadius: AppSpacing.brMd,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: AppSpacing.brMd,
              border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: AppSpacing.brSm,
                  ),
                  child: note.icon.isNotEmpty
                      ? Text(note.icon, style: const TextStyle(fontSize: 18))
                      : Icon(Symbols.sticky_note_2_rounded,
                          size: 18, color: color),
                ),
                AppSpacing.gapMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              note.title.trim().isEmpty ? 'Sin título' : note.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          if (note.favorite)
                            Icon(Symbols.star_rounded,
                                size: 15, fill: 1, color: theme.colorScheme.tertiary),
                        ],
                      ),
                      AppSpacing.gapXs,
                      Text(
                        note.preview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                      if (note.tags.isNotEmpty || note.pendingCount > 0) ...[
                        AppSpacing.gapSm,
                        Row(
                          children: [
                            for (final tag in note.tags.take(2)) ...[
                              _Tag(label: '#$tag'),
                              AppSpacing.gapXs,
                            ],
                            const Spacer(),
                            if (note.pendingCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm, vertical: 2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary
                                      .withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusPill),
                                ),
                                child: Text(
                                  '${note.pendingCount} pend.',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.secondary,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
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

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(label,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    );
  }
}

class _EmptySpace extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            const AppLottie(AppAnim.notesEmpty, size: 170),
            Text('Este espacio está vacío', style: theme.textTheme.titleMedium),
            AppSpacing.gapSm,
            Text('Crea una nota con el botón +.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

// ===================== TODAS / SIN ESPACIO =====================

class _FlatList extends ConsumerWidget {
  const _FlatList({required this.scope});

  final NotesScope scope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final allNotes = ref.watch(notesProvider).value ?? const <Note>[];
    final notes = notesInScope(scope, allNotes)
      ..sort((a, b) {
        final ad = a.updatedAt, bd = b.updatedAt;
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });
    final title = switch (scope) {
      NotesScopeUnfiled() => 'Sin espacio',
      _ => 'Todas las notas',
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 110),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => ref.read(notesScopeProvider.notifier).openHome(),
              icon: const Icon(Symbols.arrow_back_rounded),
              visualDensity: VisualDensity.compact,
            ),
            Text(title, style: theme.textTheme.titleLarge),
          ],
        ),
        AppSpacing.gapMd,
        if (notes.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: Center(
              child: Text('Nada por aquí.',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            ),
          )
        else
          for (final n in notes)
            _NoteRow(
              note: n,
              folder: NoteFolder(id: n.folderId ?? '', name: ''),
            ),
      ],
    );
  }
}
