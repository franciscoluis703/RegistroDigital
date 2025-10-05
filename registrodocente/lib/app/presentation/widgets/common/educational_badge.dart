import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

/// Badge educativo con iconos y colores temáticos
class EducationalBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool isSmall;

  const EducationalBadge({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppColors.primary;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: Colors.white,
              size: isSmall ? 12 : 14,
            ),
            SizedBox(width: isSmall ? 4 : 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
