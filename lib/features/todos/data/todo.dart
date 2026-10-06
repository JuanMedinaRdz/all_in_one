import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../domain/todo_status.dart';

part 'todo.freezed.dart';

/// Un "breakpoint": un paso de la tarea, con su duración y un detalle opcional.
///
/// La hora de cada paso no se guarda: se calcula sola encadenando las duraciones
/// desde la hora de inicio de la tarea (ver [Todo.breakpointClock]). Así mover o
/// reordenar pasos recalcula todo sin que tengas que editar horas a mano.
@freezed
abstract class Breakpoint with _$Breakpoint {
  const Breakpoint._();

  const factory Breakpoint({
    required String id,
    @Default('') String title,

    /// Nota/detalle que se despliega bajo el paso (opcional).
    @Default('') String detail,

    /// Cuánto dura este paso, en minutos.
    @Default(15) int durationMinutes,

    @Default(false) bool done,
  }) = _Breakpoint;

  factory Breakpoint.fromMap(Map<String, dynamic> map) => Breakpoint(
        id: (map['id'] as String?) ?? '',
        title: (map['title'] as String?) ?? '',
        detail: (map['detail'] as String?) ?? '',
        durationMinutes: (map['durationMinutes'] as num?)?.toInt() ?? 15,
        done: (map['done'] as bool?) ?? false,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'detail': detail,
        'durationMinutes': durationMinutes,
        'done': done,
      };

  bool get isEmpty => title.trim().isEmpty;
}

/// Una tarea del tablero de To Do's.
///
/// La firma de la sección son los [breakpoints]: pasos con duración, detalle y
/// check, encadenados en el tiempo. El progreso (círculo, barra, "X de N pasos")
/// se deriva de ellos. Todo va embebido en un solo documento: se lee y escribe
/// entero con una sola operación.
@freezed
abstract class Todo with _$Todo {
  const Todo._();

  const factory Todo({
    required String id,
    @Default('') String title,
    @Default('') String category,
    @Default(TodoStatus.todo) TodoStatus status,

    /// Día en que la tarea aparece en el calendario. `null` = sin fecha.
    /// Se guarda normalizado a medianoche: aquí importa el día, no la hora (la
    /// hora vive en [startMinutes]).
    DateTime? date,

    /// Hora de inicio en minutos desde medianoche (9:00 = 540). `null` = sin hora.
    int? startMinutes,

    /// Duración total planeada, en minutos.
    @Default(60) int durationMinutes,

    @Default(<Breakpoint>[]) List<Breakpoint> breakpoints,

    @Default('') String notes,

    /// Posición manual dentro de su columna (drag & drop). `null` = por recencia.
    double? sortIndex,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Todo;

  factory Todo.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return Todo(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      status: TodoStatus.fromName(data['status'] as String?),
      date: (data['date'] as Timestamp?)?.toDate(),
      startMinutes: (data['startMinutes'] as num?)?.toInt(),
      durationMinutes: (data['durationMinutes'] as num?)?.toInt() ?? 60,
      breakpoints: ((data['breakpoints'] as List<dynamic>?) ?? const [])
          .map((b) => Breakpoint.fromMap(Map<String, dynamic>.from(b as Map)))
          .toList(),
      notes: (data['notes'] as String?) ?? '',
      sortIndex: (data['sortIndex'] as num?)?.toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'category': category,
        'status': status.name,
        // Se manda explícitamente aunque sea null: así quitar la fecha con
        // `merge: true` de verdad la borra (omitirla la dejaría intacta).
        'date': date == null ? null : Timestamp.fromDate(date!),
        'startMinutes': startMinutes,
        'durationMinutes': durationMinutes,
        'breakpoints': breakpoints.map((b) => b.toMap()).toList(),
        'notes': notes,
        if (sortIndex != null) 'sortIndex': sortIndex,
        'updatedAt': FieldValue.serverTimestamp(),
        if (createdAt == null) 'createdAt': FieldValue.serverTimestamp(),
      };

  // --- Derivados de los breakpoints ---

  List<Breakpoint> get realBreakpoints =>
      breakpoints.where((b) => !b.isEmpty).toList();

  int get totalSteps => realBreakpoints.length;
  int get doneSteps => realBreakpoints.where((b) => b.done).length;

  int get totalMinutes =>
      realBreakpoints.fold(0, (acc, b) => acc + b.durationMinutes);
  int get doneMinutes => realBreakpoints
      .where((b) => b.done)
      .fold(0, (acc, b) => acc + b.durationMinutes);

  /// Progreso 0–1 por pasos. Si no hay pasos, 1 cuando está "Hecho", si no 0.
  double get progress {
    if (totalSteps == 0) return status == TodoStatus.done ? 1 : 0;
    return doneSteps / totalSteps;
  }

  /// Primer paso sin terminar (el "siguiente"). `null` si ya no queda ninguno.
  Breakpoint? get nextBreakpoint =>
      realBreakpoints.where((b) => !b.done).firstOrNull;

  /// Hora (en minutos desde medianoche) a la que termina el breakpoint [index],
  /// encadenando duraciones desde el inicio de la tarea. `null` si no hay inicio.
  int? breakpointClock(int index) {
    if (startMinutes == null) return null;
    var acc = startMinutes!;
    for (var i = 0; i <= index && i < breakpoints.length; i++) {
      acc += breakpoints[i].durationMinutes;
    }
    return acc;
  }

  /// Fin planeado de la tarea (inicio + duración). `null` si no tiene hora.
  int? get endMinutes =>
      startMinutes == null ? null : startMinutes! + durationMinutes;

  bool get isBlank =>
      title.trim().isEmpty &&
      notes.trim().isEmpty &&
      realBreakpoints.isEmpty;

  String get displayTitle =>
      title.trim().isEmpty ? 'Tarea sin título' : title.trim();
}
