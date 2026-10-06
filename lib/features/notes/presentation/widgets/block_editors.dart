import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../data/note.dart';
import '../../domain/note_enums.dart';
import '../pomodoro_screen.dart';

/// Marco común de todo bloque: barra superior con su tipo y el botón de quitar.
class BlockFrame extends StatelessWidget {
  const BlockFrame({
    super.key,
    required this.kind,
    required this.onDelete,
    required this.child,
    this.trailing,
  });

  final NoteBlockKind kind;
  final VoidCallback onDelete;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppSpacing.brMd,
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.xs, 0),
            child: Row(
              children: [
                Icon(kind.icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
                AppSpacing.gapXs,
                Text(
                  kind.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                if (trailing != null) trailing!,
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Symbols.delete_rounded, size: 18),
                  color: theme.colorScheme.onSurfaceVariant,
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Quitar bloque',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Campo de texto sin bordes que se mantiene en sync sin robar el cursor.
class _PlainField extends StatefulWidget {
  const _PlainField({
    required this.value,
    required this.onChanged,
    required this.hint,
    this.autofocus = false,
    this.style,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String hint;
  final bool autofocus;
  final TextStyle? style;

  @override
  State<_PlainField> createState() => _PlainFieldState();
}

class _PlainFieldState extends State<_PlainField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(_PlainField old) {
    super.didUpdateWidget(old);
    // Solo se pisa si el cambio vino de fuera (otro dispositivo), no mientras
    // escribes: así el cursor no salta al inicio.
    if (widget.value != _controller.text && widget.value != old.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      maxLines: null,
      textCapitalization: TextCapitalization.sentences,
      style: widget.style,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        isDense: true,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        hintText: widget.hint,
      ),
    );
  }
}

/// Imagen con botón para quitarla.
class _BlockImage extends StatelessWidget {
  const _BlockImage({required this.url, required this.onRemove});

  final String url;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: AppSpacing.brSm,
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: url,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, _) => Container(
              height: 140,
              color: theme.colorScheme.surfaceContainerHighest,
              child: const Center(
                child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            ),
            errorWidget: (context, _, __) => Container(
              height: 120,
              color: theme.colorScheme.surfaceContainerHighest,
              child: Icon(Symbols.broken_image_rounded,
                  color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Positioned(
            top: AppSpacing.xs,
            right: AppSpacing.xs,
            child: Material(
              color: Colors.black.withValues(alpha: 0.5),
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onRemove,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  child: Icon(Symbols.close_rounded, size: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón "Imagen" o spinner mientras sube.
class _ImageButton extends StatelessWidget {
  const _ImageButton({required this.uploading, required this.onTap});

  final bool uploading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (uploading) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: SizedBox(
            width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Symbols.add_photo_alternate_rounded, size: 18),
      label: const Text('Imagen'),
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TEXTO
// ---------------------------------------------------------------------------

class TextBlockEditor extends StatelessWidget {
  const TextBlockEditor({
    super.key,
    required this.block,
    required this.autofocus,
    required this.uploading,
    required this.onChanged,
    required this.onDelete,
    required this.onRequestImage,
    this.onSlash,
  });

  final NoteBlock block;
  final bool autofocus;
  final bool uploading;
  final ValueChanged<NoteBlock> onChanged;
  final VoidCallback onDelete;
  final Future<String?> Function() onRequestImage;

  /// Al escribir "/" en un bloque vacío, abre el menú de bloques (lo convierte).
  final VoidCallback? onSlash;

  @override
  Widget build(BuildContext context) {
    return BlockFrame(
      kind: NoteBlockKind.text,
      onDelete: onDelete,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlainField(
            value: block.text,
            autofocus: autofocus,
            hint: "Escribe, o '/' para un bloque…",
            style: Theme.of(context).textTheme.bodyLarge,
            onChanged: (v) {
              if (v == '/' && onSlash != null) {
                onSlash!();
                return;
              }
              onChanged(block.copyWith(text: v));
            },
          ),
          if (block.imageUrl != null) ...[
            AppSpacing.gapSm,
            _BlockImage(
              url: block.imageUrl!,
              onRemove: () => onChanged(block.copyWith(imageUrl: null)),
            ),
          ] else
            Align(
              alignment: Alignment.centerLeft,
              child: _ImageButton(
                uploading: uploading,
                onTap: () async {
                  final url = await onRequestImage();
                  if (url != null) onChanged(block.copyWith(imageUrl: url));
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CHECKLIST
// ---------------------------------------------------------------------------

class ChecklistBlockEditor extends StatelessWidget {
  const ChecklistBlockEditor({
    super.key,
    required this.block,
    required this.onChanged,
    required this.onDelete,
  });

  final NoteBlock block;
  final ValueChanged<NoteBlock> onChanged;
  final VoidCallback onDelete;

  void _updateItem(BlockItem item) => onChanged(block.copyWith(
        items: [for (final i in block.items) if (i.id == item.id) item else i],
      ));

  @override
  Widget build(BuildContext context) {
    return BlockFrame(
      kind: NoteBlockKind.checklist,
      onDelete: onDelete,
      trailing: block.items.where((i) => !i.isEmpty).isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: Text(
                '${(block.progress * 100).round()}%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlainField(
            value: block.text,
            hint: 'Título de la lista (opcional)',
            style: Theme.of(context).textTheme.titleSmall,
            onChanged: (v) => onChanged(block.copyWith(text: v)),
          ),
          AppSpacing.gapSm,
          for (final item in block.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 26,
                    height: 26,
                    child: Checkbox(
                      value: item.done,
                      onChanged: (v) =>
                          _updateItem(item.copyWith(done: v ?? false)),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                    ),
                  ),
                  AppSpacing.gapSm,
                  Expanded(
                    child: _PlainField(
                      value: item.text,
                      hint: 'Un pendiente...',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            decoration:
                                item.done ? TextDecoration.lineThrough : null,
                            color: item.done
                                ? Theme.of(context).colorScheme.onSurfaceVariant
                                : null,
                          ),
                      onChanged: (v) => _updateItem(item.copyWith(text: v)),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onChanged(block.copyWith(
                      items: block.items.where((i) => i.id != item.id).toList(),
                    )),
                    icon: const Icon(Symbols.close_rounded, size: 16),
                    visualDensity: VisualDensity.compact,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => onChanged(block.copyWith(
                items: [...block.items, BlockItem(id: const Uuid().v4())],
              )),
              icon: const Icon(Symbols.add_rounded, size: 18),
              label: const Text('Agregar pendiente'),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SECUENCIA / TUTORIAL
// ---------------------------------------------------------------------------

class SequenceBlockEditor extends StatelessWidget {
  const SequenceBlockEditor({
    super.key,
    required this.block,
    required this.uploadingItemId,
    required this.onChanged,
    required this.onDelete,
    required this.onRequestImage,
  });

  final NoteBlock block;
  final String? uploadingItemId;
  final ValueChanged<NoteBlock> onChanged;
  final VoidCallback onDelete;
  final Future<String?> Function(String itemId) onRequestImage;

  void _updateItem(BlockItem item) => onChanged(block.copyWith(
        items: [for (final i in block.items) if (i.id == item.id) item else i],
      ));

  @override
  Widget build(BuildContext context) {
    final horizontal = block.layout == BlockLayout.horizontal;

    return BlockFrame(
      kind: NoteBlockKind.sequence,
      onDelete: onDelete,
      trailing: IconButton(
        onPressed: () =>
            onChanged(block.copyWith(layout: block.layout.toggled)),
        icon: Icon(block.layout.icon, size: 18),
        visualDensity: VisualDensity.compact,
        color: Theme.of(context).colorScheme.tertiary,
        tooltip: block.layout.label,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlainField(
            value: block.text,
            hint: 'Título del tutorial (opcional)',
            style: Theme.of(context).textTheme.titleSmall,
            onChanged: (v) => onChanged(block.copyWith(text: v)),
          ),
          AppSpacing.gapSm,
          if (horizontal)
            SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: block.items.length,
                separatorBuilder: (_, __) => AppSpacing.gapMd,
                itemBuilder: (context, i) => SizedBox(
                  width: 240,
                  child: SingleChildScrollView(
                    child: _buildStep(index: i, item: block.items[i]),
                  ),
                ),
              ),
            )
          else
            for (final (i, item) in block.items.indexed) ...[
              _buildStep(index: i, item: item),
              AppSpacing.gapSm,
            ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => onChanged(block.copyWith(
                items: [...block.items, BlockItem(id: const Uuid().v4())],
              )),
              icon: const Icon(Symbols.add_rounded, size: 18),
              label: const Text('Agregar paso'),
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep({required int index, required BlockItem item}) {
    return Builder(builder: (context) {
      final theme = Theme.of(context);
      return Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: AppSpacing.brSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Text('${index + 1}',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.primary)),
                ),
                AppSpacing.gapSm,
                Expanded(
                  child: _PlainField(
                    value: item.text,
                    hint: 'Describe este paso...',
                    onChanged: (v) => _updateItem(item.copyWith(text: v)),
                  ),
                ),
                IconButton(
                  onPressed: () => onChanged(block.copyWith(
                    items: block.items.where((i) => i.id != item.id).toList(),
                  )),
                  icon: const Icon(Symbols.close_rounded, size: 16),
                  visualDensity: VisualDensity.compact,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            if (item.imageUrl != null) ...[
              AppSpacing.gapSm,
              _BlockImage(
                url: item.imageUrl!,
                onRemove: () => _updateItem(item.copyWith(imageUrl: null)),
              ),
            ] else
              Align(
                alignment: Alignment.centerLeft,
                child: _ImageButton(
                  uploading: uploadingItemId == item.id,
                  onTap: () async {
                    final url = await onRequestImage(item.id);
                    if (url != null) _updateItem(item.copyWith(imageUrl: url));
                  },
                ),
              ),
          ],
        ),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// PENDIENTE (con Pomodoro)
// ---------------------------------------------------------------------------

class TodoBlockEditor extends StatelessWidget {
  const TodoBlockEditor({
    super.key,
    required this.block,
    required this.autofocus,
    required this.onChanged,
    required this.onDelete,
  });

  final NoteBlock block;
  final bool autofocus;
  final ValueChanged<NoteBlock> onChanged;
  final VoidCallback onDelete;

  Future<void> _start(BuildContext context) async {
    final result = await PomodoroScreen.show(
      context,
      activity: block.text,
      initialMinutes: block.pomodoroMinutes,
    );
    if (result == null) return;
    onChanged(block.copyWith(
      pomodoroMinutes: result.minutes,
      done: result.markDone ? true : block.done,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlockFrame(
      kind: NoteBlockKind.todo,
      onDelete: onDelete,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 26,
                height: 26,
                child: Checkbox(
                  value: block.done,
                  onChanged: (v) => onChanged(block.copyWith(done: v ?? false)),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                ),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: _PlainField(
                  value: block.text,
                  autofocus: autofocus,
                  hint: '¿Qué hay que hacer?',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    decoration: block.done ? TextDecoration.lineThrough : null,
                    color: block.done ? theme.colorScheme.onSurfaceVariant : null,
                  ),
                  onChanged: (v) => onChanged(block.copyWith(text: v)),
                ),
              ),
            ],
          ),
          AppSpacing.gapSm,
          Row(
            children: [
              _MinutesChip(
                minutes: block.pomodoroMinutes,
                onChanged: (m) => onChanged(block.copyWith(pomodoroMinutes: m)),
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: () => _start(context),
                icon: const Icon(Symbols.play_arrow_rounded, fill: 1, size: 18),
                label: const Text('Comenzar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Chip que muestra los minutos y abre un menú para cambiarlos.
class _MinutesChip extends StatelessWidget {
  const _MinutesChip({required this.minutes, required this.onChanged});

  final int minutes;
  final ValueChanged<int> onChanged;

  static const _options = [5, 10, 15, 25, 45, 60];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopupMenuButton<int>(
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final o in _options)
          PopupMenuItem(value: o, child: Text('$o min')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.timer_rounded, size: 16, color: theme.colorScheme.primary),
            AppSpacing.gapXs,
            Text('$minutes min', style: theme.textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TÍTULO (heading)
// ---------------------------------------------------------------------------

class HeadingBlockEditor extends StatelessWidget {
  const HeadingBlockEditor({
    super.key,
    required this.block,
    required this.autofocus,
    required this.onChanged,
    required this.onDelete,
  });

  final NoteBlock block;
  final bool autofocus;
  final ValueChanged<NoteBlock> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return BlockFrame(
      kind: NoteBlockKind.heading,
      onDelete: onDelete,
      child: _PlainField(
        value: block.text,
        autofocus: autofocus,
        hint: 'Título de sección',
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.w800),
        onChanged: (v) => onChanged(block.copyWith(text: v)),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CÓDIGO (con copiar)
// ---------------------------------------------------------------------------

class CodeBlockEditor extends StatelessWidget {
  const CodeBlockEditor({
    super.key,
    required this.block,
    required this.autofocus,
    required this.onChanged,
    required this.onDelete,
  });

  final NoteBlock block;
  final bool autofocus;
  final ValueChanged<NoteBlock> onChanged;
  final VoidCallback onDelete;

  static const _mono = TextStyle(fontFamily: 'JetBrains Mono', fontSize: 13, height: 1.6);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlockFrame(
      kind: NoteBlockKind.code,
      onDelete: onDelete,
      trailing: IconButton(
        tooltip: 'Copiar',
        visualDensity: VisualDensity.compact,
        icon: const Icon(Symbols.content_copy_rounded, size: 16),
        color: theme.colorScheme.onSurfaceVariant,
        onPressed: () {
          Clipboard.setData(ClipboardData(text: block.text));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Código copiado'),
                behavior: SnackBarBehavior.floating),
          );
        },
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: const Color(0xFF12161D),
          borderRadius: AppSpacing.brSm,
          border:
              Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
        ),
        child: _PlainField(
          value: block.text,
          autofocus: autofocus,
          hint: 'escribe tu código…',
          style: _mono.copyWith(color: const Color(0xFFC3CAD3)),
          onChanged: (v) => onChanged(block.copyWith(text: v)),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TOGGLE (colapsable)
// ---------------------------------------------------------------------------

class ToggleBlockEditor extends StatelessWidget {
  const ToggleBlockEditor({
    super.key,
    required this.block,
    required this.autofocus,
    required this.onChanged,
    required this.onDelete,
  });

  final NoteBlock block;
  final bool autofocus;
  final ValueChanged<NoteBlock> onChanged;
  final VoidCallback onDelete;

  String get _body => block.items.isNotEmpty ? block.items.first.text : '';

  void _setBody(String v) {
    final items = [BlockItem(id: block.items.isNotEmpty ? block.items.first.id : 'body', text: v)];
    onChanged(block.copyWith(items: items));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlockFrame(
      kind: NoteBlockKind.toggle,
      onDelete: onDelete,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => onChanged(block.copyWith(collapsed: !block.collapsed)),
                borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    block.collapsed
                        ? Symbols.chevron_right_rounded
                        : Symbols.expand_more_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              AppSpacing.gapXs,
              Expanded(
                child: _PlainField(
                  value: block.text,
                  autofocus: autofocus,
                  hint: 'Título del toggle',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                  onChanged: (v) => onChanged(block.copyWith(text: v)),
                ),
              ),
            ],
          ),
          if (!block.collapsed)
            Padding(
              padding: const EdgeInsets.only(left: 28, top: AppSpacing.xs),
              child: _PlainField(
                value: _body,
                hint: 'Contenido oculto…',
                style: theme.textTheme.bodyLarge,
                onChanged: _setBody,
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CALLOUT
// ---------------------------------------------------------------------------

class CalloutBlockEditor extends StatelessWidget {
  const CalloutBlockEditor({
    super.key,
    required this.block,
    required this.autofocus,
    required this.onChanged,
    required this.onDelete,
  });

  final NoteBlock block;
  final bool autofocus;
  final ValueChanged<NoteBlock> onChanged;
  final VoidCallback onDelete;

  static const _emojis = ['💡', '⚠️', '✅', '📌', '🔥', '📝'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = block.accentColor != null
        ? Color(block.accentColor!)
        : theme.colorScheme.tertiary;

    return BlockFrame(
      kind: NoteBlockKind.callout,
      onDelete: onDelete,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: AppSpacing.brSm,
          border: Border.all(color: accent.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                final i = _emojis.indexOf(block.emoji);
                final next = _emojis[(i + 1) % _emojis.length];
                onChanged(block.copyWith(emoji: next));
              },
              borderRadius: AppSpacing.brSm,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Text(block.emoji, style: const TextStyle(fontSize: 20)),
              ),
            ),
            AppSpacing.gapSm,
            Expanded(
              child: _PlainField(
                value: block.text,
                autofocus: autofocus,
                hint: 'Escribe un aviso…',
                style: theme.textTheme.bodyLarge,
                onChanged: (v) => onChanged(block.copyWith(text: v)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ENLACE A NOTA
// ---------------------------------------------------------------------------

class NoteLinkBlockEditor extends StatelessWidget {
  const NoteLinkBlockEditor({
    super.key,
    required this.block,
    required this.title,
    required this.onOpen,
    required this.onDelete,
  });

  final NoteBlock block;

  /// Título de la nota destino (ya resuelto por la pantalla). `null` = no existe.
  final String? title;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlockFrame(
      kind: NoteBlockKind.noteLink,
      onDelete: onDelete,
      child: InkWell(
        onTap: title == null ? null : onOpen,
        borderRadius: AppSpacing.brSm,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: AppSpacing.brSm,
          ),
          child: Row(
            children: [
              Icon(Symbols.description_rounded,
                  size: 18, color: theme.colorScheme.primary),
              AppSpacing.gapSm,
              Expanded(
                child: Text(
                  title ?? 'Nota no encontrada',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: title == null
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (title != null)
                Icon(Symbols.arrow_outward_rounded,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ARCHIVO
// ---------------------------------------------------------------------------

class FileBlockEditor extends StatelessWidget {
  const FileBlockEditor({
    super.key,
    required this.block,
    required this.uploading,
    required this.onChanged,
    required this.onDelete,
    required this.onRequestImage,
  });

  final NoteBlock block;
  final bool uploading;
  final ValueChanged<NoteBlock> onChanged;
  final VoidCallback onDelete;
  final Future<String?> Function() onRequestImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlockFrame(
      kind: NoteBlockKind.file,
      onDelete: onDelete,
      child: block.fileUrl != null
          ? Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                borderRadius: AppSpacing.brSm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary.withValues(alpha: 0.18),
                      borderRadius: AppSpacing.brSm,
                    ),
                    child: Icon(Symbols.description_rounded,
                        size: 18, color: theme.colorScheme.tertiary),
                  ),
                  AppSpacing.gapSm,
                  Expanded(
                    child: Text(
                      block.fileName.isEmpty ? 'Archivo' : block.fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => onChanged(
                        block.copyWith(fileUrl: null, fileName: '')),
                    icon: const Icon(Symbols.close_rounded, size: 16),
                    visualDensity: VisualDensity.compact,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            )
          : Align(
              alignment: Alignment.centerLeft,
              child: _ImageButton(
                uploading: uploading,
                onTap: () async {
                  final url = await onRequestImage();
                  if (url != null) {
                    onChanged(block.copyWith(fileUrl: url, fileName: 'Imagen'));
                  }
                },
              ),
            ),
    );
  }
}
