import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';

/// Sube y borra imágenes del usuario en Firebase Storage.
///
/// Genérico: cada sección (notas, mensualidades...) crea uno con su propia
/// [folder] bajo `workspace/main/`, que es la ruta que permiten las reglas de
/// seguridad. Antes esto vivía duplicado en cada feature.
class WorkspaceImageService {
  const WorkspaceImageService(this._storage, {required this.folder});

  final FirebaseStorage _storage;

  /// Subcarpeta bajo `workspace/main/` (p. ej. `notes`, `payments`).
  final String folder;

  /// Lado máximo de la imagen guardada. Una foto de 4000 px no aporta nada en
  /// pantalla y costaría ~40x más espacio y descarga.
  static const _maxSide = 1600;
  static const _quality = 82;

  /// Comprime la imagen y la sube. Devuelve la URL para guardar en el dato.
  ///
  /// La compresión es lo que mantiene esto en la capa gratuita: una foto de
  /// 5 MB del celular baja a unos 200–400 KB sin diferencia visible.
  Future<String> upload(File file) async {
    final bytes = await _compress(file);
    final ref = _storage.ref('workspace/main/$folder/${const Uuid().v4()}.jpg');

    await ref.putData(
      bytes,
      SettableMetadata(
        contentType: 'image/jpeg',
        // Cada subida es un archivo nuevo (nunca se sobreescribe), así que se
        // puede cachear agresivamente.
        cacheControl: 'public, max-age=31536000, immutable',
      ),
    );

    return ref.getDownloadURL();
  }

  Future<Uint8List> _compress(File file) async {
    try {
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: _maxSide,
        minHeight: _maxSide,
        quality: _quality,
        format: CompressFormat.jpeg,
      );

      // Si el compresor no soporta el formato, subimos el original antes que
      // fallar: mejor una imagen pesada que perder el trabajo del usuario.
      if (result == null) {
        debugPrint('No se pudo comprimir ${file.path}; se sube el original.');
        return file.readAsBytes();
      }
      return result;
    } catch (e) {
      // El plugin de compresión no está en todas las plataformas (p. ej. algunas
      // de escritorio). En ese caso subimos el original en vez de tronar.
      debugPrint('Compresión no disponible ($e); se sube el original.');
      return file.readAsBytes();
    }
  }

  /// Borra imágenes por URL. Nunca lanza: si una imagen ya no existe, o la red
  /// falla, no tiene sentido tumbar el borrado del dato por eso.
  Future<void> deleteAll(Iterable<String> urls) async {
    await Future.wait(urls.map(_deleteOne));
  }

  Future<void> _deleteOne(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (e) {
      debugPrint('No se pudo borrar la imagen $url: $e');
    }
  }
}
