// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_folder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NoteFolder {
  String get id;
  String get name;
  String get emoji;

  /// Color elegido a mano (ARGB). `null` = derivado del nombre.
  int? get colorValue;

  /// Descripción corta del espacio (bajo el nombre en la portada).
  String get description;

  /// Motivo de la portada ilustrada: 'leaf', 'spark', 'steam', 'wave'...
  /// Vacío = se elige por el color. Ver `SpaceCover`.
  String get motif;

  /// Orden manual entre espacios. `null` = por creación.
  double? get sortIndex;
  DateTime? get createdAt;
  DateTime? get updatedAt;

  /// Create a copy of NoteFolder
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NoteFolderCopyWith<NoteFolder> get copyWith =>
      _$NoteFolderCopyWithImpl<NoteFolder>(this as NoteFolder, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NoteFolder &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.motif, motif) || other.motif == motif) &&
            (identical(other.sortIndex, sortIndex) ||
                other.sortIndex == sortIndex) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, emoji, colorValue,
      description, motif, sortIndex, createdAt, updatedAt);

  @override
  String toString() {
    return 'NoteFolder(id: $id, name: $name, emoji: $emoji, colorValue: $colorValue, description: $description, motif: $motif, sortIndex: $sortIndex, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $NoteFolderCopyWith<$Res> {
  factory $NoteFolderCopyWith(
          NoteFolder value, $Res Function(NoteFolder) _then) =
      _$NoteFolderCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String emoji,
      int? colorValue,
      String description,
      String motif,
      double? sortIndex,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$NoteFolderCopyWithImpl<$Res> implements $NoteFolderCopyWith<$Res> {
  _$NoteFolderCopyWithImpl(this._self, this._then);

  final NoteFolder _self;
  final $Res Function(NoteFolder) _then;

  /// Create a copy of NoteFolder
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? emoji = null,
    Object? colorValue = freezed,
    Object? description = null,
    Object? motif = null,
    Object? sortIndex = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
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
      emoji: null == emoji
          ? _self.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      colorValue: freezed == colorValue
          ? _self.colorValue
          : colorValue // ignore: cast_nullable_to_non_nullable
              as int?,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      motif: null == motif
          ? _self.motif
          : motif // ignore: cast_nullable_to_non_nullable
              as String,
      sortIndex: freezed == sortIndex
          ? _self.sortIndex
          : sortIndex // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [NoteFolder].
extension NoteFolderPatterns on NoteFolder {
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
    TResult Function(_NoteFolder value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NoteFolder() when $default != null:
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
    TResult Function(_NoteFolder value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NoteFolder():
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
    TResult? Function(_NoteFolder value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NoteFolder() when $default != null:
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
            String emoji,
            int? colorValue,
            String description,
            String motif,
            double? sortIndex,
            DateTime? createdAt,
            DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NoteFolder() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.emoji,
            _that.colorValue,
            _that.description,
            _that.motif,
            _that.sortIndex,
            _that.createdAt,
            _that.updatedAt);
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
            String emoji,
            int? colorValue,
            String description,
            String motif,
            double? sortIndex,
            DateTime? createdAt,
            DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NoteFolder():
        return $default(
            _that.id,
            _that.name,
            _that.emoji,
            _that.colorValue,
            _that.description,
            _that.motif,
            _that.sortIndex,
            _that.createdAt,
            _that.updatedAt);
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
            String emoji,
            int? colorValue,
            String description,
            String motif,
            double? sortIndex,
            DateTime? createdAt,
            DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NoteFolder() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.emoji,
            _that.colorValue,
            _that.description,
            _that.motif,
            _that.sortIndex,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _NoteFolder extends NoteFolder {
  const _NoteFolder(
      {required this.id,
      required this.name,
      this.emoji = '📁',
      this.colorValue,
      this.description = '',
      this.motif = '',
      this.sortIndex,
      this.createdAt,
      this.updatedAt})
      : super._();

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final String emoji;

  /// Color elegido a mano (ARGB). `null` = derivado del nombre.
  @override
  final int? colorValue;

  /// Descripción corta del espacio (bajo el nombre en la portada).
  @override
  @JsonKey()
  final String description;

  /// Motivo de la portada ilustrada: 'leaf', 'spark', 'steam', 'wave'...
  /// Vacío = se elige por el color. Ver `SpaceCover`.
  @override
  @JsonKey()
  final String motif;

  /// Orden manual entre espacios. `null` = por creación.
  @override
  final double? sortIndex;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  /// Create a copy of NoteFolder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NoteFolderCopyWith<_NoteFolder> get copyWith =>
      __$NoteFolderCopyWithImpl<_NoteFolder>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NoteFolder &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.motif, motif) || other.motif == motif) &&
            (identical(other.sortIndex, sortIndex) ||
                other.sortIndex == sortIndex) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, emoji, colorValue,
      description, motif, sortIndex, createdAt, updatedAt);

  @override
  String toString() {
    return 'NoteFolder(id: $id, name: $name, emoji: $emoji, colorValue: $colorValue, description: $description, motif: $motif, sortIndex: $sortIndex, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$NoteFolderCopyWith<$Res>
    implements $NoteFolderCopyWith<$Res> {
  factory _$NoteFolderCopyWith(
          _NoteFolder value, $Res Function(_NoteFolder) _then) =
      __$NoteFolderCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String emoji,
      int? colorValue,
      String description,
      String motif,
      double? sortIndex,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$NoteFolderCopyWithImpl<$Res> implements _$NoteFolderCopyWith<$Res> {
  __$NoteFolderCopyWithImpl(this._self, this._then);

  final _NoteFolder _self;
  final $Res Function(_NoteFolder) _then;

  /// Create a copy of NoteFolder
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? emoji = null,
    Object? colorValue = freezed,
    Object? description = null,
    Object? motif = null,
    Object? sortIndex = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_NoteFolder(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _self.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
      colorValue: freezed == colorValue
          ? _self.colorValue
          : colorValue // ignore: cast_nullable_to_non_nullable
              as int?,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      motif: null == motif
          ? _self.motif
          : motif // ignore: cast_nullable_to_non_nullable
              as String,
      sortIndex: freezed == sortIndex
          ? _self.sortIndex
          : sortIndex // ignore: cast_nullable_to_non_nullable
              as double?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
