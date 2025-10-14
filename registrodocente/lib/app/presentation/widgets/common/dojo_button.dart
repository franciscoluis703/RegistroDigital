import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../themes/app_colors.dart';

/// 🎨 DojoButton - Botón personalizado estilo ClassDojo
///
/// Botón vibrante y amigable con esquinas redondeadas,
/// sombras suaves y efectos hover/press.
class DojoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final DojoButtonStyle style;
  final DojoButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const DojoButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = DojoButtonStyle.primary,
    this.size = DojoButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  State<DojoButton> createState() => _DojoButtonState();
}

class _DojoButtonState extends State<DojoButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _handleTapCancel();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final buttonConfig = _getButtonConfig();

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.isFullWidth ? double.infinity : null,
          height: buttonConfig.height,
          padding: buttonConfig.padding,
          decoration: BoxDecoration(
            gradient: widget.onPressed == null || widget.isLoading
                ? null
                : buttonConfig.gradient,
            color: widget.onPressed == null || widget.isLoading
                ? buttonConfig.disabledColor
                : (buttonConfig.gradient == null
                    ? buttonConfig.backgroundColor
                    : null),
            borderRadius: BorderRadius.circular(buttonConfig.borderRadius),
            border: buttonConfig.border,
            boxShadow: widget.onPressed == null || widget.isLoading
                ? null
                : [
                    BoxShadow(
                      color: buttonConfig.shadowColor,
                      blurRadius: _isPressed ? 8 : 12,
                      offset: Offset(0, _isPressed ? 2 : 4),
                    ),
                  ],
          ),
          child: widget.isLoading
              ? Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        buttonConfig.textColor,
                      ),
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: buttonConfig.textColor,
                        size: buttonConfig.iconSize,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: GoogleFonts.nunito(
                        fontSize: buttonConfig.fontSize,
                        fontWeight: FontWeight.w700,
                        color: buttonConfig.textColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  _ButtonConfig _getButtonConfig() {
    switch (widget.style) {
      case DojoButtonStyle.primary:
        return _ButtonConfig(
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
          height: widget.size.height,
          padding: widget.size.padding,
          fontSize: widget.size.fontSize,
          iconSize: widget.size.iconSize,
          borderRadius: 28,
          gradient: AppColors.primaryGradient,
        );

      case DojoButtonStyle.secondary:
        return _ButtonConfig(
          backgroundColor: AppColors.secondary,
          textColor: Colors.white,
          shadowColor: AppColors.secondary.withValues(alpha: 0.4),
          height: widget.size.height,
          padding: widget.size.padding,
          fontSize: widget.size.fontSize,
          iconSize: widget.size.iconSize,
          borderRadius: 28,
          gradient: AppColors.secondaryGradient,
        );

      case DojoButtonStyle.success:
        return _ButtonConfig(
          backgroundColor: AppColors.success,
          textColor: Colors.white,
          shadowColor: AppColors.success.withValues(alpha: 0.4),
          height: widget.size.height,
          padding: widget.size.padding,
          fontSize: widget.size.fontSize,
          iconSize: widget.size.iconSize,
          borderRadius: 28,
          gradient: AppColors.successGradient,
        );

      case DojoButtonStyle.warning:
        return _ButtonConfig(
          backgroundColor: AppColors.warning,
          textColor: Colors.white,
          shadowColor: AppColors.warning.withValues(alpha: 0.4),
          height: widget.size.height,
          padding: widget.size.padding,
          fontSize: widget.size.fontSize,
          iconSize: widget.size.iconSize,
          borderRadius: 28,
          gradient: const LinearGradient(
            colors: [Color(0xFFFFAB40), Color(0xFFFFCC80)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        );

      case DojoButtonStyle.outlined:
        return _ButtonConfig(
          backgroundColor: Colors.transparent,
          textColor: AppColors.primary,
          shadowColor: Colors.transparent,
          height: widget.size.height,
          padding: widget.size.padding,
          fontSize: widget.size.fontSize,
          iconSize: widget.size.iconSize,
          borderRadius: 28,
          border: Border.all(color: AppColors.primary, width: 2.5),
        );

      case DojoButtonStyle.text:
        return _ButtonConfig(
          backgroundColor: Colors.transparent,
          textColor: AppColors.primary,
          shadowColor: Colors.transparent,
          height: widget.size.height,
          padding: widget.size.padding,
          fontSize: widget.size.fontSize,
          iconSize: widget.size.iconSize,
          borderRadius: 16,
        );
    }
  }
}

class _ButtonConfig {
  final Color backgroundColor;
  final Color textColor;
  final Color shadowColor;
  final Color? disabledColor;
  final double height;
  final EdgeInsets padding;
  final double fontSize;
  final double iconSize;
  final double borderRadius;
  final LinearGradient? gradient;
  final Border? border;

  _ButtonConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.shadowColor,
    this.disabledColor,
    required this.height,
    required this.padding,
    required this.fontSize,
    required this.iconSize,
    required this.borderRadius,
    this.gradient,
    this.border,
  });
}

/// Estilos de botón disponibles
enum DojoButtonStyle {
  primary,
  secondary,
  success,
  warning,
  outlined,
  text,
}

/// Tamaños de botón disponibles
enum DojoButtonSize {
  small,
  medium,
  large;

  double get height {
    switch (this) {
      case DojoButtonSize.small:
        return 40;
      case DojoButtonSize.medium:
        return 54;
      case DojoButtonSize.large:
        return 64;
    }
  }

  EdgeInsets get padding {
    switch (this) {
      case DojoButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 10);
      case DojoButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
      case DojoButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 40, vertical: 20);
    }
  }

  double get fontSize {
    switch (this) {
      case DojoButtonSize.small:
        return 14;
      case DojoButtonSize.medium:
        return 17;
      case DojoButtonSize.large:
        return 19;
    }
  }

  double get iconSize {
    switch (this) {
      case DojoButtonSize.small:
        return 18;
      case DojoButtonSize.medium:
        return 22;
      case DojoButtonSize.large:
        return 26;
    }
  }
}
