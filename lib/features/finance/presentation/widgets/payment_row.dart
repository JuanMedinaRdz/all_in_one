import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../domain/payment_schedule.dart';

/// Renglón estructurado de un pago en la lista.
///
/// Miniatura de portada (o icono si no hay foto), nombre + categoría, monto, y
/// a la derecha cuándo toca el próximo cobro. Sin casillas.
class PaymentRow extends StatelessWidget {
  const PaymentRow({super.key, required this.upcoming, required this.onTap});

  final UpcomingPayment upcoming;
  final VoidCallback onTap;

  static const _money = TextStyle(fontFeatures: [FontFeature.tabularFigures()]);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final payment = upcoming.payment;
    final color = payment.displayColor;
    final soon = upcoming.daysUntil <= 3;

    return SoftCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      child: Row(
        children: [
          _Thumb(
            url: payment.coverImageUrl,
            color: color,
            icon: payment.displayIcon,
          ),
          AppSpacing.gapMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 1),
                Text(
                  payment.category.trim().isEmpty
                      ? Fmt.dayOfMonth(payment.dayOfMonth)
                      : '${payment.category} · ${Fmt.dayOfMonth(payment.dayOfMonth)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.gapSm,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Fmt.mxn(payment.amountMxn),
                style: theme.textTheme.titleSmall?.merge(_money),
              ),
              const SizedBox(height: 3),
              _DayPill(label: Fmt.relativeDays(upcoming.daysUntil), color: color, soon: soon),
            ],
          ),
          AppSpacing.gapXs,
        ],
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({required this.label, required this.color, required this.soon});

  final String label;
  final Color color;
  final bool soon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: soon
            ? color.withValues(alpha: 0.16)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: soon ? color : theme.colorScheme.onSurfaceVariant,
          fontWeight: soon ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

/// Miniatura 46x46: foto de portada recortada, o el icono del pago sobre su
/// color si no tiene foto.
class _Thumb extends StatelessWidget {
  const _Thumb({required this.url, required this.color, required this.icon});

  final String? url;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return ClipRRect(
        borderRadius: AppSpacing.brSm,
        child: CachedNetworkImage(
          imageUrl: url!,
          width: 46,
          height: 46,
          fit: BoxFit.cover,
          placeholder: (_, __) => _iconBox(),
          errorWidget: (_, __, ___) => _iconBox(),
        ),
      );
    }
    return _iconBox();
  }

  Widget _iconBox() => Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0.12)],
          ),
          borderRadius: AppSpacing.brSm,
        ),
        child: Icon(icon, color: color, size: 24),
      );
}
