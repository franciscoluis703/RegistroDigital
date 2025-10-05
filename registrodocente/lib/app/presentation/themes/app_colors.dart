import 'package:flutter/material.dart';

/// Colores educativos y profesionales para la aplicación
class AppColors {
  // Colores primarios - Azul educativo vibrante
  static const Color primary = Color(0xFF1976D2); // Azul Material Design
  static const Color primaryLight = Color(0xFF42A5F5); // Azul claro
  static const Color primaryDark = Color(0xFF0D47A1); // Azul oscuro
  static const Color primarySurface = Color(0xFFE3F2FD); // Azul muy claro para fondos

  // Colores secundarios - Naranja académico
  static const Color secondary = Color(0xFFFF9800); // Naranja vibrante
  static const Color secondaryLight = Color(0xFFFFB74D); // Naranja claro
  static const Color secondaryDark = Color(0xFFF57C00); // Naranja oscuro
  static const Color secondarySurface = Color(0xFFFFE0B2); // Naranja muy claro

  // Colores terciarios - Verde éxito
  static const Color tertiary = Color(0xFF4CAF50); // Verde Material
  static const Color tertiaryLight = Color(0xFF81C784); // Verde claro
  static const Color tertiaryDark = Color(0xFF388E3C); // Verde oscuro
  static const Color tertiarySurface = Color(0xFFC8E6C9); // Verde muy claro

  // Colores de acento - Morado creatividad
  static const Color accent = Color(0xFF9C27B0); // Morado Material
  static const Color accentLight = Color(0xFFBA68C8); // Morado claro
  static const Color accentDark = Color(0xFF7B1FA2); // Morado oscuro
  static const Color accentSurface = Color(0xFFE1BEE7); // Morado muy claro

  // Estados
  static const Color success = Color(0xFF4CAF50); // Verde
  static const Color warning = Color(0xFFFF9800); // Naranja
  static const Color error = Color(0xFFF44336); // Rojo Material
  static const Color info = Color(0xFF2196F3); // Azul info

  // Superficies de estado
  static const Color successSurface = Color(0xFFC8E6C9);
  static const Color warningSurface = Color(0xFFFFE0B2);
  static const Color errorSurface = Color(0xFFFFCDD2);
  static const Color infoSurface = Color(0xFFBBDEFB);

  // Grises neutrales
  static const Color textPrimary = Color(0xFF212121); // Texto principal
  static const Color textSecondary = Color(0xFF757575); // Texto secundario
  static const Color textTertiary = Color(0xFF9E9E9E); // Texto terciario
  static const Color textDisabled = Color(0xFFBDBDBD); // Texto deshabilitado

  // Fondos
  static const Color background = Color(0xFFFAFAFA); // Fondo principal
  static const Color surface = Color(0xFFFFFFFF); // Superficie (cards)
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Superficie variante
  static const Color divider = Color(0xFFE0E0E0); // Divisores y bordes

  // Colores temáticos educativos
  static const Color asistencia = Color(0xFF4CAF50); // Verde
  static const Color calificaciones = Color(0xFFFF9800); // Naranja
  static const Color promocion = Color(0xFF9C27B0); // Morado
  static const Color datosGenerales = Color(0xFF2196F3); // Azul
  static const Color calendario = Color(0xFFE91E63); // Rosa Material
  static const Color horario = Color(0xFF00BCD4); // Cian Material

  // Colores con opacidad
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
}
