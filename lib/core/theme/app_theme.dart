import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Construye el tema único de la app en modo claro y oscuro.
///
/// Tipografía: Fredoka (títulos, redondeada y "gordita") + Nunito (cuerpo,
/// redondeada y muy legible en tamaños chicos). Ambas soportan acentos del
/// español.
abstract final class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final scheme = ColorScheme(
      brightness: brightness,
      primary: isLight ? AppColors.lightPrimary : AppColors.darkPrimary,
      onPrimary: isLight ? AppColors.lightOnPrimary : AppColors.darkOnPrimary,
      secondary: isLight ? AppColors.lightSecondary : AppColors.darkSecondary,
      onSecondary: isLight ? AppColors.lightOnPrimary : AppColors.darkOnPrimary,
      tertiary: isLight ? AppColors.lightTertiary : AppColors.darkTertiary,
      onTertiary: isLight ? AppColors.lightOnPrimary : AppColors.darkOnPrimary,
      error: AppColors.danger,
      onError: Colors.white,
      surface: isLight ? AppColors.lightSurface : AppColors.darkSurface,
      onSurface: isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
      // Escala de superficies en capas (hundido → elevado).
      surfaceContainerLowest:
          isLight ? AppColors.lightSurfaceLow : AppColors.darkSurfaceLow,
      surfaceContainerLow:
          isLight ? AppColors.lightSurfaceLow : AppColors.darkSurface,
      surfaceContainer:
          isLight ? AppColors.lightSurface : AppColors.darkSurface,
      surfaceContainerHigh:
          isLight ? AppColors.lightSurfaceHigh : AppColors.darkSurfaceHigh,
      surfaceContainerHighest:
          isLight ? AppColors.lightSurfaceAlt : AppColors.darkSurfaceAlt,
      onSurfaceVariant:
          isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
      outline: isLight ? AppColors.lightOutline : AppColors.darkOutline,
      outlineVariant: isLight ? AppColors.lightOutline : AppColors.darkOutline,
    );

    final background =
        isLight ? AppColors.lightBackground : AppColors.darkBackground;

    final textTheme = _textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        foregroundColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.brMd,
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withValues(alpha: 0.4),
        thickness: 1,
        space: AppSpacing.lg,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.primary,
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.5)),
        shape: const RoundedRectangleBorder(borderRadius: AppSpacing.brSm),
        labelStyle: textTheme.labelLarge,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl, vertical: AppSpacing.md),
          shape: const RoundedRectangleBorder(borderRadius: AppSpacing.brMd),
          textStyle: textTheme.labelLarge,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 2,
        shape: const RoundedRectangleBorder(borderRadius: AppSpacing.brLg),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.lightSurfaceLow : AppColors.darkSurfaceLow,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        // Sin borde por defecto: el relleno hundido ya delimita el campo,
        // y solo el foco dibuja un anillo. Más limpio y premium.
        border: const OutlineInputBorder(
          borderRadius: AppSpacing.brMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppSpacing.brMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.brMd,
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isLight
            ? AppColors.lightSurfaceHigh
            : AppColors.darkSurfaceHigh,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isLight
            ? AppColors.lightSurfaceHigh
            : AppColors.darkSurfaceHigh,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
        // Sin esto, Material pinta el icono activo con `onSecondaryContainer`,
        // que en esta paleta queda casi blanco sobre el indicador claro.
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isLight ? AppColors.lightSurface : AppColors.darkSurface,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelMedium!.copyWith(
          color: scheme.primary,
        ),
        unselectedLabelTextStyle: textTheme.labelMedium!.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    final base = GoogleFonts.nunitoTextTheme().apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    TextStyle display(TextStyle? s) => GoogleFonts.fredoka(
          textStyle: s,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        );

    return base.copyWith(
      displayLarge: display(base.displayLarge),
      displayMedium: display(base.displayMedium),
      displaySmall: display(base.displaySmall),
      headlineLarge: display(base.headlineLarge),
      headlineMedium: display(base.headlineMedium),
      headlineSmall: display(base.headlineSmall),
      titleLarge: display(base.titleLarge).copyWith(fontWeight: FontWeight.w600),
    );
  }
}
