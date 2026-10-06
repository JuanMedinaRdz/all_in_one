import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

/// Un paso de preparación: número en círculo + texto multilínea + quitar.
class StepRow extends StatefulWidget {
  const StepRow({
    super.key,
    required this.number,
    required this.initial,
    required this.onChanged,
    required this.onRemove,
  });

  final int number;
  final String initial;
  final ValueChanged<String> onChanged;
  final VoidCallback onRemove;

  @override
  State<StepRow> createState() => _StepRowState();
}

class _StepRowState extends State<StepRow> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${widget.number}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AppSpacing.gapMd,
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Describe el paso...',
                isDense: true,
                border: InputBorder.none,
              ),
              onChanged: widget.onChanged,
            ),
          ),
          IconButton(
            onPressed: widget.onRemove,
            icon: const Icon(Icons.close_rounded, size: 18),
            visualDensity: VisualDensity.compact,
            color: theme.colorScheme.onSurfaceVariant,
            tooltip: 'Quitar paso',
          ),
        ],
      ),
    );
  }
}
