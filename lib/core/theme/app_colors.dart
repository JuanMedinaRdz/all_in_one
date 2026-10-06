import 'package:flutter/material.dart';

/// Paleta "Midnight" inspirada en la referencia: fondo casi negro, verde
/// esmeralda como acento principal y violeta para las deudas. Premium, tipo
/// fintech, pero con superficies en capas para dar profundidad.
///
/// Un solo lugar para los colores de toda la app. La app arranca en **oscuro**
/// (ver `AppTheme` / `themeMode`), que es donde este esquema brilla; el modo
/// claro es una variante limpia del mismo verde por si el sistema lo pide.
abstract final class AppColors {
  const AppColors._();

  // ------------------- MODO CLARO (variante clara del verde) -------------
  static const lightBackground = Color(0xFFF3F5F8);
  static const lightSurfaceLow = Color(0xFFE9EDF2);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceHigh = Color(0xFFFFFFFF);
  static const lightSurfaceAlt = Color(0xFFEDF1F5);
  static const lightPrimary = Color(0xFF10B981); // esmeralda
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightSecondary = Color(0xFF7C6BC4); // violeta
  static const lightTertiary = Color(0xFF3B82F6); // azul
  static const lightTextPrimary = Color(0xFF161C26);
  static const lightTextSecondary = Color(0xFF64707E);
  static const lightOutline = Color(0xFFD9DFE7);

  // --------------------- MODO OSCURO (el de la referencia) ---------------
  static const darkBackground = Color(0xFF0E1216); // casi negro, frío
  static const darkSurfaceLow = Color(0xFF090C10);
  static const darkSurface = Color(0xFF171D24); // tarjetas
  static const darkSurfaceHigh = Color(0xFF212932); // elevada
  static const darkSurfaceAlt = Color(0xFF2A333D);
  static const darkPrimary = Color(0xFF2DD088); // esmeralda luminosa
  static const darkOnPrimary = Color(0xFF04160D);
  static const darkSecondary = Color(0xFF9E88E0); // violeta luminosa
  static const darkTertiary = Color(0xFF5B93F7); // azul
  static const darkTextPrimary = Color(0xFFE9EEF4);
  static const darkTextSecondary = Color(0xFF94A0AE);
  static const darkOutline = Color(0xFF2C3540);

  // ----------------------------- FIRMA / SOMBRAS -------------------------
  /// Brillo (sheen) sobre las tarjetas con degradado: una franja de luz suave
  /// en la esquina superior, como reflejo de cristal. La firma visual.
  static const crema = Color(0xFFFFFFFF);

  /// Sombras: en oscuro, negras profundas para que las tarjetas floten; en
  /// claro, suaves y difusas.
  static List<BoxShadow> softShadow(Brightness b) => b == Brightness.light
      ? const [
          BoxShadow(
            color: Color(0x14202A3A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ]
      : const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ];

  // --------------------------- SEMÁNTICOS COMUNES ------------------------
  static const success = Color(0xFF2DD088); // verde esmeralda
  static const warning = Color(0xFFE8B84B); // ámbar
  static const danger = Color(0xFFE5484D); // rojo

  /// Paleta vívida para color-coding de categorías (finanzas, notas), al estilo
  /// de la referencia: cada categoría un color distinto y saturado.
  static const categoryPalette = <Color>[
    Color(0xFF4C82F7), // azul
    Color(0xFFE89A3C), // naranja
    Color(0xFFE0685A), // coral
    Color(0xFF46C08A), // verde
    Color(0xFF9B7ED9), // púrpura
    Color(0xFF3FB6C9), // teal
    Color(0xFFE07AAE), // rosa
    Color(0xFFE8B84B), // ámbar
  ];

  /// Devuelve un color estable de [categoryPalette] a partir de un texto
  /// (nombre de categoría), sin necesidad de guardar el color en la base.
  static Color forKey(String key) {
    if (key.isEmpty) return categoryPalette.first;
    final hash = key.codeUnits.fold<int>(0, (acc, c) => acc + c);
    return categoryPalette[hash % categoryPalette.length];
  }
}
