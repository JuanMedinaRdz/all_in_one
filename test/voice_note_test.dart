import 'package:all_in_one/features/notes/domain/voice_note.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VoiceNote.deriveTitle', () {
    test('un dictado corto se usa completo como título', () {
      expect(VoiceNote.deriveTitle('Comprar café'), 'Comprar café');
    });

    test('un dictado largo se corta en límite de palabra con elipsis', () {
      final title = VoiceNote.deriveTitle(
        'Recordar que mañana tengo que pasar por la despensa antes de ir al dentista',
      );
      expect(title.endsWith('…'), isTrue);
      expect(title.length, lessThanOrEqualTo(37)); // 36 + elipsis
      expect(title.contains(RegExp(r'\s$')), isFalse);
      // No corta a media palabra: lo anterior a la elipsis es palabra completa.
      expect(title, 'Recordar que mañana tengo que pasar…');
    });

    test('espacios repetidos y saltos se normalizan', () {
      expect(VoiceNote.deriveTitle('  hola   mundo  '), 'hola mundo');
    });

    test('vacío cae en un título por defecto', () {
      expect(VoiceNote.deriveTitle(''), 'Nota de voz');
      expect(VoiceNote.deriveTitle('   '), 'Nota de voz');
    });
  });

  group('VoiceNote.join', () {
    test('une fragmentos con un espacio', () {
      expect(VoiceNote.join('hola', 'mundo'), 'hola mundo');
    });

    test('ignora fragmentos vacíos y no deja espacios colgando', () {
      expect(VoiceNote.join('', 'hola'), 'hola');
      expect(VoiceNote.join('hola', ''), 'hola');
      expect(VoiceNote.join('hola', '   '), 'hola');
    });
  });
}
