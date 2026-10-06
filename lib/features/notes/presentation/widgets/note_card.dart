import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../data/note.dart';
import '../../domain/note_enums.dart';

/// Tipos de bloque presentes en la nota, sin el texto simple (que es lo normal
/// y no distingue). En orden de catálogo, para un vistazo consistente.
List<NoteBlockKind> _kindsOf(Note note) {
  final present = note.blocks.map((b) => b.kind).toSet();
  return [
    for (final k in NoteBlockKind.values)
      if (k != NoteBlockKind.text && present.contains(k)) k,
  ];
}

/// Tarjeta de una nota en la lista.
///
/// Muestra de un vistazo lo que importa para decidir si abrirla: relevancia,
/// tipo, título, un adelanto del contenido y —si es checklist— cuánto llevas.
class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onCycleStatus,
    this.trailing,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onCycleStatus;

  /// Widget extra en la esquina superior derecha (p. ej. el asa de arrastre
  /// del drag & drop).
  final Widget? trailing;

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
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.brLg,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusPill(status: note.status, onTap: onCycleStatus),
                  const Spacer(),
                  // Iconos de los tipos de bloque presentes (menos el texto
                  // simple, que es lo normal y no aporta como distintivo).
                  for (final kind in _kindsOf(note))
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.xs),
                      child: Icon(
                        kind.icon,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (note.imageCount > 0) ...[
                    AppSpacing.gapSm,
                    Icon(
                      Symbols.image_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${note.imageCount}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (trailing != null) ...[
                    AppSpacing.gapSm,
                    trailing!,
                  ],
                ],
              ),
              AppSpacing.gapMd,
              Text(
                note.title.trim().isEmpty ? 'Sin título' : note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              AppSpacing.gapXs,
              Text(
                note.preview,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (note.taskProgress != null) ...[
                AppSpacing.gapMd,
                _Progress(value: note.taskProgress!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.onTap});

  final NoteStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: status.color.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs + 1,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // El icono se rellena y cambia con el estado, sin cambiar de glifo.
              AnimatedSwitcher(
                duration: AppMotion.fast,
                child: Icon(
                  status.icon,
                  key: ValueKey(status),
                  size: 14,
                  fill: 1,
                  color: status.color,
                ),
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Text(
                status.label,
                style: theme.textTheme.labelSmall?.copyWith(color: status.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value),
              duration: AppMotion.medium,
              curve: AppMotion.emphasized,
              builder: (context, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 6,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        AppSpacing.gapSm,
        Text(
          '${(value * 100).round()}%',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
