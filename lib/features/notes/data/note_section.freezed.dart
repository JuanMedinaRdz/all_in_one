// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_section.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NoteSection {
  String get id;
  String get folderId;
  String get name;

  /// Orden manual dentro del espacio.
  double get sortIndex;

  /// Colapsada en la vista del espacio.
  bool get collapsed;
  DateTime? get createdAt;

  /// Create a copy of NoteSection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NoteSectionCopyWith<NoteSection> get copyWith =>
      _$NoteSectionCopyWithImpl<NoteSection>(this as NoteSection, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NoteSection &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.folderId, folderId) ||
                other.folderId == folderId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sortIndex, sortIndex) ||
                other.sortIndex == sortIndex) &&
            (identical(other.collapsed, collapsed) ||
                other.collapsed == collapsed) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, folderId, name, sortIndex, collapsed, createdAt);

  @override
  String toString() {
    return 'NoteSection(id: $id, folderId: $folderId, name: $name, sortIndex: $sortIndex, collapsed: $collapsed, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $NoteSectionCopyWith<$Res> {
  factory $NoteSectionCopyWith(
          NoteSection value, $Res Function(NoteSection) _then) =
      _$NoteSectionCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String folderId,
      String name,
      double sortIndex,
      bool collapsed,
      DateTime? createdAt});
}

/// @nodoc
class _$NoteSectionCopyWithImpl<$Res> implements $NoteSectionCopyWith<$Res> {
  _$NoteSectionCopyWithImpl(this._self, this._then);

  final NoteSection _self;
  final $Res Function(NoteSection) _then;

  /// Create a copy of NoteSection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? folderId = null,
    Object? name = null,
    Object? sortIndex = null,
    Object? collapsed = null,
    Object? createdAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      folderId: null == folderId
          ? _self.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sortIndex: null == sortIndex
          ? _self.sortIndex
          : sortIndex // ignore: cast_nullable_to_non_nullable
              as double,
      collapsed: null == collapsed
          ? _self.collapsed
          : collapsed // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [NoteSection].
extension NoteSectionPatterns on NoteSection {
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
    TResult Function(_NoteSection value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NoteSection() when $default != null:
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
    TResult Function(_NoteSection value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NoteSection():
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
    TResult? Function(_NoteSection value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NoteSection() when $default != null:
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
    TResult Function(String id, String folderId, String name, double sortIndex,
            bool collapsed, DateTime? createdAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NoteSection() when $default != null:
        return $default(_that.id, _that.folderId, _that.name, _that.sortIndex,
            _that.collapsed, _that.createdAt);
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
    TResult Function(String id, String folderId, String name, double sortIndex,
            bool collapsed, DateTime? createdAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NoteSection():
        return $default(_that.id, _that.folderId, _that.name, _that.sortIndex,
            _that.collapsed, _that.createdAt);
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
    TResult? Function(String id, String folderId, String name, double sortIndex,
            bool collapsed, DateTime? createdAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NoteSection() when $default != null:
        return $default(_that.id, _that.folderId, _that.name, _that.sortIndex,
            _that.collapsed, _that.createdAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _NoteSection extends NoteSection {
  const _NoteSection(
      {required this.id,
      required this.folderId,
      this.name = '',
      this.sortIndex = 0,
      this.collapsed = false,
      this.createdAt})
      : super._();

  @override
  final String id;
  @override
  final String folderId;
  @override
  @JsonKey()
  final String name;

  /// Orden manual dentro del espacio.
  @override
  @JsonKey()
  final double sortIndex;

  /// Colapsada en la vista del espacio.
  @override
  @JsonKey()
  final bool collapsed;
  @override
  final DateTime? createdAt;

  /// Create a copy of NoteSection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NoteSectionCopyWith<_NoteSection> get copyWith =>
      __$NoteSectionCopyWithImpl<_NoteSection>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NoteSection &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.folderId, folderId) ||
                other.folderId == folderId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.sortIndex, sortIndex) ||
                other.sortIndex == sortIndex) &&
            (identical(other.collapsed, collapsed) ||
                other.collapsed == collapsed) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, folderId, name, sortIndex, collapsed, createdAt);

  @override
  String toString() {
    return 'NoteSection(id: $id, folderId: $folderId, name: $name, sortIndex: $sortIndex, collapsed: $collapsed, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$NoteSectionCopyWith<$Res>
    implements $NoteSectionCopyWith<$Res> {
  factory _$NoteSectionCopyWith(
          _NoteSection value, $Res Function(_NoteSection) _then) =
      __$NoteSectionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String folderId,
      String name,
      double sortIndex,
      bool collapsed,
      DateTime? createdAt});
}

/// @nodoc
class __$NoteSectionCopyWithImpl<$Res> implements _$NoteSectionCopyWith<$Res> {
  __$NoteSectionCopyWithImpl(this._self, this._then);

  final _NoteSection _self;
  final $Res Function(_NoteSection) _then;

  /// Create a copy of NoteSection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? folderId = null,
    Object? name = null,
    Object? sortIndex = null,
    Object? collapsed = null,
    Object? createdAt = freezed,
  }) {
    return _then(_NoteSection(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      folderId: null == folderId
          ? _self.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sortIndex: null == sortIndex
          ? _self.sortIndex
          : sortIndex // ignore: cast_nullable_to_non_nullable
              as double,
      collapsed: null == collapsed
          ? _self.collapsed
          : collapsed // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
