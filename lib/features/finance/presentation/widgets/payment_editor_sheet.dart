import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../application/payment_providers.dart';
import '../../data/payment.dart';
import '../../domain/payment_category.dart';
import 'personalization_pickers.dart';
import 'shared_section.dart';

/// Hoja para crear o editar una mensualidad.
///
/// Todo es personalizable: nombre, categoría (texto libre), icono y color. El
/// icono y el color tienen modo "Auto": si no eliges nada, la app los deduce
/// de la marca reconocida (Netflix, Spotify) o de la categoría.
///
/// Devuelve un [PaymentEditorResult] al cerrarse, o `null` si se canceló.
/// No habla con Firestore: solo arma el dato y deja que la pantalla decida.
class PaymentEditorSheet extends ConsumerStatefulWidget {
  const PaymentEditorSheet({
    super.key,
    this.existing,
    this.categorySuggestions = const [],
  });

  /// `null` = alta nueva.
  final Payment? existing;

  /// Categorías que ya usaste en otros pagos, para ofrecerlas como atajo.
  final List<String> categorySuggestions;

  static Future<PaymentEditorResult?> show(
    BuildContext context, {
    Payment? existing,
    List<String> categorySuggestions = const [],
  }) {
    return showModalBottomSheet<PaymentEditorResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PaymentEditorSheet(
        existing: existing,
        categorySuggestions: categorySuggestions,
      ),
    );
  }

  @override
  ConsumerState<PaymentEditorSheet> createState() => _PaymentEditorSheetState();
}

/// Qué pidió el usuario al cerrar la hoja.
sealed class PaymentEditorResult {
  const PaymentEditorResult();
}

class SavePayment extends PaymentEditorResult {
  const SavePayment(this.payment);
  final Payment payment;
}

class DeletePayment extends PaymentEditorResult {
  const DeletePayment(this.payment);
  final Payment payment;
}

class _PaymentEditorSheetState extends ConsumerState<PaymentEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late final TextEditingController _category;
  late int _dayOfMonth;

  /// Overrides del usuario. `null` = automático.
  String? _iconKey;
  int? _colorValue;

  /// Foto de portada (URL ya subida) y estado de la subida en curso.
  String? _coverUrl;
  bool _uploadingCover = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final p = widget.existing;
    _name = TextEditingController(text: p?.name ?? '');
    _amount = TextEditingController(
      text: p == null ? '' : p.amountMxn.toStringAsFixed(2),
    );
    _category = TextEditingController(text: p?.category ?? '');
    _dayOfMonth = p?.dayOfMonth ?? 1;
    _iconKey = p?.iconKey;
    _colorValue = p?.colorValue;
    _coverUrl = p?.coverImageUrl;
    // La vista previa depende del nombre y la categoría (para autodetección).
    _name.addListener(_refresh);
    _category.addListener(_refresh);
  }

  /// Elige una foto, la comprime y la sube; queda como portada del pago.
  Future<void> _pickCover() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2400,
    );
    if (picked == null) return;

    setState(() => _uploadingCover = true);
    try {
      final url = await ref
          .read(paymentImageServiceProvider)
          .upload(File(picked.path));
      if (mounted) setState(() => _coverUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No pude subir la foto: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingCover = false);
    }
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _category.dispose();
    super.dispose();
  }

  /// Pago "de mentira" con el estado actual, solo para leer su icono y color
  /// resueltos. Así el preview usa exactamente la misma lógica que la app real
  /// (incluida la detección de marca).
  Payment get _preview => Payment(
        id: 'preview',
        name: _name.text,
        amountMxn: 0,
        category: _category.text.trim(),
        dayOfMonth: _dayOfMonth,
        iconKey: _iconKey,
        colorValue: _colorValue,
      );

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final payment = Payment(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _name.text.trim(),
      amountMxn: double.parse(_amount.text.replaceAll(',', '')),
      category: _category.text.trim(),
      dayOfMonth: _dayOfMonth,
      iconKey: _iconKey,
      colorValue: _colorValue,
      coverImageUrl: _coverUrl,
      createdAt: widget.existing?.createdAt,
    );
    Navigator.of(context).pop(SavePayment(payment));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = _preview;
    final suggestions = _suggestions();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Form(
            key: _formKey,
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
                // Preview + título: ves cómo quedará mientras lo armas.
                Row(
                  children: [
                    _PreviewAvatar(
                      icon: preview.displayIcon,
                      color: preview.displayColor,
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: Text(
                        _isEditing ? 'Editar mensualidad' : 'Nueva mensualidad',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapLg,
                _CoverPicker(
                  url: _coverUrl,
                  uploading: _uploadingCover,
                  fallbackColor: preview.displayColor,
                  fallbackIcon: preview.displayIcon,
                  onPick: _pickCover,
                  onRemove: () => setState(() => _coverUrl = null),
                ),
                AppSpacing.gapLg,
                TextFormField(
                  controller: _name,
                  autofocus: !_isEditing,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Netflix, renta, mi curso...',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ponle un nombre'
                      : null,
                ),
                AppSpacing.gapLg,
                TextFormField(
                  controller: _amount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Monto mensual',
                    prefixText: r'$ ',
                    suffixText: 'MXN',
                  ),
                  validator: (v) {
                    final parsed = double.tryParse(v ?? '');
                    if (parsed == null) return 'Escribe un monto válido';
                    if (parsed <= 0) return 'Debe ser mayor a cero';
                    return null;
                  },
                ),
                AppSpacing.gapLg,
                TextFormField(
                  controller: _category,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    hintText: 'La que quieras',
                  ),
                ),
                if (suggestions.isNotEmpty) ...[
                  AppSpacing.gapSm,
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final s in suggestions)
                        _SuggestionChip(
                          label: s,
                          selected:
                              _category.text.trim().toLowerCase() ==
                                  s.toLowerCase(),
                          onTap: () {
                            _category.text = s;
                            _refresh();
                          },
                        ),
                    ],
                  ),
                ],
                AppSpacing.gapXl,
                IconPicker(
                  selected: _iconKey,
                  color: preview.displayColor,
                  onSelect: (key) => setState(() => _iconKey = key),
                ),
                AppSpacing.gapLg,
                ColorPicker(
                  selected: _colorValue,
                  autoColor: Payment(
                    id: 'p',
                    name: _name.text,
                    amountMxn: 0,
                    category: _category.text.trim(),
                    dayOfMonth: 1,
                  ).displayColor,
                  onSelect: (value) => setState(() => _colorValue = value),
                ),
                AppSpacing.gapXl,
                Row(
                  children: [
                    Text('Día de cobro', style: theme.textTheme.titleSmall),
                    const Spacer(),
                    Text(
                      '$_dayOfMonth',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _dayOfMonth.toDouble(),
                  min: 1,
                  max: 31,
                  divisions: 30,
                  label: '$_dayOfMonth',
                  onChanged: (v) => setState(() => _dayOfMonth = v.round()),
                ),
                AppSpacing.gapLg,
                Row(
                  children: [
                    if (_isEditing)
                      IconButton(
                        onPressed: () => Navigator.of(context)
                            .pop(DeletePayment(widget.existing!)),
                        icon: const Icon(Symbols.delete_rounded),
                        color: theme.colorScheme.error,
                        tooltip: 'Eliminar',
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                    AppSpacing.gapSm,
                    FilledButton(
                      onPressed: _save,
                      child: Text(_isEditing ? 'Guardar' : 'Agregar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Categorías a sugerir: primero las que ya usaste, luego los presets, sin
  /// repetir.
  List<String> _suggestions() {
    final seen = <String>{};
    final result = <String>[];
    for (final s in [
      ...widget.categorySuggestions,
      ...PaymentCategory.values.map((c) => c.label),
    ]) {
      final trimmed = s.trim();
      if (trimmed.isEmpty) continue;
      if (seen.add(trimmed.toLowerCase())) result.add(trimmed);
    }
    return result;
  }
}

/// Selector de foto de portada: banner ancho con la imagen (y botón para
/// quitarla) o, si no hay, un botón para agregarla sobre el color del pago.
class _CoverPicker extends StatelessWidget {
  const _CoverPicker({
    required this.url,
    required this.uploading,
    required this.fallbackColor,
    required this.fallbackIcon,
    required this.onPick,
    required this.onRemove,
  });

  final String? url;
  final bool uploading;
  final Color fallbackColor;
  final IconData fallbackIcon;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  /// Degradado con el color del pago + su icono, usado cuando no hay foto o
  /// cuando la foto no carga.
  Widget _fallback() => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              fallbackColor.withValues(alpha: 0.85),
              fallbackColor.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: Center(
          child: Icon(fallbackIcon,
              color: Colors.white.withValues(alpha: 0.9), size: 34),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: AppSpacing.brMd,
      child: SizedBox(
        height: 128,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (url != null)
              CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                // Si Storage no responde (p. ej. facturación pausada), se cae
                // al degradado en vez de mostrar una imagen rota.
                errorWidget: (_, __, ___) => _fallback(),
              )
            else
              _fallback(),
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
            // Acción: agregar (si no hay foto) o quitar (si hay).
            Positioned(
              right: AppSpacing.sm,
              bottom: AppSpacing.sm,
              child: url == null
                  ? FilledButton.tonalIcon(
                      onPressed: uploading ? null : onPick,
                      icon: const Icon(Symbols.add_photo_alternate_rounded, size: 18),
                      label: const Text('Portada'),
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
                  'Foto de portada',
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
      color: Colors.black.withValues(alpha: 0.5),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _PreviewAvatar extends StatelessWidget {
  const _PreviewAvatar({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.fast,
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: AppSpacing.brMd,
      ),
      child: AnimatedSwitcher(
        duration: AppMotion.fast,
        child: Icon(icon, key: ValueKey(icon.codePoint), color: color, size: 28),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.16) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(
            color: selected
                ? primary
                : theme.colorScheme.outline.withValues(alpha: 0.6),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected ? primary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

