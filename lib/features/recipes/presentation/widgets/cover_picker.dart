import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../../core/theme/app_spacing.dart';

/// Selector de foto de portada de la receta: banner ancho con la imagen (y
/// botones para cambiarla/quitarla) o, si no hay, un botón para agregarla.
class CoverPicker extends StatelessWidget {
  const CoverPicker({
    super.key,
    required this.url,
    required this.uploading,
    required this.onPick,
    required this.onRemove,
  });

  final String? url;
  final bool uploading;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  Widget _fallback(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
              Theme.of(context).colorScheme.secondary.withValues(alpha: 0.6),
            ],
          ),
        ),
        child: const Center(child: Text('🍳', style: TextStyle(fontSize: 40))),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: AppSpacing.brMd,
      child: SizedBox(
        height: 168,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url != null)
              CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => _fallback(context),
                placeholder: (_, __) => _fallback(context),
              )
            else
              _fallback(context),
            if (uploading)
              Container(
                color: Colors.black.withValues(alpha: 0.35),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  ),
                ),
              ),
            Positioned(
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: url == null
                  ? FilledButton.tonalIcon(
                      onPressed: uploading ? null : onPick,
                      icon: const Icon(Symbols.add_photo_alternate_rounded, size: 18),
                      label: const Text('Foto'),
                    )
                  : Row(
                      children: [
                        _MiniAction(
                          icon: Symbols.swap_horiz_rounded,
                          onTap: uploading ? null : onPick,
                        ),
                        AppSpacing.gapSm,
                        _MiniAction(
                          icon: Symbols.close_rounded,
                          onTap: uploading ? null : onRemove,
                        ),
                      ],
                    ),
            ),
            if (url == null)
              Positioned(
                left: AppSpacing.md,
                top: AppSpacing.sm,
                child: Text(
                  'Foto del platillo',
                  style: theme.textTheme.labelMedium
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniAction extends StatelessWidget {
  const _MiniAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}
