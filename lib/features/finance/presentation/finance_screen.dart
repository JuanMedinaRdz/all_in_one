import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/layout/responsive.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/hover.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_lottie.dart';
import '../../../core/widgets/section_placeholder.dart';
import '../../../core/widgets/soft_card.dart';
import '../application/finance_summary.dart';
import '../application/payment_providers.dart';
import '../data/payment.dart';
import '../domain/payment_schedule.dart';
import 'debts_view.dart';
import 'widgets/add_finance_sheet.dart';
import 'widgets/category_breakdown.dart';
import 'widgets/next_payment_hero.dart';
import 'widgets/payment_editor_sheet.dart';
import 'widgets/payment_row.dart';

/// Sub-apartado activo de Finanzas: 0 = Mensualidades, 1 = Deudas.
class FinanceTab extends Notifier<int> {
  @override
  int build() => 0;
  void select(int index) => state = index;
}

final financeTabProvider = NotifierProvider<FinanceTab, int>(FinanceTab.new);

/// Pantalla de Finanzas con dos sub-apartados en la misma vista: las
/// mensualidades (pagos que se repiten) y las deudas (saldos a liquidar).
class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  Future<void> _openPaymentEditor(
    BuildContext context,
    WidgetRef ref, {
    Payment? existing,
  }) async {
    // Ofrece como atajo las categorías que ya usaste en otros pagos.
    final existingCategories = <String>{
      for (final p in ref.read(paymentsProvider).value ?? const [])
        if (p.category.trim().isNotEmpty) p.category.trim(),
    }.toList();

    final result = await PaymentEditorSheet.show(
      context,
      existing: existing,
      categorySuggestions: existingCategories,
    );
    if (result == null) return;

    final repo = ref.read(paymentRepositoryProvider);
    switch (result) {
      case SavePayment(:final payment):
        await repo.save(payment);
      case DeletePayment(:final payment):
        await repo.delete(payment);
    }
  }

  /// Abre el selector "Agregar nuevo" y, tras elegir, cambia a la pestaña
  /// correspondiente y abre su editor.
  Future<void> _addNew(BuildContext context, WidgetRef ref) async {
    final choice = await AddFinanceSheet.show(context);
    if (choice == null || !context.mounted) return;
    switch (choice) {
      case AddFinanceChoice.payment:
        ref.read(financeTabProvider.notifier).select(0);
        await _openPaymentEditor(context, ref);
      case AddFinanceChoice.debt:
        ref.read(financeTabProvider.notifier).select(1);
        if (context.mounted) await DebtsView.openEditor(context, ref);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(financeTabProvider);
    final isPayments = tab == 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNew(context, ref),
        tooltip: 'Agregar nuevo',
        child: const HoverRotateIcon(Symbols.add_rounded, fill: 1),
      ),
      body: SectionScaffold(
        title: 'Finanzas',
        subtitle: isPayments
            ? 'Tu próximo pago y en qué se te va'
            : 'Tarjetas y préstamos por liquidar',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SubTabBar(
              selected: tab,
              onSelect: (i) => ref.read(financeTabProvider.notifier).select(i),
            ),
            AppSpacing.gapLg,
            Expanded(
              child: AnimatedSwitcher(
                duration: AppMotion.medium,
                child: isPayments
                    ? _PaymentsView(
                        key: const ValueKey('payments'),
                        onTapPayment: (p) =>
                            _openPaymentEditor(context, ref, existing: p),
                        onAdd: () => _openPaymentEditor(context, ref),
                      )
                    : const DebtsView(key: ValueKey('debts')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selector de sub-apartado, estilo píldora segmentada (igual que en Notas).
class _SubTabBar extends StatelessWidget {
  const _SubTabBar({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  static const _tabs = [
    (icon: Symbols.wallet_rounded, label: 'Mensualidades'),
    (icon: Symbols.credit_card_rounded, label: 'Deudas'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        children: [
          for (final (i, tab) in _tabs.indexed)
            Expanded(
              child: _SubTab(
                icon: tab.icon,
                label: tab.label,
                selected: selected == i,
                onTap: () => onSelect(i),
              ),
            ),
        ],
      ),
    );
  }
}

class _SubTab extends StatelessWidget {
  const _SubTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.gentle,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              fill: selected ? 1 : 0,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            AppSpacing.gapSm,
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Contenido del sub-apartado Mensualidades.
class _PaymentsView extends ConsumerWidget {
  const _PaymentsView({super.key, required this.onTapPayment, required this.onAdd});

  final ValueChanged<Payment> onTapPayment;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingPaymentsProvider);
    final summaryAsync = ref.watch(financeSummaryProvider);

    return switch (upcomingAsync) {
      AsyncError(:final error) => _ErrorState(error: error),
      AsyncLoading() => const _LoadingState(),
      AsyncData(value: final upcoming) => _Content(
          upcoming: upcoming,
          summary: summaryAsync.value ??
              FinanceSummary.from([for (final u in upcoming) u.payment]),
          onTapPayment: onTapPayment,
          onAdd: onAdd,
        ),
    };
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.upcoming,
    required this.summary,
    required this.onTapPayment,
    required this.onAdd,
  });

  final List<UpcomingPayment> upcoming;
  final FinanceSummary summary;
  final ValueChanged<Payment> onTapPayment;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    if (upcoming.isEmpty) return _EmptyState(onAdd: onAdd);

    final theme = Theme.of(context);
    final next = upcoming.first;

    // Resumen: portada del próximo pago + totales + desglose.
    final overview = <Widget>[
      NextPaymentHero(
        upcoming: next,
        onTap: () => onTapPayment(next.payment),
      ),
      AppSpacing.gapLg,
      _TotalStrip(summary: summary),
      if (summary.byCategory.length > 1) ...[
        AppSpacing.gapLg,
        CategoryBreakdown(summary: summary),
      ],
    ];

    final paymentsHeader = Row(
      children: [
        Text('Tus pagos', style: theme.textTheme.titleMedium),
        AppSpacing.gapSm,
        Text(
          '${upcoming.length}',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    final paymentTiles = <Widget>[
      for (final (i, u) in upcoming.indexed) ...[
        PaymentRow(
          upcoming: u,
          onTap: () => onTapPayment(u.payment),
        )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: 40 * i),
              duration: AppMotion.medium,
            )
            .slideY(begin: 0.12, end: 0, curve: AppMotion.emphasized),
        AppSpacing.gapMd,
      ],
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Ancho: resumen a la izquierda (fijo) y lista de pagos a la derecha,
        // cada una con su propio scroll. Angosto: todo en una columna.
        if (constraints.maxWidth >= Breakpoints.expanded) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 380,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 96),
                  children: overview,
                ),
              ),
              AppSpacing.gapXl,
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 96),
                  children: [paymentsHeader, AppSpacing.gapMd, ...paymentTiles],
                ),
              ),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            ...overview,
            AppSpacing.gapLg,
            paymentsHeader,
            AppSpacing.gapMd,
            ...paymentTiles,
          ],
        );
      },
    );
  }
}

/// Resumen rápido: dos tarjetas premium con el total al mes y al año.
class _TotalStrip extends StatelessWidget {
  const _TotalStrip({required this.summary});

  final FinanceSummary summary;

  static const _money = TextStyle(fontFeatures: [FontFeature.tabularFigures()]);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Symbols.calendar_month_rounded,
            label: 'Al mes',
            value: Fmt.mxn(summary.totalMxn),
          ),
        ),
        AppSpacing.gapMd,
        Expanded(
          child: _StatTile(
            icon: Symbols.trending_up_rounded,
            label: 'Al año',
            value: Fmt.mxnCompact(summary.yearlyMxn),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SoftCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          AppSpacing.gapSm,
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleLarge?.merge(_TotalStrip._money),
          ),
        ],
      ),
    );
  }
}

/// Espera del primer snapshot. Discreta a propósito: casi siempre dura unos
/// milisegundos, y un spinner agresivo se sentiría como un parpadeo.
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: theme.colorScheme.primary,
            ),
          ),
          AppSpacing.gapLg,
          Text(
            'Cargando tus pagos...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
          Text('Todavía no hay pagos', style: theme.textTheme.titleMedium),
          AppSpacing.gapSm,
          Text(
            'Agrega tu primera mensualidad y verás\naquí cuánto se te va al mes.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.gapXl,
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Symbols.add_rounded),
            label: const Text('Agregar la primera'),
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

    // Scroll + recorte del detalle: un error largo no debe romper el layout.
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Symbols.cloud_off_rounded,
                size: 40,
                color: theme.colorScheme.error,
              ),
              AppSpacing.gapLg,
              Text(
                'No pude cargar tus pagos',
                style: theme.textTheme.titleMedium,
              ),
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
