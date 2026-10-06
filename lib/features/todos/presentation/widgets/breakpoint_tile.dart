import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/todo.dart';

/// Un breakpoint editable dentro del detalle de una tarea: check para marcarlo,
/// título, su hora calculada, la duración y un detalle desplegable.
///
/// El estado "hecho" y la duración están **controlados por el padre** (se leen
/// de [value]), para que arrastrar la barra de progreso también actualice los
/// checks. El texto sí es local (con su controller) para no perder el cursor.
class BreakpointTile extends StatefulWidget {
  const BreakpointTile({
    super.key,
    required this.value,
    required this.clockMinutes,
    required this.accent,
    required this.onToggleDone,
    required this.onDurationChanged,
    required this.onTitleChanged,
    required this.onDetailChanged,
    required this.onRemove,
  });

  final Breakpoint value;

  /// Hora calculada (minutos desde medianoche) a la que termina este paso.
  final int? clockMinutes;
  final Color accent;
  final VoidCallback onToggleDone;
  final ValueChanged<int> onDurationChanged;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<String> onDetailChanged;
  final VoidCallback onRemove;

  @override
  State<BreakpointTile> createState() => _BreakpointTileState();
}

class _BreakpointTileState extends State<BreakpointTile> {
  late final TextEditingController _title =
      TextEditingController(text: widget.value.title);
  late final TextEditingController _detail =
      TextEditingController(text: widget.value.detail);
  late bool _expanded = widget.value.detail.trim().isNotEmpty;

  static const _durations = [5, 10, 15, 20, 30, 45, 60, 90];

  @override
  void dispose() {
    _title.dispose();
    _detail.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = widget.value.done;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Check (controlado por el padre).
              IconButton(
                onPressed: widget.onToggleDone,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  done
                      ? Symbols.check_circle_rounded
                      : Symbols.radio_button_unchecked_rounded,
                  fill: done ? 1 : 0,
                  color: done ? widget.accent : theme.colorScheme.outline,
                ),
              ),
              // Título
              Expanded(
                child: TextField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  style: TextStyle(
                    decoration: done ? TextDecoration.lineThrough : null,
                    color: done ? theme.colorScheme.onSurfaceVariant : null,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Paso',
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  onChanged: widget.onTitleChanged,
                ),
              ),
              // Hora calculada
              if (widget.clockMinutes != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: Text(
                    Fmt.clock(widget.clockMinutes!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              // Duración (menú)
              PopupMenuButton<int>(
                initialValue: widget.value.durationMinutes,
                tooltip: 'Duración',
                onSelected: widget.onDurationChanged,
                itemBuilder: (context) => [
                  for (final d in _durations)
                    PopupMenuItem(value: d, child: Text(Fmt.duration(d))),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  ),
                  child: Text('${widget.value.durationMinutes} min',
                      style: theme.textTheme.labelSmall),
                ),
              ),
              // Detalle (desplegar) / quitar
              IconButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                visualDensity: VisualDensity.compact,
                tooltip: 'Detalle',
                icon: Icon(
                  _expanded ? Symbols.expand_less_rounded : Symbols.notes_rounded,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              IconButton(
                onPressed: widget.onRemove,
                visualDensity: VisualDensity.compact,
                tooltip: 'Quitar',
                icon: Icon(Icons.close_rounded,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(left: 48, bottom: AppSpacing.sm),
              child: TextField(
                controller: _detail,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                style: theme.textTheme.bodySmall,
                decoration: InputDecoration(
                  hintText: 'Detalle o nota del paso...',
                  isDense: true,
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  border: OutlineInputBorder(
                    borderRadius: AppSpacing.brSm,
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: widget.onDetailChanged,
              ),
            ),
        ],
      ),
    );
  }
}
