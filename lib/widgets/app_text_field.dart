import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.labelText,
    this.hintText,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.obscureText = false, // oculta o texto digitado
    this.isPasswordField = false, //visibilidade de senha
  });

  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool obscureText; //oculta o texto digitado
  final bool isPasswordField; //visibilidade de senha

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
 late bool _obscureText; 

 @override
 void initState() {
  super.initState();
  _obscureText = widget.obscureText; // Inicializa o estado do texto oculto
 }
   //Função que alterna a visibilidade da senha
  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(widget.labelText!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
            ),
          ),
        if (widget.labelText != null) const SizedBox(height: 4),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: Color(0xFFCCCCCC),
              fontSize: 16,
              fontWeight: FontWeight.w200,
              
            ),
          
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(
                color: Color(0xFFCCCCCC),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(
                color: Color(0xFFCCCCCC),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(
                color: Color(0xFFDDDDDD),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
              // Adiciona botão de visibilidade se for campo de senha
            suffixIcon: widget.isPasswordField
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility, // alterna o ícone
                      color: Colors.grey,
                    ),
                    onPressed: _toggleVisibility, // alterna o estado ao clicar
                  )
                : null, 
          ),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          cursorColor: const Color(0xFF8692DE),
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
        ),
      ],
    );
  }
}