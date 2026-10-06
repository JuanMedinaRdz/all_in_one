import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/payment_icons.dart';

/// Selectores de icono y color compartidos por los editores de pago y de deuda.
///
/// Ambos tienen modo "Auto" (✨): si no eliges nada, la app deduce el
/// icono/color sola. Antes vivían privados en el editor de pagos.

/// Selector de icono: "Auto" + rejilla de iconos, en una fila que se desliza.
class IconPicker extends StatelessWidget {
  const IconPicker({
    super.key,
    required this.selected,
    required this.color,
    required this.onSelect,
  });

  final String? selected;
  final Color color;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Icono', style: theme.textTheme.titleSmall),
        AppSpacing.gapSm,
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _Option(
                selected: selected == null,
                color: color,
                onTap: () => onSelect(null),
                child: Icon(Symbols.auto_awesome_rounded, size: 22, color: color),
              ),
              for (final key in PaymentIcons.keys)
                _Option(
                  selected: selected == key,
                  color: color,
                  onTap: () => onSelect(key),
                  child: Icon(
                    PaymentIcons.catalog[key],
                    size: 22,
                    color: selected == key ? color : theme.colorScheme.onSurface,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Selector de color: "Auto" + muestras.
class ColorPicker extends StatelessWidget {
  const ColorPicker({
    super.key,
    required this.selected,
    required this.autoColor,
    required this.onSelect,
  });

  final int? selected;
  final Color autoColor;
  final ValueChanged<int?> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color', style: theme.textTheme.titleSmall),
        AppSpacing.gapSm,
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _Swatch(
                color: autoColor,
                selected: selected == null,
                onTap: () => onSelect(null),
                child: Icon(
                  Symbols.auto_awesome_rounded,
                  size: 16,
                  color: theme.colorScheme.surface,
                ),
              ),
              for (final c in PaymentColors.swatches)
                _Swatch(
                  color: c,
                  selected: selected == PaymentColors.toValue(c),
                  onTap: () => onSelect(PaymentColors.toValue(c)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.selected,
    required this.color,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.brMd,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          width: 52,
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.16) : Colors.transparent,
            borderRadius: AppSpacing.brMd,
            border: Border.all(
              color: selected
                  ? color
                  : theme.colorScheme.outline.withValues(alpha: 0.5),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
    this.child,
  });

  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? theme.colorScheme.onSurface : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: child == null
              ? (selected
                  ? Icon(Symbols.check_rounded,
                      size: 18, color: theme.colorScheme.surface)
                  : null)
              : Center(child: child),
        ),
      ),
    );
  }
}
