import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/theme/app_colors.dart';

part 'note_folder.freezed.dart';

/// Una carpeta de notas ("Ideas", "Recetas", "Universidad"...).
///
/// Vive en su propia colección (`workspace/main/noteFolders`); las notas la
/// referencian por [id]. Borrar una carpeta NO borra sus notas: quedan
/// "sin carpeta", que es lo reversible y lo que menos duele por accidente.
@freezed
abstract class NoteFolder with _$NoteFolder {
  const NoteFolder._();

  const factory NoteFolder({
    required String id,
    required String name,
    @Default('📁') String emoji,

    /// Color elegido a mano (ARGB). `null` = derivado del nombre.
    int? colorValue,

    /// Descripción corta del espacio (bajo el nombre en la portada).
    @Default('') String description,

    /// Motivo de la portada ilustrada: 'leaf', 'spark', 'steam', 'wave'...
    /// Vacío = se elige por el color. Ver `SpaceCover`.
    @Default('') String motif,

    /// Orden manual entre espacios. `null` = por creación.
    double? sortIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _NoteFolder;

  factory NoteFolder.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return NoteFolder(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      emoji: (data['emoji'] as String?) ?? '📁',
      colorValue: (data['colorValue'] as num?)?.toInt(),
      description: (data['description'] as String?) ?? '',
      motif: (data['motif'] as String?) ?? '',
      sortIndex: (data['sortIndex'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'emoji': emoji,
        'colorValue': colorValue,
        'description': description,
        'motif': motif,
        if (sortIndex != null) 'sortIndex': sortIndex,
        'updatedAt': FieldValue.serverTimestamp(),
        if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
      };

  Color get color => colorValue != null
      ? Color(colorValue!)
      : AppColors.forKey(name.toLowerCase());
}
