import 'package:flutter/material.dart';
import '../../themes/app_colors.dart';

/// 🎨 DojoCard - Card personalizado estilo ClassDojo
///
/// Tarjeta con esquinas muy redondeadas, sombras suaves
/// y efectos de hover para una experiencia amigable.
class DojoCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final DojoCardStyle style;
  final bool enableHoverEffect;

  const DojoCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
    this.style = DojoCardStyle.normal,
    this.enableHoverEffect = true,
  });

  @override
  State<DojoCard> createState() => _DojoCardState();
}

class _DojoCardState extends State<DojoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 3,
      end: (widget.elevation ?? 3) + 4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleHover(bool isHovered) {
    if (!widget.enableHoverEffect || widget.onTap == null) return;

    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardConfig = _getCardConfig();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: MouseRegion(
        onEnter: (_) => _handleHover(true),
        onExit: (_) => _handleHover(false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: widget.padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: widget.color ?? cardConfig.backgroundColor,
              borderRadius: BorderRadius.circular(cardConfig.borderRadius),
              border: cardConfig.border,
              gradient: cardConfig.gradient,
              boxShadow: [
                BoxShadow(
                  color: cardConfig.shadowColor,
                  blurRadius: _isHovered ? _elevationAnimation.value * 2 : _elevationAnimation.value * 1.5,
                  offset: Offset(0, _isHovered ? 6 : 4),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  _CardConfig _getCardConfig() {
    switch (widget.style) {
      case DojoCardStyle.normal:
        return _CardConfig(
          backgroundColor: AppColors.surface,
          shadowColor: AppColors.textPrimary.withValues(alpha: 0.08),
          borderRadius: 20,
        );

      case DojoCardStyle.primary:
        return _CardConfig(
          backgroundColor: AppColors.primarySurface,
          shadowColor: AppColors.primary.withValues(alpha: 0.15),
          borderRadius: 20,
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
        );

      case DojoCardStyle.secondary:
        return _CardConfig(
          backgroundColor: AppColors.secondarySurface,
          shadowColor: AppColors.secondary.withValues(alpha: 0.15),
          borderRadius: 20,
          border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2), width: 2),
        );

      case DojoCardStyle.success:
        return _CardConfig(
          backgroundColor: AppColors.successSurface,
          shadowColor: AppColors.success.withValues(alpha: 0.15),
          borderRadius: 20,
          border: Border.all(color: AppColors.success.withValues(alpha: 0.2), width: 2),
        );

      case DojoCardStyle.warning:
        return _CardConfig(
          backgroundColor: AppColors.warningSurface,
          shadowColor: AppColors.warning.withValues(alpha: 0.15),
          borderRadius: 20,
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.2), width: 2),
        );

      case DojoCardStyle.error:
        return _CardConfig(
          backgroundColor: AppColors.errorSurface,
          shadowColor: AppColors.error.withValues(alpha: 0.15),
          borderRadius: 20,
          border: Border.all(color: AppColors.error.withValues(alpha: 0.2), width: 2),
        );

      case DojoCardStyle.gradient:
        return _CardConfig(
          backgroundColor: Colors.transparent,
          shadowColor: AppColors.primary.withValues(alpha: 0.2),
          borderRadius: 20,
          gradient: AppColors.primaryGradient,
        );

      case DojoCardStyle.celebration:
        return _CardConfig(
          backgroundColor: Colors.transparent,
          shadowColor: AppColors.pink.withValues(alpha: 0.2),
          borderRadius: 20,
          gradient: AppColors.premiumGradient,
        );
    }
  }
}

class _CardConfig {
  final Color backgroundColor;
  final Color shadowColor;
  final double borderRadius;
  final Border? border;
  final LinearGradient? gradient;

  _CardConfig({
    required this.backgroundColor,
    required this.shadowColor,
    required this.borderRadius,
    this.border,
    this.gradient,
  });
}

/// Estilos de card disponibles
enum DojoCardStyle {
  normal,
  primary,
  secondary,
  success,
  warning,
  error,
  gradient,
  celebration,
}
