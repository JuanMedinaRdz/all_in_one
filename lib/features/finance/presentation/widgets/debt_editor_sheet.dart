import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../data/debt.dart';
import 'personalization_pickers.dart';

/// Qué pidió el usuario al cerrar la hoja de deuda.
sealed class DebtEditorResult {
  const DebtEditorResult();
}

class SaveDebt extends DebtEditorResult {
  const SaveDebt(this.debt);
  final Debt debt;
}

class DeleteDebt extends DebtEditorResult {
  const DeleteDebt(this.id);
  final String id;
}

/// Hoja para crear o editar una deuda.
///
/// Cubre tarjetas (con límite → % de uso) y préstamos/deudas sueltas (solo
/// saldo). La fecha es opcional: "sin fecha específica" es un caso normal.
class DebtEditorSheet extends StatefulWidget {
  const DebtEditorSheet({super.key, this.existing});

  final Debt? existing;

  static Future<DebtEditorResult?> show(BuildContext context, {Debt? existing}) {
    return showModalBottomSheet<DebtEditorResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DebtEditorSheet(existing: existing),
    );
  }

  @override
  State<DebtEditorSheet> createState() => _DebtEditorSheetState();
}

class _DebtEditorSheetState extends State<DebtEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _category;
  late final TextEditingController _balance;
  late final TextEditingController _limit;
  late final TextEditingController _suggested;

  bool _isCard = false;
  DateTime? _dueDate;
  String? _iconKey;
  int? _colorValue;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final d = widget.existing;
    _name = TextEditingController(text: d?.name ?? '');
    _category = TextEditingController(text: d?.category ?? '');
    _balance =
        TextEditingController(text: d == null ? '' : d.balance.toStringAsFixed(2));
    _limit = TextEditingController(
        text: d?.creditLimit == null ? '' : d!.creditLimit!.toStringAsFixed(2));
    _suggested = TextEditingController(
        text: d?.suggestedPayment == null
            ? ''
            : d!.suggestedPayment!.toStringAsFixed(2));
    _isCard = d?.isCard ?? false;
    _dueDate = d?.dueDate;
    _iconKey = d?.iconKey;
    _colorValue = d?.colorValue;
    _name.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _balance.dispose();
    _limit.dispose();
    _suggested.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController c) {
    final t = c.text.trim().replaceAll(',', '');
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  Debt get _preview => Debt(
        id: 'preview',
        name: _name.text,
        category: _category.text.trim(),
        balance: 0,
        creditLimit: _isCard ? 1 : null,
        iconKey: _iconKey,
        colorValue: _colorValue,
      );

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 10),
      locale: const Locale('es', 'MX'),
    );
    if (picked != null) {
      setState(() => _dueDate = DateTime(picked.year, picked.month, picked.day));
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final debt = Debt(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _name.text.trim(),
      category: _category.text.trim(),
      balance: _parse(_balance) ?? 0,
      creditLimit: _isCard ? _parse(_limit) : null,
      suggestedPayment: _parse(_suggested),
      dueDate: _dueDate,
      iconKey: _iconKey,
      colorValue: _colorValue,
      createdAt: widget.existing?.createdAt,
    );
    Navigator.of(context).pop(SaveDebt(debt));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = _preview;

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
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: preview.displayColor.withValues(alpha: 0.18),
                        borderRadius: AppSpacing.brMd,
                      ),
                      child: Icon(preview.displayIcon,
                          color: preview.displayColor, size: 26),
                    ),
                    AppSpacing.gapMd,
                    Expanded(
                      child: Text(
                        _isEditing ? 'Editar deuda' : 'Nueva deuda',
                        style: theme.textTheme.headlineSmall,
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapXl,
                TextFormField(
                  controller: _name,
                  autofocus: !_isEditing,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Tarjeta de crédito, préstamo...',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Ponle un nombre' : null,
                ),
                AppSpacing.gapLg,
                _MoneyField(
                  controller: _balance,
                  label: _isCard ? 'Saldo actual' : 'Saldo restante',
                  validator: (v) {
                    final parsed = double.tryParse((v ?? '').replaceAll(',', ''));
                    if (parsed == null) return 'Escribe un monto válido';
                    if (parsed < 0) return 'No puede ser negativo';
                    return null;
                  },
                ),
                AppSpacing.gapMd,
                SwitchListTile(
                  value: _isCard,
                  onChanged: (v) => setState(() => _isCard = v),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Es una tarjeta de crédito'),
                  subtitle: const Text('Muestra el % del límite usado'),
                ),
                if (_isCard) ...[
                  _MoneyField(controller: _limit, label: 'Límite de la tarjeta'),
                  AppSpacing.gapLg,
                ],
                _MoneyField(
                  controller: _suggested,
                  label: 'Pago sugerido (opcional)',
                ),
                AppSpacing.gapLg,
                TextFormField(
                  controller: _category,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Categoría (opcional)',
                    hintText: 'Bancos, familia...',
                  ),
                ),
                AppSpacing.gapLg,
                // Fecha opcional.
                InkWell(
                  onTap: _pickDate,
                  borderRadius: AppSpacing.brMd,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      borderRadius: AppSpacing.brMd,
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Symbols.event_rounded,
                            size: 20, color: theme.colorScheme.onSurfaceVariant),
                        AppSpacing.gapMd,
                        Expanded(
                          child: Text(
                            _dueDate == null
                                ? 'Sin fecha específica'
                                : 'Vence: ${DateFormat("d 'de' MMMM y", 'es_MX').format(_dueDate!)}',
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        if (_dueDate != null)
                          IconButton(
                            onPressed: () => setState(() => _dueDate = null),
                            icon: const Icon(Symbols.close_rounded, size: 18),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
                ),
                AppSpacing.gapXl,
                IconPicker(
                  selected: _iconKey,
                  color: preview.displayColor,
                  onSelect: (key) => setState(() => _iconKey = key),
                ),
                AppSpacing.gapLg,
                ColorPicker(
                  selected: _colorValue,
                  autoColor: Debt(
                    id: 'p',
                    name: _name.text,
                    category: _category.text.trim(),
                    balance: 0,
                  ).displayColor,
                  onSelect: (v) => setState(() => _colorValue = v),
                ),
                AppSpacing.gapXl,
                Row(
                  children: [
                    if (_isEditing)
                      IconButton(
                        onPressed: () => Navigator.of(context)
                            .pop(DeleteDebt(widget.existing!.id)),
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
}

/// Campo de dinero con prefijo $ y teclado numérico.
class _MoneyField extends StatelessWidget {
  const _MoneyField({
    required this.controller,
    required this.label,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      decoration: InputDecoration(
        labelText: label,
        prefixText: r'$ ',
        suffixText: 'MXN',
      ),
      validator: validator,
    );
  }
}
