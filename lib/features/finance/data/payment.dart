import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/theme/app_colors.dart';
import '../domain/payment_category.dart';
import '../domain/payment_icons.dart';
import '../domain/subscription_brand.dart';

part 'payment.freezed.dart';

/// Un pago recurrente mensual (Netflix, renta, un curso...).
///
/// Es totalmente personalizable: la categoría es texto libre, y el icono y el
/// color se pueden fijar a mano. Si no se fijan, la app los deduce sola (de la
/// marca reconocida o de la categoría).
///
/// El mapeo a Firestore se hace a mano en vez de con json_serializable porque
/// Firestore usa `Timestamp`, no `DateTime`, y así el contrato con la base
/// queda explícito y en un solo sitio.
@freezed
abstract class Payment with _$Payment {
  const Payment._();

  const factory Payment({
    required String id,
    required String name,
    required double amountMxn,

    /// Categoría en texto libre ("Streaming", "Mis cursos", lo que sea).
    @Default('') String category,

    /// Día del mes en que se cobra (1–31).
    required int dayOfMonth,

    /// Icono elegido a mano (clave de [PaymentIcons]). `null` = automático.
    String? iconKey,

    /// Color elegido a mano (ARGB). `null` = automático.
    int? colorValue,

    /// Foto de portada del pago (URL en Storage). `null` = sin foto: se usa el
    /// icono/color. Es la personalización principal del rediseño.
    String? coverImageUrl,

    /// Pago compartido entre varias personas (plan familiar).
    @Default(false) bool shared,

    /// Ids de las personas que participan (del roster `people`).
    @Default(<String>[]) List<String> participantIds,

    /// Modo de reparto: 'turns' (a cada mes le toca alguien) o 'split'
    /// (se divide entre todos cada mes).
    @Default('turns') String rotationMode,

    /// A quién le toca por mes (clave "YYYY-MM" → personId). Solo en 'turns'.
    @Default(<String, String>{}) Map<String, String> assignments,
    DateTime? createdAt,
  }) = _Payment;

  factory Payment.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Payment(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      // Firestore devuelve int si el número no tiene decimales.
      amountMxn: (data['amountMxn'] as num?)?.toDouble() ?? 0,
      category: _readCategory(data['category'] as String?),
      dayOfMonth: (data['dayOfMonth'] as num?)?.toInt() ?? 1,
      iconKey: data['iconKey'] as String?,
      colorValue: (data['colorValue'] as num?)?.toInt(),
      coverImageUrl: data['coverImageUrl'] as String?,
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

  /// Los pagos viejos guardaban la categoría como clave de enum ("streaming").
  /// Se convierte a su etiqueta ("Streaming") para que se lea bien como texto.
  static String _readCategory(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final preset = PaymentCategory.values
        .where((c) => c.name == raw)
        .firstOrNull;
    return preset?.label ?? raw;
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'amountMxn': amountMxn,
        'category': category,
        'dayOfMonth': dayOfMonth,
        // Se mandan aunque sean null: así se puede quitar un icono/color/foto
        // personalizado y volver al automático (merge no borraría el campo).
        'iconKey': iconKey,
        'colorValue': colorValue,
        'coverImageUrl': coverImageUrl,
        'shared': shared,
        'participantIds': participantIds,
        'rotationMode': rotationMode,
        'assignments': assignments,
        // En altas lo pone el servidor; en ediciones se conserva el existente
        // gracias a `SetOptions(merge: true)`.
        if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
      };

  /// URLs de imágenes propias del pago, para limpiarlas de Storage al borrarlo.
  List<String> get imageUrls => [if (coverImageUrl != null) coverImageUrl!];

  bool get hasCover => coverImageUrl != null;

  /// Lo que este pago representa al año. Útil para dimensionar el gasto.
  double get yearlyMxn => amountMxn * 12;

  /// Marca detectada por el nombre (Netflix, Spotify...). `null` si no aplica.
  SubscriptionBrand? get brand => SubscriptionBrand.detect(name);

  /// Preset de categoría que coincide con el texto, si lo hay (para deducir un
  /// icono/color por defecto cuando no se reconoce marca ni se personalizó).
  PaymentCategory? get _categoryPreset {
    final lower = category.trim().toLowerCase();
    if (lower.isEmpty) return null;
    return PaymentCategory.values
        .where((c) => c.label.toLowerCase() == lower)
        .firstOrNull;
  }

  /// Icono a mostrar, por prioridad: elegido a mano → marca → preset de
  /// categoría → color-coding genérico por texto.
  IconData get displayIcon {
    if (iconKey != null) return PaymentIcons.resolve(iconKey);
    return brand?.icon ?? _categoryPreset?.icon ?? PaymentIcons.fallback;
  }

  /// Color a mostrar, con la misma prioridad que [displayIcon].
  Color get displayColor {
    if (colorValue != null) return Color(colorValue!);
    return brand?.color ??
        _categoryPreset?.color ??
        AppColors.forKey(category.isEmpty ? name : category);
  }
}
