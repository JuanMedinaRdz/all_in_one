import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/note_enums.dart';

part 'note.freezed.dart';

/// Un sub-ítem dentro de un bloque de lista o secuencia: un pendiente marcable
/// o un paso del tutorial.
@freezed
abstract class BlockItem with _$BlockItem {
  const BlockItem._();

  const factory BlockItem({
    required String id,
    @Default('') String text,

    /// Marcado (solo en listas de pasos).
    @Default(false) bool done,

    /// URL en Firebase Storage (solo en secuencias). `null` = sin imagen.
    String? imageUrl,

    /// Si este ítem de checklist se envió a To Do's, el id de la tarea creada.
    /// `null` = no enviado. Permite sincronizar el "hecho" en ambos lados y no
    /// duplicar.
    String? todoId,
  }) = _BlockItem;

  factory BlockItem.fromMap(Map<String, dynamic> map) => BlockItem(
        id: (map['id'] as String?) ?? '',
        text: (map['text'] as String?) ?? '',
        done: (map['done'] as bool?) ?? false,
        imageUrl: map['imageUrl'] as String?,
        todoId: map['todoId'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'done': done,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (todoId != null) 'todoId': todoId,
      };

  bool get isEmpty => text.trim().isEmpty && imageUrl == null;
}

/// Un bloque de la nota. Su [kind] decide qué es y cómo se dibuja:
/// - `text`: un párrafo (opcionalmente con una imagen).
/// - `checklist` / `sequence`: un encabezado + [items].
/// - `todo`: una tarea con temporizador Pomodoro de [pomodoroMinutes].
@freezed
abstract class NoteBlock with _$NoteBlock {
  const NoteBlock._();

  const factory NoteBlock({
    required String id,
    @Default(NoteBlockKind.text) NoteBlockKind kind,

    /// Texto del bloque: el párrafo (text), el encabezado (checklist/sequence)
    /// o la actividad (todo).
    @Default('') String text,

    /// Imagen del bloque de texto. `null` = sin imagen.
    String? imageUrl,

    /// Tarea completada (solo en `todo`).
    @Default(false) bool done,

    /// Minutos del Pomodoro (solo en `todo`).
    @Default(25) int pomodoroMinutes,

    /// Orientación de una secuencia.
    @Default(BlockLayout.vertical) BlockLayout layout,

    /// Sub-ítems de checklist o secuencia.
    @Default(<BlockItem>[]) List<BlockItem> items,

    // --- Campos de los bloques nuevos (opcionales) ---

    /// Toggle colapsado (oculta su texto).
    @Default(false) bool collapsed,

    /// Lenguaje del bloque de código (solo informativo, p. ej. "dart").
    @Default('') String language,

    /// Id de la nota destino (solo `noteLink`).
    String? targetNoteId,

    /// Archivo adjunto (solo `file`).
    String? fileUrl,
    @Default('') String fileName,
    int? fileSize,

    /// Color de acento del callout (ARGB). `null` = color por defecto.
    int? accentColor,

    /// Emoji del callout.
    @Default('💡') String emoji,
  }) = _NoteBlock;

  factory NoteBlock.fromMap(Map<String, dynamic> map) => NoteBlock(
        id: (map['id'] as String?) ?? '',
        kind: NoteBlockKind.fromName(map['kind'] as String?),
        text: (map['text'] as String?) ?? '',
        imageUrl: map['imageUrl'] as String?,
        done: (map['done'] as bool?) ?? false,
        pomodoroMinutes: (map['pomodoroMinutes'] as num?)?.toInt() ?? 25,
        layout: BlockLayout.fromName(map['layout'] as String?),
        items: ((map['items'] as List<dynamic>?) ?? const [])
            .map((i) => BlockItem.fromMap(Map<String, dynamic>.from(i as Map)))
            .toList(),
        collapsed: (map['collapsed'] as bool?) ?? false,
        language: (map['language'] as String?) ?? '',
        targetNoteId: map['targetNoteId'] as String?,
        fileUrl: map['fileUrl'] as String?,
        fileName: (map['fileName'] as String?) ?? '',
        fileSize: (map['fileSize'] as num?)?.toInt(),
        accentColor: (map['accentColor'] as num?)?.toInt(),
        emoji: (map['emoji'] as String?) ?? '💡',
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'kind': kind.name,
        'text': text,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'done': done,
        'pomodoroMinutes': pomodoroMinutes,
        'layout': layout.name,
        'items': items.map((i) => i.toMap()).toList(),
        if (collapsed) 'collapsed': collapsed,
        if (language.isNotEmpty) 'language': language,
        if (targetNoteId != null) 'targetNoteId': targetNoteId,
        if (fileUrl != null) 'fileUrl': fileUrl,
        if (fileName.isNotEmpty) 'fileName': fileName,
        if (fileSize != null) 'fileSize': fileSize,
        if (accentColor != null) 'accentColor': accentColor,
        if (kind == NoteBlockKind.callout) 'emoji': emoji,
      };

  /// Progreso 0–1 de un bloque de lista (ítems marcados). 0 si no aplica.
  double get progress {
    final real = items.where((i) => !i.isEmpty).toList();
    if (real.isEmpty) return 0;
    return real.where((i) => i.done).length / real.length;
  }

  List<String> get imageUrls => [
        if (imageUrl != null) imageUrl!,
        for (final i in items)
          if (i.imageUrl != null) i.imageUrl!,
      ];

  bool get isEmpty {
    final noText = text.trim().isEmpty;
    return switch (kind) {
      NoteBlockKind.text => noText && imageUrl == null,
      NoteBlockKind.todo ||
      NoteBlockKind.heading ||
      NoteBlockKind.code ||
      NoteBlockKind.toggle ||
      NoteBlockKind.callout =>
        noText,
      NoteBlockKind.checklist ||
      NoteBlockKind.sequence =>
        noText && items.every((i) => i.isEmpty),
      // Un enlace o archivo nunca está "vacío" si tiene destino/archivo.
      NoteBlockKind.noteLink => targetNoteId == null,
      NoteBlockKind.file => fileUrl == null,
    };
  }
}

/// Una nota: un **workspace** con una pila de [blocks] ordenados y de tipos
/// mezclables.
///
/// Todo va embebido en el documento (no en subcolecciones) a propósito: una
/// nota se lee y se escribe entera con **una sola** operación en vez de N. El
/// límite de 1 MB por documento es enorme para texto, y las imágenes solo
/// guardan su URL, no los bytes.
@freezed
abstract class Note with _$Note {
  const Note._();

  const factory Note({
    required String id,
    @Default('') String title,
    @Default(NoteStatus.todo) NoteStatus status,
    @Default(<NoteBlock>[]) List<NoteBlock> blocks,

    /// Espacio (carpeta) al que pertenece. `null` = sin espacio.
    String? folderId,

    /// Sección dentro del espacio. `null` = "Sin sección".
    String? sectionId,

    /// Emoji/icono de la nota. Vacío = sin icono (se usa el del tipo).
    @Default('') String icon,

    /// Etiquetas (#backend, #api...). Sin el "#".
    @Default(<String>[]) List<String> tags,

    /// Marcada como favorita (estrella).
    @Default(false) bool favorite,

    /// Fijada arriba dentro del espacio.
    @Default(false) bool pinned,

    /// Tarea de To Do's vinculada a esta nota. `null` = ninguna.
    String? linkedTodoId,

    /// Posición manual asignada por drag & drop. `null` = sin ordenar (se
    /// muestra por recencia). Ver `NoteOrdering`.
    double? sortIndex,

    /// Día en que esta nota debe aparecer en el calendario. `null` = sin fecha.
    /// Se guarda normalizada a medianoche: aquí importa el día, no la hora.
    DateTime? reminderDate,
    DateTime? createdAt,
    DateTime? updatedAt,

    /// Última vez que se abrió (para "Seguir donde lo dejaste").
    DateTime? lastOpenedAt,
  }) = _Note;

  factory Note.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    final rawBlocks = (data['blocks'] as List<dynamic>?) ?? const [];

    return Note(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      status: NoteStatus.fromName(data['status'] as String?),
      blocks: _readBlocks(rawBlocks, data['type'] as String?,
          data['layout'] as String?),
      folderId: data['folderId'] as String?,
      sectionId: data['sectionId'] as String?,
      icon: (data['icon'] as String?) ?? '',
      tags: ((data['tags'] as List<dynamic>?) ?? const [])
          .map((t) => t as String)
          .toList(),
      favorite: (data['favorite'] as bool?) ?? false,
      pinned: (data['pinned'] as bool?) ?? false,
      linkedTodoId: data['linkedTodoId'] as String?,
      sortIndex: (data['sortIndex'] as num?)?.toDouble(),
      reminderDate: (data['reminderDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      lastOpenedAt: (data['lastOpenedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Lee los bloques, migrando el formato viejo si hace falta.
  ///
  /// Antes, la nota tenía un `type` global y los bloques eran los ítems. Ahora
  /// cada bloque tiene su `kind`. Se detecta el formato viejo por la ausencia
  /// del campo `kind` en el primer bloque, y se convierte sin perder nada:
  /// - `plain`  → un bloque de texto por cada ítem viejo.
  /// - `checklist` → un solo bloque checklist con los ítems dentro.
  /// - `sequence`  → un solo bloque secuencia con los pasos dentro.
  static List<NoteBlock> _readBlocks(
    List<dynamic> raw,
    String? legacyType,
    String? legacyLayout,
  ) {
    if (raw.isEmpty) return const [];

    final maps = raw.map((b) => Map<String, dynamic>.from(b as Map)).toList();
    final isNewFormat = maps.first.containsKey('kind');
    if (isNewFormat) return maps.map(NoteBlock.fromMap).toList();

    // --- migración desde el formato viejo ---
    final type = NoteType.fromName(legacyType);
    switch (type) {
      case NoteType.plain:
        return [
          for (final m in maps)
            NoteBlock(
              id: (m['id'] as String?) ?? '',
              kind: NoteBlockKind.text,
              text: (m['text'] as String?) ?? '',
              imageUrl: m['imageUrl'] as String?,
            ),
        ];
      case NoteType.checklist:
      case NoteType.sequence:
        final items = maps.map(BlockItem.fromMap).toList();
        return [
          NoteBlock(
            id: 'migrated_${type.name}',
            kind: type == NoteType.checklist
                ? NoteBlockKind.checklist
                : NoteBlockKind.sequence,
            layout: BlockLayout.fromName(legacyLayout),
            items: items,
          ),
        ];
    }
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'status': status.name,
        'blocks': blocks.map((b) => b.toMap()).toList(),
        // folderId, sectionId y reminderDate se mandan explícitamente, incluso
        // en null: así se puede quitar un espacio/sección/fecha ya puesto
        // (omitirlos con `merge: true` los dejaría intactos).
        'folderId': folderId,
        'sectionId': sectionId,
        'icon': icon,
        'tags': tags,
        'favorite': favorite,
        'pinned': pinned,
        'linkedTodoId': linkedTodoId,
        if (sortIndex != null) 'sortIndex': sortIndex,
        'reminderDate':
            reminderDate == null ? null : Timestamp.fromDate(reminderDate!),
        if (lastOpenedAt != null)
          'lastOpenedAt': Timestamp.fromDate(lastOpenedAt!),
        'updatedAt': FieldValue.serverTimestamp(),
        if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
      };

  /// `true` si la nota no tiene nada del usuario: ni título, ni contenido, ni
  /// fecha. Se usa para auto-borrar notas creadas por accidente.
  bool get isBlank =>
      title.trim().isEmpty &&
      blocks.every((b) => b.isEmpty) &&
      reminderDate == null;

  /// Progreso global de tareas (0–1): ítems de checklist marcados + pendientes
  /// `todo` completados, sobre el total. `null` si la nota no tiene tareas.
  double? get taskProgress {
    var total = 0;
    var done = 0;
    for (final b in blocks) {
      if (b.kind == NoteBlockKind.checklist) {
        for (final i in b.items.where((i) => !i.isEmpty)) {
          total++;
          if (i.done) done++;
        }
      } else if (b.kind == NoteBlockKind.todo && b.text.trim().isNotEmpty) {
        total++;
        if (b.done) done++;
      }
    }
    return total == 0 ? null : done / total;
  }

  List<String> get imageUrls =>
      [for (final b in blocks) ...b.imageUrls];

  int get imageCount => imageUrls.length;

  /// Vista previa para la tarjeta de la lista: junta el texto de los bloques.
  String get preview {
    final parts = <String>[];
    for (final b in blocks) {
      if (b.text.trim().isNotEmpty) parts.add(b.text.trim());
      for (final i in b.items) {
        if (i.text.trim().isNotEmpty) parts.add(i.text.trim());
      }
    }
    final text = parts.join(' · ');
    return text.isEmpty ? 'Nota vacía' : text;
  }

  /// Ítems de checklist sin marcar (los "pendientes" que alimentan To Do's).
  List<BlockItem> get pendingItems => [
        for (final b in blocks)
          if (b.kind == NoteBlockKind.checklist)
            for (final i in b.items)
              if (!i.isEmpty && !i.done) i,
      ];

  int get pendingCount => pendingItems.length;

  /// Ids de las notas enlazadas desde esta ([[ ... ]]), para "Mencionada en".
  List<String> get linkedNoteIds => [
        for (final b in blocks)
          if (b.kind == NoteBlockKind.noteLink && b.targetNoteId != null)
            b.targetNoteId!,
      ];
}
