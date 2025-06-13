import 'package:flutter/material.dart';


enum ButtonSize { small, medium, large }

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final ButtonType type;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isDisabled;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.type = ButtonType.primary,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine padding based on size
    EdgeInsets padding;
    double height;
    TextStyle textStyle;
    double iconSize;

    switch (size) {
      case ButtonSize.small:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        height = 36;
        textStyle = Theme.of(context).textTheme.labelSmall ?? const TextStyle(fontSize: 12);
        iconSize = 16;
        break;
      case ButtonSize.large:
        padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
        height = 56;
        textStyle = Theme.of(context).textTheme.labelLarge ?? const TextStyle(fontSize: 18);
        iconSize = 24;
        break;
      case ButtonSize.medium:
      default:
        padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
        height = 48;
        textStyle = Theme.of(context).textTheme.labelMedium ?? const TextStyle(fontSize: 16);
        iconSize = 20;
        break;
    }

    // Determine colors based on type
    final colorScheme = Theme.of(context).colorScheme;
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    switch (type) {
      case ButtonType.secondary:
        backgroundColor = colorScheme.secondary;
        textColor = colorScheme.onSecondary;
        borderColor = colorScheme.secondary;
        break;
      case ButtonType.outline:
        backgroundColor = Colors.transparent;
        textColor = colorScheme.primary;
        borderColor = colorScheme.primary;
        break;
      case ButtonType.text:
        backgroundColor = Colors.transparent;
        textColor = colorScheme.primary;
        borderColor = Colors.transparent;
        break;
      case ButtonType.primary:
      default:
        backgroundColor = colorScheme.primary;
        textColor = colorScheme.onPrimary;
        borderColor = colorScheme.primary;
        break;
    }

    // Apply disabled state
    if (isDisabled) {
      backgroundColor =
          type == ButtonType.text || type == ButtonType.outline
              ? Colors.transparent
              : colorScheme.surface.withOpacity(0.4);
      textColor = colorScheme.onSurface.withOpacity(0.5);
      borderColor =
          type == ButtonType.outline ? colorScheme.surface.withOpacity(0.4) : borderColor;
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: (isDisabled || isLoading) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: borderColor,
              width: type == ButtonType.outline ? 1.5 : 0,
            ),
          ),
          elevation:
              type == ButtonType.text || type == ButtonType.outline ? 0 : 2,
          shadowColor:
              type == ButtonType.text || type == ButtonType.outline
                  ? Colors.transparent
                  : colorScheme.shadow,
        ),
        child:
            isLoading
                ? SizedBox(
                  width: iconSize,
                  height: iconSize,
                  child: CircularProgressIndicator(
                    color: textColor,
                    strokeWidth: 2,
                  ),
                )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (leadingIcon != null) ...[
                      Icon(leadingIcon, size: iconSize, color: textColor),
                      const SizedBox(width: 8),
                    ],
                    Text(text, style: textStyle.copyWith(color: textColor)),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 8),
                      Icon(trailingIcon, size: iconSize, color: textColor),
                    ],
                  ],
                ),
      ),
    );
  }
}
