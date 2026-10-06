import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/debouncer.dart';
import '../application/folder_providers.dart';
import '../application/note_providers.dart';
import '../data/note.dart';
import '../domain/note_enums.dart';
import '../domain/spoken_date.dart';
import 'widgets/block_editors.dart';
import 'widgets/folder_editor_sheet.dart';
import 'widgets/folder_picker_sheet.dart';
import 'widgets/voice_capture_sheet.dart';

/// Editor de una nota, entendida como un **workspace**: un título y una pila de
/// bloques de tipos mezclables (texto, listas, secuencias, pendientes).
///
/// Arranca limpio (título + un bloque de texto). Los bloques especiales se
/// agregan con el botón "+". Los detalles (carpeta, recordatorio, relevancia)
/// viven en el menú ⋮ para no ensuciar la escritura.
///
/// Guarda solo: mantiene la nota en estado local y la escribe con debounce, de
/// modo que escribir un párrafo cueste una escritura y no una por tecla.
class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key, required this.noteId});

  final String noteId;

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _debouncer = Debouncer();
  final _titleController = TextEditingController();

  Note? _note;
  bool _titleInitialized = false;

  /// Bloque o ítem cuya imagen se está subiendo (para el spinner).
  String? _uploadingId;

  /// Bloque recién agregado, para darle el foco una sola vez.
  String? _focusBlockId;

  /// La nota vigente: el estado local si ya editaste algo, o la remota si no.
  Note? get _current => _note ?? ref.read(noteProvider(widget.noteId)).value;

  @override
  void dispose() {
    _debouncer.flush();
    _debouncer.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _update(Note updated, {bool immediate = false}) {
    setState(() => _note = updated);
    final repo = ref.read(noteRepositoryProvider);
    if (immediate) {
      _debouncer.dispose();
      repo.save(updated);
    } else {
      _debouncer.run(() => repo.save(updated));
    }
  }

  /// Reemplaza un bloque por id.
  void _updateBlock(NoteBlock block, {bool immediate = false}) {
    final note = _current;
    if (note == null) return;
    _update(
      note.copyWith(
        blocks: [for (final b in note.blocks) if (b.id == block.id) block else b],
      ),
      immediate: immediate,
    );
  }

  void _removeBlock(String id) {
    final note = _current;
    if (note == null) return;
    _update(
      note.copyWith(blocks: note.blocks.where((b) => b.id != id).toList()),
      immediate: true,
    );
  }

  void _addBlock(NoteBlockKind kind, {NoteBlock? replace}) {
    final note = _current;
    if (note == null) return;
    final block = NoteBlock(
      id: const Uuid().v4(),
      kind: kind,
      items: switch (kind) {
        NoteBlockKind.checklist ||
        NoteBlockKind.sequence =>
          [BlockItem(id: const Uuid().v4())],
        NoteBlockKind.toggle => [BlockItem(id: const Uuid().v4())],
        _ => const [],
      },
    );
    _focusBlockId = block.id;
    final blocks = [
      for (final b in note.blocks)
        if (replace != null && b.id == replace.id) block else b,
    ];
    if (replace == null) blocks.add(block);
    _update(note.copyWith(blocks: blocks), immediate: true);
  }

  /// Menú de tipos de bloque (al tocar "+", o al escribir "/" en un bloque de
  /// texto vacío, en cuyo caso [replace] es ese bloque que se transforma).
  Future<void> _pickBlockKind({NoteBlock? replace}) async {
    final kind = await showModalBottomSheet<NoteBlockKind>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final k in NoteBlockKind.values)
              ListTile(
                leading: Icon(k.icon),
                title: Text(k.label),
                onTap: () => Navigator.of(context).pop(k),
              ),
          ],
        ),
      ),
    );
    if (kind == null) return;
    if (kind == NoteBlockKind.noteLink) {
      _insertNoteLink(replace: replace);
    } else {
      _addBlock(kind, replace: replace);
    }
  }

  /// Abre un buscador de notas y enlaza la elegida como bloque [noteLink].
  Future<void> _insertNoteLink({NoteBlock? replace}) async {
    final notes = (ref.read(notesProvider).value ?? const <Note>[])
        .where((n) => n.id != widget.noteId && !n.isBlank)
        .toList()
      ..sort((a, b) {
        final ad = a.updatedAt, bd = b.updatedAt;
        if (ad == null || bd == null) return 0;
        return bd.compareTo(ad);
      });
    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => _NotePicker(notes: notes),
    );
    if (chosen == null) return;
    final note = _current;
    if (note == null) return;
    final block = NoteBlock(
      id: const Uuid().v4(),
      kind: NoteBlockKind.noteLink,
      targetNoteId: chosen,
    );
    final blocks = [
      for (final b in note.blocks)
        if (replace != null && b.id == replace.id) block else b,
    ];
    if (replace == null) blocks.add(block);
    _update(note.copyWith(blocks: blocks), immediate: true);
  }

  void _toggleFavorite() {
    final note = _current;
    if (note == null) return;
    _update(note.copyWith(favorite: !note.favorite), immediate: true);
  }

  /// Elige una imagen, la sube y devuelve su URL. [targetId] es el bloque o
  /// ítem que la pidió (para mostrar su spinner). `null` si se canceló/falló.
  Future<String?> _requestImage(String targetId) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2400,
    );
    if (picked == null) return null;

    setState(() => _uploadingId = targetId);
    try {
      return await ref.read(noteImageServiceProvider).upload(File(picked.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No pude subir la imagen: $e')),
        );
      }
      return null;
    } finally {
      if (mounted) setState(() => _uploadingId = null);
    }
  }

  /// Dicta un bloque de texto nuevo. Si menciona una fecha y la nota aún no
  /// tiene recordatorio, se agenda solo.
  Future<void> _dictateBlock() async {
    final transcript = await VoiceCaptureSheet.show(context);
    final text = transcript?.trim() ?? '';
    if (text.isEmpty) return;
    final note = _current;
    if (note == null) return;

    final spoken = note.reminderDate == null ? SpokenDate.parse(text) : null;
    _update(
      note.copyWith(
        blocks: [
          ...note.blocks,
          NoteBlock(id: const Uuid().v4(), kind: NoteBlockKind.text, text: text),
        ],
        reminderDate: spoken?.date ?? note.reminderDate,
      ),
      immediate: true,
    );
    if (spoken != null) _toast('📅 Recordatorio para ${_dateLabel(spoken.date)}');
  }

  Future<void> _pickReminder() async {
    final note = _current;
    if (note == null) return;
    if (note.reminderDate != null) {
      _update(note.copyWith(reminderDate: null), immediate: true);
      _toast('Recordatorio quitado');
      return;
    }
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      locale: const Locale('es', 'MX'),
    );
    if (picked == null) return;
    _update(
      note.copyWith(reminderDate: DateTime(picked.year, picked.month, picked.day)),
      immediate: true,
    );
  }

  Future<void> _pickFolder() async {
    final note = _current;
    if (note == null) return;
    final folders = ref.read(foldersProvider).value ?? const [];
    final result = await FolderPickerSheet.show(
      context,
      folders: folders,
      currentId: note.folderId,
    );
    switch (result) {
      case null:
        return;
      case PickedFolder(:final folderId):
        _update(note.copyWith(folderId: folderId), immediate: true);
      case CreateNewFolder():
        if (!mounted) return;
        final folder = await FolderEditorSheet.show(context);
        if (folder == null) return;
        await ref.read(noteFolderRepositoryProvider).save(folder);
        _update(note.copyWith(folderId: folder.id), immediate: true);
    }
  }

  void _cycleStatus() {
    final note = _current;
    if (note == null) return;
    _update(note.copyWith(status: note.status.next), immediate: true);
  }

  void _goBack() {
    final note = _current;
    if (note != null && note.isBlank) {
      _debouncer.dispose();
      ref.read(noteRepositoryProvider).delete(note);
    }
    context.go(AppRoutes.notes);
  }

  Future<void> _confirmDelete() async {
    final note = _current;
    if (note == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Borrar esta nota?'),
        content: Text(
          note.imageCount > 0
              ? 'Se borrarán también sus ${note.imageCount} imagen(es). No se puede deshacer.'
              : 'No se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    _debouncer.dispose();
    await ref.read(noteRepositoryProvider).delete(note);
    if (mounted) context.go(AppRoutes.notes);
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  String _dateLabel(DateTime d) =>
      DateFormat("EEEE d 'de' MMMM", 'es_MX').format(d);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remote = ref.watch(noteProvider(widget.noteId));
    final note = _note ?? remote.value;

    if (note == null) {
      return Scaffold(
        appBar: AppBar(leading: _backButton()),
        body: Center(
          child: remote.hasError
              ? Text('No pude abrir la nota: ${remote.error}')
              : const CircularProgressIndicator(),
        ),
      );
    }

    if (!_titleInitialized) {
      _titleController.text = note.title;
      _titleInitialized = true;
    }

    // El bloque a enfocar se consume tras este frame para no robar el foco en
    // los siguientes rebuilds.
    final focusId = _focusBlockId;
    if (focusId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusBlockId = null);
    }

    return Scaffold(
      appBar: AppBar(
        leading: _backButton(),
        title: Text('Guardado',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _toggleFavorite,
            tooltip: note.favorite ? 'Quitar favorita' : 'Marcar favorita',
            icon: Icon(
              note.favorite
                  ? Symbols.star_rounded
                  : Symbols.star_outline_rounded,
              fill: note.favorite ? 1 : 0,
              color: note.favorite ? theme.colorScheme.tertiary : null,
            ),
          ),
          _DetailsMenu(
            note: note,
            folderLabel: _folderLabel(note),
            onFolder: _pickFolder,
            onReminder: _pickReminder,
            onStatus: _cycleStatus,
            onDelete: _confirmDelete,
          ),
          AppSpacing.gapSm,
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 140),
          children: [
            _Breadcrumb(label: _breadcrumb(note)),
            TextField(
              controller: _titleController,
              style: theme.textTheme.headlineSmall,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (v) => _update(note.copyWith(title: v)),
              decoration: const InputDecoration(
                hintText: 'Título',
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            _TagsRow(
              tags: note.tags,
              onAdd: _addTag,
              onRemove: (t) => _update(
                  note.copyWith(tags: [...note.tags]..remove(t)),
                  immediate: true),
            ),
            // Detalles activos, discretos: solo aparecen si los pusiste.
            _ActiveDetails(note: note, folderLabel: _folderLabel(note)),
            AppSpacing.gapLg,
            for (final block in note.blocks) ...[
              _blockEditor(block, autofocus: block.id == focusId),
              AppSpacing.gapMd,
            ],
            AppSpacing.gapSm,
            _AddBlockBar(
              onAdd: _addBlock,
              onMenu: () => _pickBlockKind(),
              onLink: () => _insertNoteLink(),
              onDictate: _dictateBlock,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addTag() async {
    final note = _current;
    if (note == null) return;
    final controller = TextEditingController();
    final tag = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva etiqueta'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'etiqueta', prefixText: '#'),
          onSubmitted: (v) => Navigator.of(context).pop(v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Agregar')),
        ],
      ),
    );
    final clean = tag?.trim().replaceAll('#', '').replaceAll(' ', '');
    if (clean == null || clean.isEmpty || note.tags.contains(clean)) return;
    _update(note.copyWith(tags: [...note.tags, clean]), immediate: true);
  }

  String _breadcrumb(Note note) {
    if (note.folderId == null) return 'Sin espacio';
    final folders = ref.read(foldersProvider).value ?? const [];
    final folder = folders.where((f) => f.id == note.folderId).firstOrNull;
    final space = folder == null ? 'Espacio' : '${folder.emoji} ${folder.name}';
    if (note.sectionId == null) return space;
    final sections = ref.read(sectionsForFolderProvider(note.folderId!));
    final sec = sections.where((s) => s.id == note.sectionId).firstOrNull;
    return sec == null ? space : '$space  /  ${sec.name}';
  }

  Widget _blockEditor(NoteBlock block, {required bool autofocus}) {
    return switch (block.kind) {
      NoteBlockKind.text => TextBlockEditor(
          key: ValueKey(block.id),
          block: block,
          autofocus: autofocus,
          uploading: _uploadingId == block.id,
          onChanged: _updateBlock,
          onDelete: () => _removeBlock(block.id),
          onRequestImage: () => _requestImage(block.id),
          onSlash: () => _pickBlockKind(replace: block),
        ),
      NoteBlockKind.checklist => ChecklistBlockEditor(
          key: ValueKey(block.id),
          block: block,
          onChanged: _updateBlock,
          onDelete: () => _removeBlock(block.id),
        ),
      NoteBlockKind.sequence => SequenceBlockEditor(
          key: ValueKey(block.id),
          block: block,
          uploadingItemId: _uploadingId,
          onChanged: _updateBlock,
          onDelete: () => _removeBlock(block.id),
          onRequestImage: _requestImage,
        ),
      NoteBlockKind.todo => TodoBlockEditor(
          key: ValueKey(block.id),
          block: block,
          autofocus: autofocus,
          // Marcar/desmarcar y terminar un Pomodoro se guardan al vuelo.
          onChanged: (b) => _updateBlock(b, immediate: true),
          onDelete: () => _removeBlock(block.id),
        ),
      NoteBlockKind.heading => HeadingBlockEditor(
          key: ValueKey(block.id),
          block: block,
          autofocus: autofocus,
          onChanged: _updateBlock,
          onDelete: () => _removeBlock(block.id),
        ),
      NoteBlockKind.code => CodeBlockEditor(
          key: ValueKey(block.id),
          block: block,
          autofocus: autofocus,
          onChanged: _updateBlock,
          onDelete: () => _removeBlock(block.id),
        ),
      NoteBlockKind.toggle => ToggleBlockEditor(
          key: ValueKey(block.id),
          block: block,
          autofocus: autofocus,
          onChanged: (b) => _updateBlock(b, immediate: true),
          onDelete: () => _removeBlock(block.id),
        ),
      NoteBlockKind.callout => CalloutBlockEditor(
          key: ValueKey(block.id),
          block: block,
          autofocus: autofocus,
          onChanged: _updateBlock,
          onDelete: () => _removeBlock(block.id),
        ),
      NoteBlockKind.noteLink => NoteLinkBlockEditor(
          key: ValueKey(block.id),
          block: block,
          title: _linkTitle(block.targetNoteId),
          onOpen: () => context.go('${AppRoutes.notes}/${block.targetNoteId}'),
          onDelete: () => _removeBlock(block.id),
        ),
      NoteBlockKind.file => FileBlockEditor(
          key: ValueKey(block.id),
          block: block,
          uploading: _uploadingId == block.id,
          onChanged: (b) => _updateBlock(b, immediate: true),
          onDelete: () => _removeBlock(block.id),
          onRequestImage: () => _requestImage(block.id),
        ),
    };
  }

  /// Título de la nota enlazada (para el bloque de enlace). `null` si no existe.
  String? _linkTitle(String? id) {
    if (id == null) return null;
    final notes = ref.read(notesProvider).value ?? const <Note>[];
    final n = notes.where((n) => n.id == id).firstOrNull;
    if (n == null) return null;
    return n.title.trim().isEmpty ? 'Sin título' : n.title.trim();
  }

  Widget _backButton() => IconButton(
        onPressed: _goBack,
        icon: const Icon(Symbols.arrow_back_rounded),
        tooltip: 'Volver',
      );

  String _folderLabel(Note note) {
    if (note.folderId == null) return 'Sin carpeta';
    final folders = ref.watch(foldersProvider).value ?? const [];
    final folder = folders.where((f) => f.id == note.folderId).firstOrNull;
    return folder == null ? 'Carpeta' : '${folder.emoji} ${folder.name}';
  }
}

/// Menú ⋮ con los detalles de la nota: relevancia, recordatorio, carpeta y
/// borrar. Fuera de la vista principal para que el editor abra limpio.
class _DetailsMenu extends StatelessWidget {
  const _DetailsMenu({
    required this.note,
    required this.folderLabel,
    required this.onFolder,
    required this.onReminder,
    required this.onStatus,
    required this.onDelete,
  });

  final Note note;
  final String folderLabel;
  final VoidCallback onFolder;
  final VoidCallback onReminder;
  final VoidCallback onStatus;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      icon: const Icon(Symbols.more_vert_rounded),
      onSelected: (v) => switch (v) {
        'status' => onStatus(),
        'reminder' => onReminder(),
        'folder' => onFolder(),
        'delete' => onDelete(),
        _ => null,
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'status',
          child: Row(
            children: [
              Icon(note.status.icon, size: 20, color: note.status.color),
              AppSpacing.gapMd,
              Text('Relevancia: ${note.status.label}'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'reminder',
          child: Row(
            children: [
              Icon(
                note.reminderDate == null
                    ? Symbols.event_rounded
                    : Symbols.event_available_rounded,
                size: 20,
              ),
              AppSpacing.gapMd,
              Text(note.reminderDate == null
                  ? 'Agregar recordatorio'
                  : 'Recordatorio: ${DateFormat("d MMM", 'es_MX').format(note.reminderDate!)}'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'folder',
          child: Row(
            children: [
              const Icon(Symbols.folder_rounded, size: 20),
              AppSpacing.gapMd,
              Flexible(child: Text('Carpeta: $folderLabel')),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Symbols.delete_rounded, size: 20, color: theme.colorScheme.error),
              AppSpacing.gapMd,
              Text('Borrar nota',
                  style: TextStyle(color: theme.colorScheme.error)),
            ],
          ),
        ),
      ],
    );
  }
}

/// Chips discretos, debajo del título, que muestran los detalles que YA pusiste
/// (relevancia distinta de "por hacer", recordatorio, carpeta). Si no hay nada,
/// no ocupa espacio.
class _ActiveDetails extends StatelessWidget {
  const _ActiveDetails({required this.note, required this.folderLabel});

  final Note note;
  final String folderLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chips = <Widget>[
      if (note.status != NoteStatus.todo)
        _MiniChip(
          icon: note.status.icon,
          label: note.status.label,
          color: note.status.color,
        ),
      if (note.reminderDate != null)
        _MiniChip(
          icon: Symbols.event_available_rounded,
          label: DateFormat("d MMM", 'es_MX').format(note.reminderDate!),
          color: theme.colorScheme.secondary,
        ),
      if (note.folderId != null)
        _MiniChip(
          icon: Symbols.folder_rounded,
          label: folderLabel,
          color: theme.colorScheme.primary,
        ),
    ];
    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: chips),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, fill: 1, color: color),
          AppSpacing.gapXs,
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// Migaja de pan: Espacio / Sección arriba de la nota.
class _Breadcrumb extends StatelessWidget {
  const _Breadcrumb({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.xs),
      child: Row(
        children: [
          Icon(Symbols.folder_rounded,
              size: 14, color: theme.colorScheme.primary),
          AppSpacing.gapXs,
          Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}

/// Fila de etiquetas (#tags) con botón para agregar.
class _TagsRow extends StatelessWidget {
  const _TagsRow(
      {required this.tags, required this.onAdd, required this.onRemove});

  final List<String> tags;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final t in tags)
            InputChip(
              label: Text('#$t'),
              onDeleted: () => onRemove(t),
              visualDensity: VisualDensity.compact,
              labelStyle: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.primary),
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
              side: BorderSide.none,
            ),
          ActionChip(
            avatar: const Icon(Symbols.add_rounded, size: 16),
            label: const Text('Etiqueta'),
            onPressed: onAdd,
            visualDensity: VisualDensity.compact,
            backgroundColor:
                theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            side: BorderSide.none,
          ),
        ],
      ),
    );
  }
}

/// Barra flotante inferior con accesos rápidos a los bloques (estilo spec).
class _AddBlockBar extends StatelessWidget {
  const _AddBlockBar({
    required this.onAdd,
    required this.onMenu,
    required this.onLink,
    required this.onDictate,
  });

  final void Function(NoteBlockKind kind) onAdd;
  final VoidCallback onMenu;
  final VoidCallback onLink;
  final VoidCallback onDictate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget btn(IconData icon, String tip, VoidCallback onTap,
            {Color? color, Color? bg}) =>
        IconButton(
          onPressed: onTap,
          tooltip: tip,
          icon: Icon(icon, size: 20),
          color: color ?? theme.colorScheme.onSurfaceVariant,
          style: bg == null
              ? null
              : IconButton.styleFrom(backgroundColor: bg),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppSpacing.brMd,
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          btn(Symbols.add_rounded, 'Insertar bloque', onMenu,
              color: theme.colorScheme.primary,
              bg: theme.colorScheme.primary.withValues(alpha: 0.14)),
          btn(Symbols.notes_rounded, 'Texto',
              () => onAdd(NoteBlockKind.text)),
          btn(Symbols.checklist_rounded, 'Checklist',
              () => onAdd(NoteBlockKind.checklist)),
          btn(Symbols.code_rounded, 'Código', () => onAdd(NoteBlockKind.code)),
          btn(Symbols.image_rounded, 'Imagen',
              () => onAdd(NoteBlockKind.text)),
          btn(Symbols.link_rounded, 'Enlazar nota', onLink),
          btn(Symbols.mic_rounded, 'Nota de voz', onDictate,
              color: theme.colorScheme.secondary),
        ],
      ),
    ).animate().fadeIn(duration: AppMotion.medium);
  }
}

/// Buscador de notas para enlazar (bloque [[ ]]).
class _NotePicker extends StatefulWidget {
  const _NotePicker({required this.notes});

  final List<Note> notes;

  @override
  State<_NotePicker> createState() => _NotePickerState();
}

class _NotePickerState extends State<_NotePicker> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _q.isEmpty
        ? widget.notes
        : widget.notes
            .where((n) => n.title.toLowerCase().contains(_q.toLowerCase()))
            .toList();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, controller) => Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _q = v),
              decoration: const InputDecoration(
                hintText: 'Buscar una nota para enlazar…',
                prefixIcon: Icon(Symbols.search_rounded),
              ),
            ),
            AppSpacing.gapSm,
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text('Sin resultados',
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)))
                  : ListView.builder(
                      controller: controller,
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final n = filtered[i];
                        return ListTile(
                          leading: const Icon(Symbols.description_rounded),
                          title: Text(
                              n.title.trim().isEmpty ? 'Sin título' : n.title,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          onTap: () => Navigator.of(context).pop(n.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
