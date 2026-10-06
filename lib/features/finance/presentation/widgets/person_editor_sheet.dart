import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../data/person.dart';

/// Hoja para crear o editar una persona del roster.
class PersonEditorSheet extends StatefulWidget {
  const PersonEditorSheet({super.key, this.existing});

  final Person? existing;

  static Future<Person?> show(BuildContext context, {Person? existing}) {
    return showModalBottomSheet<Person>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: PersonEditorSheet(existing: existing),
      ),
    );
  }

  @override
  State<PersonEditorSheet> createState() => _PersonEditorSheetState();
}

class _PersonEditorSheetState extends State<PersonEditorSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late String _emoji = widget.existing?.emoji ?? '🐰';
  late int _color = widget.existing?.colorValue ??
      AppColors.categoryPalette.first.toARGB32();

  static const _emojis = ['🐰', '🐱', '🐻', '🦊', '🐼', '🐸', '🐥', '☕', '🌙', '⭐'];

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(
      (widget.existing ?? Person(id: const Uuid().v4(), name: name)).copyWith(
        name: name,
        emoji: _emoji,
        colorValue: _color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.existing == null ? 'Nueva persona' : 'Editar persona',
              style: theme.textTheme.titleLarge),
          AppSpacing.gapLg,
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nombre'),
            onSubmitted: (_) => _save(),
          ),
          AppSpacing.gapLg,
          Text('Avatar', style: theme.textTheme.labelLarge),
          AppSpacing.gapSm,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final e in _emojis)
                GestureDetector(
                  onTap: () => setState(() => _emoji = e),
                  child: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _emoji == e
                          ? Color(_color).withValues(alpha: 0.22)
                          : theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _emoji == e
                            ? Color(_color)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Text(e, style: const TextStyle(fontSize: 20)),
                  ),
                ),
            ],
          ),
          AppSpacing.gapLg,
          Text('Color', style: theme.textTheme.labelLarge),
          AppSpacing.gapSm,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final c in AppColors.categoryPalette)
                GestureDetector(
                  onTap: () => setState(() => _color = c.toARGB32()),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _color == c.toARGB32()
                            ? theme.colorScheme.onSurface
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.gapXl,
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: _save, child: const Text('Guardar')),
          ),
        ],
      ),
    );
  }
}
