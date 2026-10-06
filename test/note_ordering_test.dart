import 'package:all_in_one/features/notes/application/folder_providers.dart';
import 'package:all_in_one/features/notes/data/note.dart';
import 'package:all_in_one/features/notes/domain/note_ordering.dart';
import 'package:flutter_test/flutter_test.dart';

Note n(
  String id, {
  double? sortIndex,
  String? folderId,
  DateTime? updatedAt,
}) =>
    Note(
      id: id,
      title: id,
      sortIndex: sortIndex,
      folderId: folderId,
      updatedAt: updatedAt,
    );

void main() {
  group('NoteOrdering.compare', () {
    test('las notas con índice manual van primero, ascendente', () {
      final sorted = NoteOrdering.sorted([
        n('reciente', updatedAt: DateTime(2026, 7, 10)),
        n('segunda', sortIndex: 2048),
        n('primera', sortIndex: 0),
      ]);
      expect(sorted.map((x) => x.id).toList(), ['primera', 'segunda', 'reciente']);
    });

    test('sin índice, manda la recencia (como siempre fue)', () {
      final sorted = NoteOrdering.sorted([
        n('vieja', updatedAt: DateTime(2026, 1, 1)),
        n('nueva', updatedAt: DateTime(2026, 7, 1)),
        n('sin fecha'), // recién creada, timestamp pendiente: arriba
      ]);
      expect(sorted.map((x) => x.id).toList(), ['sin fecha', 'nueva', 'vieja']);
    });
  });

  group('NoteOrdering.between', () {
    test('lista vacía arranca en 0', () {
      expect(NoteOrdering.between(null, null), 0);
    });

    test('al inicio y al final deja hueco', () {
      expect(NoteOrdering.between(null, 1024), 1024 - NoteOrdering.gap);
      expect(NoteOrdering.between(2048, null), 2048 + NoteOrdering.gap);
    });

    test('entre dos vecinas devuelve el punto medio', () {
      expect(NoteOrdering.between(0, 1024), 512);
    });

    test('con la precisión agotada pide reindexar (null)', () {
      // Dos doubles consecutivos: no cabe nada entre ellos.
      const a = 1.0;
      final b = a + 2.220446049250313e-16; // siguiente double representable
      expect(NoteOrdering.between(a, b), isNull);
    });
  });

  group('NoteOrdering.resolveMove', () {
    test('mover entre vecinas indexadas escribe SOLO la nota movida', () {
      final visible = [
        n('a', sortIndex: 0),
        n('b', sortIndex: 1024),
        n('c', sortIndex: 2048),
      ];
      // c se mueve entre a y b (posición 1)
      final writes = NoteOrdering.resolveMove(visible, 2, 1);
      expect(writes, {'c': 512});
    });

    test('si hay vecinas sin índice, reindexa toda la lista visible', () {
      final visible = [
        n('a'), // sin índice
        n('b'),
        n('c'),
      ];
      final writes = NoteOrdering.resolveMove(visible, 2, 0);
      expect(writes.length, 3, reason: 'formaliza el orden completo');
      expect(writes['c'], 0);
      expect(writes['a'], NoteOrdering.gap);
      expect(writes['b'], NoteOrdering.gap * 2);
    });

    test('mover al inicio de una lista indexada escribe solo la movida', () {
      final visible = [
        n('a', sortIndex: 0),
        n('b', sortIndex: 1024),
      ];
      final writes = NoteOrdering.resolveMove(visible, 1, 0);
      expect(writes, {'b': -NoteOrdering.gap});
    });
  });

  group('notesInScope', () {
    final all = [
      n('suelta1'),
      n('suelta2'),
      n('recetas1', folderId: 'recetas'),
      n('uni1', folderId: 'uni'),
    ];

    test('home y todas devuelven todo', () {
      expect(notesInScope(const NotesScopeHome(), all).length, 4);
      expect(notesInScope(const NotesScopeAll(), all).length, 4);
    });

    test('sin carpeta filtra las que no tienen folderId', () {
      final result = notesInScope(const NotesScopeUnfiled(), all);
      expect(result.map((x) => x.id).toSet(), {'suelta1', 'suelta2'});
    });

    test('una carpeta concreta filtra por su id', () {
      final result = notesInScope(const NotesScopeFolder('recetas'), all);
      expect(result.single.id, 'recetas1');
    });

    test('dos scopes de la misma carpeta son iguales (para el switcher)', () {
      expect(const NotesScopeFolder('x'), const NotesScopeFolder('x'));
      expect(const NotesScopeFolder('x'), isNot(const NotesScopeFolder('y')));
    });
  });

  group('Note.isBlank', () {
    test('una nota recién creada está en blanco', () {
      expect(const Note(id: 'n').isBlank, isTrue);
    });

    test('cualquier contenido la salva del auto-borrado', () {
      expect(const Note(id: 'n', title: 'algo').isBlank, isFalse);
      expect(
        const Note(id: 'n', blocks: [NoteBlock(id: 'b', text: 'hola')]).isBlank,
        isFalse,
      );
      expect(
        const Note(id: 'n', blocks: [NoteBlock(id: 'b', imageUrl: 'x')]).isBlank,
        isFalse,
      );
      expect(Note(id: 'n', reminderDate: DateTime(2026)).isBlank, isFalse);
    });
  });
}
