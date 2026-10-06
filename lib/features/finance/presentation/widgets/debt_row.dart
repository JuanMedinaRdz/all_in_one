import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../data/debt.dart';

/// Renglón de una deuda. Para tarjetas muestra la barra de % del límite usado;
/// para préstamos/deudas sueltas, el pago sugerido y la fecha (o "sin fecha").
class DebtRow extends StatelessWidget {
  const DebtRow({super.key, required this.debt, required this.onTap});

  final Debt debt;
  final VoidCallback onTap;

  static const _money = TextStyle(fontFeatures: [FontFeature.tabularFigures()]);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = debt.displayColor;
    final utilization = debt.utilization;

    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: 0.22),
                      color.withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: AppSpacing.brSm,
                ),
                child: Icon(debt.displayIcon, color: color, size: 23),
              ),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      debt.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text:
                                '${debt.isCard ? 'Saldo actual' : 'Saldo restante'} · '),
                        TextSpan(
                          text: Fmt.mxn(debt.balance),
                          style: _money.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Symbols.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant, size: 20),
            ],
          ),
              if (utilization != null) ...[
                AppSpacing.gapMd,
                _UtilizationBar(fraction: utilization, color: color),
                AppSpacing.gapXs,
                Row(
                  children: [
                    Text(
                      '${Fmt.percent(utilization)} del límite usado',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Límite ${Fmt.mxnCompact(debt.creditLimit!)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                AppSpacing.gapMd,
                Row(
                  children: [
                    if (debt.suggestedPayment != null)
                      _Tag(
                        icon: Symbols.savings_rounded,
                        label: 'Sugerido ${Fmt.mxnCompact(debt.suggestedPayment!)}',
                        color: theme.colorScheme.primary,
                      ),
                    const Spacer(),
                    _Tag(
                      icon: debt.dueDate == null
                          ? Symbols.event_busy_rounded
                          : Symbols.event_available_rounded,
                      label: debt.dueDate == null
                          ? 'Sin fecha'
                          : DateFormat("d MMM", 'es_MX').format(debt.dueDate!),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ],
          ),
    );
  }
}

class _UtilizationBar extends StatelessWidget {
  const _UtilizationBar({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Rojo si se acerca al límite: pasar del 80% es señal de alerta.
    final barColor = fraction >= 0.8 ? theme.colorScheme.error : color;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: fraction),
        duration: AppMotion.medium,
        curve: AppMotion.emphasized,
        builder: (context, value, _) => LinearProgressIndicator(
          value: value,
          minHeight: 8,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          color: barColor,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ],
    );
  }
}
