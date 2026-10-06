import '../data/note.dart';

/// Lógica del orden manual de las notas (drag & drop).
///
/// Cada nota puede tener un `sortIndex` (double). La estrategia es "índice
/// fraccional": al soltar una nota entre dos, se le asigna el punto medio de
/// sus vecinas, así **solo la nota movida se escribe** en Firestore. Cuando el
/// punto medio ya no cabe (precisión agotada) o hay notas sin índice de por
/// medio, se reindexa la lista visible en un solo batch.
abstract final class NoteOrdering {
  const NoteOrdering._();

  /// Separación entre índices al (re)indexar. Grande a propósito: da espacio
  /// para miles de inserciones intermedias antes de necesitar reindexar.
  static const double gap = 1024;

  /// Orden de la lista: primero las notas con índice manual (ascendente);
  /// después las no ordenadas, por recencia (como siempre fue).
  static int compare(Note a, Note b) {
    final ai = a.sortIndex;
    final bi = b.sortIndex;
    if (ai != null && bi != null) {
      final byIndex = ai.compareTo(bi);
      if (byIndex != 0) return byIndex;
    } else if (ai != null) {
      return -1;
    } else if (bi != null) {
      return 1;
    }

    final ad = a.updatedAt;
    final bd = b.updatedAt;
    if (ad == null && bd == null) return 0;
    if (ad == null) return -1; // recién creada (timestamp aún en el servidor)
    if (bd == null) return 1;
    return bd.compareTo(ad);
  }

  static List<Note> sorted(Iterable<Note> notes) => notes.toList()..sort(compare);

  /// Índice para colocarse entre [prev] y [next] escribiendo un solo doc.
  /// `null` = no se puede (precisión agotada): hay que reindexar con [reindex].
  static double? between(double? prev, double? next) {
    if (prev == null && next == null) return 0;
    if (prev == null) return next! - gap;
    if (next == null) return prev + gap;
    final mid = (prev + next) / 2;
    if (mid <= prev || mid >= next) return null;
    return mid;
  }

  /// Índices limpios para toda la lista, en el orden dado. Se aplica en un
  /// único `WriteBatch` (una operación de red).
  static Map<String, double> reindex(List<Note> ordered) => {
        for (var i = 0; i < ordered.length; i++) ordered[i].id: i * gap,
      };

  /// Resuelve un movimiento de [oldIndex] a [newIndex] sobre [visible] (la
  /// lista tal como se ve). Devuelve qué índices escribir: idealmente solo el
  /// de la nota movida; si no se puede, la lista completa reindexada.
  ///
  /// [newIndex] es la posición final ya compensada (como la entrega
  /// `ReorderableListView.onReorderItem`).
  static Map<String, double> resolveMove(
    List<Note> visible,
    int oldIndex,
    int newIndex,
  ) {
    final list = List<Note>.of(visible);
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);

    final prev = newIndex > 0 ? list[newIndex - 1] : null;
    final next = newIndex < list.length - 1 ? list[newIndex + 1] : null;

    // Si alguna vecina no tiene índice, el punto medio no significa nada:
    // toca formalizar el orden de toda la lista visible.
    final neighborsIndexed = (prev == null || prev.sortIndex != null) &&
        (next == null || next.sortIndex != null);

    if (neighborsIndexed) {
      final mid = between(prev?.sortIndex, next?.sortIndex);
      if (mid != null) return {moved.id: mid};
    }
    return reindex(list);
  }
}
