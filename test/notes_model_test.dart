import 'package:all_in_one/features/notes/data/note.dart';
import 'package:all_in_one/features/notes/domain/note_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoteBlock · campos nuevos (migración aditiva)', () {
    test('un bloque viejo (sin campos nuevos) carga con defaults', () {
      final b = NoteBlock.fromMap({
        'id': 'b1',
        'kind': 'text',
        'text': 'Hola',
      });
      expect(b.collapsed, isFalse);
      expect(b.language, '');
      expect(b.targetNoteId, isNull);
      expect(b.fileUrl, isNull);
      expect(b.emoji, '💡');
      expect(b.text, 'Hola');
    });

    test('code / noteLink / file hacen round-trip', () {
      const code = NoteBlock(
          id: 'c', kind: NoteBlockKind.code, text: 'print(1)', language: 'dart');
      expect(NoteBlock.fromMap(code.toMap()).language, 'dart');

      const link =
          NoteBlock(id: 'l', kind: NoteBlockKind.noteLink, targetNoteId: 'n9');
      expect(NoteBlock.fromMap(link.toMap()).targetNoteId, 'n9');

      const file = NoteBlock(
          id: 'f',
          kind: NoteBlockKind.file,
          fileUrl: 'http://x/y.pdf',
          fileName: 'y.pdf',
          fileSize: 2400000);
      final back = NoteBlock.fromMap(file.toMap());
      expect(back.fileName, 'y.pdf');
      expect(back.fileSize, 2400000);
    });

    test('un ítem de checklist conserva su todoId', () {
      const item = BlockItem(id: 'i', text: 'Paso', todoId: 't1');
      expect(BlockItem.fromMap(item.toMap()).todoId, 't1');
    });
  });

  group('Note · helpers nuevos', () {
    const note = Note(
      id: 'n1',
      title: 'Backend',
      blocks: [
        NoteBlock(id: 'b1', kind: NoteBlockKind.checklist, items: [
          BlockItem(id: 'i1', text: 'Hecho', done: true),
          BlockItem(id: 'i2', text: 'Pendiente A'),
          BlockItem(id: 'i3', text: 'Pendiente B'),
          BlockItem(id: 'i4', text: ''), // vacío: no cuenta
        ]),
        NoteBlock(id: 'b2', kind: NoteBlockKind.noteLink, targetNoteId: 'n2'),
      ],
    );

    test('pendingItems cuenta los no marcados (ignora vacíos)', () {
      expect(note.pendingCount, 2);
      expect(note.pendingItems.map((i) => i.text), ['Pendiente A', 'Pendiente B']);
    });

    test('linkedNoteIds saca los enlaces a otras notas', () {
      expect(note.linkedNoteIds, ['n2']);
    });

    test('campos nuevos con defaults', () {
      const n = Note(id: 'x');
      expect(n.favorite, isFalse);
      expect(n.pinned, isFalse);
      expect(n.tags, isEmpty);
      expect(n.sectionId, isNull);
      expect(n.icon, '');
    });
  });
}
