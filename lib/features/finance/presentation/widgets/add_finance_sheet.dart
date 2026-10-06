import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_spacing.dart';

/// Qué eligió el usuario en el selector "Agregar nuevo".
enum AddFinanceChoice { payment, debt }

/// Hoja para elegir qué agregar: una mensualidad (se repite) o una deuda (un
/// saldo a liquidar). Dos tarjetas grandes y tactiles, cada una con su color.
class AddFinanceSheet extends StatelessWidget {
  const AddFinanceSheet({super.key});

  static Future<AddFinanceChoice?> show(BuildContext context) {
    return showModalBottomSheet<AddFinanceChoice>(
      context: context,
      builder: (_) => const AddFinanceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
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
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
              ),
            ),
            AppSpacing.gapLg,
            Text('Agregar nuevo', style: theme.textTheme.headlineSmall),
            AppSpacing.gapXs,
            Text(
              'Elige qué quieres registrar',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            AppSpacing.gapXl,
            _Option(
              icon: Symbols.calendar_month_rounded,
              color: theme.colorScheme.primary,
              title: 'Mensualidad',
              subtitle: 'Suscripciones, servicios y pagos recurrentes',
              onTap: () =>
                  Navigator.of(context).pop(AddFinanceChoice.payment),
            ).animate().fadeIn(duration: AppMotion.fast).slideY(begin: 0.1, end: 0),
            AppSpacing.gapMd,
            _Option(
              icon: Symbols.account_balance_wallet_rounded,
              color: const Color(0xFF8A6C96),
              title: 'Deuda',
              subtitle: 'Tarjetas, préstamos o dinero que debes',
              onTap: () => Navigator.of(context).pop(AddFinanceChoice.debt),
            )
                .animate()
                .fadeIn(delay: 60.ms, duration: AppMotion.fast)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: AppSpacing.brLg,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.brLg,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.brLg,
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, Color.lerp(color, Colors.black, 0.25)!],
                  ),
                  borderRadius: AppSpacing.brMd,
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              AppSpacing.gapLg,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Symbols.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
