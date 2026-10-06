import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/theme/app_colors.dart';

part 'person.freezed.dart';

/// Una persona que contribuye a los pagos compartidos ("Familia").
///
/// Es un roster global (`workspace/main/people`): se agrega una vez y se
/// reutiliza en cualquier mensualidad o deuda compartida.
@freezed
abstract class Person with _$Person {
  const Person._();

  const factory Person({
    required String id,
    required String name,

    /// Emoji del avatar (🐰, 🐱, ☕…).
    @Default('🐰') String emoji,

    /// Color (ARGB). `null` = derivado del nombre.
    int? colorValue,

    /// Orden manual en el roster.
    @Default(0) double sortIndex,
    DateTime? createdAt,
  }) = _Person;

  factory Person.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Person(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      emoji: (data['emoji'] as String?) ?? '🐰',
      colorValue: (data['colorValue'] as num?)?.toInt(),
      sortIndex: (data['sortIndex'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'emoji': emoji,
        'colorValue': colorValue,
        'sortIndex': sortIndex,
        if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
      };

  Color get color =>
      colorValue != null ? Color(colorValue!) : AppColors.forKey(id);

  String get shortName => name.trim().isEmpty ? '¿?' : name.trim();
}
