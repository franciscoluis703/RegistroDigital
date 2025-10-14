import 'package:flutter/material.dart';

/// 🎨 Sistema de Colores Educativo Inspirado en ClassDojo
///
/// Paleta vibrante, cálida y amigable diseñada para entornos educativos.
/// Colores suaves con acentos brillantes que transmiten alegría y motivación.
class AppColors {
  // ============================================
  // 🌈 COLORES PRINCIPALES - Paleta ClassDojo Style
  // ============================================

  /// Color primario - Azul cielo vibrante (inspirado en el cielo del aprendizaje)
  static const Color primary = Color(0xFF5B9FED); // #5B9FED - Azul ClassDojo
  static const Color primaryLight = Color(0xFF8BC4FF); // Versión más clara
  static const Color primaryDark = Color(0xFF2E7DD1); // Versión más oscura
  static const Color primarySurface = Color(0xFFE8F4FF); // Fondo azul muy suave

  /// Color secundario - Verde menta (crecimiento y éxito)
  static const Color secondary = Color(0xFF6BCF8F); // #6BCF8F - Verde menta
  static const Color secondaryLight = Color(0xFF9BE2B0); // Verde claro
  static const Color secondaryDark = Color(0xFF4BA86F); // Verde oscuro
  static const Color secondarySurface = Color(0xFFE7F9EE); // Fondo verde suave

  /// Color terciario - Naranja alegre (energía y creatividad)
  static const Color tertiary = Color(0xFFFFAB40); // #FFAB40 - Naranja brillante
  static const Color tertiaryLight = Color(0xFFFFCC80); // Naranja claro
  static const Color tertiaryDark = Color(0xFFFF9100); // Naranja oscuro
  static const Color tertiarySurface = Color(0xFFFFF3E0); // Fondo naranja suave

  /// Color de acento - Violeta mágico (creatividad e imaginación)
  static const Color accent = Color(0xFFB388FF); // #B388FF - Violeta pastel
  static const Color accentLight = Color(0xFFD1C4E9); // Violeta muy claro
  static const Color accentDark = Color(0xFF7C4DFF); // Violeta oscuro
  static const Color accentSurface = Color(0xFFF3E5F5); // Fondo violeta suave

  /// Color complementario - Rosa cálido (diversión y entusiasmo)
  static const Color pink = Color(0xFFFF6B9D); // #FF6B9D - Rosa vibrante
  static const Color pinkLight = Color(0xFFFF8FB8); // Rosa claro
  static const Color pinkDark = Color(0xFFE91E63); // Rosa oscuro
  static const Color pinkSurface = Color(0xFFFCE4EC); // Fondo rosa suave

  /// Color amarillo - Sol y positividad
  static const Color yellow = Color(0xFFFFD54F); // #FFD54F - Amarillo suave
  static const Color yellowLight = Color(0xFFFFE57F); // Amarillo claro
  static const Color yellowDark = Color(0xFFFFC107); // Amarillo oscuro
  static const Color yellowSurface = Color(0xFFFFFDE7); // Fondo amarillo suave

  // ============================================
  // ✅ ESTADOS SEMÁNTICOS
  // ============================================

  /// Éxito (aprobado, correcto, completado)
  static const Color success = Color(0xFF6BCF8F); // Verde menta
  static const Color successLight = Color(0xFF9BE2B0);
  static const Color successDark = Color(0xFF4BA86F);
  static const Color successSurface = Color(0xFFE7F9EE);

  /// Advertencia (atención, pendiente)
  static const Color warning = Color(0xFFFFAB40); // Naranja
  static const Color warningLight = Color(0xFFFFCC80);
  static const Color warningDark = Color(0xFFFF9100);
  static const Color warningSurface = Color(0xFFFFF3E0);

  /// Error (incorrecto, fallo, eliminado)
  static const Color error = Color(0xFFFF6B6B); // Rojo suave
  static const Color errorLight = Color(0xFFFF8A8A);
  static const Color errorDark = Color(0xFFE53935);
  static const Color errorSurface = Color(0xFFFFEBEE);

  /// Información (notas, consejos, ayuda)
  static const Color info = Color(0xFF5B9FED); // Azul cielo
  static const Color infoLight = Color(0xFF8BC4FF);
  static const Color infoDark = Color(0xFF2E7DD1);
  static const Color infoSurface = Color(0xFFE8F4FF);

  // ============================================
  // 📝 TEXTOS Y NEUTRALES
  // ============================================

  /// Texto principal - Gris oscuro cálido
  static const Color textPrimary = Color(0xFF2D3748); // #2D3748 - Gris oscuro

  /// Texto secundario - Gris medio
  static const Color textSecondary = Color(0xFF718096); // #718096 - Gris medio

  /// Texto terciario - Gris claro
  static const Color textTertiary = Color(0xFFA0AEC0); // #A0AEC0 - Gris claro

  /// Texto deshabilitado
  static const Color textDisabled = Color(0xFFCBD5E0); // #CBD5E0 - Gris muy claro

  // ============================================
  // 🎭 FONDOS Y SUPERFICIES
  // ============================================

  /// Fondo principal de la app - Azul cielo muy suave
  static const Color background = Color(0xFFF7FAFC); // #F7FAFC - Casi blanco con tinte azul

  /// Superficie de cards y contenedores - Blanco puro
  static const Color surface = Color(0xFFFFFFFF); // #FFFFFF - Blanco

  /// Superficie alternativa - Gris muy claro
  static const Color surfaceVariant = Color(0xFFF1F5F9); // #F1F5F9 - Gris muy claro

  /// Divisores y bordes
  static const Color divider = Color(0xFFE2E8F0); // #E2E8F0 - Gris claro para bordes

  /// Superficie con elevación (modales, diálogos)
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  // ============================================
  // 🎓 COLORES TEMÁTICOS EDUCATIVOS
  // ============================================

  /// Asistencia - Verde éxito
  static const Color asistencia = Color(0xFF6BCF8F);
  static const Color asistenciaSurface = Color(0xFFE7F9EE);

  /// Calificaciones - Azul académico
  static const Color calificaciones = Color(0xFF5B9FED);
  static const Color calificacionesSurface = Color(0xFFE8F4FF);

  /// Promoción de grado - Violeta celebración
  static const Color promocion = Color(0xFFB388FF);
  static const Color promocionSurface = Color(0xFFF3E5F5);

  /// Datos generales - Naranja información
  static const Color datosGenerales = Color(0xFFFFAB40);
  static const Color datosGeneralesSurface = Color(0xFFFFF3E0);

  /// Calendario escolar - Rosa eventos
  static const Color calendario = Color(0xFFFF6B9D);
  static const Color calendarioSurface = Color(0xFFFCE4EC);

  /// Horario de clases - Amarillo organización
  static const Color horario = Color(0xFFFFD54F);
  static const Color horarioSurface = Color(0xFFFFFDE7);

  /// Evidencias y documentos - Teal documentación
  static const Color evidencias = Color(0xFF26A69A);
  static const Color evidenciasSurface = Color(0xFFE0F2F1);

  /// Notas y observaciones - Índigo reflexión
  static const Color notas = Color(0xFF5C6BC0);
  static const Color notasSurface = Color(0xFFE8EAF6);

  // ============================================
  // 🌟 GRADIENTES DECORATIVOS (Para headers y elementos especiales)
  // ============================================

  /// Gradiente primario (azul a azul claro)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5B9FED), Color(0xFF8BC4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente secundario (verde a verde claro)
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF6BCF8F), Color(0xFF9BE2B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente de éxito (verde menta a turquesa)
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF6BCF8F), Color(0xFF4ECDC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente de celebración (rosa a naranja)
  static const LinearGradient celebrationGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFFAB40)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente mágico (violeta a azul)
  static const LinearGradient magicGradient = LinearGradient(
    colors: [Color(0xFFB388FF), Color(0xFF5B9FED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================
  // 🎨 UTILIDADES
  // ============================================

  /// Obtener color con opacidad personalizada
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  /// Oscurecer un color
  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  /// Aclarar un color
  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }
}
