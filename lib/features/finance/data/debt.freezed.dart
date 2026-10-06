// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'debt.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Debt {
  String get id;
  String get name;
  String get category;

  /// Saldo actual / restante por pagar.
  double get balance;

  /// Límite de la tarjeta. `null` = no es tarjeta (préstamo/deuda suelta).
  double? get creditLimit;

  /// Pago sugerido para este periodo. `null` = no aplica.
  double? get suggestedPayment;

  /// Fecha específica de pago. `null` = sin fecha.
  DateTime? get dueDate;
  String? get iconKey;
  int? get colorValue;

  /// Deuda compartida entre varias personas.
  bool get shared;
  List<String> get participantIds;
  String get rotationMode;
  Map<String, String> get assignments;
  DateTime? get createdAt;

  /// Create a copy of Debt
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DebtCopyWith<Debt> get copyWith =>
      _$DebtCopyWithImpl<Debt>(this as Debt, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Debt &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.creditLimit, creditLimit) ||
                other.creditLimit == creditLimit) &&
            (identical(other.suggestedPayment, suggestedPayment) ||
                other.suggestedPayment == suggestedPayment) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.iconKey, iconKey) || other.iconKey == iconKey) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue) &&
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
      category,
      balance,
      creditLimit,
      suggestedPayment,
      dueDate,
      iconKey,
      colorValue,
      shared,
      const DeepCollectionEquality().hash(participantIds),
      rotationMode,
      const DeepCollectionEquality().hash(assignments),
      createdAt);

  @override
  String toString() {
    return 'Debt(id: $id, name: $name, category: $category, balance: $balance, creditLimit: $creditLimit, suggestedPayment: $suggestedPayment, dueDate: $dueDate, iconKey: $iconKey, colorValue: $colorValue, shared: $shared, participantIds: $participantIds, rotationMode: $rotationMode, assignments: $assignments, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $DebtCopyWith<$Res> {
  factory $DebtCopyWith(Debt value, $Res Function(Debt) _then) =
      _$DebtCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String category,
      double balance,
      double? creditLimit,
      double? suggestedPayment,
      DateTime? dueDate,
      String? iconKey,
      int? colorValue,
      bool shared,
      List<String> participantIds,
      String rotationMode,
      Map<String, String> assignments,
      DateTime? createdAt});
}

/// @nodoc
class _$DebtCopyWithImpl<$Res> implements $DebtCopyWith<$Res> {
  _$DebtCopyWithImpl(this._self, this._then);

  final Debt _self;
  final $Res Function(Debt) _then;

  /// Create a copy of Debt
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? balance = null,
    Object? creditLimit = freezed,
    Object? suggestedPayment = freezed,
    Object? dueDate = freezed,
    Object? iconKey = freezed,
    Object? colorValue = freezed,
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
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _self.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      creditLimit: freezed == creditLimit
          ? _self.creditLimit
          : creditLimit // ignore: cast_nullable_to_non_nullable
              as double?,
      suggestedPayment: freezed == suggestedPayment
          ? _self.suggestedPayment
          : suggestedPayment // ignore: cast_nullable_to_non_nullable
              as double?,
      dueDate: freezed == dueDate
          ? _self.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      iconKey: freezed == iconKey
          ? _self.iconKey
          : iconKey // ignore: cast_nullable_to_non_nullable
              as String?,
      colorValue: freezed == colorValue
          ? _self.colorValue
          : colorValue // ignore: cast_nullable_to_non_nullable
              as int?,
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

/// Adds pattern-matching-related methods to [Debt].
extension DebtPatterns on Debt {
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
    TResult Function(_Debt value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Debt() when $default != null:
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
    TResult Function(_Debt value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Debt():
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
    TResult? Function(_Debt value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Debt() when $default != null:
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
            String category,
            double balance,
            double? creditLimit,
            double? suggestedPayment,
            DateTime? dueDate,
            String? iconKey,
            int? colorValue,
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
      case _Debt() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.category,
            _that.balance,
            _that.creditLimit,
            _that.suggestedPayment,
            _that.dueDate,
            _that.iconKey,
            _that.colorValue,
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
            String category,
            double balance,
            double? creditLimit,
            double? suggestedPayment,
            DateTime? dueDate,
            String? iconKey,
            int? colorValue,
            bool shared,
            List<String> participantIds,
            String rotationMode,
            Map<String, String> assignments,
            DateTime? createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Debt():
        return $default(
            _that.id,
            _that.name,
            _that.category,
            _that.balance,
            _that.creditLimit,
            _that.suggestedPayment,
            _that.dueDate,
            _that.iconKey,
            _that.colorValue,
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
            String category,
            double balance,
            double? creditLimit,
            double? suggestedPayment,
            DateTime? dueDate,
            String? iconKey,
            int? colorValue,
            bool shared,
            List<String> participantIds,
            String rotationMode,
            Map<String, String> assignments,
            DateTime? createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Debt() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.category,
            _that.balance,
            _that.creditLimit,
            _that.suggestedPayment,
            _that.dueDate,
            _that.iconKey,
            _that.colorValue,
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

class _Debt extends Debt {
  const _Debt(
      {required this.id,
      required this.name,
      this.category = '',
      required this.balance,
      this.creditLimit,
      this.suggestedPayment,
      this.dueDate,
      this.iconKey,
      this.colorValue,
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
  @JsonKey()
  final String category;

  /// Saldo actual / restante por pagar.
  @override
  final double balance;

  /// Límite de la tarjeta. `null` = no es tarjeta (préstamo/deuda suelta).
  @override
  final double? creditLimit;

  /// Pago sugerido para este periodo. `null` = no aplica.
  @override
  final double? suggestedPayment;

  /// Fecha específica de pago. `null` = sin fecha.
  @override
  final DateTime? dueDate;
  @override
  final String? iconKey;
  @override
  final int? colorValue;

  /// Deuda compartida entre varias personas.
  @override
  @JsonKey()
  final bool shared;
  final List<String> _participantIds;
  @override
  @JsonKey()
  List<String> get participantIds {
    if (_participantIds is EqualUnmodifiableListView) return _participantIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantIds);
  }

  @override
  @JsonKey()
  final String rotationMode;
  final Map<String, String> _assignments;
  @override
  @JsonKey()
  Map<String, String> get assignments {
    if (_assignments is EqualUnmodifiableMapView) return _assignments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_assignments);
  }

  @override
  final DateTime? createdAt;

  /// Create a copy of Debt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DebtCopyWith<_Debt> get copyWith =>
      __$DebtCopyWithImpl<_Debt>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Debt &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.creditLimit, creditLimit) ||
                other.creditLimit == creditLimit) &&
            (identical(other.suggestedPayment, suggestedPayment) ||
                other.suggestedPayment == suggestedPayment) &&
            (identical(other.dueDate, dueDate) || other.dueDate == dueDate) &&
            (identical(other.iconKey, iconKey) || other.iconKey == iconKey) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue) &&
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
      category,
      balance,
      creditLimit,
      suggestedPayment,
      dueDate,
      iconKey,
      colorValue,
      shared,
      const DeepCollectionEquality().hash(_participantIds),
      rotationMode,
      const DeepCollectionEquality().hash(_assignments),
      createdAt);

  @override
  String toString() {
    return 'Debt(id: $id, name: $name, category: $category, balance: $balance, creditLimit: $creditLimit, suggestedPayment: $suggestedPayment, dueDate: $dueDate, iconKey: $iconKey, colorValue: $colorValue, shared: $shared, participantIds: $participantIds, rotationMode: $rotationMode, assignments: $assignments, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$DebtCopyWith<$Res> implements $DebtCopyWith<$Res> {
  factory _$DebtCopyWith(_Debt value, $Res Function(_Debt) _then) =
      __$DebtCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String category,
      double balance,
      double? creditLimit,
      double? suggestedPayment,
      DateTime? dueDate,
      String? iconKey,
      int? colorValue,
      bool shared,
      List<String> participantIds,
      String rotationMode,
      Map<String, String> assignments,
      DateTime? createdAt});
}

/// @nodoc
class __$DebtCopyWithImpl<$Res> implements _$DebtCopyWith<$Res> {
  __$DebtCopyWithImpl(this._self, this._then);

  final _Debt _self;
  final $Res Function(_Debt) _then;

  /// Create a copy of Debt
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? category = null,
    Object? balance = null,
    Object? creditLimit = freezed,
    Object? suggestedPayment = freezed,
    Object? dueDate = freezed,
    Object? iconKey = freezed,
    Object? colorValue = freezed,
    Object? shared = null,
    Object? participantIds = null,
    Object? rotationMode = null,
    Object? assignments = null,
    Object? createdAt = freezed,
  }) {
    return _then(_Debt(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _self.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      creditLimit: freezed == creditLimit
          ? _self.creditLimit
          : creditLimit // ignore: cast_nullable_to_non_nullable
              as double?,
      suggestedPayment: freezed == suggestedPayment
          ? _self.suggestedPayment
          : suggestedPayment // ignore: cast_nullable_to_non_nullable
              as double?,
      dueDate: freezed == dueDate
          ? _self.dueDate
          : dueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      iconKey: freezed == iconKey
          ? _self.iconKey
          : iconKey // ignore: cast_nullable_to_non_nullable
              as String?,
      colorValue: freezed == colorValue
          ? _self.colorValue
          : colorValue // ignore: cast_nullable_to_non_nullable
              as int?,
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
