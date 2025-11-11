import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    this.onPressed, // Mude para nullable
    required this.label,
    this.buttonColor,
    this.textButtonColor,
    this.fontSize,
    this.textStyle,
    this.padding,
    this.widthFactor = 0.9,
    this.minWidth,
    this.borderRadiusValue,
    this.icon, // Novo parâmetro para o ícone
    this.borderSide, // Novo parâmetro para a borda
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
  final double? borderRadiusValue;
  final Widget? icon; // Ícone opcional no final
  final BorderSide? borderSide; // Borda opcional

  static const Color defaultColor = Color(0xFF8692DE);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
            borderRadius: BorderRadius.circular(borderRadiusValue ?? 50),
            side: borderSide ?? BorderSide.none, // Padrão sem borda
          ),
          elevation: 0, // Remove sombra padrão do ElevatedButton
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
