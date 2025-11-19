import 'package:flutter/material.dart';
import '../theme/widgets/theme_extensions.dart';

/// Custom Button dengan styling konsisten
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    final button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: textColor ?? context.primaryColor,
              padding: padding ??
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              minimumSize: Size(width ?? 0, height ?? 48),
            ),
            child: buttonChild,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? context.primaryColor,
              foregroundColor: textColor ?? Colors.white,
              padding: padding ??
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              minimumSize: Size(width ?? 0, height ?? 48),
            ),
            child: buttonChild,
          );

    return SizedBox(
      width: width,
      height: height,
      child: button,
    );
  }
}
