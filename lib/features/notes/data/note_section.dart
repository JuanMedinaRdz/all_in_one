import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'note_section.freezed.dart';

/// Una sección dentro de un espacio ("Backend", "Despliegue"...).
///
/// Vive en `workspace/main/noteSections` y referencia a su espacio por
/// [folderId]. Las notas apuntan a la sección por su [id] (`sectionId`). Borrar
/// una sección no borra sus notas: quedan "Sin sección".
@freezed
abstract class NoteSection with _$NoteSection {
  const NoteSection._();

  const factory NoteSection({
    required String id,
    required String folderId,
    @Default('') String name,

    /// Orden manual dentro del espacio.
    @Default(0) double sortIndex,

    /// Colapsada en la vista del espacio.
    @Default(false) bool collapsed,
    DateTime? createdAt,
  }) = _NoteSection;

  factory NoteSection.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return NoteSection(
      id: doc.id,
      folderId: (data['folderId'] as String?) ?? '',
      name: (data['name'] as String?) ?? '',
      sortIndex: (data['sortIndex'] as num?)?.toDouble() ?? 0,
      collapsed: (data['collapsed'] as bool?) ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'folderId': folderId,
        'name': name,
        'sortIndex': sortIndex,
        'collapsed': collapsed,
        if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
      };
}
