// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'todo.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Breakpoint {
  String get id;
  String get title;

  /// Nota/detalle que se despliega bajo el paso (opcional).
  String get detail;

  /// Cuánto dura este paso, en minutos.
  int get durationMinutes;
  bool get done;

  /// Create a copy of Breakpoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BreakpointCopyWith<Breakpoint> get copyWith =>
      _$BreakpointCopyWithImpl<Breakpoint>(this as Breakpoint, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Breakpoint &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.detail, detail) || other.detail == detail) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.done, done) || other.done == done));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, detail, durationMinutes, done);

  @override
  String toString() {
    return 'Breakpoint(id: $id, title: $title, detail: $detail, durationMinutes: $durationMinutes, done: $done)';
  }
}

/// @nodoc
abstract mixin class $BreakpointCopyWith<$Res> {
  factory $BreakpointCopyWith(
          Breakpoint value, $Res Function(Breakpoint) _then) =
      _$BreakpointCopyWithImpl;
  @useResult
  $Res call(
      {String id, String title, String detail, int durationMinutes, bool done});
}

/// @nodoc
class _$BreakpointCopyWithImpl<$Res> implements $BreakpointCopyWith<$Res> {
  _$BreakpointCopyWithImpl(this._self, this._then);

  final Breakpoint _self;
  final $Res Function(Breakpoint) _then;

  /// Create a copy of Breakpoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? detail = null,
    Object? durationMinutes = null,
    Object? done = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      detail: null == detail
          ? _self.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _self.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      done: null == done
          ? _self.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [Breakpoint].
extension BreakpointPatterns on Breakpoint {
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
    TResult Function(_Breakpoint value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Breakpoint() when $default != null:
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
    TResult Function(_Breakpoint value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Breakpoint():
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
    TResult? Function(_Breakpoint value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Breakpoint() when $default != null:
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
    TResult Function(String id, String title, String detail,
            int durationMinutes, bool done)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Breakpoint() when $default != null:
        return $default(_that.id, _that.title, _that.detail,
            _that.durationMinutes, _that.done);
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
    TResult Function(String id, String title, String detail,
            int durationMinutes, bool done)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Breakpoint():
        return $default(_that.id, _that.title, _that.detail,
            _that.durationMinutes, _that.done);
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
    TResult? Function(String id, String title, String detail,
            int durationMinutes, bool done)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Breakpoint() when $default != null:
        return $default(_that.id, _that.title, _that.detail,
            _that.durationMinutes, _that.done);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Breakpoint extends Breakpoint {
  const _Breakpoint(
      {required this.id,
      this.title = '',
      this.detail = '',
      this.durationMinutes = 15,
      this.done = false})
      : super._();

  @override
  final String id;
  @override
  @JsonKey()
  final String title;

  /// Nota/detalle que se despliega bajo el paso (opcional).
  @override
  @JsonKey()
  final String detail;

  /// Cuánto dura este paso, en minutos.
  @override
  @JsonKey()
  final int durationMinutes;
  @override
  @JsonKey()
  final bool done;

  /// Create a copy of Breakpoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BreakpointCopyWith<_Breakpoint> get copyWith =>
      __$BreakpointCopyWithImpl<_Breakpoint>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Breakpoint &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.detail, detail) || other.detail == detail) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.done, done) || other.done == done));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, title, detail, durationMinutes, done);

  @override
  String toString() {
    return 'Breakpoint(id: $id, title: $title, detail: $detail, durationMinutes: $durationMinutes, done: $done)';
  }
}

/// @nodoc
abstract mixin class _$BreakpointCopyWith<$Res>
    implements $BreakpointCopyWith<$Res> {
  factory _$BreakpointCopyWith(
          _Breakpoint value, $Res Function(_Breakpoint) _then) =
      __$BreakpointCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id, String title, String detail, int durationMinutes, bool done});
}

/// @nodoc
class __$BreakpointCopyWithImpl<$Res> implements _$BreakpointCopyWith<$Res> {
  __$BreakpointCopyWithImpl(this._self, this._then);

  final _Breakpoint _self;
  final $Res Function(_Breakpoint) _then;

  /// Create a copy of Breakpoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? detail = null,
    Object? durationMinutes = null,
    Object? done = null,
  }) {
    return _then(_Breakpoint(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      detail: null == detail
          ? _self.detail
          : detail // ignore: cast_nullable_to_non_nullable
              as String,
      durationMinutes: null == durationMinutes
          ? _self.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      done: null == done
          ? _self.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$Todo {
  String get id;
  String get title;
  String get category;
  TodoStatus get status;

  /// Día en que la tarea aparece en el calendario. `null` = sin fecha.
  /// Se guarda normalizado a medianoche: aquí importa el día, no la hora (la
  /// hora vive en [startMinutes]).
  DateTime? get date;

  /// Hora de inicio en minutos desde medianoche (9:00 = 540). `null` = sin hora.
  int? get startMinutes;

  /// Duración total planeada, en minutos.
  int get durationMinutes;
  List<Breakpoint> get breakpoints;
  String get notes;

  /// Posición manual dentro de su columna (drag & drop). `null` = por recencia.
  double? get sortIndex;
  DateTime? get createdAt;
  DateTime? get updatedAt;

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TodoCopyWith<Todo> get copyWith =>
      _$TodoCopyWithImpl<Todo>(this as Todo, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Todo &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.startMinutes, startMinutes) ||
                other.startMinutes == startMinutes) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            const DeepCollectionEquality()
                .equals(other.breakpoints, breakpoints) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.sortIndex, sortIndex) ||
                other.sortIndex == sortIndex) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      category,
      status,
      date,
      startMinutes,
      durationMinutes,
      const DeepCollectionEquality().hash(breakpoints),
      notes,
      sortIndex,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, category: $category, status: $status, date: $date, startMinutes: $startMinutes, durationMinutes: $durationMinutes, breakpoints: $breakpoints, notes: $notes, sortIndex: $sortIndex, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $TodoCopyWith<$Res> {
  factory $TodoCopyWith(Todo value, $Res Function(Todo) _then) =
      _$TodoCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String title,
      String category,
      TodoStatus status,
      DateTime? date,
      int? startMinutes,
      int durationMinutes,
      List<Breakpoint> breakpoints,
      String notes,
      double? sortIndex,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$TodoCopyWithImpl<$Res> implements $TodoCopyWith<$Res> {
  _$TodoCopyWithImpl(this._self, this._then);

  final Todo _self;
  final $Res Function(Todo) _then;

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? category = null,
    Object? status = null,
    Object? date = freezed,
    Object? startMinutes = freezed,
    Object? durationMinutes = null,
    Object? breakpoints = null,
    Object? notes = null,
    Object? sortIndex = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as TodoStatus,
      date: freezed == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startMinutes: freezed == startMinutes
          ? _self.startMinutes
          : startMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      durationMinutes: null == durationMinutes
          ? _self.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      breakpoints: null == breakpoints
          ? _self.breakpoints
          : breakpoints // ignore: cast_nullable_to_non_nullable
              as List<Breakpoint>,
      notes: null == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
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

/// Adds pattern-matching-related methods to [Todo].
extension TodoPatterns on Todo {
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
    TResult Function(_Todo value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Todo() when $default != null:
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
    TResult Function(_Todo value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Todo():
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
    TResult? Function(_Todo value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Todo() when $default != null:
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
            String title,
            String category,
            TodoStatus status,
            DateTime? date,
            int? startMinutes,
            int durationMinutes,
            List<Breakpoint> breakpoints,
            String notes,
            double? sortIndex,
            DateTime? createdAt,
            DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Todo() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.category,
            _that.status,
            _that.date,
            _that.startMinutes,
            _that.durationMinutes,
            _that.breakpoints,
            _that.notes,
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
            String title,
            String category,
            TodoStatus status,
            DateTime? date,
            int? startMinutes,
            int durationMinutes,
            List<Breakpoint> breakpoints,
            String notes,
            double? sortIndex,
            DateTime? createdAt,
            DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Todo():
        return $default(
            _that.id,
            _that.title,
            _that.category,
            _that.status,
            _that.date,
            _that.startMinutes,
            _that.durationMinutes,
            _that.breakpoints,
            _that.notes,
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
            String title,
            String category,
            TodoStatus status,
            DateTime? date,
            int? startMinutes,
            int durationMinutes,
            List<Breakpoint> breakpoints,
            String notes,
            double? sortIndex,
            DateTime? createdAt,
            DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Todo() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.category,
            _that.status,
            _that.date,
            _that.startMinutes,
            _that.durationMinutes,
            _that.breakpoints,
            _that.notes,
            _that.sortIndex,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Todo extends Todo {
  const _Todo(
      {required this.id,
      this.title = '',
      this.category = '',
      this.status = TodoStatus.todo,
      this.date,
      this.startMinutes,
      this.durationMinutes = 60,
      final List<Breakpoint> breakpoints = const <Breakpoint>[],
      this.notes = '',
      this.sortIndex,
      this.createdAt,
      this.updatedAt})
      : _breakpoints = breakpoints,
        super._();

  @override
  final String id;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String category;
  @override
  @JsonKey()
  final TodoStatus status;

  /// Día en que la tarea aparece en el calendario. `null` = sin fecha.
  /// Se guarda normalizado a medianoche: aquí importa el día, no la hora (la
  /// hora vive en [startMinutes]).
  @override
  final DateTime? date;

  /// Hora de inicio en minutos desde medianoche (9:00 = 540). `null` = sin hora.
  @override
  final int? startMinutes;

  /// Duración total planeada, en minutos.
  @override
  @JsonKey()
  final int durationMinutes;
  final List<Breakpoint> _breakpoints;
  @override
  @JsonKey()
  List<Breakpoint> get breakpoints {
    if (_breakpoints is EqualUnmodifiableListView) return _breakpoints;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_breakpoints);
  }

  @override
  @JsonKey()
  final String notes;

  /// Posición manual dentro de su columna (drag & drop). `null` = por recencia.
  @override
  final double? sortIndex;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TodoCopyWith<_Todo> get copyWith =>
      __$TodoCopyWithImpl<_Todo>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Todo &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.startMinutes, startMinutes) ||
                other.startMinutes == startMinutes) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            const DeepCollectionEquality()
                .equals(other._breakpoints, _breakpoints) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.sortIndex, sortIndex) ||
                other.sortIndex == sortIndex) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      category,
      status,
      date,
      startMinutes,
      durationMinutes,
      const DeepCollectionEquality().hash(_breakpoints),
      notes,
      sortIndex,
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Todo(id: $id, title: $title, category: $category, status: $status, date: $date, startMinutes: $startMinutes, durationMinutes: $durationMinutes, breakpoints: $breakpoints, notes: $notes, sortIndex: $sortIndex, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$TodoCopyWith<$Res> implements $TodoCopyWith<$Res> {
  factory _$TodoCopyWith(_Todo value, $Res Function(_Todo) _then) =
      __$TodoCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String category,
      TodoStatus status,
      DateTime? date,
      int? startMinutes,
      int durationMinutes,
      List<Breakpoint> breakpoints,
      String notes,
      double? sortIndex,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$TodoCopyWithImpl<$Res> implements _$TodoCopyWith<$Res> {
  __$TodoCopyWithImpl(this._self, this._then);

  final _Todo _self;
  final $Res Function(_Todo) _then;

  /// Create a copy of Todo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? category = null,
    Object? status = null,
    Object? date = freezed,
    Object? startMinutes = freezed,
    Object? durationMinutes = null,
    Object? breakpoints = null,
    Object? notes = null,
    Object? sortIndex = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_Todo(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _self.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as TodoStatus,
      date: freezed == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      startMinutes: freezed == startMinutes
          ? _self.startMinutes
          : startMinutes // ignore: cast_nullable_to_non_nullable
              as int?,
      durationMinutes: null == durationMinutes
          ? _self.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      breakpoints: null == breakpoints
          ? _self._breakpoints
          : breakpoints // ignore: cast_nullable_to_non_nullable
              as List<Breakpoint>,
      notes: null == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
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
