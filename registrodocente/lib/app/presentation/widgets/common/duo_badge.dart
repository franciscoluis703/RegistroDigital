import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../themes/app_colors.dart';

/// 🦉 DuoBadge - Insignia estilo Duolingo
///
/// Badge pequeño y colorido para etiquetar información.
class DuoBadge extends StatelessWidget {
  final String text;
  final DuoBadgeStyle style;
  final IconData? icon;

  const DuoBadge({
    super.key,
    required this.text,
    this.style = DuoBadgeStyle.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getBadgeConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: config.borderColor,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: config.textColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _getBadgeConfig() {
    switch (style) {
      case DuoBadgeStyle.primary:
        return _BadgeConfig(
          backgroundColor: AppColors.primarySurface,
          borderColor: AppColors.primary,
          textColor: AppColors.primary,
        );

      case DuoBadgeStyle.secondary:
        return _BadgeConfig(
          backgroundColor: AppColors.secondarySurface,
          borderColor: AppColors.secondary,
          textColor: AppColors.secondary,
        );

      case DuoBadgeStyle.success:
        return _BadgeConfig(
          backgroundColor: AppColors.successSurface,
          borderColor: AppColors.success,
          textColor: AppColors.success,
        );

      case DuoBadgeStyle.warning:
        return _BadgeConfig(
          backgroundColor: AppColors.warningSurface,
          borderColor: AppColors.warning,
          textColor: AppColors.warning,
        );

      case DuoBadgeStyle.error:
        return _BadgeConfig(
          backgroundColor: AppColors.errorSurface,
          borderColor: AppColors.error,
          textColor: AppColors.error,
        );

      case DuoBadgeStyle.info:
        return _BadgeConfig(
          backgroundColor: AppColors.infoSurface,
          borderColor: AppColors.info,
          textColor: AppColors.info,
        );

      case DuoBadgeStyle.neutral:
        return _BadgeConfig(
          backgroundColor: AppColors.surfaceVariant,
          borderColor: AppColors.border,
          textColor: AppColors.textSecondary,
        );
    }
  }
}

class _BadgeConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  _BadgeConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}

/// Estilos de badge disponibles
enum DuoBadgeStyle {
  primary,
  secondary,
  success,
  warning,
  error,
  info,
  neutral,
}
