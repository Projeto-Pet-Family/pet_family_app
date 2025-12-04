import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.onPressed,
    required this.label,
    this.buttonColor,
    this.textButtonColor,
    this.fontSize,
    this.textStyle,
    this.padding,
    this.widthFactor = 0.9,
    this.minWidth,
    this.borderRadiusValue,
    this.borderRadius,
    this.icon,
    this.borderSide,
  });

  final VoidCallback? onPressed;
  final String label;
  final Color? buttonColor;
  final Color? textButtonColor;
  final TextStyle? textStyle;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final double? widthFactor; // Alterado para nullable
  final double? minWidth;
  final double? borderRadiusValue;
  final BorderRadius? borderRadius;
  final Widget? icon;
  final BorderSide? borderSide;

  static const Color defaultColor = Color(0xFF8692DE);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Lógica para determinar o borderRadius final
    final BorderRadius finalBorderRadius = borderRadius ??
        (borderRadiusValue != null
            ? BorderRadius.circular(borderRadiusValue!)
            : BorderRadius.circular(50));

    // Se widthFactor for null, usa o tamanho natural do botão
    if (widthFactor == null) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null
              ? Colors.grey
              : buttonColor ?? defaultColor,
          foregroundColor: textButtonColor ?? Colors.white,
          padding: padding ??
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: finalBorderRadius,
            side: borderSide ?? BorderSide.none,
          ),
          elevation: 0,
          minimumSize: minWidth != null ? Size(minWidth!, 0) : null,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min, // Importante para largura mínima
          mainAxisAlignment: icon != null
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: textStyle ??
                  TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (icon != null) icon!,
          ],
        ),
      );
    }

    // Se widthFactor não for null, usa a largura proporcional
    return SizedBox(
      width: screenWidth * widthFactor!,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null
              ? Colors.grey
              : buttonColor ?? defaultColor,
          foregroundColor: textButtonColor ?? Colors.white,
          padding: padding ??
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: finalBorderRadius,
            side: borderSide ?? BorderSide.none,
          ),
          elevation: 0,
          minimumSize: minWidth != null ? Size(minWidth!, 0) : null,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: icon != null
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: textStyle ??
                  TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (icon != null) icon!,
          ],
        ),
      ),
    );
  }
}