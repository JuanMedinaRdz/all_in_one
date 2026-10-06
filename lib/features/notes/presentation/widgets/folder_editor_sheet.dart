import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/note_folder.dart';

/// Hoja para crear o editar una carpeta: nombre, emoji y color.
///
/// Devuelve la [NoteFolder] lista para guardar, o `null` si se canceló.
class FolderEditorSheet extends StatefulWidget {
  const FolderEditorSheet({super.key, this.existing});

  final NoteFolder? existing;

  static Future<NoteFolder?> show(BuildContext context, {NoteFolder? existing}) {
    return showModalBottomSheet<NoteFolder>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FolderEditorSheet(existing: existing),
    );
  }

  @override
  State<FolderEditorSheet> createState() => _FolderEditorSheetState();
}

class _FolderEditorSheetState extends State<FolderEditorSheet> {
  static const _emojis = [
    '📁', '📚', '💡', '🎧', '🧠', '💻', '🎨', '🌱',
    '☕', '✨', '🏋️', '🍳', '📷', '🎮', '✈️', '🧪',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late String _emoji;
  int? _colorValue;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _emoji = widget.existing?.emoji ?? '📁';
    _colorValue = widget.existing?.colorValue;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      NoteFolder(
        id: widget.existing?.id ?? const Uuid().v4(),
        name: _name.text.trim(),
        emoji: _emoji,
        colorValue: _colorValue,
        createdAt: widget.existing?.createdAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Color de la vista previa: el elegido, o el derivado del nombre actual.
    final autoColor = AppColors.forKey(_name.text.trim().toLowerCase());
    final color = _colorValue != null ? Color(_colorValue!) : autoColor;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outline,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                  ),
                ),
                AppSpacing.gapLg,
                Text(
                  _isEditing ? 'Editar carpeta' : 'Nueva carpeta',
                  style: theme.textTheme.headlineSmall,
                ),
                AppSpacing.gapXl,
                Row(
                  children: [
                    AnimatedContainer(
                      duration: AppMotion.fast,
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
                        borderRadius: AppSpacing.brMd,
                      ),
                      child: Center(
                        child:
                            Text(_emoji, style: const TextStyle(fontSize: 26)),
                      ),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: TextFormField(
                        controller: _name,
                        autofocus: !_isEditing,
                        textCapitalization: TextCapitalization.sentences,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          hintText: 'Ideas, recetas, uni...',
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Ponle un nombre'
                            : null,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapXl,
                Text('Emoji', style: theme.textTheme.titleSmall),
                AppSpacing.gapSm,
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final e in _emojis)
                      InkWell(
                        onTap: () => setState(() => _emoji = e),
                        borderRadius: AppSpacing.brSm,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: e == _emoji
                                ? color.withValues(alpha: 0.2)
                                : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: AppSpacing.brSm,
                            border: e == _emoji
                                ? Border.all(color: color, width: 1.6)
                                : null,
                          ),
                          child: Center(
                            child:
                                Text(e, style: const TextStyle(fontSize: 22)),
                          ),
                        ),
                      ),
                  ],
                ),
                AppSpacing.gapXl,
                Text('Color', style: theme.textTheme.titleSmall),
                AppSpacing.gapSm,
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _Swatch(
                        color: autoColor,
                        selected: _colorValue == null,
                        onTap: () => setState(() => _colorValue = null),
                        child: Icon(
                          Symbols.auto_awesome_rounded,
                          size: 16,
                          color: theme.colorScheme.surface,
                        ),
                      ),
                      for (final c in AppColors.categoryPalette)
                        _Swatch(
                          color: c,
                          selected: _colorValue == c.toARGB32(),
                          onTap: () =>
                              setState(() => _colorValue = c.toARGB32()),
                        ),
                    ],
                  ),
                ),
                AppSpacing.gapXl,
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    AppSpacing.gapSm,
                    FilledButton(
                      onPressed: _save,
                      child: Text(_isEditing ? 'Guardar' : 'Crear'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
    this.child,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color:
                  selected ? theme.colorScheme.onSurface : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: child == null
              ? (selected
                  ? Icon(Symbols.check_rounded,
                      size: 18, color: theme.colorScheme.surface)
                  : null)
              : Center(child: child),
        ),
      ),
    );
  }
}
