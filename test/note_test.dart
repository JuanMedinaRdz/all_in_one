import 'package:all_in_one/core/utils/debouncer.dart';
import 'package:all_in_one/features/notes/data/note.dart';
import 'package:all_in_one/features/notes/domain/note_enums.dart';
import 'package:flutter_test/flutter_test.dart';

NoteBlock textBlock(String id, {String text = '', String? image}) =>
    NoteBlock(id: id, kind: NoteBlockKind.text, text: text, imageUrl: image);

NoteBlock checklist(String id, {String heading = '', List<BlockItem>? items}) =>
    NoteBlock(
      id: id,
      kind: NoteBlockKind.checklist,
      text: heading,
      items: items ?? const [],
    );

NoteBlock todo(String id, {String text = '', bool done = false}) =>
    NoteBlock(id: id, kind: NoteBlockKind.todo, text: text, done: done);

BlockItem item(String id, {String text = '', bool done = false, String? image}) =>
    BlockItem(id: id, text: text, done: done, imageUrl: image);

void main() {
  group('Note.taskProgress', () {
    test('null cuando la nota no tiene tareas', () {
      expect(const Note(id: 'n').taskProgress, isNull);
      expect(
        Note(id: 'n', blocks: [textBlock('t', text: 'solo texto')]).taskProgress,
        isNull,
      );
    });

    test('cuenta ítems de checklist marcados', () {
      final note = Note(id: 'n', blocks: [
        checklist('c', items: [
          item('1', text: 'uno', done: true),
          item('2', text: 'dos'),
          item('3', text: 'tres', done: true),
          item('4', text: 'cuatro'),
        ]),
      ]);
      expect(note.taskProgress, 0.5);
    });

    test('los ítems vacíos no bajan el progreso', () {
      final note = Note(id: 'n', blocks: [
        checklist('c', items: [
          item('1', text: 'uno', done: true),
          item('2'), // vacío: aún no escribes nada
        ]),
      ]);
      expect(note.taskProgress, 1.0);
    });

    test('mezcla checklist y pendientes (todo)', () {
      final note = Note(id: 'n', blocks: [
        checklist('c', items: [item('1', text: 'a', done: true), item('2', text: 'b')]),
        todo('t1', text: 'tarea', done: true),
        todo('t2', text: 'otra'),
      ]);
      // 2 hechos (a + t1) de 4 = 0.5
      expect(note.taskProgress, 0.5);
    });
  });

  group('Note.imageUrls', () {
    test('reúne imágenes de bloques de texto y de ítems de secuencia', () {
      final note = Note(id: 'n', blocks: [
        textBlock('t', text: 'con foto', image: 'https://x/a.jpg'),
        NoteBlock(id: 's', kind: NoteBlockKind.sequence, items: [
          item('1', image: 'https://x/b.jpg'),
          item('2', text: 'sin foto'),
        ]),
      ]);
      expect(note.imageUrls, ['https://x/a.jpg', 'https://x/b.jpg']);
      expect(note.imageCount, 2);
    });
  });

  group('Note.preview', () {
    test('junta texto de bloques y de sus ítems', () {
      final note = Note(id: 'n', blocks: [
        textBlock('t', text: 'Hola'),
        checklist('c', heading: 'Lista', items: [item('1', text: 'Mundo')]),
      ]);
      expect(note.preview, 'Hola · Lista · Mundo');
    });

    test('sin texto dice "Nota vacía"', () {
      expect(const Note(id: 'n').preview, 'Nota vacía');
    });
  });

  group('Note.isBlank', () {
    test('nota nueva con un bloque de texto vacío está en blanco', () {
      expect(Note(id: 'n', blocks: [textBlock('t')]).isBlank, isTrue);
    });

    test('cualquier contenido la salva', () {
      expect(Note(id: 'n', blocks: [textBlock('t', text: 'algo')]).isBlank, isFalse);
      expect(Note(id: 'n', title: 'x', blocks: [textBlock('t')]).isBlank, isFalse);
    });
  });

  group('NoteBlock.isEmpty', () {
    test('todo vacío = sin texto de actividad', () {
      expect(todo('t').isEmpty, isTrue);
      expect(todo('t', text: 'hacer algo').isEmpty, isFalse);
    });

    test('checklist vacío = sin heading ni ítems con contenido', () {
      expect(checklist('c').isEmpty, isTrue);
      expect(checklist('c', items: [item('1', text: 'x')]).isEmpty, isFalse);
    });
  });

  group('NoteBlockKind', () {
    test('un tipo desconocido cae en texto', () {
      expect(NoteBlockKind.fromName('gizmo'), NoteBlockKind.text);
      expect(NoteBlockKind.fromName(null), NoteBlockKind.text);
      expect(NoteBlockKind.fromName('todo'), NoteBlockKind.todo);
    });
  });

  group('NoteStatus', () {
    test('el ciclo pasa por los tres estados y vuelve al inicio', () {
      expect(NoteStatus.todo.next, NoteStatus.inProgress);
      expect(NoteStatus.inProgress.next, NoteStatus.done);
      expect(NoteStatus.done.next, NoteStatus.todo);
    });
  });

  group('Debouncer', () {
    test('una ráfaga de llamadas se colapsa en una sola', () async {
      final d = Debouncer(delay: const Duration(milliseconds: 40));
      var calls = 0;
      for (var i = 0; i < 10; i++) {
        d.run(() => calls++);
      }
      expect(calls, 0, reason: 'no debe escribir mientras sigues tecleando');
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(calls, 1);
      d.dispose();
    });

    test('flush() guarda lo pendiente al instante', () async {
      final d = Debouncer(delay: const Duration(seconds: 10));
      var saved = '';
      d.run(() => saved = 'lo último que escribí');
      expect(saved, '');
      d.flush();
      expect(saved, 'lo último que escribí');
      d.dispose();
    });

    test('dispose() cancela lo pendiente (nota borrada)', () async {
      final d = Debouncer(delay: const Duration(milliseconds: 20));
      var calls = 0;
      d.run(() => calls++);
      d.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(calls, 0, reason: 'no debe revivir una nota ya borrada');
    });
  });
}
