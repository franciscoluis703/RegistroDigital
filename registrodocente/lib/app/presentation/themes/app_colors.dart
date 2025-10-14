import 'package:flutter/material.dart';

/// 🦉 Sistema de Colores Duolingo
///
/// Paleta vibrante, limpia y moderna inspirada en Duolingo.
/// Colores brillantes con alto contraste que transmiten energía y motivación.
class AppColors {
  // ============================================
  // 🌈 COLORES PRINCIPALES - Paleta Duolingo
  // ============================================

  /// Color primario - Verde Duolingo (éxito y aprendizaje)
  static const Color primary = Color(0xFF58CC02); // #58CC02 - Verde Duolingo
  static const Color primaryLight = Color(0xFF89E34A); // Verde más claro
  static const Color primaryDark = Color(0xFF3DA700); // Verde más oscuro
  static const Color primarySurface = Color(0xFFE7F9E1); // Fondo verde muy suave

  /// Color secundario - Azul Duolingo (información y navegación)
  static const Color secondary = Color(0xFF1CB0F6); // #1CB0F6 - Azul brillante
  static const Color secondaryLight = Color(0xFF6DCFF6); // Azul claro
  static const Color secondaryDark = Color(0xFF0A87D1); // Azul oscuro
  static const Color secondarySurface = Color(0xFFE0F4FF); // Fondo azul suave

  /// Color terciario - Amarillo Duolingo (racha y logros)
  static const Color tertiary = Color(0xFFFF9600); // #FF9600 - Naranja/Amarillo
  static const Color tertiaryLight = Color(0xFFFFBF00); // Amarillo brillante
  static const Color tertiaryDark = Color(0xFFE67E00); // Naranja oscuro
  static const Color tertiarySurface = Color(0xFFFFF4E0); // Fondo amarillo suave

  /// Color de acento - Violeta Duolingo (premium y especial)
  static const Color accent = Color(0xFFCE82FF); // #CE82FF - Violeta brillante
  static const Color accentLight = Color(0xFFE5B8FF); // Violeta claro
  static const Color accentDark = Color(0xFFB554FF); // Violeta oscuro
  static const Color accentSurface = Color(0xFFF9F0FF); // Fondo violeta suave

  /// Color rosa - Rosa Duolingo (amor y motivación)
  static const Color pink = Color(0xFFFF73B9); // #FF73B9 - Rosa brillante
  static const Color pinkLight = Color(0xFFFFAAD5); // Rosa claro
  static const Color pinkDark = Color(0xFFE6479B); // Rosa oscuro
  static const Color pinkSurface = Color(0xFFFFEFF7); // Fondo rosa suave

  // ============================================
  // ✅ ESTADOS SEMÁNTICOS
  // ============================================

  /// Éxito (correcto, completado)
  static const Color success = Color(0xFF58CC02); // Verde Duolingo
  static const Color successLight = Color(0xFF89E34A);
  static const Color successDark = Color(0xFF3DA700);
  static const Color successSurface = Color(0xFFE7F9E1);

  /// Advertencia (atención, revisar)
  static const Color warning = Color(0xFFFF9600); // Naranja/Amarillo
  static const Color warningLight = Color(0xFFFFBF00);
  static const Color warningDark = Color(0xFFE67E00);
  static const Color warningSurface = Color(0xFFFFF4E0);

  /// Error (incorrecto, fallo)
  static const Color error = Color(0xFFFF4B4B); // #FF4B4B - Rojo Duolingo
  static const Color errorLight = Color(0xFFFF7A7A);
  static const Color errorDark = Color(0xFFEA2B2B);
  static const Color errorSurface = Color(0xFFFFE9E9);

  /// Información (consejos, ayuda)
  static const Color info = Color(0xFF1CB0F6); // Azul Duolingo
  static const Color infoLight = Color(0xFF6DCFF6);
  static const Color infoDark = Color(0xFF0A87D1);
  static const Color infoSurface = Color(0xFFE0F4FF);

  // ============================================
  // 📝 TEXTOS Y NEUTRALES
  // ============================================

  /// Texto principal - Gris oscuro (casi negro)
  static const Color textPrimary = Color(0xFF3C3C3C); // #3C3C3C - Gris muy oscuro

  /// Texto secundario - Gris medio
  static const Color textSecondary = Color(0xFF777777); // #777777 - Gris medio

  /// Texto terciario - Gris claro
  static const Color textTertiary = Color(0xFFAFAFAF); // #AFAFAF - Gris claro

  /// Texto deshabilitado
  static const Color textDisabled = Color(0xFFE5E5E5); // #E5E5E5 - Gris muy claro

  /// Texto en fondos oscuros
  static const Color textOnDark = Color(0xFFFFFFFF); // Blanco

  // ============================================
  // 🎭 FONDOS Y SUPERFICIES
  // ============================================

  /// Fondo principal de la app - Blanco limpio
  static const Color background = Color(0xFFFFFFFF); // #FFFFFF - Blanco puro

  /// Fondo secundario - Gris muy claro
  static const Color backgroundSecondary = Color(0xFFF7F7F7); // #F7F7F7 - Casi blanco

  /// Superficie de cards y contenedores - Blanco
  static const Color surface = Color(0xFFFFFFFF); // #FFFFFF - Blanco

  /// Superficie alternativa - Gris muy suave
  static const Color surfaceVariant = Color(0xFFFAFAFA); // #FAFAFA - Gris muy claro

  /// Divisores y bordes
  static const Color divider = Color(0xFFE5E5E5); // #E5E5E5 - Gris claro para bordes

  /// Bordes oscuros (estilo Duolingo con borde pronunciado)
  static const Color border = Color(0xFFE5E5E5); // Borde claro
  static const Color borderDark = Color(0xFFCECECE); // Borde medio
  static const Color borderHeavy = Color(0xFFAFAFAF); // Borde pronunciado

  // ============================================
  // 🎓 COLORES TEMÁTICOS EDUCATIVOS
  // ============================================

  /// Asistencia - Verde éxito
  static const Color asistencia = Color(0xFF58CC02);
  static const Color asistenciaSurface = Color(0xFFE7F9E1);

  /// Calificaciones - Azul académico
  static const Color calificaciones = Color(0xFF1CB0F6);
  static const Color calificacionesSurface = Color(0xFFE0F4FF);

  /// Promoción de grado - Violeta especial
  static const Color promocion = Color(0xFFCE82FF);
  static const Color promocionSurface = Color(0xFFF9F0FF);

  /// Datos generales - Naranja información
  static const Color datosGenerales = Color(0xFFFF9600);
  static const Color datosGeneralesSurface = Color(0xFFFFF4E0);

  /// Calendario escolar - Rosa eventos
  static const Color calendario = Color(0xFFFF73B9);
  static const Color calendarioSurface = Color(0xFFFFEFF7);

  /// Horario de clases - Amarillo organización
  static const Color horario = Color(0xFFFFBF00);
  static const Color horarioSurface = Color(0xFFFFF9E6);

  /// Evidencias y documentos - Azul claro
  static const Color evidencias = Color(0xFF1CB0F6);
  static const Color evidenciasSurface = Color(0xFFE0F4FF);

  /// Notas y observaciones - Verde suave
  static const Color notas = Color(0xFF58CC02);
  static const Color notasSurface = Color(0xFFE7F9E1);

  // ============================================
  // 🌟 GRADIENTES DECORATIVOS
  // ============================================

  /// Gradiente primario (verde Duolingo)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF58CC02), Color(0xFF89E34A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Gradiente secundario (azul Duolingo)
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF1CB0F6), Color(0xFF6DCFF6)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Gradiente de éxito (verde brillante)
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF58CC02), Color(0xFF3DA700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente premium (violeta a rosa)
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFCE82FF), Color(0xFFFF73B9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente de racha (amarillo a naranja)
  static const LinearGradient streakGradient = LinearGradient(
    colors: [Color(0xFFFFBF00), Color(0xFFFF9600)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ============================================
  // 🎨 SOMBRAS (Estilo Duolingo - Sombras pronunciadas)
  // ============================================

  /// Sombra suave para botones (inferior)
  static const Color shadowPrimary = Color(0xFF46A302); // Verde oscuro
  static const Color shadowSecondary = Color(0xFF0E87CC); // Azul oscuro
  static const Color shadowTertiary = Color(0xFFD17000); // Naranja oscuro
  static const Color shadowError = Color(0xFFCE2B2B); // Rojo oscuro
  static const Color shadowGray = Color(0xFFCECECE); // Gris para sombras neutras

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
