import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

/// Card educativo reutilizable con diseño consistente
class EducationalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final bool isActive;
  final bool isDisabled;

  const EducationalCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.isActive = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      onLongPress: isDisabled ? null : onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.surfaceVariant
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isActive
              ? Border.all(color: AppColors.secondary, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: isActive
                  ? AppColors.secondary.withValues(alpha: 0.2)
                  : AppColors.textPrimary.withValues(alpha: 0.08),
              blurRadius: isActive ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDisabled
                          ? AppColors.textDisabled
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDisabled
                            ? AppColors.textDisabled
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Trailing
            if (trailing != null) trailing!,
            if (trailing == null && onTap != null)
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
