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

  final VoidCallback? onPressed; // Agora pode ser nulo
  final String label;
  final Color? buttonColor;
  final Color? textButtonColor;
  final TextStyle? textStyle;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final double widthFactor;
  final double? minWidth;
  final double? borderRadiusValue; // Mantido para compatibilidade
  final BorderRadius? borderRadius; // Novo parâmetro para controle detalhado
  final Widget? icon; // Ícone opcional no final
  final BorderSide? borderSide; // Borda opcional

  static const Color defaultColor = Color(0xFF8692DE);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Lógica para determinar o borderRadius final
    final BorderRadius finalBorderRadius = borderRadius ??
        (borderRadiusValue != null
            ? BorderRadius.circular(borderRadiusValue!)
            : BorderRadius.circular(50));

    return SizedBox(
      width: screenWidth * widthFactor,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null
              ? Colors.grey // Cor quando desabilitado
              : buttonColor ?? defaultColor,
          foregroundColor: textButtonColor ?? Colors.white,
          padding: padding ??
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: finalBorderRadius,
            side: borderSide ?? BorderSide.none, // Padrão sem borda
          ),
          elevation: 0, // Remove sombra padrão do ElevatedButton
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: icon != null
              ? MainAxisAlignment
                  .spaceBetween // SpaceBetween apenas se tiver ícone
              : MainAxisAlignment.center, // Centro se não tiver ícone
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
