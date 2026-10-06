import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/payment_icons.dart';

part 'debt.freezed.dart';

/// Una deuda: un saldo que se paga (una o varias veces) hasta liquidarlo, a
/// diferencia de una mensualidad que se repite para siempre.
///
/// Cubre dos formas comunes:
/// - **Tarjeta de crédito**: tiene [creditLimit], así se muestra el % de uso.
/// - **Préstamo / deuda suelta**: solo saldo, con [suggestedPayment] opcional.
///
/// La fecha ([dueDate]) es opcional: muchas deudas "no tienen fecha específica".
/// Si la tiene, aparece también en el calendario y puede recordarse.
@freezed
abstract class Debt with _$Debt {
  const Debt._();

  const factory Debt({
    required String id,
    required String name,
    @Default('') String category,

    /// Saldo actual / restante por pagar.
    required double balance,

    /// Límite de la tarjeta. `null` = no es tarjeta (préstamo/deuda suelta).
    double? creditLimit,

    /// Pago sugerido para este periodo. `null` = no aplica.
    double? suggestedPayment,

    /// Fecha específica de pago. `null` = sin fecha.
    DateTime? dueDate,
    String? iconKey,
    int? colorValue,

    /// Deuda compartida entre varias personas.
    @Default(false) bool shared,
    @Default(<String>[]) List<String> participantIds,
    @Default('turns') String rotationMode,
    @Default(<String, String>{}) Map<String, String> assignments,
    DateTime? createdAt,
  }) = _Debt;

  factory Debt.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Debt(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      balance: (data['balance'] as num?)?.toDouble() ?? 0,
      creditLimit: (data['creditLimit'] as num?)?.toDouble(),
      suggestedPayment: (data['suggestedPayment'] as num?)?.toDouble(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      iconKey: data['iconKey'] as String?,
      colorValue: (data['colorValue'] as num?)?.toInt(),
      shared: (data['shared'] as bool?) ?? false,
      participantIds: ((data['participantIds'] as List<dynamic>?) ?? const [])
          .map((e) => e as String)
          .toList(),
      rotationMode: (data['rotationMode'] as String?) ?? 'turns',
      assignments: ((data['assignments'] as Map<String, dynamic>?) ?? const {})
          .map((k, v) => MapEntry(k, v as String)),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'category': category,
        'balance': balance,
        // Se mandan aunque sean null: así se pueden quitar y volver al default
        // (merge no borraría el campo).
        'creditLimit': creditLimit,
        'suggestedPayment': suggestedPayment,
        'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
        'iconKey': iconKey,
        'colorValue': colorValue,
        'shared': shared,
        'participantIds': participantIds,
        'rotationMode': rotationMode,
        'assignments': assignments,
        if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
      };

  /// Es una tarjeta de crédito (tiene límite útil).
  bool get isCard => creditLimit != null && creditLimit! > 0;

  /// Porcentaje del límite usado (0–1). `null` si no es tarjeta.
  double? get utilization =>
      isCard ? (balance / creditLimit!).clamp(0.0, 1.0) : null;

  IconData get displayIcon {
    if (iconKey != null) return PaymentIcons.resolve(iconKey);
    return isCard ? Symbols.credit_card_rounded : Symbols.account_balance_rounded;
  }

  Color get displayColor {
    if (colorValue != null) return Color(colorValue!);
    final key = category.trim().isEmpty ? name : category;
    return AppColors.forKey(key.toLowerCase());
  }
}
