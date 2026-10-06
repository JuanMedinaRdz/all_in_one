import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../application/finance_summary.dart';

/// "En qué se te va": dona + leyenda ordenada de mayor a menor.
///
/// La leyenda es la que de verdad responde la pregunta (es rankeable y
/// legible); la dona da la proporción de un vistazo.
class CategoryBreakdown extends StatelessWidget {
  const CategoryBreakdown({super.key, required this.summary});

  final FinanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('En qué se te va', style: theme.textTheme.titleMedium),
          AppSpacing.gapLg,
          Row(
            children: [
              SizedBox(
                width: 116,
                height: 116,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 34,
                    startDegreeOffset: -90,
                    sections: [
                      for (final c in summary.byCategory)
                        PieChartSectionData(
                          value: c.totalMxn,
                          color: c.color,
                          radius: 20,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
              ),
              AppSpacing.gapLg,
              Expanded(
                child: Column(
                  children: [
                    for (final c in summary.byCategory.take(4))
                      _LegendRow(total: c),
                  ],
                ),
              ),
            ],
          ),
          if (summary.byCategory.length > 4) ...[
            AppSpacing.gapMd,
            for (final c in summary.byCategory.skip(4)) _LegendRow(total: c),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 60.ms, duration: AppMotion.medium);
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.total});

  final CategoryTotal total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: total.color,
              shape: BoxShape.circle,
            ),
          ),
          AppSpacing.gapSm,
          Expanded(
            child: Text(
              total.displayLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            Fmt.percent(total.fraction),
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          AppSpacing.gapSm,
          Text(
            Fmt.mxnCompact(total.totalMxn),
            style: theme.textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}
