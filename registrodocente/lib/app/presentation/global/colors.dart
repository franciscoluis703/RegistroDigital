
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Colores educativos principales
  static const Color primaryBlue = Color(0xFF4A90E2);      // Azul confiable
  static const Color primaryPurple = Color(0xFF7B68EE);    // Púrpura creativo
  static const Color accentOrange = Color(0xFFFF8C42);     // Naranja energético
  static const Color accentGreen = Color(0xFF4CAF50);      // Verde éxito

  // Colores de fondo
  static const Color background = Color(0xFFF5F7FA);       // Gris muy claro
  static const Color cardBackground = Colors.white;

  // Colores de texto
  static const Color textPrimary = Color(0xFF2C3E50);      // Gris oscuro
  static const Color textSecondary = Color(0xFF95A5A6);    // Gris medio
  static const Color textLight = Colors.white;

  // Colores funcionales
  static const Color error = Color(0xFFE74C3C);            // Rojo error
  static const Color success = Color(0xFF2ECC71);          // Verde éxito
  static const Color warning = Color(0xFFF39C12);          // Amarillo advertencia

  // Gradientes educativos
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentOrange, Color(0xFFFFB347)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
