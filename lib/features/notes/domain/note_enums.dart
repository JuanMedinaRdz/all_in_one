import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';

/// Tipo de un bloque dentro de una nota. Una nota es un "workspace": una pila
/// de bloques heterogéneos, cada uno con su propio [NoteBlockKind].
enum NoteBlockKind {
  /// Párrafo de texto libre. Es el bloque con el que arranca toda nota.
  text('Texto', Symbols.notes_rounded),

  /// Lista de pendientes marcables (cada ítem se tacha).
  checklist('Lista de pasos', Symbols.checklist_rounded),

  /// Secuencia/tutorial: pasos numerados con imagen opcional.
  sequence('Secuencia', Symbols.view_carousel_rounded),

  /// Una tarea con temporizador Pomodoro para concentrarte en ella.
  todo('Pendiente', Symbols.timer_rounded),

  /// Encabezado (título de sección dentro de la nota).
  heading('Título', Symbols.title_rounded),

  /// Bloque de código monoespaciado, con botón de copiar.
  code('Código', Symbols.code_rounded),

  /// Toggle colapsable: un encabezado que esconde/revela su texto.
  toggle('Toggle', Symbols.expand_more_rounded),

  /// Callout: nota resaltada con color y emoji.
  callout('Callout', Symbols.lightbulb_rounded),

  /// Enlace a otra nota ([[ ... ]]).
  noteLink('Enlace a nota', Symbols.link_rounded),

  /// Archivo adjunto (PDF, imagen, etc.).
  file('Archivo', Symbols.attach_file_rounded);

  const NoteBlockKind(this.label, this.icon);

  final String label;
  final IconData icon;

  static NoteBlockKind fromName(String? name) => values.firstWhere(
        (k) => k.name == name,
        orElse: () => NoteBlockKind.text,
      );
}

/// Tipo antiguo de nota (cuando el tipo aplicaba a toda la nota). Se conserva
/// solo para **migrar** las notas creadas antes del modelo de bloques.
enum NoteType {
  plain,
  checklist,
  sequence;

  static NoteType fromName(String? name) => values.firstWhere(
        (t) => t.name == name,
        orElse: () => NoteType.plain,
      );
}

/// Relevancia de la nota: en qué punto está.
enum NoteStatus {
  todo('Por hacer', Symbols.radio_button_unchecked_rounded, AppColors.warning),
  inProgress('En progreso', Symbols.pending_rounded, AppColors.lightSecondary),
  done('Hecho', Symbols.check_circle_rounded, AppColors.success);

  const NoteStatus(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;

  /// Siguiente estado al tocar la píldora: to do → en progreso → hecho → …
  NoteStatus get next => values[(index + 1) % values.length];

  static NoteStatus fromName(String? name) => values.firstWhere(
        (s) => s.name == name,
        orElse: () => NoteStatus.todo,
      );
}

/// Orientación de los bloques en una nota de secuencia.
enum BlockLayout {
  vertical('Vertical', Symbols.view_agenda_rounded),
  horizontal('Horizontal', Symbols.view_column_rounded);

  const BlockLayout(this.label, this.icon);

  final String label;
  final IconData icon;

  BlockLayout get toggled =>
      this == BlockLayout.vertical ? BlockLayout.horizontal : BlockLayout.vertical;

  static BlockLayout fromName(String? name) => values.firstWhere(
        (l) => l.name == name,
        orElse: () => BlockLayout.vertical,
      );
}
