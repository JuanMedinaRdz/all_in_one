import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/calendar_event.dart';
import 'day_landscape.dart';

/// Lo que pasa el día seleccionado.
class DayEventsPanel extends StatelessWidget {
  const DayEventsPanel({
    super.key,
    required this.day,
    required this.events,
    required this.total,
    required this.onTapEvent,
  });

  final DateTime day;
  final List<CalendarEvent> events;
  final double total;
  final ValueChanged<CalendarEvent> onTapEvent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = DateFormat("EEEE d 'de' MMMM", 'es_MX').format(day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                // El formato viene en minúscula: "lunes 28 de julio".
                label[0].toUpperCase() + label.substring(1),
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (total > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
                child: Text(
                  Fmt.mxn(total),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        // Día tranquilo: un paisaje cozy arriba. Con muchas tareas no estorba.
        if (events.length <= 1) ...[
          AppSpacing.gapMd,
          const DayLandscape(),
          AppSpacing.gapXs,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Día ligero',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
        AppSpacing.gapMd,
        Expanded(
          child: events.isEmpty
              ? _Empty(key: ValueKey(day))
              : ListView.separated(
                  key: ValueKey(day),
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => AppSpacing.gapSm,
                  itemBuilder: (context, i) => _EventTile(
                    event: events[i],
                    onTap: () => onTapEvent(events[i]),
                  )
                      .animate()
                      .fadeIn(
                        delay: Duration(milliseconds: 30 * i),
                        duration: AppMotion.fast,
                      )
                      .slideX(begin: 0.06, end: 0, curve: AppMotion.emphasized),
                ),
        ),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.onTap});

  final CalendarEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: AppSpacing.brMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.brMd,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppSpacing.brMd,
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              _EventThumb(event: event),
              AppSpacing.gapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    if (event.subtitle != null)
                      Text(
                        event.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              // Distingue de un vistazo un cobro de un recordatorio.
              Icon(
                event.isPayment
                    ? Symbols.payments_rounded
                    : Symbols.push_pin_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Miniatura del evento: la foto de portada del pago si tiene, o su icono.
class _EventThumb extends StatelessWidget {
  const _EventThumb({required this.event});

  final CalendarEvent event;

  @override
  Widget build(BuildContext context) {
    if (event.imageUrl != null) {
      return ClipRRect(
        borderRadius: AppSpacing.brSm,
        child: CachedNetworkImage(
          imageUrl: event.imageUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            width: 40,
            height: 40,
            color: event.color.withValues(alpha: 0.18),
          ),
          errorWidget: (_, __, ___) => _iconBox(),
        ),
      );
    }
    return _iconBox();
  }

  Widget _iconBox() => Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: event.color.withValues(alpha: 0.18),
          borderRadius: AppSpacing.brSm,
        ),
        child: Icon(event.icon, color: event.color, size: 20),
      );
}

class _Empty extends StatelessWidget {
  const _Empty({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Symbols.wb_sunny_rounded,
            size: 28,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
          AppSpacing.gapSm,
          Text(
            'Nada este día',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
