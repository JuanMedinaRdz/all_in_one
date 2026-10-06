import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/debouncer.dart';
import '../application/recipe_providers.dart';
import '../data/recipe.dart';
import 'widgets/cover_picker.dart';
import 'widgets/ingredient_row.dart';
import 'widgets/step_row.dart';

/// Editor de una receta: portada, datos, ingredientes (con icono automático) y
/// pasos. Guarda con debounce (como el editor de notas): escribir un renglón
/// cuesta una escritura, no una por tecla. Si sales sin llenar nada, se borra.
class RecipeEditorScreen extends ConsumerStatefulWidget {
  const RecipeEditorScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  final _debouncer = Debouncer();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  Recipe? _recipe;
  bool _initialized = false;
  bool _uploadingCover = false;

  /// Llaves estables por renglón (ingredientes/pasos) para que los controllers
  /// no se barajen al agregar o quitar filas.
  final _ingredientKeys = <Key>[];
  final _stepKeys = <Key>[];

  Recipe? get _current => _recipe ?? ref.read(recipeProvider(widget.recipeId)).value;

  @override
  void dispose() {
    _debouncer.flush();
    _debouncer.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Siembra los controllers y llaves la primera vez que llega la receta.
  void _initFrom(Recipe recipe) {
    if (_initialized) return;
    _initialized = true;
    _nameController.text = recipe.name;
    _descriptionController.text = recipe.description;
    _ingredientKeys
      ..clear()
      ..addAll(List.generate(recipe.ingredients.length, (_) => UniqueKey()));
    _stepKeys
      ..clear()
      ..addAll(List.generate(recipe.steps.length, (_) => UniqueKey()));
  }

  void _update(Recipe updated, {bool immediate = false}) {
    setState(() => _recipe = updated);
    final repo = ref.read(recipeRepositoryProvider);
    if (immediate) {
      repo.save(updated);
    } else {
      _debouncer.run(() => repo.save(updated));
    }
  }

  // --- Portada ---
  Future<void> _pickCover() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2400,
    );
    if (picked == null) return;

    setState(() => _uploadingCover = true);
    try {
      final url =
          await ref.read(recipeImageServiceProvider).upload(File(picked.path));
      final recipe = _current;
      if (recipe != null && mounted) {
        _update(recipe.copyWith(coverImageUrl: url), immediate: true);
      }
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

  void _removeCover() {
    final recipe = _current;
    if (recipe == null) return;
    _update(recipe.copyWith(coverImageUrl: null), immediate: true);
  }

  // --- Ingredientes ---
  void _addIngredient() {
    final recipe = _current;
    if (recipe == null) return;
    setState(() => _ingredientKeys.add(UniqueKey()));
    _update(
      recipe.copyWith(ingredients: [...recipe.ingredients, const RecipeIngredient(name: '')]),
      immediate: true,
    );
  }

  void _updateIngredient(int index, RecipeIngredient value) {
    final recipe = _current;
    if (recipe == null) return;
    final list = [...recipe.ingredients];
    if (index >= list.length) return;
    list[index] = value;
    _update(recipe.copyWith(ingredients: list));
  }

  void _removeIngredient(int index) {
    final recipe = _current;
    if (recipe == null) return;
    final list = [...recipe.ingredients]..removeAt(index);
    setState(() => _ingredientKeys.removeAt(index));
    _update(recipe.copyWith(ingredients: list), immediate: true);
  }

  // --- Pasos ---
  void _addStep() {
    final recipe = _current;
    if (recipe == null) return;
    setState(() => _stepKeys.add(UniqueKey()));
    _update(recipe.copyWith(steps: [...recipe.steps, '']), immediate: true);
  }

  void _updateStep(int index, String value) {
    final recipe = _current;
    if (recipe == null) return;
    final list = [...recipe.steps];
    if (index >= list.length) return;
    list[index] = value;
    _update(recipe.copyWith(steps: list));
  }

  void _removeStep(int index) {
    final recipe = _current;
    if (recipe == null) return;
    final list = [...recipe.steps]..removeAt(index);
    setState(() => _stepKeys.removeAt(index));
    _update(recipe.copyWith(steps: list), immediate: true);
  }

  // --- Datos sueltos ---
  void _setServings(int? v) {
    final recipe = _current;
    if (recipe != null) _update(recipe.copyWith(servings: v), immediate: true);
  }

  void _setMinutes(int? v) {
    final recipe = _current;
    if (recipe != null) _update(recipe.copyWith(minutes: v), immediate: true);
  }

  void _setPlanned(bool v) {
    final recipe = _current;
    if (recipe != null) {
      HapticFeedback.selectionClick();
      _update(recipe.copyWith(plannedThisWeek: v), immediate: true);
    }
  }

  Future<void> _confirmDelete() async {
    final recipe = _current;
    if (recipe == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Eliminar "${recipe.displayName}"?'),
        content: const Text('Se borrará la receta y su foto. No se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    _debouncer.dispose();
    await ref.read(recipeRepositoryProvider).delete(recipe);
    if (mounted) context.pop();
  }

  /// Al salir, si la receta quedó en blanco, se borra sola (se creó por el "+").
  Future<void> _onExit() async {
    _debouncer.flush();
    final recipe = _current;
    if (recipe != null && recipe.isBlank) {
      await ref.read(recipeRepositoryProvider).delete(recipe);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final async = ref.watch(recipeProvider(widget.recipeId));

    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('No pude abrir la receta: $e')),
      ),
      data: (remote) {
        if (remote == null && _recipe == null) {
          // Borrada desde otro lado, o aún no existe.
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Esta receta ya no existe.')),
          );
        }
        _initFrom(remote ?? _recipe!);
        final recipe = _current!;

        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) _onExit();
          },
          child: Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  title: const Text('Receta'),
                  actions: [
                    IconButton(
                      onPressed: _confirmDelete,
                      icon: const Icon(Symbols.delete_rounded),
                      tooltip: 'Eliminar',
                    ),
                  ],
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xxl),
                  sliver: SliverList.list(
                    children: [
                      CoverPicker(
                        url: recipe.coverImageUrl,
                        uploading: _uploadingCover,
                        onPick: _pickCover,
                        onRemove: _removeCover,
                      ),
                      AppSpacing.gapLg,
                      // Nombre
                      TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.sentences,
                        style: theme.textTheme.headlineSmall,
                        decoration: const InputDecoration(
                          hintText: 'Nombre de la receta',
                          border: InputBorder.none,
                        ),
                        onChanged: (v) => _update(recipe.copyWith(name: v)),
                      ),
                      // Porciones + tiempo
                      Row(
                        children: [
                          Expanded(
                            child: _NumberField(
                              icon: Symbols.restaurant_rounded,
                              label: 'Porciones',
                              value: recipe.servings,
                              onChanged: _setServings,
                            ),
                          ),
                          AppSpacing.gapMd,
                          Expanded(
                            child: _NumberField(
                              icon: Symbols.timer_rounded,
                              label: 'Minutos',
                              value: recipe.minutes,
                              onChanged: _setMinutes,
                            ),
                          ),
                        ],
                      ),
                      AppSpacing.gapMd,
                      _PlanTile(planned: recipe.plannedThisWeek, onChanged: _setPlanned),
                      AppSpacing.gapLg,
                      // Descripción
                      TextField(
                        controller: _descriptionController,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                        style: theme.textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Notas: de dónde salió, tips, para cuántos rinde...',
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.brMd,
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (v) => _update(recipe.copyWith(description: v)),
                      ),
                      AppSpacing.gapXl,
                      // Ingredientes
                      _SectionHeader(
                        emoji: '🧺',
                        title: 'Ingredientes',
                        count: recipe.realIngredients.length,
                      ),
                      AppSpacing.gapMd,
                      for (var i = 0; i < recipe.ingredients.length; i++)
                        IngredientRow(
                          key: _ingredientKeys[i],
                          initial: recipe.ingredients[i],
                          onChanged: (v) => _updateIngredient(i, v),
                          onRemove: () => _removeIngredient(i),
                        ),
                      _AddButton(label: 'Agregar ingrediente', onTap: _addIngredient),
                      AppSpacing.gapXl,
                      // Pasos
                      _SectionHeader(
                        emoji: '👩‍🍳',
                        title: 'Preparación',
                        count: recipe.realSteps.length,
                      ),
                      AppSpacing.gapMd,
                      for (var i = 0; i < recipe.steps.length; i++)
                        StepRow(
                          key: _stepKeys[i],
                          number: i + 1,
                          initial: recipe.steps[i],
                          onChanged: (v) => _updateStep(i, v),
                          onRemove: () => _removeStep(i),
                        ),
                      _AddButton(label: 'Agregar paso', onTap: _addStep),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Campo numérico compacto (porciones / minutos) con icono y etiqueta.
class _NumberField extends StatefulWidget {
  const _NumberField({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  State<_NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<_NumberField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value?.toString() ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon, size: 20),
        labelText: widget.label,
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.brMd,
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (v) => widget.onChanged(v.trim().isEmpty ? null : int.tryParse(v)),
    );
  }
}

/// Interruptor "Cocinar esta semana" (entra a la lista de compras).
class _PlanTile extends StatelessWidget {
  const _PlanTile({required this.planned, required this.onChanged});

  final bool planned;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: planned
          ? theme.colorScheme.primary.withValues(alpha: 0.12)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      borderRadius: AppSpacing.brMd,
      child: SwitchListTile(
        value: planned,
        onChanged: onChanged,
        shape: const RoundedRectangleBorder(borderRadius: AppSpacing.brMd),
        secondary: Icon(
          Symbols.bookmark_rounded,
          fill: planned ? 1 : 0,
          color: planned ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
        ),
        title: const Text('Cocinar esta semana'),
        subtitle: Text(
          'Sus ingredientes entran a tu lista de compras',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.emoji, required this.title, required this.count});

  final String emoji;
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(emoji, style: theme.textTheme.titleMedium),
        AppSpacing.gapSm,
        Text(title, style: theme.textTheme.titleMedium),
        AppSpacing.gapSm,
        if (count > 0)
          Text('$count',
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onTap,
        icon: const Icon(Symbols.add_rounded, size: 20),
        label: Text(label),
      ),
    );
  }
}
