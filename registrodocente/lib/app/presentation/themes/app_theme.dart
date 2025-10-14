import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// 🦉 Tema Duolingo
///
/// Sistema de diseño limpio, vibrante y moderno inspirado en Duolingo.
/// Enfoque en botones grandes, bordes redondeados y sombras pronunciadas.
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        primaryContainer: AppColors.primarySurface,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondarySurface,
        tertiary: AppColors.tertiary,
        tertiaryContainer: AppColors.tertiarySurface,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: Colors.white,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
        brightness: Brightness.light,
      ),

      // Background
      scaffoldBackgroundColor: AppColors.background,

      // AppBar Theme - Estilo Duolingo limpio
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        shadowColor: AppColors.divider,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: 0,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: 24,
        ),
        actionsIconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: 24,
        ),
      ),

      // Card Theme - Bordes redondeados grandes estilo Duolingo
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: AppColors.border,
            width: 2,
          ),
        ),
        color: AppColors.surface,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        surfaceTintColor: Colors.transparent,
      ),

      // Elevated Button Theme - Botones grandes con sombra inferior
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(120, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: AppColors.shadowPrimary,
              width: 0,
            ),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.border, width: 2),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(120, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),

      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        sizeConstraints: BoxConstraints(
          minWidth: 56,
          minHeight: 56,
        ),
      ),

      // Input Decoration Theme - Inputs estilo Duolingo
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.nunito(
          fontSize: 16,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: GoogleFonts.nunito(
          fontSize: 16,
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: AppColors.error,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: AppColors.secondary,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Chip Theme - Chips redondeados
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primarySurface,
        labelStyle: GoogleFonts.nunito(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: Colors.transparent),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 2,
        space: 2,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: 24,
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),

      // Dialog Theme - Diálogos limpios
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(
            color: AppColors.border,
            width: 2,
          ),
        ),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
          letterSpacing: 0,
        ),
        contentTextStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          side: BorderSide(
            color: AppColors.border,
            width: 2,
          ),
        ),
      ),

      // Text Theme - Tipografía Nunito
      textTheme: GoogleFonts.nunitoTextTheme(
        const TextTheme(
          // Display - Títulos grandes
          displayLarge: TextStyle(
            fontSize: 56,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.1,
            letterSpacing: -1,
          ),
          displayMedium: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.15,
            letterSpacing: 0,
          ),
          displaySmall: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.2,
            letterSpacing: 0,
          ),

          // Headlines - Títulos de secciones
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.25,
            letterSpacing: 0,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.3,
            letterSpacing: 0,
          ),
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.3,
            letterSpacing: 0,
          ),

          // Titles - Títulos de cards
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.3,
            letterSpacing: 0,
          ),
          titleMedium: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.4,
            letterSpacing: 0,
          ),
          titleSmall: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            height: 1.4,
            letterSpacing: 0,
          ),

          // Body - Texto de contenido
          bodyLarge: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
            height: 1.5,
            letterSpacing: 0,
          ),
          bodyMedium: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.5,
            letterSpacing: 0,
          ),
          bodySmall: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiary,
            height: 1.5,
            letterSpacing: 0,
          ),

          // Labels - Etiquetas y botones
          labelLarge: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0,
          ),
          labelMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0,
          ),
          labelSmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textTertiary,
            letterSpacing: 0,
          ),
        ),
      ),

      // Font Family - Nunito
      fontFamily: GoogleFonts.nunito().fontFamily,

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        circularTrackColor: AppColors.primarySurface,
        linearTrackColor: AppColors.primarySurface,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.divider;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: const BorderSide(
          color: AppColors.border,
          width: 2,
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.textTertiary;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primarySurface,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withValues(alpha: 0.2),
        valueIndicatorColor: AppColors.primary,
        trackHeight: 8,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
        valueIndicatorTextStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
