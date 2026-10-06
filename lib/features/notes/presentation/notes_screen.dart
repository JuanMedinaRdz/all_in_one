import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:uuid/uuid.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/hover.dart';
import '../../../core/widgets/section_placeholder.dart';
import '../../recipes/presentation/recipes_view.dart';
import '../application/folder_providers.dart';
import '../application/note_providers.dart';
import '../data/note.dart';
import '../domain/spoken_date.dart';
import '../domain/voice_note.dart';
import 'notes_home_view.dart';
import 'notes_scope_view.dart';
import 'widgets/voice_capture_sheet.dart';

/// Sub-apartado activo dentro de la pantalla: 0 = Notas, 1 = Recetas.
class NotesHubTab extends Notifier<int> {
  @override
  int build() => 0;
  void select(int index) => state = index;
}

final notesHubTabProvider = NotifierProvider<NotesHubTab, int>(NotesHubTab.new);

/// Pantalla contenedora con dos sub-apartados en la misma vista: las notas
/// (con su home de carpetas) y las recetas. El selector va arriba; el botón
/// "+" y el título cambian según dónde estés.
class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(notesHubTabProvider);
    final scope = ref.watch(notesScopeProvider);
    final isNotes = tab == 0;

    // Crear desde dentro de una carpeta guarda la nota ahí mismo.
    final folderId = switch (scope) {
      NotesScopeFolder(:final folderId) => folderId,
      _ => null,
    };

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isNotes) ...[
            // Nota por voz: hablas y la app la escribe.
            FloatingActionButton.small(
              heroTag: 'fab_voice',
              onPressed: () =>
                  NotesView.createVoiceNote(context, ref, folderId: folderId),
              tooltip: 'Nota por voz',
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: const Icon(Symbols.mic_rounded, fill: 1),
            ),
            AppSpacing.gapMd,
          ],
          FloatingActionButton(
            heroTag: 'fab_add',
            onPressed: () => isNotes
                ? NotesView.createNote(context, ref, folderId: folderId)
                : RecipesView.createRecipe(context, ref),
            tooltip: isNotes ? 'Nueva nota' : 'Nueva receta',
            child: const HoverRotateIcon(Symbols.add_rounded, fill: 1),
          ),
        ],
      ),
      // Dentro de un espacio (o Todas/Sin espacio) la vista va a pantalla
      // completa, con su propia portada y botón de volver — sin el título
      // "Notas" ni el selector Notas/Recetas, que solo estorban ahí.
      body: isNotes && scope is! NotesScopeHome
          ? SafeArea(
              bottom: false,
              child: NotesScopeView(key: ValueKey(scope), scope: scope),
            )
          : SectionScaffold(
              title: isNotes ? 'Notas' : 'Recetas',
              subtitle: isNotes
                  ? 'Tu segundo cerebro, a tu manera'
                  : 'Tu recetario y la lista de la semana',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SubTabBar(
                    selected: tab,
                    onSelect: (i) =>
                        ref.read(notesHubTabProvider.notifier).select(i),
                  ),
                  AppSpacing.gapLg,
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: AppMotion.medium,
                      child: !isNotes
                          ? const RecipesView(key: ValueKey('recipes'))
                          : const NotesHomeView(key: ValueKey('home')),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// Punto de entrada a la creación de notas (lo usa también el FAB del hub).
abstract final class NotesView {
  const NotesView._();

  /// Crea una nota vacía y abre el editor: escribir el título es lo primero
  /// que querrás hacer, no llenar un formulario antes de empezar. Si al salir
  /// sigue vacía, el editor la borra solo.
  static Future<void> createNote(
    BuildContext context,
    WidgetRef ref, {
    String? folderId,
  }) async {
    // Arranca limpia: título + un bloque de texto listo para escribir.
    final note = Note(
      id: const Uuid().v4(),
      folderId: folderId,
      blocks: [NoteBlock(id: const Uuid().v4())],
    );
    await ref.read(noteRepositoryProvider).save(note);
    if (context.mounted) context.go('${AppRoutes.notes}/${note.id}');
  }

  /// Crea una nota dictándola: abre la captura por voz y, con lo transcrito,
  /// arma la nota (título derivado de las primeras palabras + el texto
  /// completo como bloque) y la deja abierta en el editor por si quieres
  /// retocarla.
  static Future<void> createVoiceNote(
    BuildContext context,
    WidgetRef ref, {
    String? folderId,
  }) async {
    final transcript = await VoiceCaptureSheet.show(context);
    final text = transcript?.trim() ?? '';
    if (text.isEmpty) return;

    // Si mencionaste una fecha ("mañana", "el viernes"...), se agenda sola:
    // la nota nace con recordatorio y aparece en el calendario.
    final spoken = SpokenDate.parse(text);

    final note = Note(
      id: const Uuid().v4(),
      folderId: folderId,
      title: VoiceNote.deriveTitle(text),
      blocks: [NoteBlock(id: const Uuid().v4(), text: text)],
      reminderDate: spoken?.date,
    );
    await ref.read(noteRepositoryProvider).save(note);

    if (!context.mounted) return;
    if (spoken != null) _showReminderToast(context, spoken);
    context.go('${AppRoutes.notes}/${note.id}');
  }

  /// Aviso amable de que se detectó una fecha y se agendó. Da control: un
  /// toque en "Quitar" borra el recordatorio si no era lo que querías.
  static void _showReminderToast(BuildContext context, SpokenDate spoken) {
    final label = DateFormat("EEEE d 'de' MMMM", 'es_MX').format(spoken.date);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📅 Recordatorio agendado para $label'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Selector de sub-apartado, estilo píldora segmentada.
class _SubTabBar extends StatelessWidget {
  const _SubTabBar({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  static const _tabs = [
    (icon: Symbols.sticky_note_2_rounded, label: 'Notas'),
    (icon: Symbols.restaurant_menu_rounded, label: 'Recetas'),
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
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
