/* import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/providers/auth_provider.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';

class TypingNewPassword extends StatefulWidget {
  final String token;

  const TypingNewPassword({
    super.key,
    required this.token,
  });

  @override
  State<TypingNewPassword> createState() => _TypingNewPasswordState();
}

class _TypingNewPasswordState extends State<TypingNewPassword> {
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _senhaRedefinida = false;

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
                'Nova senha',
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
          if (!_senhaRedefinida) ...[
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Campo Nova Senha
                  AppTextField(
                    controller: _novaSenhaController,
                    labelText: 'Nova Senha',
                    hintText: 'Digite sua nova senha',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, digite a nova senha';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),

                  // Campo Confirmar Senha
                  AppTextField(
                    controller: _confirmarSenhaController,
                    labelText: 'Confirmar Senha',
                    hintText: 'Digite novamente sua nova senha',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, confirme sua senha';
                      }
                      if (value != _novaSenhaController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
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
                    label: 'Redefinir Senha',
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final success = await authProvider.redefinirSenha(
                          widget.token,
                          _novaSenhaController.text,
                        );

                        if (success) {
                          setState(() {
                            _senhaRedefinida = true;
                          });

                          // Limpa o erro se existir
                          authProvider.clearError();
                        }
                      }
                    },
                  ),
          ] else ...[
            // ✅ Tela de sucesso
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            SizedBox(height: 20),
            Text(
              'Senha redefinida com sucesso!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Sua senha foi alterada com sucesso.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            AppButton(
              label: 'Fazer Login',
              onPressed: () {
                // Fecha todos os modals e vai para o login
                Navigator.pop(context); // Fecha este modal
                Navigator.pop(context); // Fecha a tela de inserir token
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              },
            ),
          ],
          SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }
}
 */