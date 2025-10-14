import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../themes/app_colors.dart';

/// 🦉 DuoButton - Botón estilo Duolingo
///
/// Botón con bordes redondeados, sombra inferior pronunciada
/// y diseño limpio característico de Duolingo.
class DuoButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final DuoButtonStyle style;
  final DuoButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;

  const DuoButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = DuoButtonStyle.primary,
    this.size = DuoButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final buttonConfig = _getButtonConfig();
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.isFullWidth ? double.infinity : null,
        height: buttonConfig.height,
        padding: buttonConfig.padding,
        decoration: BoxDecoration(
          color: isDisabled
              ? AppColors.border
              : buttonConfig.backgroundColor,
          borderRadius: BorderRadius.circular(buttonConfig.borderRadius),
          border: buttonConfig.border,
          // Sombra inferior pronunciada estilo Duolingo
          boxShadow: isDisabled
              ? null
              : [
                  BoxShadow(
                    color: buttonConfig.shadowColor,
                    offset: Offset(0, _isPressed ? 2 : 4),
                    blurRadius: 0,
                  ),
                ],
        ),
        // Efecto de presión: mueve el botón hacia abajo
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
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
                      color: isDisabled
                          ? AppColors.textDisabled
                          : buttonConfig.textColor,
                      size: buttonConfig.iconSize,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: GoogleFonts.nunito(
                      fontSize: buttonConfig.fontSize,
                      fontWeight: FontWeight.w700,
                      color: isDisabled
                          ? AppColors.textDisabled
                          : buttonConfig.textColor,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  _ButtonConfig _getButtonConfig() {
    switch (widget.style) {
      case DuoButtonStyle.primary:
        return _ButtonConfig(
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          shadowColor: AppColors.shadowPrimary,
          height: widget.size.height,
          padding: widget.size.padding,
          fontSize: widget.size.fontSize,
          iconSize: widget.size.iconSize,
          borderRadius: 16,
        );

      case DuoButtonStyle.secondary:
        return _ButtonConfig(
          backgroundColor: AppColors.secondary,
          textColor: Colors.white,
          shadowColor: AppColors.shadowSecondary,
          height: widget.size.height,
          padding: widget.size.padding,
          fontSize: widget.size.fontSize,
          iconSize: widget.size.iconSize,
          borderRadius: 16,
        );

      case DuoButtonStyle.success:
        return _ButtonConfig(
          backgroundColor: AppColors.success,
          textColor: Colors.white,
          shadowColor: AppColors.shadowPrimary,
          height: widget.size.height,
          padding: widget.size.padding,
          fontSize: widget.size.fontSize,
          iconSize: widget.size.iconSize,
          borderRadius: 16,
        );

      case DuoButtonStyle.warning:
        return _ButtonConfig(
          backgroundColor: AppColors.warning,
          textColor: Colors.white,
          shadowColor: AppColors.shadowTertiary,
          height: widget.size.height,
          padding: widget.size.padding,
          fontSize: widget.size.fontSize,
          iconSize: widget.size.iconSize,
          borderRadius: 16,
        );

      case DuoButtonStyle.error:
        return _ButtonConfig(
          backgroundColor: AppColors.error,
          textColor: Colors.white,
          shadowColor: AppColors.shadowError,
          height: widget.size.height,
          padding: widget.size.padding,
          fontSize: widget.size.fontSize,
          iconSize: widget.size.iconSize,
          borderRadius: 16,
        );

      case DuoButtonStyle.outlined:
        return _ButtonConfig(
          backgroundColor: Colors.white,
          textColor: AppColors.primary,
          shadowColor: AppColors.shadowGray,
          height: widget.size.height,
          padding: widget.size.padding,
          fontSize: widget.size.fontSize,
          iconSize: widget.size.iconSize,
          borderRadius: 16,
          border: Border.all(color: AppColors.border, width: 2),
        );

      case DuoButtonStyle.text:
        return _ButtonConfig(
          backgroundColor: Colors.transparent,
          textColor: AppColors.secondary,
          shadowColor: Colors.transparent,
          height: widget.size.height,
          padding: widget.size.padding,
          fontSize: widget.size.fontSize,
          iconSize: widget.size.iconSize,
          borderRadius: 12,
        );
    }
  }
}

class _ButtonConfig {
  final Color backgroundColor;
  final Color textColor;
  final Color shadowColor;
  final double height;
  final EdgeInsets padding;
  final double fontSize;
  final double iconSize;
  final double borderRadius;
  final Border? border;

  _ButtonConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.shadowColor,
    required this.height,
    required this.padding,
    required this.fontSize,
    required this.iconSize,
    required this.borderRadius,
    this.border,
  });
}

/// Estilos de botón disponibles
enum DuoButtonStyle {
  primary,
  secondary,
  success,
  warning,
  error,
  outlined,
  text,
}

/// Tamaños de botón disponibles
enum DuoButtonSize {
  small,
  medium,
  large;

  double get height {
    switch (this) {
      case DuoButtonSize.small:
        return 44;
      case DuoButtonSize.medium:
        return 50;
      case DuoButtonSize.large:
        return 58;
    }
  }

  EdgeInsets get padding {
    switch (this) {
      case DuoButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case DuoButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
      case DuoButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
  }

  double get fontSize {
    switch (this) {
      case DuoButtonSize.small:
        return 15;
      case DuoButtonSize.medium:
        return 17;
      case DuoButtonSize.large:
        return 19;
    }
  }

  double get iconSize {
    switch (this) {
      case DuoButtonSize.small:
        return 20;
      case DuoButtonSize.medium:
        return 22;
      case DuoButtonSize.large:
        return 24;
    }
  }
}
