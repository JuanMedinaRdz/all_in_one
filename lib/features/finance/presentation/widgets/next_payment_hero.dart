import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/soft_card.dart';
import '../../domain/payment_schedule.dart';

/// La portada de la sección: el **próximo pago** en grande, con el tratamiento
/// "latte" (degradado + brillo de crema). Si el pago tiene foto, va de fondo
/// con un velo para que el texto se lea; si no, degradado de su color.
class NextPaymentHero extends StatelessWidget {
  const NextPaymentHero({super.key, required this.upcoming, required this.onTap});

  final UpcomingPayment upcoming;
  final VoidCallback onTap;

  static const _money = TextStyle(fontFeatures: [FontFeature.tabularFigures()]);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final payment = upcoming.payment;
    final color = payment.displayColor;

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color, Color.lerp(color, Colors.black, 0.38)!],
    );

    return LatteCard(
      onTap: onTap,
      gradient: gradient,
      glowColor: color,
      padding: EdgeInsets.zero,
      height: 208,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Foto de portada (si hay), sobre el degradado del LatteCard.
          if (payment.hasCover)
            CachedNetworkImage(
              imageUrl: payment.coverImageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => const SizedBox.shrink(),
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
          if (payment.hasCover)
            const DecoratedBox(
              decoration: BoxDecoration(
                // Oscurece arriba (para el "Próximo pago") y abajo (título +
                // monto), dejando la foto visible en el centro.
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent, Colors.black87],
                  stops: [0, 0.42, 1],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Symbols.schedule_rounded, size: 15, color: Colors.white70),
                    AppSpacing.gapXs,
                    Text(
                      'Próximo pago',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const Spacer(),
                    _DaysBadge(days: upcoming.daysUntil),
                  ],
                ),
                const Spacer(),
                Text(
                  payment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppSpacing.gapSm,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      Fmt.mxn(payment.amountMxn),
                      style: theme.textTheme.titleLarge?.merge(_money).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    AppSpacing.gapSm,
                    Expanded(
                      child: Text(
                        '· ${Fmt.dayMonth(upcoming.nextDate)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppMotion.medium).slideY(
          begin: 0.06,
          end: 0,
          curve: AppMotion.emphasized,
        );
  }
}

class _DaysBadge extends StatelessWidget {
  const _DaysBadge({required this.days});

  final int days;

  @override
  Widget build(BuildContext context) {
    // Urgente (hoy/mañana) resalta en blanco sólido; lo demás, translúcido.
    final urgent = days <= 1;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: urgent ? Colors.white : Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        Fmt.relativeDays(days),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: urgent ? Colors.black87 : Colors.white,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
