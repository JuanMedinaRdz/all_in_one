/// Utilidades puras de las notas por voz.
abstract final class VoiceNote {
  const VoiceNote._();

  /// Deriva un título corto del dictado: las primeras palabras, cortadas en
  /// un límite de palabra, con "…" si el texto sigue. Así la tarjeta de la
  /// lista dice algo útil en vez de "Sin título".
  static String deriveTitle(String transcript, {int maxLength = 36}) {
    final clean = transcript.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) return 'Nota de voz';
    if (clean.length <= maxLength) return clean;

    final cut = clean.substring(0, maxLength);
    final lastSpace = cut.lastIndexOf(' ');
    // Si la primera palabra es larguísima, se corta a lo bruto; si no, en el
    // último espacio para no partir palabras a la mitad.
    final head = lastSpace > 12 ? cut.substring(0, lastSpace) : cut;
    return '$head…';
  }

  /// Une el texto ya aceptado con un fragmento nuevo del dictado.
  static String join(String accepted, String fragment) {
    final f = fragment.trim();
    if (f.isEmpty) return accepted;
    if (accepted.isEmpty) return f;
    return '$accepted $f';
  }
}
