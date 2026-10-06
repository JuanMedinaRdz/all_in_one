import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../data/recipe.dart';
import '../../domain/ingredient_icons.dart';

/// Un renglón editable de ingrediente: icono (automático o elegido), nombre y
/// cantidad. El icono se detecta solo conforme escribes el nombre; tócalo para
/// cambiarlo a mano.
class IngredientRow extends StatefulWidget {
  const IngredientRow({
    super.key,
    required this.initial,
    required this.onChanged,
    required this.onRemove,
  });

  final RecipeIngredient initial;
  final ValueChanged<RecipeIngredient> onChanged;
  final VoidCallback onRemove;

  @override
  State<IngredientRow> createState() => _IngredientRowState();
}

class _IngredientRowState extends State<IngredientRow> {
  late final TextEditingController _name =
      TextEditingController(text: widget.initial.name);
  late final TextEditingController _quantity =
      TextEditingController(text: widget.initial.quantity);
  late String _emoji = widget.initial.emoji; // '' = automático

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
    super.dispose();
  }

  RecipeIngredient get _value => RecipeIngredient(
        name: _name.text,
        quantity: _quantity.text,
        emoji: _emoji,
      );

  String get _shownEmoji =>
      _emoji.isNotEmpty ? _emoji : IngredientIcons.emojiOrDefault(_name.text);

  Future<void> _pickEmoji() async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => _EmojiPicker(current: _emoji),
    );
    if (chosen == null) return;
    // '' viene de la opción "Automático".
    setState(() => _emoji = chosen);
    widget.onChanged(_value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icono
          Material(
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _pickEmoji,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: Text(_shownEmoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
            ),
          ),
          AppSpacing.gapSm,
          // Nombre
          Expanded(
            flex: 3,
            child: TextField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ingrediente',
                isDense: true,
                border: InputBorder.none,
              ),
              // Redibuja para refrescar el emoji automático.
              onChanged: (_) {
                setState(() {});
                widget.onChanged(_value);
              },
            ),
          ),
          AppSpacing.gapSm,
          // Cantidad
          Expanded(
            flex: 2,
            child: TextField(
              controller: _quantity,
              textAlign: TextAlign.end,
              decoration: InputDecoration(
                hintText: 'Cant.',
                isDense: true,
                border: InputBorder.none,
                hintStyle: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              onChanged: (_) => widget.onChanged(_value),
            ),
          ),
          IconButton(
            onPressed: widget.onRemove,
            icon: const Icon(Icons.close_rounded, size: 18),
            visualDensity: VisualDensity.compact,
            color: theme.colorScheme.onSurfaceVariant,
            tooltip: 'Quitar',
          ),
        ],
      ),
    );
  }
}

/// Rejilla de emojis de comida para elegir a mano, con opción "Automático".
class _EmojiPicker extends StatelessWidget {
  const _EmojiPicker({required this.current});

  final String current;

  static const _emojis = <String>[
    '🍅', '🧅', '🧄', '🥔', '🥕', '🥦', '🥬', '🌽',
    '🌶️', '🫑', '🥒', '🍆', '🥑', '🍄', '🫛', '🎃',
    '🍎', '🍌', '🍋', '🍊', '🍓', '🍇', '🍍', '🥭',
    '🍉', '🍑', '🍒', '🥝', '🥥', '🍐', '🍈', '🍯',
    '🍗', '🥩', '🥓', '🍖', '🐟', '🦐', '🐙', '🥚',
    '🥛', '🧀', '🧈', '🍞', '🥖', '🫓', '🍚', '🍝',
    '🌾', '🫘', '🥜', '🧂', '🫒', '🥫', '🍲', '🥣',
    '☕', '🍵', '🍫', '🍪', '🧊', '🌿', '🫚', '🥄',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text('Elige un icono', style: theme.textTheme.titleMedium),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pop(''),
                  icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                  label: const Text('Automático'),
                ),
              ],
            ),
            AppSpacing.gapSm,
            Flexible(
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 8,
                children: [
                  for (final e in _emojis)
                    InkWell(
                      onTap: () => Navigator.of(context).pop(e),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: e == current
                              ? theme.colorScheme.primary.withValues(alpha: 0.18)
                              : null,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Center(
                          child: Text(e, style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
