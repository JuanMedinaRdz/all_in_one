import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../application/people_providers.dart';
import '../../data/person.dart';
import '../../domain/payment_sharing.dart';
import 'person_avatar.dart';
import 'person_editor_sheet.dart';

/// Configuración de compartir que devuelve el editor de rotación.
typedef SharingConfig = ({
  bool shared,
  List<String> participantIds,
  String rotationMode,
  Map<String, String> assignments,
});

/// Editor de "Rotación de pagos": quiénes participan, el modo (por turnos o
/// dividir) y a quién le toca cada mes. Devuelve un [SharingConfig].
class RotationEditorSheet extends ConsumerStatefulWidget {
  const RotationEditorSheet({
    super.key,
    required this.title,
    required this.amount,
    required this.initial,
  });

  final String title;
  final double amount;
  final SharingConfig initial;

  static Future<SharingConfig?> show(
    BuildContext context, {
    required String title,
    required double amount,
    required SharingConfig initial,
  }) {
    return showModalBottomSheet<SharingConfig>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => RotationEditorSheet(
          title: title, amount: amount, initial: initial),
    );
  }

  @override
  ConsumerState<RotationEditorSheet> createState() =>
      _RotationEditorSheetState();
}

class _RotationEditorSheetState extends ConsumerState<RotationEditorSheet> {
  late final List<String> _participants = [...widget.initial.participantIds];
  late String _mode = widget.initial.rotationMode;
  late Map<String, String> _assignments = {...widget.initial.assignments};

  static const _monthsAhead = 12;

  List<DateTime> get _months {
    final now = DateTime.now();
    return [for (var i = 0; i < _monthsAhead; i++) DateTime(now.year, now.month + i)];
  }

  void _toggleParticipant(String id) {
    setState(() {
      if (_participants.contains(id)) {
        _participants.remove(id);
        _assignments.removeWhere((_, v) => v == id);
      } else {
        _participants.add(id);
      }
    });
  }

  void _cycle(String key) {
    if (_participants.isEmpty) return;
    setState(() {
      final current = _assignments[key];
      if (current == null) {
        _assignments[key] = _participants.first;
      } else {
        final i = _participants.indexOf(current);
        if (i < 0 || i == _participants.length - 1) {
          _assignments.remove(key);
        } else {
          _assignments[key] = _participants[i + 1];
        }
      }
    });
  }

  void _fillInOrder() {
    setState(() {
      _assignments = PaymentSharing.fillInOrder(
          _participants, _months.first, _monthsAhead);
    });
  }

  Future<void> _addPerson() async {
    final person = await PersonEditorSheet.show(context);
    if (person == null) return;
    await ref.read(personRepositoryProvider).save(person);
    setState(() => _participants.add(person.id));
  }

  Map<String, double> _yearTotals() {
    final items = [
      for (final m in _months)
        (
          amount: widget.amount,
          participantIds: _participants,
          rotationMode: _mode,
          assigned: _assignments[PaymentSharing.monthKey(m)],
        ),
    ];
    return PaymentSharing.contributions(items);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final people = ref.watch(peopleProvider).value ?? const <Person>[];
    final byId = {for (final p in people) p.id: p};

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxl),
        children: [
          Text('Rotación de pagos', style: theme.textTheme.titleLarge),
          AppSpacing.gapXs,
          Text(widget.title,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          AppSpacing.gapLg,

          // Participantes.
          Text('¿Quiénes participan?', style: theme.textTheme.titleSmall),
          AppSpacing.gapSm,
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              for (final p in people)
                GestureDetector(
                  onTap: () => _toggleParticipant(p.id),
                  child: Column(
                    children: [
                      PersonAvatar(
                        person: p,
                        size: 48,
                        selected: _participants.contains(p.id),
                        dimmed: !_participants.contains(p.id),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        width: 52,
                        child: Text(p.shortName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.labelSmall),
                      ),
                    ],
                  ),
                ),
              GestureDetector(
                onTap: _addPerson,
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: theme.colorScheme.outline
                                .withValues(alpha: 0.6)),
                      ),
                      child: Icon(Symbols.add_rounded,
                          color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 2),
                    Text('Agregar', style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.gapLg,

          // Modo.
          Row(
            children: [
              Expanded(
                child: _ModeButton(
                  label: 'Por turnos',
                  selected: _mode == 'turns',
                  onTap: () => setState(() => _mode = 'turns'),
                ),
              ),
              AppSpacing.gapSm,
              Expanded(
                child: _ModeButton(
                  label: 'Dividir cada mes',
                  selected: _mode == 'split',
                  onTap: () => setState(() => _mode = 'split'),
                ),
              ),
            ],
          ),
          AppSpacing.gapLg,

          if (_mode == 'turns') ...[
            Row(
              children: [
                Text('Toca un mes para cambiar',
                    style: theme.textTheme.titleSmall),
                const Spacer(),
                TextButton.icon(
                  onPressed: _participants.isEmpty ? null : _fillInOrder,
                  icon: const Icon(Symbols.auto_fix_high_rounded, size: 16),
                  label: const Text('Rellenar en orden'),
                ),
              ],
            ),
            AppSpacing.gapSm,
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 1.5,
              children: [
                for (final m in _months)
                  _MonthCell(
                    month: m,
                    person: byId[_assignments[PaymentSharing.monthKey(m)]],
                    onTap: () => _cycle(PaymentSharing.monthKey(m)),
                  ),
              ],
            ),
            AppSpacing.gapLg,
          ],

          // Totales en 12 meses.
          Container(
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
                Row(
                  children: [
                    Text('En 12 meses', style: theme.textTheme.titleSmall),
                    const Spacer(),
                    Text(Fmt.mxnCompact(widget.amount * 12),
                        style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                  ],
                ),
                AppSpacing.gapSm,
                for (final e in _yearTotals().entries)
                  if (byId[e.key] != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          PersonAvatar(person: byId[e.key]!, size: 24),
                          AppSpacing.gapSm,
                          Expanded(child: Text(byId[e.key]!.shortName)),
                          Text(Fmt.mxnCompact(e.value),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                if (_participants.isEmpty)
                  Text('Agrega participantes para repartir.',
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          AppSpacing.gapXl,
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop((
                shared: _participants.isNotEmpty,
                participantIds: _participants,
                rotationMode: _mode,
                assignments: _assignments,
              )),
              child: const Text('Guardar rotación'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton(
      {required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.brSm,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.16)
              : theme.colorScheme.surface,
          borderRadius: AppSpacing.brSm,
          border: Border.all(
            color: selected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Text(label,
            style: theme.textTheme.labelLarge?.copyWith(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _MonthCell extends StatelessWidget {
  const _MonthCell(
      {required this.month, required this.person, required this.onTap});

  final DateTime month;
  final Person? person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = DateFormat.MMM('es_MX').format(month);
    final color = person?.color ?? theme.colorScheme.outline;
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.brSm,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: person == null
              ? theme.colorScheme.surface
              : color.withValues(alpha: 0.14),
          borderRadius: AppSpacing.brSm,
          border: Border.all(
            color: person == null
                ? theme.colorScheme.outline.withValues(alpha: 0.4)
                : color.withValues(alpha: 0.6),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${label[0].toUpperCase()}${label.substring(1)}'
              '${month.month == 1 ? " ${month.year % 100}" : ""}',
              style: theme.textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            if (person != null)
              PersonAvatar(person: person!, size: 24)
            else
              Text('—',
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
