import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../themes/app_colors.dart';

/// 🎨 DojoBadge - Badge/Insignia decorativa estilo ClassDojo
///
/// Pequeñas etiquetas coloridas para estados, categorías o números.
class DojoBadge extends StatelessWidget {
  final String text;
  final DojoBadgeStyle style;
  final DojoBadgeSize size;
  final IconData? icon;

  const DojoBadge({
    super.key,
    required this.text,
    this.style = DojoBadgeStyle.primary,
    this.size = DojoBadgeSize.medium,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Container(
      padding: config.padding,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(config.borderRadius),
        border: config.border,
        boxShadow: [
          BoxShadow(
            color: config.shadowColor,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: config.iconSize,
              color: config.textColor,
            ),
            SizedBox(width: config.spacing),
          ],
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: config.fontSize,
              fontWeight: FontWeight.w800,
              color: config.textColor,
              letterSpacing: 0.5,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _getConfig() {
    switch (style) {
      case DojoBadgeStyle.primary:
        return _BadgeConfig(
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          borderRadius: size.borderRadius,
          padding: size.padding,
          fontSize: size.fontSize,
          iconSize: size.iconSize,
          spacing: size.spacing,
        );

      case DojoBadgeStyle.secondary:
        return _BadgeConfig(
          backgroundColor: AppColors.secondary,
          textColor: Colors.white,
          shadowColor: AppColors.secondary.withValues(alpha: 0.3),
          borderRadius: size.borderRadius,
          padding: size.padding,
          fontSize: size.fontSize,
          iconSize: size.iconSize,
          spacing: size.spacing,
        );

      case DojoBadgeStyle.success:
        return _BadgeConfig(
          backgroundColor: AppColors.success,
          textColor: Colors.white,
          shadowColor: AppColors.success.withValues(alpha: 0.3),
          borderRadius: size.borderRadius,
          padding: size.padding,
          fontSize: size.fontSize,
          iconSize: size.iconSize,
          spacing: size.spacing,
        );

      case DojoBadgeStyle.warning:
        return _BadgeConfig(
          backgroundColor: AppColors.warning,
          textColor: Colors.white,
          shadowColor: AppColors.warning.withValues(alpha: 0.3),
          borderRadius: size.borderRadius,
          padding: size.padding,
          fontSize: size.fontSize,
          iconSize: size.iconSize,
          spacing: size.spacing,
        );

      case DojoBadgeStyle.error:
        return _BadgeConfig(
          backgroundColor: AppColors.error,
          textColor: Colors.white,
          shadowColor: AppColors.error.withValues(alpha: 0.3),
          borderRadius: size.borderRadius,
          padding: size.padding,
          fontSize: size.fontSize,
          iconSize: size.iconSize,
          spacing: size.spacing,
        );

      case DojoBadgeStyle.info:
        return _BadgeConfig(
          backgroundColor: AppColors.info,
          textColor: Colors.white,
          shadowColor: AppColors.info.withValues(alpha: 0.3),
          borderRadius: size.borderRadius,
          padding: size.padding,
          fontSize: size.fontSize,
          iconSize: size.iconSize,
          spacing: size.spacing,
        );

      case DojoBadgeStyle.primaryLight:
        return _BadgeConfig(
          backgroundColor: AppColors.primarySurface,
          textColor: AppColors.primary,
          shadowColor: Colors.transparent,
          borderRadius: size.borderRadius,
          padding: size.padding,
          fontSize: size.fontSize,
          iconSize: size.iconSize,
          spacing: size.spacing,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
        );

      case DojoBadgeStyle.secondaryLight:
        return _BadgeConfig(
          backgroundColor: AppColors.secondarySurface,
          textColor: AppColors.secondary,
          shadowColor: Colors.transparent,
          borderRadius: size.borderRadius,
          padding: size.padding,
          fontSize: size.fontSize,
          iconSize: size.iconSize,
          spacing: size.spacing,
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3), width: 1.5),
        );

      case DojoBadgeStyle.outlined:
        return _BadgeConfig(
          backgroundColor: Colors.transparent,
          textColor: AppColors.textPrimary,
          shadowColor: Colors.transparent,
          borderRadius: size.borderRadius,
          padding: size.padding,
          fontSize: size.fontSize,
          iconSize: size.iconSize,
          spacing: size.spacing,
          border: Border.all(color: AppColors.divider, width: 2),
        );
    }
  }
}

class _BadgeConfig {
  final Color backgroundColor;
  final Color textColor;
  final Color shadowColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double fontSize;
  final double iconSize;
  final double spacing;
  final Border? border;

  _BadgeConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.shadowColor,
    required this.borderRadius,
    required this.padding,
    required this.fontSize,
    required this.iconSize,
    required this.spacing,
    this.border,
  });
}

/// Estilos de badge disponibles
enum DojoBadgeStyle {
  primary,
  secondary,
  success,
  warning,
  error,
  info,
  primaryLight,
  secondaryLight,
  outlined,
}

/// Tamaños de badge disponibles
enum DojoBadgeSize {
  small,
  medium,
  large;

  double get borderRadius {
    switch (this) {
      case DojoBadgeSize.small:
        return 8;
      case DojoBadgeSize.medium:
        return 12;
      case DojoBadgeSize.large:
        return 16;
    }
  }

  EdgeInsets get padding {
    switch (this) {
      case DojoBadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case DojoBadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case DojoBadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  double get fontSize {
    switch (this) {
      case DojoBadgeSize.small:
        return 11;
      case DojoBadgeSize.medium:
        return 13;
      case DojoBadgeSize.large:
        return 15;
    }
  }

  double get iconSize {
    switch (this) {
      case DojoBadgeSize.small:
        return 14;
      case DojoBadgeSize.medium:
        return 16;
      case DojoBadgeSize.large:
        return 18;
    }
  }

  double get spacing {
    switch (this) {
      case DojoBadgeSize.small:
        return 4;
      case DojoBadgeSize.medium:
        return 6;
      case DojoBadgeSize.large:
        return 8;
    }
  }
}
