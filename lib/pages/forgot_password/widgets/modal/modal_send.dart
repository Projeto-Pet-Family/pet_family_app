/* import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/providers/auth_provider.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';

class ModalSend extends StatefulWidget {
  final Icon iconTitle;
  final String textTitle;
  final String label;
  final String hint;

  const ModalSend({
    super.key,
    required this.iconTitle,
    required this.textTitle,
    required this.label,
    required this.hint,
  });

  @override
  State<ModalSend> createState() => _ModalSendState();
}

class _ModalSendState extends State<ModalSend> {
  final TextEditingController _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recuperar senha',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF000000),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(height: 20),
          widget.iconTitle,
          SizedBox(height: 16),
          Text(
            widget.textTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w100,
              color: Color(0xFF000000),
            ),
          ),
          SizedBox(height: 20),
          Form(
            key: _formKey,
            child: AppTextField(
              controller: _controller,
              labelText: widget.label,
              hintText: widget.hint,
              keyboardType: widget.label == 'E-mail'
                  ? TextInputType.emailAddress
                  : TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, digite seu ${widget.label.toLowerCase()}';
                }
                if (widget.label == 'E-mail' && !value.contains('@')) {
                  return 'Digite um email válido';
                }
                return null;
              },
            ),
          ),
          SizedBox(height: 10),
          if (authProvider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                authProvider.errorMessage!,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          authProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : AppButton(
                  label: 'Enviar token',
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // ✅ Implementação para email
                      if (widget.label == 'E-mail') {
                        final success =
                            await authProvider.solicitarRecuperacaoSenha(
                          _controller.text.trim(),
                        );

                        if (success) {
                          // Fecha o modal e navega para inserir token
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/insert-token');

                          // Mostrar mensagem de sucesso
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Token enviado com sucesso! Verifique o console do backend.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } else {
                        // ✅ Para telefone (implementação futura)
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Recuperação por SMS ainda não disponível'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      }
                    }
                  },
                ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
 */