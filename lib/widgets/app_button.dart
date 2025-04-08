import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.buttonColor,
    this.textButtonColor,
    this.fontSize,
    this.textStyle,
    this.padding,
    this.widthFactor = 0.9,
    this.minWidth
  });

  final VoidCallback onPressed;
  final String label;
  final Color? buttonColor;
  final Color? textButtonColor;
  final TextStyle? textStyle;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final double widthFactor;
  final double? minWidth;

  static const Color defaultColor = Color(0xFF8692DE);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: screenWidth * widthFactor,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor ?? defaultColor,
          foregroundColor: textButtonColor ?? Colors.white,
          padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: textStyle ??
              TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
