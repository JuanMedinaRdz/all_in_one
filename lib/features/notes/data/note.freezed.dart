// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BlockItem {
  String get id;
  String get text;

  /// Marcado (solo en listas de pasos).
  bool get done;

  /// URL en Firebase Storage (solo en secuencias). `null` = sin imagen.
  String? get imageUrl;

  /// Si este ítem de checklist se envió a To Do's, el id de la tarea creada.
  /// `null` = no enviado. Permite sincronizar el "hecho" en ambos lados y no
  /// duplicar.
  String? get todoId;

  /// Create a copy of BlockItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BlockItemCopyWith<BlockItem> get copyWith =>
      _$BlockItemCopyWithImpl<BlockItem>(this as BlockItem, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BlockItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.done, done) || other.done == done) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.todoId, todoId) || other.todoId == todoId));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, text, done, imageUrl, todoId);

  @override
  String toString() {
    return 'BlockItem(id: $id, text: $text, done: $done, imageUrl: $imageUrl, todoId: $todoId)';
  }
}

/// @nodoc
abstract mixin class $BlockItemCopyWith<$Res> {
  factory $BlockItemCopyWith(BlockItem value, $Res Function(BlockItem) _then) =
      _$BlockItemCopyWithImpl;
  @useResult
  $Res call(
      {String id, String text, bool done, String? imageUrl, String? todoId});
}

/// @nodoc
class _$BlockItemCopyWithImpl<$Res> implements $BlockItemCopyWith<$Res> {
  _$BlockItemCopyWithImpl(this._self, this._then);

  final BlockItem _self;
  final $Res Function(BlockItem) _then;

  /// Create a copy of BlockItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? done = null,
    Object? imageUrl = freezed,
    Object? todoId = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      done: null == done
          ? _self.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      todoId: freezed == todoId
          ? _self.todoId
          : todoId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [BlockItem].
extension BlockItemPatterns on BlockItem {
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
    TResult Function(_BlockItem value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BlockItem() when $default != null:
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
    TResult Function(_BlockItem value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BlockItem():
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
    TResult? Function(_BlockItem value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BlockItem() when $default != null:
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
    TResult Function(String id, String text, bool done, String? imageUrl,
            String? todoId)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BlockItem() when $default != null:
        return $default(
            _that.id, _that.text, _that.done, _that.imageUrl, _that.todoId);
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
            String id, String text, bool done, String? imageUrl, String? todoId)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BlockItem():
        return $default(
            _that.id, _that.text, _that.done, _that.imageUrl, _that.todoId);
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
    TResult? Function(String id, String text, bool done, String? imageUrl,
            String? todoId)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BlockItem() when $default != null:
        return $default(
            _that.id, _that.text, _that.done, _that.imageUrl, _that.todoId);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _BlockItem extends BlockItem {
  const _BlockItem(
      {required this.id,
      this.text = '',
      this.done = false,
      this.imageUrl,
      this.todoId})
      : super._();

  @override
  final String id;
  @override
  @JsonKey()
  final String text;

  /// Marcado (solo en listas de pasos).
  @override
  @JsonKey()
  final bool done;

  /// URL en Firebase Storage (solo en secuencias). `null` = sin imagen.
  @override
  final String? imageUrl;

  /// Si este ítem de checklist se envió a To Do's, el id de la tarea creada.
  /// `null` = no enviado. Permite sincronizar el "hecho" en ambos lados y no
  /// duplicar.
  @override
  final String? todoId;

  /// Create a copy of BlockItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BlockItemCopyWith<_BlockItem> get copyWith =>
      __$BlockItemCopyWithImpl<_BlockItem>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BlockItem &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.done, done) || other.done == done) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.todoId, todoId) || other.todoId == todoId));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, text, done, imageUrl, todoId);

  @override
  String toString() {
    return 'BlockItem(id: $id, text: $text, done: $done, imageUrl: $imageUrl, todoId: $todoId)';
  }
}

/// @nodoc
abstract mixin class _$BlockItemCopyWith<$Res>
    implements $BlockItemCopyWith<$Res> {
  factory _$BlockItemCopyWith(
          _BlockItem value, $Res Function(_BlockItem) _then) =
      __$BlockItemCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id, String text, bool done, String? imageUrl, String? todoId});
}

/// @nodoc
class __$BlockItemCopyWithImpl<$Res> implements _$BlockItemCopyWith<$Res> {
  __$BlockItemCopyWithImpl(this._self, this._then);

  final _BlockItem _self;
  final $Res Function(_BlockItem) _then;

  /// Create a copy of BlockItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? text = null,
    Object? done = null,
    Object? imageUrl = freezed,
    Object? todoId = freezed,
  }) {
    return _then(_BlockItem(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      done: null == done
          ? _self.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      todoId: freezed == todoId
          ? _self.todoId
          : todoId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$NoteBlock {
  String get id;
  NoteBlockKind get kind;

  /// Texto del bloque: el párrafo (text), el encabezado (checklist/sequence)
  /// o la actividad (todo).
  String get text;

  /// Imagen del bloque de texto. `null` = sin imagen.
  String? get imageUrl;

  /// Tarea completada (solo en `todo`).
  bool get done;

  /// Minutos del Pomodoro (solo en `todo`).
  int get pomodoroMinutes;

  /// Orientación de una secuencia.
  BlockLayout get layout;

  /// Sub-ítems de checklist o secuencia.
  List<BlockItem>
      get items; // --- Campos de los bloques nuevos (opcionales) ---
  /// Toggle colapsado (oculta su texto).
  bool get collapsed;

  /// Lenguaje del bloque de código (solo informativo, p. ej. "dart").
  String get language;

  /// Id de la nota destino (solo `noteLink`).
  String? get targetNoteId;

  /// Archivo adjunto (solo `file`).
  String? get fileUrl;
  String get fileName;
  int? get fileSize;

  /// Color de acento del callout (ARGB). `null` = color por defecto.
  int? get accentColor;

  /// Emoji del callout.
  String get emoji;

  /// Create a copy of NoteBlock
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NoteBlockCopyWith<NoteBlock> get copyWith =>
      _$NoteBlockCopyWithImpl<NoteBlock>(this as NoteBlock, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NoteBlock &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.done, done) || other.done == done) &&
            (identical(other.pomodoroMinutes, pomodoroMinutes) ||
                other.pomodoroMinutes == pomodoroMinutes) &&
            (identical(other.layout, layout) || other.layout == layout) &&
            const DeepCollectionEquality().equals(other.items, items) &&
            (identical(other.collapsed, collapsed) ||
                other.collapsed == collapsed) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.targetNoteId, targetNoteId) ||
                other.targetNoteId == targetNoteId) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.accentColor, accentColor) ||
                other.accentColor == accentColor) &&
            (identical(other.emoji, emoji) || other.emoji == emoji));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      kind,
      text,
      imageUrl,
      done,
      pomodoroMinutes,
      layout,
      const DeepCollectionEquality().hash(items),
      collapsed,
      language,
      targetNoteId,
      fileUrl,
      fileName,
      fileSize,
      accentColor,
      emoji);

  @override
  String toString() {
    return 'NoteBlock(id: $id, kind: $kind, text: $text, imageUrl: $imageUrl, done: $done, pomodoroMinutes: $pomodoroMinutes, layout: $layout, items: $items, collapsed: $collapsed, language: $language, targetNoteId: $targetNoteId, fileUrl: $fileUrl, fileName: $fileName, fileSize: $fileSize, accentColor: $accentColor, emoji: $emoji)';
  }
}

/// @nodoc
abstract mixin class $NoteBlockCopyWith<$Res> {
  factory $NoteBlockCopyWith(NoteBlock value, $Res Function(NoteBlock) _then) =
      _$NoteBlockCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      NoteBlockKind kind,
      String text,
      String? imageUrl,
      bool done,
      int pomodoroMinutes,
      BlockLayout layout,
      List<BlockItem> items,
      bool collapsed,
      String language,
      String? targetNoteId,
      String? fileUrl,
      String fileName,
      int? fileSize,
      int? accentColor,
      String emoji});
}

/// @nodoc
class _$NoteBlockCopyWithImpl<$Res> implements $NoteBlockCopyWith<$Res> {
  _$NoteBlockCopyWithImpl(this._self, this._then);

  final NoteBlock _self;
  final $Res Function(NoteBlock) _then;

  /// Create a copy of NoteBlock
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? kind = null,
    Object? text = null,
    Object? imageUrl = freezed,
    Object? done = null,
    Object? pomodoroMinutes = null,
    Object? layout = null,
    Object? items = null,
    Object? collapsed = null,
    Object? language = null,
    Object? targetNoteId = freezed,
    Object? fileUrl = freezed,
    Object? fileName = null,
    Object? fileSize = freezed,
    Object? accentColor = freezed,
    Object? emoji = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      kind: null == kind
          ? _self.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as NoteBlockKind,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      done: null == done
          ? _self.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
      pomodoroMinutes: null == pomodoroMinutes
          ? _self.pomodoroMinutes
          : pomodoroMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      layout: null == layout
          ? _self.layout
          : layout // ignore: cast_nullable_to_non_nullable
              as BlockLayout,
      items: null == items
          ? _self.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<BlockItem>,
      collapsed: null == collapsed
          ? _self.collapsed
          : collapsed // ignore: cast_nullable_to_non_nullable
              as bool,
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      targetNoteId: freezed == targetNoteId
          ? _self.targetNoteId
          : targetNoteId // ignore: cast_nullable_to_non_nullable
              as String?,
      fileUrl: freezed == fileUrl
          ? _self.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      fileName: null == fileName
          ? _self.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: freezed == fileSize
          ? _self.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      accentColor: freezed == accentColor
          ? _self.accentColor
          : accentColor // ignore: cast_nullable_to_non_nullable
              as int?,
      emoji: null == emoji
          ? _self.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [NoteBlock].
extension NoteBlockPatterns on NoteBlock {
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
    TResult Function(_NoteBlock value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NoteBlock() when $default != null:
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
    TResult Function(_NoteBlock value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NoteBlock():
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
    TResult? Function(_NoteBlock value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NoteBlock() when $default != null:
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
            NoteBlockKind kind,
            String text,
            String? imageUrl,
            bool done,
            int pomodoroMinutes,
            BlockLayout layout,
            List<BlockItem> items,
            bool collapsed,
            String language,
            String? targetNoteId,
            String? fileUrl,
            String fileName,
            int? fileSize,
            int? accentColor,
            String emoji)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NoteBlock() when $default != null:
        return $default(
            _that.id,
            _that.kind,
            _that.text,
            _that.imageUrl,
            _that.done,
            _that.pomodoroMinutes,
            _that.layout,
            _that.items,
            _that.collapsed,
            _that.language,
            _that.targetNoteId,
            _that.fileUrl,
            _that.fileName,
            _that.fileSize,
            _that.accentColor,
            _that.emoji);
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
            NoteBlockKind kind,
            String text,
            String? imageUrl,
            bool done,
            int pomodoroMinutes,
            BlockLayout layout,
            List<BlockItem> items,
            bool collapsed,
            String language,
            String? targetNoteId,
            String? fileUrl,
            String fileName,
            int? fileSize,
            int? accentColor,
            String emoji)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NoteBlock():
        return $default(
            _that.id,
            _that.kind,
            _that.text,
            _that.imageUrl,
            _that.done,
            _that.pomodoroMinutes,
            _that.layout,
            _that.items,
            _that.collapsed,
            _that.language,
            _that.targetNoteId,
            _that.fileUrl,
            _that.fileName,
            _that.fileSize,
            _that.accentColor,
            _that.emoji);
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
            NoteBlockKind kind,
            String text,
            String? imageUrl,
            bool done,
            int pomodoroMinutes,
            BlockLayout layout,
            List<BlockItem> items,
            bool collapsed,
            String language,
            String? targetNoteId,
            String? fileUrl,
            String fileName,
            int? fileSize,
            int? accentColor,
            String emoji)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NoteBlock() when $default != null:
        return $default(
            _that.id,
            _that.kind,
            _that.text,
            _that.imageUrl,
            _that.done,
            _that.pomodoroMinutes,
            _that.layout,
            _that.items,
            _that.collapsed,
            _that.language,
            _that.targetNoteId,
            _that.fileUrl,
            _that.fileName,
            _that.fileSize,
            _that.accentColor,
            _that.emoji);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _NoteBlock extends NoteBlock {
  const _NoteBlock(
      {required this.id,
      this.kind = NoteBlockKind.text,
      this.text = '',
      this.imageUrl,
      this.done = false,
      this.pomodoroMinutes = 25,
      this.layout = BlockLayout.vertical,
      final List<BlockItem> items = const <BlockItem>[],
      this.collapsed = false,
      this.language = '',
      this.targetNoteId,
      this.fileUrl,
      this.fileName = '',
      this.fileSize,
      this.accentColor,
      this.emoji = '💡'})
      : _items = items,
        super._();

  @override
  final String id;
  @override
  @JsonKey()
  final NoteBlockKind kind;

  /// Texto del bloque: el párrafo (text), el encabezado (checklist/sequence)
  /// o la actividad (todo).
  @override
  @JsonKey()
  final String text;

  /// Imagen del bloque de texto. `null` = sin imagen.
  @override
  final String? imageUrl;

  /// Tarea completada (solo en `todo`).
  @override
  @JsonKey()
  final bool done;

  /// Minutos del Pomodoro (solo en `todo`).
  @override
  @JsonKey()
  final int pomodoroMinutes;

  /// Orientación de una secuencia.
  @override
  @JsonKey()
  final BlockLayout layout;

  /// Sub-ítems de checklist o secuencia.
  final List<BlockItem> _items;

  /// Sub-ítems de checklist o secuencia.
  @override
  @JsonKey()
  List<BlockItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

// --- Campos de los bloques nuevos (opcionales) ---
  /// Toggle colapsado (oculta su texto).
  @override
  @JsonKey()
  final bool collapsed;

  /// Lenguaje del bloque de código (solo informativo, p. ej. "dart").
  @override
  @JsonKey()
  final String language;

  /// Id de la nota destino (solo `noteLink`).
  @override
  final String? targetNoteId;

  /// Archivo adjunto (solo `file`).
  @override
  final String? fileUrl;
  @override
  @JsonKey()
  final String fileName;
  @override
  final int? fileSize;

  /// Color de acento del callout (ARGB). `null` = color por defecto.
  @override
  final int? accentColor;

  /// Emoji del callout.
  @override
  @JsonKey()
  final String emoji;

  /// Create a copy of NoteBlock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NoteBlockCopyWith<_NoteBlock> get copyWith =>
      __$NoteBlockCopyWithImpl<_NoteBlock>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NoteBlock &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.kind, kind) || other.kind == kind) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.done, done) || other.done == done) &&
            (identical(other.pomodoroMinutes, pomodoroMinutes) ||
                other.pomodoroMinutes == pomodoroMinutes) &&
            (identical(other.layout, layout) || other.layout == layout) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.collapsed, collapsed) ||
                other.collapsed == collapsed) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.targetNoteId, targetNoteId) ||
                other.targetNoteId == targetNoteId) &&
            (identical(other.fileUrl, fileUrl) || other.fileUrl == fileUrl) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.accentColor, accentColor) ||
                other.accentColor == accentColor) &&
            (identical(other.emoji, emoji) || other.emoji == emoji));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      kind,
      text,
      imageUrl,
      done,
      pomodoroMinutes,
      layout,
      const DeepCollectionEquality().hash(_items),
      collapsed,
      language,
      targetNoteId,
      fileUrl,
      fileName,
      fileSize,
      accentColor,
      emoji);

  @override
  String toString() {
    return 'NoteBlock(id: $id, kind: $kind, text: $text, imageUrl: $imageUrl, done: $done, pomodoroMinutes: $pomodoroMinutes, layout: $layout, items: $items, collapsed: $collapsed, language: $language, targetNoteId: $targetNoteId, fileUrl: $fileUrl, fileName: $fileName, fileSize: $fileSize, accentColor: $accentColor, emoji: $emoji)';
  }
}

/// @nodoc
abstract mixin class _$NoteBlockCopyWith<$Res>
    implements $NoteBlockCopyWith<$Res> {
  factory _$NoteBlockCopyWith(
          _NoteBlock value, $Res Function(_NoteBlock) _then) =
      __$NoteBlockCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      NoteBlockKind kind,
      String text,
      String? imageUrl,
      bool done,
      int pomodoroMinutes,
      BlockLayout layout,
      List<BlockItem> items,
      bool collapsed,
      String language,
      String? targetNoteId,
      String? fileUrl,
      String fileName,
      int? fileSize,
      int? accentColor,
      String emoji});
}

/// @nodoc
class __$NoteBlockCopyWithImpl<$Res> implements _$NoteBlockCopyWith<$Res> {
  __$NoteBlockCopyWithImpl(this._self, this._then);

  final _NoteBlock _self;
  final $Res Function(_NoteBlock) _then;

  /// Create a copy of NoteBlock
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? kind = null,
    Object? text = null,
    Object? imageUrl = freezed,
    Object? done = null,
    Object? pomodoroMinutes = null,
    Object? layout = null,
    Object? items = null,
    Object? collapsed = null,
    Object? language = null,
    Object? targetNoteId = freezed,
    Object? fileUrl = freezed,
    Object? fileName = null,
    Object? fileSize = freezed,
    Object? accentColor = freezed,
    Object? emoji = null,
  }) {
    return _then(_NoteBlock(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      kind: null == kind
          ? _self.kind
          : kind // ignore: cast_nullable_to_non_nullable
              as NoteBlockKind,
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      done: null == done
          ? _self.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
      pomodoroMinutes: null == pomodoroMinutes
          ? _self.pomodoroMinutes
          : pomodoroMinutes // ignore: cast_nullable_to_non_nullable
              as int,
      layout: null == layout
          ? _self.layout
          : layout // ignore: cast_nullable_to_non_nullable
              as BlockLayout,
      items: null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<BlockItem>,
      collapsed: null == collapsed
          ? _self.collapsed
          : collapsed // ignore: cast_nullable_to_non_nullable
              as bool,
      language: null == language
          ? _self.language
          : language // ignore: cast_nullable_to_non_nullable
              as String,
      targetNoteId: freezed == targetNoteId
          ? _self.targetNoteId
          : targetNoteId // ignore: cast_nullable_to_non_nullable
              as String?,
      fileUrl: freezed == fileUrl
          ? _self.fileUrl
          : fileUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      fileName: null == fileName
          ? _self.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String,
      fileSize: freezed == fileSize
          ? _self.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      accentColor: freezed == accentColor
          ? _self.accentColor
          : accentColor // ignore: cast_nullable_to_non_nullable
              as int?,
      emoji: null == emoji
          ? _self.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$Note {
  String get id;
  String get title;
  NoteStatus get status;
  List<NoteBlock> get blocks;

  /// Espacio (carpeta) al que pertenece. `null` = sin espacio.
  String? get folderId;

  /// Sección dentro del espacio. `null` = "Sin sección".
  String? get sectionId;

  /// Emoji/icono de la nota. Vacío = sin icono (se usa el del tipo).
  String get icon;

  /// Etiquetas (#backend, #api...). Sin el "#".
  List<String> get tags;

  /// Marcada como favorita (estrella).
  bool get favorite;

  /// Fijada arriba dentro del espacio.
  bool get pinned;

  /// Tarea de To Do's vinculada a esta nota. `null` = ninguna.
  String? get linkedTodoId;

  /// Posición manual asignada por drag & drop. `null` = sin ordenar (se
  /// muestra por recencia). Ver `NoteOrdering`.
  double? get sortIndex;

  /// Día en que esta nota debe aparecer en el calendario. `null` = sin fecha.
  /// Se guarda normalizada a medianoche: aquí importa el día, no la hora.
  DateTime? get reminderDate;
  DateTime? get createdAt;
  DateTime? get updatedAt;

  /// Última vez que se abrió (para "Seguir donde lo dejaste").
  DateTime? get lastOpenedAt;

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NoteCopyWith<Note> get copyWith =>
      _$NoteCopyWithImpl<Note>(this as Note, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is Note &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other.blocks, blocks) &&
            (identical(other.folderId, folderId) ||
                other.folderId == folderId) &&
            (identical(other.sectionId, sectionId) ||
                other.sectionId == sectionId) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            (identical(other.favorite, favorite) ||
                other.favorite == favorite) &&
            (identical(other.pinned, pinned) || other.pinned == pinned) &&
            (identical(other.linkedTodoId, linkedTodoId) ||
                other.linkedTodoId == linkedTodoId) &&
            (identical(other.sortIndex, sortIndex) ||
                other.sortIndex == sortIndex) &&
            (identical(other.reminderDate, reminderDate) ||
                other.reminderDate == reminderDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastOpenedAt, lastOpenedAt) ||
                other.lastOpenedAt == lastOpenedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      status,
      const DeepCollectionEquality().hash(blocks),
      folderId,
      sectionId,
      icon,
      const DeepCollectionEquality().hash(tags),
      favorite,
      pinned,
      linkedTodoId,
      sortIndex,
      reminderDate,
      createdAt,
      updatedAt,
      lastOpenedAt);

  @override
  String toString() {
    return 'Note(id: $id, title: $title, status: $status, blocks: $blocks, folderId: $folderId, sectionId: $sectionId, icon: $icon, tags: $tags, favorite: $favorite, pinned: $pinned, linkedTodoId: $linkedTodoId, sortIndex: $sortIndex, reminderDate: $reminderDate, createdAt: $createdAt, updatedAt: $updatedAt, lastOpenedAt: $lastOpenedAt)';
  }
}

/// @nodoc
abstract mixin class $NoteCopyWith<$Res> {
  factory $NoteCopyWith(Note value, $Res Function(Note) _then) =
      _$NoteCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String title,
      NoteStatus status,
      List<NoteBlock> blocks,
      String? folderId,
      String? sectionId,
      String icon,
      List<String> tags,
      bool favorite,
      bool pinned,
      String? linkedTodoId,
      double? sortIndex,
      DateTime? reminderDate,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? lastOpenedAt});
}

/// @nodoc
class _$NoteCopyWithImpl<$Res> implements $NoteCopyWith<$Res> {
  _$NoteCopyWithImpl(this._self, this._then);

  final Note _self;
  final $Res Function(Note) _then;

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? status = null,
    Object? blocks = null,
    Object? folderId = freezed,
    Object? sectionId = freezed,
    Object? icon = null,
    Object? tags = null,
    Object? favorite = null,
    Object? pinned = null,
    Object? linkedTodoId = freezed,
    Object? sortIndex = freezed,
    Object? reminderDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastOpenedAt = freezed,
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
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as NoteStatus,
      blocks: null == blocks
          ? _self.blocks
          : blocks // ignore: cast_nullable_to_non_nullable
              as List<NoteBlock>,
      folderId: freezed == folderId
          ? _self.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as String?,
      sectionId: freezed == sectionId
          ? _self.sectionId
          : sectionId // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: null == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favorite: null == favorite
          ? _self.favorite
          : favorite // ignore: cast_nullable_to_non_nullable
              as bool,
      pinned: null == pinned
          ? _self.pinned
          : pinned // ignore: cast_nullable_to_non_nullable
              as bool,
      linkedTodoId: freezed == linkedTodoId
          ? _self.linkedTodoId
          : linkedTodoId // ignore: cast_nullable_to_non_nullable
              as String?,
      sortIndex: freezed == sortIndex
          ? _self.sortIndex
          : sortIndex // ignore: cast_nullable_to_non_nullable
              as double?,
      reminderDate: freezed == reminderDate
          ? _self.reminderDate
          : reminderDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastOpenedAt: freezed == lastOpenedAt
          ? _self.lastOpenedAt
          : lastOpenedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [Note].
extension NotePatterns on Note {
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
    TResult Function(_Note value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Note() when $default != null:
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
    TResult Function(_Note value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Note():
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
    TResult? Function(_Note value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Note() when $default != null:
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
            NoteStatus status,
            List<NoteBlock> blocks,
            String? folderId,
            String? sectionId,
            String icon,
            List<String> tags,
            bool favorite,
            bool pinned,
            String? linkedTodoId,
            double? sortIndex,
            DateTime? reminderDate,
            DateTime? createdAt,
            DateTime? updatedAt,
            DateTime? lastOpenedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _Note() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.status,
            _that.blocks,
            _that.folderId,
            _that.sectionId,
            _that.icon,
            _that.tags,
            _that.favorite,
            _that.pinned,
            _that.linkedTodoId,
            _that.sortIndex,
            _that.reminderDate,
            _that.createdAt,
            _that.updatedAt,
            _that.lastOpenedAt);
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
            NoteStatus status,
            List<NoteBlock> blocks,
            String? folderId,
            String? sectionId,
            String icon,
            List<String> tags,
            bool favorite,
            bool pinned,
            String? linkedTodoId,
            double? sortIndex,
            DateTime? reminderDate,
            DateTime? createdAt,
            DateTime? updatedAt,
            DateTime? lastOpenedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Note():
        return $default(
            _that.id,
            _that.title,
            _that.status,
            _that.blocks,
            _that.folderId,
            _that.sectionId,
            _that.icon,
            _that.tags,
            _that.favorite,
            _that.pinned,
            _that.linkedTodoId,
            _that.sortIndex,
            _that.reminderDate,
            _that.createdAt,
            _that.updatedAt,
            _that.lastOpenedAt);
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
            NoteStatus status,
            List<NoteBlock> blocks,
            String? folderId,
            String? sectionId,
            String icon,
            List<String> tags,
            bool favorite,
            bool pinned,
            String? linkedTodoId,
            double? sortIndex,
            DateTime? reminderDate,
            DateTime? createdAt,
            DateTime? updatedAt,
            DateTime? lastOpenedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _Note() when $default != null:
        return $default(
            _that.id,
            _that.title,
            _that.status,
            _that.blocks,
            _that.folderId,
            _that.sectionId,
            _that.icon,
            _that.tags,
            _that.favorite,
            _that.pinned,
            _that.linkedTodoId,
            _that.sortIndex,
            _that.reminderDate,
            _that.createdAt,
            _that.updatedAt,
            _that.lastOpenedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _Note extends Note {
  const _Note(
      {required this.id,
      this.title = '',
      this.status = NoteStatus.todo,
      final List<NoteBlock> blocks = const <NoteBlock>[],
      this.folderId,
      this.sectionId,
      this.icon = '',
      final List<String> tags = const <String>[],
      this.favorite = false,
      this.pinned = false,
      this.linkedTodoId,
      this.sortIndex,
      this.reminderDate,
      this.createdAt,
      this.updatedAt,
      this.lastOpenedAt})
      : _blocks = blocks,
        _tags = tags,
        super._();

  @override
  final String id;
  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final NoteStatus status;
  final List<NoteBlock> _blocks;
  @override
  @JsonKey()
  List<NoteBlock> get blocks {
    if (_blocks is EqualUnmodifiableListView) return _blocks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blocks);
  }

  /// Espacio (carpeta) al que pertenece. `null` = sin espacio.
  @override
  final String? folderId;

  /// Sección dentro del espacio. `null` = "Sin sección".
  @override
  final String? sectionId;

  /// Emoji/icono de la nota. Vacío = sin icono (se usa el del tipo).
  @override
  @JsonKey()
  final String icon;

  /// Etiquetas (#backend, #api...). Sin el "#".
  final List<String> _tags;

  /// Etiquetas (#backend, #api...). Sin el "#".
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  /// Marcada como favorita (estrella).
  @override
  @JsonKey()
  final bool favorite;

  /// Fijada arriba dentro del espacio.
  @override
  @JsonKey()
  final bool pinned;

  /// Tarea de To Do's vinculada a esta nota. `null` = ninguna.
  @override
  final String? linkedTodoId;

  /// Posición manual asignada por drag & drop. `null` = sin ordenar (se
  /// muestra por recencia). Ver `NoteOrdering`.
  @override
  final double? sortIndex;

  /// Día en que esta nota debe aparecer en el calendario. `null` = sin fecha.
  /// Se guarda normalizada a medianoche: aquí importa el día, no la hora.
  @override
  final DateTime? reminderDate;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  /// Última vez que se abrió (para "Seguir donde lo dejaste").
  @override
  final DateTime? lastOpenedAt;

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NoteCopyWith<_Note> get copyWith =>
      __$NoteCopyWithImpl<_Note>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _Note &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality().equals(other._blocks, _blocks) &&
            (identical(other.folderId, folderId) ||
                other.folderId == folderId) &&
            (identical(other.sectionId, sectionId) ||
                other.sectionId == sectionId) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.favorite, favorite) ||
                other.favorite == favorite) &&
            (identical(other.pinned, pinned) || other.pinned == pinned) &&
            (identical(other.linkedTodoId, linkedTodoId) ||
                other.linkedTodoId == linkedTodoId) &&
            (identical(other.sortIndex, sortIndex) ||
                other.sortIndex == sortIndex) &&
            (identical(other.reminderDate, reminderDate) ||
                other.reminderDate == reminderDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.lastOpenedAt, lastOpenedAt) ||
                other.lastOpenedAt == lastOpenedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      status,
      const DeepCollectionEquality().hash(_blocks),
      folderId,
      sectionId,
      icon,
      const DeepCollectionEquality().hash(_tags),
      favorite,
      pinned,
      linkedTodoId,
      sortIndex,
      reminderDate,
      createdAt,
      updatedAt,
      lastOpenedAt);

  @override
  String toString() {
    return 'Note(id: $id, title: $title, status: $status, blocks: $blocks, folderId: $folderId, sectionId: $sectionId, icon: $icon, tags: $tags, favorite: $favorite, pinned: $pinned, linkedTodoId: $linkedTodoId, sortIndex: $sortIndex, reminderDate: $reminderDate, createdAt: $createdAt, updatedAt: $updatedAt, lastOpenedAt: $lastOpenedAt)';
  }
}

/// @nodoc
abstract mixin class _$NoteCopyWith<$Res> implements $NoteCopyWith<$Res> {
  factory _$NoteCopyWith(_Note value, $Res Function(_Note) _then) =
      __$NoteCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      NoteStatus status,
      List<NoteBlock> blocks,
      String? folderId,
      String? sectionId,
      String icon,
      List<String> tags,
      bool favorite,
      bool pinned,
      String? linkedTodoId,
      double? sortIndex,
      DateTime? reminderDate,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? lastOpenedAt});
}

/// @nodoc
class __$NoteCopyWithImpl<$Res> implements _$NoteCopyWith<$Res> {
  __$NoteCopyWithImpl(this._self, this._then);

  final _Note _self;
  final $Res Function(_Note) _then;

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? status = null,
    Object? blocks = null,
    Object? folderId = freezed,
    Object? sectionId = freezed,
    Object? icon = null,
    Object? tags = null,
    Object? favorite = null,
    Object? pinned = null,
    Object? linkedTodoId = freezed,
    Object? sortIndex = freezed,
    Object? reminderDate = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? lastOpenedAt = freezed,
  }) {
    return _then(_Note(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as NoteStatus,
      blocks: null == blocks
          ? _self._blocks
          : blocks // ignore: cast_nullable_to_non_nullable
              as List<NoteBlock>,
      folderId: freezed == folderId
          ? _self.folderId
          : folderId // ignore: cast_nullable_to_non_nullable
              as String?,
      sectionId: freezed == sectionId
          ? _self.sectionId
          : sectionId // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: null == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      favorite: null == favorite
          ? _self.favorite
          : favorite // ignore: cast_nullable_to_non_nullable
              as bool,
      pinned: null == pinned
          ? _self.pinned
          : pinned // ignore: cast_nullable_to_non_nullable
              as bool,
      linkedTodoId: freezed == linkedTodoId
          ? _self.linkedTodoId
          : linkedTodoId // ignore: cast_nullable_to_non_nullable
              as String?,
      sortIndex: freezed == sortIndex
          ? _self.sortIndex
          : sortIndex // ignore: cast_nullable_to_non_nullable
              as double?,
      reminderDate: freezed == reminderDate
          ? _self.reminderDate
          : reminderDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastOpenedAt: freezed == lastOpenedAt
          ? _self.lastOpenedAt
          : lastOpenedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
