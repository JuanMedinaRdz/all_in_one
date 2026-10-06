import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_lottie.dart';
import '../../../core/widgets/soft_card.dart';
import '../application/debt_providers.dart';
import '../data/debt.dart';
import 'widgets/debt_editor_sheet.dart';
import 'widgets/debt_row.dart';

/// Sub-apartado "Deudas": pagos que no son mensuales, sino saldos a liquidar.
class DebtsView extends ConsumerWidget {
  const DebtsView({super.key});

  static Future<void> openEditor(
    BuildContext context,
    WidgetRef ref, {
    Debt? existing,
  }) async {
    final result = await DebtEditorSheet.show(context, existing: existing);
    if (result == null) return;
    final repo = ref.read(debtRepositoryProvider);
    switch (result) {
      case SaveDebt(:final debt):
        await repo.save(debt);
      case DeleteDebt(:final id):
        await repo.delete(id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debtsAsync = ref.watch(debtsProvider);
    final summary = ref.watch(debtSummaryProvider);

    return switch (debtsAsync) {
      AsyncError(:final error) => _ErrorState(error: error),
      AsyncLoading() => const _LoadingState(),
      AsyncData(value: final debts) => debts.isEmpty
          ? _EmptyState(onAdd: () => openEditor(context, ref))
          : ListView(
              padding: const EdgeInsets.only(bottom: 96),
              children: [
                _TotalCard(summary: summary),
                AppSpacing.gapLg,
                for (final (i, d) in debts.indexed) ...[
                  DebtRow(debt: d, onTap: () => openEditor(context, ref, existing: d))
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 40 * i),
                        duration: AppMotion.medium,
                      )
                      .slideY(begin: 0.1, end: 0, curve: AppMotion.emphasized),
                  AppSpacing.gapMd,
                ],
              ],
            ),
    };
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.summary});

  final DebtSummary summary;

  // Morado apagado, coherente con la referencia pero en clave cálida: separa
  // "lo que debes" del café de las mensualidades.
  static const _plum = Color(0xFF7C5E86);
  static const _money = TextStyle(fontFeatures: [FontFeature.tabularFigures()]);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LatteCard(
      glowColor: _plum,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF8A6C96), Color(0xFF4E3A57)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Symbols.account_balance_wallet_rounded,
                  size: 16, color: Colors.white70),
              AppSpacing.gapSm,
              Text('Debes en total',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: Colors.white70, letterSpacing: 0.4)),
            ],
          ),
          AppSpacing.gapMd,
          Text(
            Fmt.mxnCompact(summary.totalBalance),
            style: theme.textTheme.displaySmall?.merge(_money).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          AppSpacing.gapXs,
          Text(
            summary.count == 1 ? '1 deuda activa' : '${summary.count} deudas activas',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppMotion.medium).slideY(begin: 0.06, end: 0);
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    ).animate().fadeIn(delay: 250.ms, duration: AppMotion.medium);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppLottie(AppAnim.financeEmpty, size: 180),
          Text('Sin deudas registradas', style: theme.textTheme.titleMedium),
          AppSpacing.gapSm,
          Text(
            'Aquí van los pagos que no son mensuales:\ntarjetas, préstamos, lo que debas.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.gapXl,
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Symbols.add_rounded),
            label: const Text('Agregar deuda'),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Symbols.cloud_off_rounded, size: 40, color: theme.colorScheme.error),
              AppSpacing.gapLg,
              Text('No pude cargar tus deudas', style: theme.textTheme.titleMedium),
              AppSpacing.gapSm,
              Text(
                '$error',
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
