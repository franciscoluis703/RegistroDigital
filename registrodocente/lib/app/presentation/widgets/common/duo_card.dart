import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

/// 🦉 DuoCard - Tarjeta estilo Duolingo
///
/// Tarjeta limpia con bordes gruesos y sombra inferior pronunciada.
class DuoCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final DuoCardStyle style;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? borderColor;

  const DuoCard({
    super.key,
    required this.child,
    this.onTap,
    this.style = DuoCardStyle.normal,
    this.padding,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getCardConfig();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(config.borderRadius),
        child: Container(
          padding: padding ?? config.padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? config.backgroundColor,
            borderRadius: BorderRadius.circular(config.borderRadius),
            border: Border.all(
              color: borderColor ?? config.borderColor,
              width: config.borderWidth,
            ),
            boxShadow: config.hasShadow
                ? [
                    BoxShadow(
                      color: config.shadowColor,
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }

  _CardConfig _getCardConfig() {
    switch (style) {
      case DuoCardStyle.normal:
        return _CardConfig(
          backgroundColor: AppColors.surface,
          borderColor: AppColors.border,
          shadowColor: AppColors.shadowGray,
          borderWidth: 2,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          hasShadow: true,
        );

      case DuoCardStyle.primary:
        return _CardConfig(
          backgroundColor: AppColors.primarySurface,
          borderColor: AppColors.primary,
          shadowColor: AppColors.shadowPrimary,
          borderWidth: 2,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          hasShadow: true,
        );

      case DuoCardStyle.secondary:
        return _CardConfig(
          backgroundColor: AppColors.secondarySurface,
          borderColor: AppColors.secondary,
          shadowColor: AppColors.shadowSecondary,
          borderWidth: 2,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          hasShadow: true,
        );

      case DuoCardStyle.success:
        return _CardConfig(
          backgroundColor: AppColors.successSurface,
          borderColor: AppColors.success,
          shadowColor: AppColors.shadowPrimary,
          borderWidth: 2,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          hasShadow: true,
        );

      case DuoCardStyle.warning:
        return _CardConfig(
          backgroundColor: AppColors.warningSurface,
          borderColor: AppColors.warning,
          shadowColor: AppColors.shadowTertiary,
          borderWidth: 2,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          hasShadow: true,
        );

      case DuoCardStyle.error:
        return _CardConfig(
          backgroundColor: AppColors.errorSurface,
          borderColor: AppColors.error,
          shadowColor: AppColors.shadowError,
          borderWidth: 2,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          hasShadow: true,
        );

      case DuoCardStyle.flat:
        return _CardConfig(
          backgroundColor: AppColors.surface,
          borderColor: AppColors.border,
          shadowColor: Colors.transparent,
          borderWidth: 2,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          hasShadow: false,
        );

      case DuoCardStyle.gradient:
        return _CardConfig(
          backgroundColor: AppColors.primary,
          borderColor: AppColors.primary,
          shadowColor: AppColors.shadowPrimary,
          borderWidth: 0,
          borderRadius: 16,
          padding: const EdgeInsets.all(20),
          hasShadow: true,
        );
    }
  }
}

class _CardConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final double borderWidth;
  final double borderRadius;
  final EdgeInsets padding;
  final bool hasShadow;

  _CardConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.shadowColor,
    required this.borderWidth,
    required this.borderRadius,
    required this.padding,
    required this.hasShadow,
  });
}

/// Estilos de tarjeta disponibles
enum DuoCardStyle {
  normal,
  primary,
  secondary,
  success,
  warning,
  error,
  flat,
  gradient,
}
