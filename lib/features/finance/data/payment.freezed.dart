// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Payment {
  String get id;
  String get name;
  double get amountMxn;

  /// Categoría en texto libre ("Streaming", "Mis cursos", lo que sea).
  String get category;

  /// Día del mes en que se cobra (1–31).
  int get dayOfMonth;

  /// Icono elegido a mano (clave de [PaymentIcons]). `null` = automático.
  String? get iconKey;

  /// Color elegido a mano (ARGB). `null` = automático.
  int? get colorValue;

  /// Foto de portada del pago (URL en Storage). `null` = sin foto: se usa el
  /// icono/color. Es la personalización principal del rediseño.
  String? get coverImageUrl;

  /// Pago compartido entre varias personas (plan familiar).
  bool get shared;

  /// Ids de las personas que participan (del roster `people`).
  List<String> get participantIds;

  /// Modo de reparto: 'turns' (a cada mes le toca alguien) o 'split'
  /// (se divide entre todos cada mes).
  String get rotationMode;

  /// A quién le toca por mes (clave "YYYY-MM" → personId). Solo en 'turns'.
  Map<String, String> get assignments;
  DateTime? get createdAt;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PaymentCopyWith<Payment> get copyWith =>
      _$PaymentCopyWithImpl<Payment>(this as Payment, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Payment &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.amountMxn, amountMxn) ||
                other.amountMxn == amountMxn) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.dayOfMonth, dayOfMonth) ||
                other.dayOfMonth == dayOfMonth) &&
            (identical(other.iconKey, iconKey) || other.iconKey == iconKey) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            (identical(other.shared, shared) || other.shared == shared) &&
            const DeepCollectionEquality()
                .equals(other.participantIds, participantIds) &&
            (identical(other.rotationMode, rotationMode) ||
                other.rotationMode == rotationMode) &&
            const DeepCollectionEquality()
                .equals(other.assignments, assignments) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      amountMxn,
      category,
      dayOfMonth,
      iconKey,
      colorValue,
      coverImageUrl,
      shared,
      const DeepCollectionEquality().hash(participantIds),
      rotationMode,
      const DeepCollectionEquality().hash(assignments),
      createdAt);

  @override
  String toString() {
    return 'Payment(id: $id, name: $name, amountMxn: $amountMxn, category: $category, dayOfMonth: $dayOfMonth, iconKey: $iconKey, colorValue: $colorValue, coverImageUrl: $coverImageUrl, shared: $shared, participantIds: $participantIds, rotationMode: $rotationMode, assignments: $assignments, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $PaymentCopyWith<$Res> {
  factory $PaymentCopyWith(Payment value, $Res Function(Payment) _then) =
      _$PaymentCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      double amountMxn,
      String category,
      int dayOfMonth,
      String? iconKey,
      int? colorValue,
      String? coverImageUrl,
      bool shared,
      List<String> participantIds,
      String rotationMode,
      Map<String, String> assignments,
      DateTime? createdAt});
}

/// @nodoc
class _$PaymentCopyWithImpl<$Res> implements $PaymentCopyWith<$Res> {
  _$PaymentCopyWithImpl(this._self, this._then);

  final Payment _self;
  final $Res Function(Payment) _then;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? amountMxn = null,
    Object? category = null,
    Object? dayOfMonth = null,
    Object? iconKey = freezed,
    Object? colorValue = freezed,
    Object? coverImageUrl = freezed,
    Object? shared = null,
    Object? participantIds = null,
    Object? rotationMode = null,
    Object? assignments = null,
    Object? createdAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      amountMxn: null == amountMxn
          ? _self.amountMxn
          : amountMxn // ignore: cast_nullable_to_non_nullable
              as double,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfMonth: null == dayOfMonth
          ? _self.dayOfMonth
          : dayOfMonth // ignore: cast_nullable_to_non_nullable
              as int,
      iconKey: freezed == iconKey
          ? _self.iconKey
          : iconKey // ignore: cast_nullable_to_non_nullable
              as String?,
      colorValue: freezed == colorValue
          ? _self.colorValue
          : colorValue // ignore: cast_nullable_to_non_nullable
              as int?,
      coverImageUrl: freezed == coverImageUrl
          ? _self.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      shared: null == shared
          ? _self.shared
          : shared // ignore: cast_nullable_to_non_nullable
              as bool,
      participantIds: null == participantIds
          ? _self.participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rotationMode: null == rotationMode
          ? _self.rotationMode
          : rotationMode // ignore: cast_nullable_to_non_nullable
              as String,
      assignments: null == assignments
          ? _self.assignments
          : assignments // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Payment].
extension PaymentPatterns on Payment {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_Payment value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Payment() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_Payment value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Payment():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_Payment value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Payment() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            double amountMxn,
            String category,
            int dayOfMonth,
            String? iconKey,
            int? colorValue,
            String? coverImageUrl,
            bool shared,
            List<String> participantIds,
            String rotationMode,
            Map<String, String> assignments,
            DateTime? createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Payment() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.amountMxn,
            _that.category,
            _that.dayOfMonth,
            _that.iconKey,
            _that.colorValue,
            _that.coverImageUrl,
            _that.shared,
            _that.participantIds,
            _that.rotationMode,
            _that.assignments,
            _that.createdAt);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String name,
            double amountMxn,
            String category,
            int dayOfMonth,
            String? iconKey,
            int? colorValue,
            String? coverImageUrl,
            bool shared,
            List<String> participantIds,
            String rotationMode,
            Map<String, String> assignments,
            DateTime? createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Payment():
        return $default(
            _that.id,
            _that.name,
            _that.amountMxn,
            _that.category,
            _that.dayOfMonth,
            _that.iconKey,
            _that.colorValue,
            _that.coverImageUrl,
            _that.shared,
            _that.participantIds,
            _that.rotationMode,
            _that.assignments,
            _that.createdAt);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String name,
            double amountMxn,
            String category,
            int dayOfMonth,
            String? iconKey,
            int? colorValue,
            String? coverImageUrl,
            bool shared,
            List<String> participantIds,
            String rotationMode,
            Map<String, String> assignments,
            DateTime? createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Payment() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.amountMxn,
            _that.category,
            _that.dayOfMonth,
            _that.iconKey,
            _that.colorValue,
            _that.coverImageUrl,
            _that.shared,
            _that.participantIds,
            _that.rotationMode,
            _that.assignments,
            _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Payment extends Payment {
  const _Payment(
      {required this.id,
      required this.name,
      required this.amountMxn,
      this.category = '',
      required this.dayOfMonth,
      this.iconKey,
      this.colorValue,
      this.coverImageUrl,
      this.shared = false,
      final List<String> participantIds = const <String>[],
      this.rotationMode = 'turns',
      final Map<String, String> assignments = const <String, String>{},
      this.createdAt})
      : _participantIds = participantIds,
        _assignments = assignments,
        super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final double amountMxn;

  /// Categoría en texto libre ("Streaming", "Mis cursos", lo que sea).
  @override
  @JsonKey()
  final String category;

  /// Día del mes en que se cobra (1–31).
  @override
  final int dayOfMonth;

  /// Icono elegido a mano (clave de [PaymentIcons]). `null` = automático.
  @override
  final String? iconKey;

  /// Color elegido a mano (ARGB). `null` = automático.
  @override
  final int? colorValue;

  /// Foto de portada del pago (URL en Storage). `null` = sin foto: se usa el
  /// icono/color. Es la personalización principal del rediseño.
  @override
  final String? coverImageUrl;

  /// Pago compartido entre varias personas (plan familiar).
  @override
  @JsonKey()
  final bool shared;

  /// Ids de las personas que participan (del roster `people`).
  final List<String> _participantIds;

  /// Ids de las personas que participan (del roster `people`).
  @override
  @JsonKey()
  List<String> get participantIds {
    if (_participantIds is EqualUnmodifiableListView) return _participantIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantIds);
  }

  /// Modo de reparto: 'turns' (a cada mes le toca alguien) o 'split'
  /// (se divide entre todos cada mes).
  @override
  @JsonKey()
  final String rotationMode;

  /// A quién le toca por mes (clave "YYYY-MM" → personId). Solo en 'turns'.
  final Map<String, String> _assignments;

  /// A quién le toca por mes (clave "YYYY-MM" → personId). Solo en 'turns'.
  @override
  @JsonKey()
  Map<String, String> get assignments {
    if (_assignments is EqualUnmodifiableMapView) return _assignments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_assignments);
  }

  @override
  final DateTime? createdAt;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PaymentCopyWith<_Payment> get copyWith =>
      __$PaymentCopyWithImpl<_Payment>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Payment &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.amountMxn, amountMxn) ||
                other.amountMxn == amountMxn) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.dayOfMonth, dayOfMonth) ||
                other.dayOfMonth == dayOfMonth) &&
            (identical(other.iconKey, iconKey) || other.iconKey == iconKey) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            (identical(other.shared, shared) || other.shared == shared) &&
            const DeepCollectionEquality()
                .equals(other._participantIds, _participantIds) &&
            (identical(other.rotationMode, rotationMode) ||
                other.rotationMode == rotationMode) &&
            const DeepCollectionEquality()
                .equals(other._assignments, _assignments) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      amountMxn,
      category,
      dayOfMonth,
      iconKey,
      colorValue,
      coverImageUrl,
      shared,
      const DeepCollectionEquality().hash(_participantIds),
      rotationMode,
      const DeepCollectionEquality().hash(_assignments),
      createdAt);

  @override
  String toString() {
    return 'Payment(id: $id, name: $name, amountMxn: $amountMxn, category: $category, dayOfMonth: $dayOfMonth, iconKey: $iconKey, colorValue: $colorValue, coverImageUrl: $coverImageUrl, shared: $shared, participantIds: $participantIds, rotationMode: $rotationMode, assignments: $assignments, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$PaymentCopyWith<$Res> implements $PaymentCopyWith<$Res> {
  factory _$PaymentCopyWith(_Payment value, $Res Function(_Payment) _then) =
      __$PaymentCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      double amountMxn,
      String category,
      int dayOfMonth,
      String? iconKey,
      int? colorValue,
      String? coverImageUrl,
      bool shared,
      List<String> participantIds,
      String rotationMode,
      Map<String, String> assignments,
      DateTime? createdAt});
}

/// @nodoc
class __$PaymentCopyWithImpl<$Res> implements _$PaymentCopyWith<$Res> {
  __$PaymentCopyWithImpl(this._self, this._then);

  final _Payment _self;
  final $Res Function(_Payment) _then;

  /// Create a copy of Payment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? amountMxn = null,
    Object? category = null,
    Object? dayOfMonth = null,
    Object? iconKey = freezed,
    Object? colorValue = freezed,
    Object? coverImageUrl = freezed,
    Object? shared = null,
    Object? participantIds = null,
    Object? rotationMode = null,
    Object? assignments = null,
    Object? createdAt = freezed,
  }) {
    return _then(_Payment(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      amountMxn: null == amountMxn
          ? _self.amountMxn
          : amountMxn // ignore: cast_nullable_to_non_nullable
              as double,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      dayOfMonth: null == dayOfMonth
          ? _self.dayOfMonth
          : dayOfMonth // ignore: cast_nullable_to_non_nullable
              as int,
      iconKey: freezed == iconKey
          ? _self.iconKey
          : iconKey // ignore: cast_nullable_to_non_nullable
              as String?,
      colorValue: freezed == colorValue
          ? _self.colorValue
          : colorValue // ignore: cast_nullable_to_non_nullable
              as int?,
      coverImageUrl: freezed == coverImageUrl
          ? _self.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      shared: null == shared
          ? _self.shared
          : shared // ignore: cast_nullable_to_non_nullable
              as bool,
      participantIds: null == participantIds
          ? _self._participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      rotationMode: null == rotationMode
          ? _self.rotationMode
          : rotationMode // ignore: cast_nullable_to_non_nullable
              as String,
      assignments: null == assignments
          ? _self._assignments
          : assignments // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
