// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecipeIngredient {
  String get name;
  String get quantity;

  /// Emoji elegido a mano. Vacío = se usa el detectado del nombre.
  String get emoji;

  /// Create a copy of RecipeIngredient
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RecipeIngredientCopyWith<RecipeIngredient> get copyWith =>
      _$RecipeIngredientCopyWithImpl<RecipeIngredient>(
          this as RecipeIngredient, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is RecipeIngredient &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.emoji, emoji) || other.emoji == emoji));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, quantity, emoji);

  @override
  String toString() {
    return 'RecipeIngredient(name: $name, quantity: $quantity, emoji: $emoji)';
  }
}

/// @nodoc
abstract mixin class $RecipeIngredientCopyWith<$Res> {
  factory $RecipeIngredientCopyWith(
          RecipeIngredient value, $Res Function(RecipeIngredient) _then) =
      _$RecipeIngredientCopyWithImpl;
  @useResult
  $Res call({String name, String quantity, String emoji});
}

/// @nodoc
class _$RecipeIngredientCopyWithImpl<$Res>
    implements $RecipeIngredientCopyWith<$Res> {
  _$RecipeIngredientCopyWithImpl(this._self, this._then);

  final RecipeIngredient _self;
  final $Res Function(RecipeIngredient) _then;

  /// Create a copy of RecipeIngredient
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? quantity = null,
    Object? emoji = null,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _self.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [RecipeIngredient].
extension RecipeIngredientPatterns on RecipeIngredient {
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
    TResult Function(_RecipeIngredient value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecipeIngredient() when $default != null:
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
    TResult Function(_RecipeIngredient value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecipeIngredient():
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
    TResult? Function(_RecipeIngredient value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecipeIngredient() when $default != null:
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
    TResult Function(String name, String quantity, String emoji)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _RecipeIngredient() when $default != null:
        return $default(_that.name, _that.quantity, _that.emoji);
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
    TResult Function(String name, String quantity, String emoji) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecipeIngredient():
        return $default(_that.name, _that.quantity, _that.emoji);
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
    TResult? Function(String name, String quantity, String emoji)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _RecipeIngredient() when $default != null:
        return $default(_that.name, _that.quantity, _that.emoji);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _RecipeIngredient extends RecipeIngredient {
  const _RecipeIngredient(
      {required this.name, this.quantity = '', this.emoji = ''})
      : super._();

  @override
  final String name;
  @override
  @JsonKey()
  final String quantity;

  /// Emoji elegido a mano. Vacío = se usa el detectado del nombre.
  @override
  @JsonKey()
  final String emoji;

  /// Create a copy of RecipeIngredient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RecipeIngredientCopyWith<_RecipeIngredient> get copyWith =>
      __$RecipeIngredientCopyWithImpl<_RecipeIngredient>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _RecipeIngredient &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.quantity, quantity) ||
                other.quantity == quantity) &&
            (identical(other.emoji, emoji) || other.emoji == emoji));
  }

  @override
  int get hashCode => Object.hash(runtimeType, name, quantity, emoji);

  @override
  String toString() {
    return 'RecipeIngredient(name: $name, quantity: $quantity, emoji: $emoji)';
  }
}

/// @nodoc
abstract mixin class _$RecipeIngredientCopyWith<$Res>
    implements $RecipeIngredientCopyWith<$Res> {
  factory _$RecipeIngredientCopyWith(
          _RecipeIngredient value, $Res Function(_RecipeIngredient) _then) =
      __$RecipeIngredientCopyWithImpl;
  @override
  @useResult
  $Res call({String name, String quantity, String emoji});
}

/// @nodoc
class __$RecipeIngredientCopyWithImpl<$Res>
    implements _$RecipeIngredientCopyWith<$Res> {
  __$RecipeIngredientCopyWithImpl(this._self, this._then);

  final _RecipeIngredient _self;
  final $Res Function(_RecipeIngredient) _then;

  /// Create a copy of RecipeIngredient
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? quantity = null,
    Object? emoji = null,
  }) {
    return _then(_RecipeIngredient(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      quantity: null == quantity
          ? _self.quantity
          : quantity // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _self.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$Recipe {
  String get id;
  String get name;

  /// Foto de portada en Firebase Storage. `null` = sin foto (se usa un
  /// degradado con emoji).
  String? get coverImageUrl;

  /// Nota libre: de dónde salió, para cuántos rinde bien, tips.
  String get description;

  /// Porciones que rinde. `null` = sin especificar.
  int? get servings;

  /// Minutos de preparación. `null` = sin especificar.
  int? get minutes;

  /// Planeada para esta semana: entra a la lista de compras.
  bool get plannedThisWeek;
  List<RecipeIngredient> get ingredients;

  /// Pasos de preparación, en orden.
  List<String> get steps;
  DateTime? get createdAt;
  DateTime? get updatedAt;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $RecipeCopyWith<Recipe> get copyWith =>
      _$RecipeCopyWithImpl<Recipe>(this as Recipe, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Recipe &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.servings, servings) ||
                other.servings == servings) &&
            (identical(other.minutes, minutes) || other.minutes == minutes) &&
            (identical(other.plannedThisWeek, plannedThisWeek) ||
                other.plannedThisWeek == plannedThisWeek) &&
            const DeepCollectionEquality()
                .equals(other.ingredients, ingredients) &&
            const DeepCollectionEquality().equals(other.steps, steps) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      coverImageUrl,
      description,
      servings,
      minutes,
      plannedThisWeek,
      const DeepCollectionEquality().hash(ingredients),
      const DeepCollectionEquality().hash(steps),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, coverImageUrl: $coverImageUrl, description: $description, servings: $servings, minutes: $minutes, plannedThisWeek: $plannedThisWeek, ingredients: $ingredients, steps: $steps, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $RecipeCopyWith<$Res> {
  factory $RecipeCopyWith(Recipe value, $Res Function(Recipe) _then) =
      _$RecipeCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String? coverImageUrl,
      String description,
      int? servings,
      int? minutes,
      bool plannedThisWeek,
      List<RecipeIngredient> ingredients,
      List<String> steps,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$RecipeCopyWithImpl<$Res> implements $RecipeCopyWith<$Res> {
  _$RecipeCopyWithImpl(this._self, this._then);

  final Recipe _self;
  final $Res Function(Recipe) _then;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? coverImageUrl = freezed,
    Object? description = null,
    Object? servings = freezed,
    Object? minutes = freezed,
    Object? plannedThisWeek = null,
    Object? ingredients = null,
    Object? steps = null,
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
      coverImageUrl: freezed == coverImageUrl
          ? _self.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      servings: freezed == servings
          ? _self.servings
          : servings // ignore: cast_nullable_to_non_nullable
              as int?,
      minutes: freezed == minutes
          ? _self.minutes
          : minutes // ignore: cast_nullable_to_non_nullable
              as int?,
      plannedThisWeek: null == plannedThisWeek
          ? _self.plannedThisWeek
          : plannedThisWeek // ignore: cast_nullable_to_non_nullable
              as bool,
      ingredients: null == ingredients
          ? _self.ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<RecipeIngredient>,
      steps: null == steps
          ? _self.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<String>,
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

/// Adds pattern-matching-related methods to [Recipe].
extension RecipePatterns on Recipe {
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
    TResult Function(_Recipe value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Recipe() when $default != null:
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
    TResult Function(_Recipe value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Recipe():
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
    TResult? Function(_Recipe value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Recipe() when $default != null:
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
            String? coverImageUrl,
            String description,
            int? servings,
            int? minutes,
            bool plannedThisWeek,
            List<RecipeIngredient> ingredients,
            List<String> steps,
            DateTime? createdAt,
            DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Recipe() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.coverImageUrl,
            _that.description,
            _that.servings,
            _that.minutes,
            _that.plannedThisWeek,
            _that.ingredients,
            _that.steps,
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
            String? coverImageUrl,
            String description,
            int? servings,
            int? minutes,
            bool plannedThisWeek,
            List<RecipeIngredient> ingredients,
            List<String> steps,
            DateTime? createdAt,
            DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Recipe():
        return $default(
            _that.id,
            _that.name,
            _that.coverImageUrl,
            _that.description,
            _that.servings,
            _that.minutes,
            _that.plannedThisWeek,
            _that.ingredients,
            _that.steps,
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
            String? coverImageUrl,
            String description,
            int? servings,
            int? minutes,
            bool plannedThisWeek,
            List<RecipeIngredient> ingredients,
            List<String> steps,
            DateTime? createdAt,
            DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Recipe() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.coverImageUrl,
            _that.description,
            _that.servings,
            _that.minutes,
            _that.plannedThisWeek,
            _that.ingredients,
            _that.steps,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Recipe extends Recipe {
  const _Recipe(
      {required this.id,
      this.name = '',
      this.coverImageUrl,
      this.description = '',
      this.servings,
      this.minutes,
      this.plannedThisWeek = false,
      final List<RecipeIngredient> ingredients = const <RecipeIngredient>[],
      final List<String> steps = const <String>[],
      this.createdAt,
      this.updatedAt})
      : _ingredients = ingredients,
        _steps = steps,
        super._();

  @override
  final String id;
  @override
  @JsonKey()
  final String name;

  /// Foto de portada en Firebase Storage. `null` = sin foto (se usa un
  /// degradado con emoji).
  @override
  final String? coverImageUrl;

  /// Nota libre: de dónde salió, para cuántos rinde bien, tips.
  @override
  @JsonKey()
  final String description;

  /// Porciones que rinde. `null` = sin especificar.
  @override
  final int? servings;

  /// Minutos de preparación. `null` = sin especificar.
  @override
  final int? minutes;

  /// Planeada para esta semana: entra a la lista de compras.
  @override
  @JsonKey()
  final bool plannedThisWeek;
  final List<RecipeIngredient> _ingredients;
  @override
  @JsonKey()
  List<RecipeIngredient> get ingredients {
    if (_ingredients is EqualUnmodifiableListView) return _ingredients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ingredients);
  }

  /// Pasos de preparación, en orden.
  final List<String> _steps;

  /// Pasos de preparación, en orden.
  @override
  @JsonKey()
  List<String> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$RecipeCopyWith<_Recipe> get copyWith =>
      __$RecipeCopyWithImpl<_Recipe>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Recipe &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.coverImageUrl, coverImageUrl) ||
                other.coverImageUrl == coverImageUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.servings, servings) ||
                other.servings == servings) &&
            (identical(other.minutes, minutes) || other.minutes == minutes) &&
            (identical(other.plannedThisWeek, plannedThisWeek) ||
                other.plannedThisWeek == plannedThisWeek) &&
            const DeepCollectionEquality()
                .equals(other._ingredients, _ingredients) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      coverImageUrl,
      description,
      servings,
      minutes,
      plannedThisWeek,
      const DeepCollectionEquality().hash(_ingredients),
      const DeepCollectionEquality().hash(_steps),
      createdAt,
      updatedAt);

  @override
  String toString() {
    return 'Recipe(id: $id, name: $name, coverImageUrl: $coverImageUrl, description: $description, servings: $servings, minutes: $minutes, plannedThisWeek: $plannedThisWeek, ingredients: $ingredients, steps: $steps, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$RecipeCopyWith<$Res> implements $RecipeCopyWith<$Res> {
  factory _$RecipeCopyWith(_Recipe value, $Res Function(_Recipe) _then) =
      __$RecipeCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? coverImageUrl,
      String description,
      int? servings,
      int? minutes,
      bool plannedThisWeek,
      List<RecipeIngredient> ingredients,
      List<String> steps,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$RecipeCopyWithImpl<$Res> implements _$RecipeCopyWith<$Res> {
  __$RecipeCopyWithImpl(this._self, this._then);

  final _Recipe _self;
  final $Res Function(_Recipe) _then;

  /// Create a copy of Recipe
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? coverImageUrl = freezed,
    Object? description = null,
    Object? servings = freezed,
    Object? minutes = freezed,
    Object? plannedThisWeek = null,
    Object? ingredients = null,
    Object? steps = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_Recipe(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      coverImageUrl: freezed == coverImageUrl
          ? _self.coverImageUrl
          : coverImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      servings: freezed == servings
          ? _self.servings
          : servings // ignore: cast_nullable_to_non_nullable
              as int?,
      minutes: freezed == minutes
          ? _self.minutes
          : minutes // ignore: cast_nullable_to_non_nullable
              as int?,
      plannedThisWeek: null == plannedThisWeek
          ? _self.plannedThisWeek
          : plannedThisWeek // ignore: cast_nullable_to_non_nullable
              as bool,
      ingredients: null == ingredients
          ? _self._ingredients
          : ingredients // ignore: cast_nullable_to_non_nullable
              as List<RecipeIngredient>,
      steps: null == steps
          ? _self._steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<String>,
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
