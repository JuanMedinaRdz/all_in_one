import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../application/people_providers.dart';
import '../../data/person.dart';
import 'person_avatar.dart';
import 'rotation_editor_sheet.dart';

/// Sección "Compartido" para el editor de una mensualidad o deuda: activa el
/// plan familiar y abre el editor de rotación. Reporta el [SharingConfig] nuevo.
class SharedSection extends ConsumerWidget {
  const SharedSection({
    super.key,
    required this.title,
    required this.amount,
    required this.config,
    required this.onChanged,
  });

  final String title;
  final double amount;
  final SharingConfig config;
  final ValueChanged<SharingConfig> onChanged;

  Future<void> _editRotation(BuildContext context) async {
    final result = await RotationEditorSheet.show(
      context,
      title: title.trim().isEmpty ? 'Este pago' : title,
      amount: amount,
      initial: config,
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final byId = ref.watch(peopleByIdProvider);
    final participants =
        config.participantIds.map((id) => byId[id]).whereType().toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppSpacing.brMd,
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            value: config.shared,
            onChanged: (v) {
              onChanged((
                shared: v,
                participantIds: config.participantIds,
                rotationMode: config.rotationMode,
                assignments: config.assignments,
              ));
              // Al activar sin participantes, abre el editor para configurarlo.
              if (v && config.participantIds.isEmpty) {
                _editRotation(context);
              }
            },
            shape: const RoundedRectangleBorder(borderRadius: AppSpacing.brMd),
            secondary: Icon(Symbols.group_rounded,
                color: config.shared
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant),
            title: const Text('Compartido (plan familiar)'),
            subtitle: Text(
              config.shared
                  ? (config.rotationMode == 'split'
                      ? 'Se divide cada mes'
                      : 'Por turnos')
                  : 'Repartir el pago entre varias personas',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          if (config.shared)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
              child: Row(
                children: [
                  if (participants.isEmpty)
                    Expanded(
                      child: Text('Sin participantes aún',
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    )
                  else
                    Expanded(
                      child: SizedBox(
                        height: 34,
                        child: Stack(
                          children: [
                            for (final (i, p) in participants.indexed)
                              Positioned(
                                left: i * 22.0,
                                child: PersonAvatar(person: p, size: 34),
                              ),
                          ],
                        ),
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () => _editRotation(context),
                    icon: const Icon(Symbols.tune_rounded, size: 18),
                    label: const Text('Editar rotación'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
