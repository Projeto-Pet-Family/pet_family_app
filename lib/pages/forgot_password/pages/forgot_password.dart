import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/providers/auth_provider.dart';
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';
import 'package:go_router/go_router.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _novaSenhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _formSenhaKey = GlobalKey<FormState>();

  bool _emailVerificado = false;
  String? _emailUsuario;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: PetFamilyAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              Text(
                'Recuperar senha',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF000000),
                ),
              ),
              SizedBox(height: 16),
              if (!_emailVerificado) ...[
                // ✅ TELA 1: Verificar Email
                Text(
                  'Digite seu email para verificar sua conta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w100,
                    color: Color(0xFF000000),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _emailController,
                          labelText: 'Email',
                          hintText: 'Digite seu email',
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor, digite seu email';
                            }
                            if (!value.contains('@')) {
                              return 'Digite um email válido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 30),

                        // ✅ MOSTRA ERRO ESPECÍFICO DO BACKEND
                        if (authProvider.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                border: Border.all(color: Colors.red),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      authProvider.errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        authProvider.isLoading
                            ? CircularProgressIndicator()
                            : AppButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    // ✅ LIMPA ERROS ANTES DE VERIFICAR
                                    authProvider.clearError();

                                    // ✅ CORREÇÃO: Use o método EXISTENTE solicitarRecuperacaoSenha
                                    final success = await authProvider.solicitarRecuperacaoSenha(
                                      _emailController.text.trim(),
                                    );

                                    // ✅ SÓ MOSTRA TELA DE SENHA SE O EMAIL FOR VÁLIDO
                                    if (success) {
                                      setState(() {
                                        _emailVerificado = true;
                                        _emailUsuario =
                                            _emailController.text.trim();
                                      });
                                    } else {
                                      // ✅ SE NÃO FOR VÁLIDO, MANTÉM NA MESMA TELA E MOSTRA ERRO
                                      print(
                                          '❌ Email não verificado: ${authProvider.errorMessage}');
                                    }
                                  }
                                },
                                label: 'Verificar Email',
                              )
                      ],
                    ),
                  ),
                )
              ] else ...[
                // ✅ TELA 2: Redefinir Senha (SÓ APARECE SE EMAIL FOR VÁLIDO)
                Text(
                  'Crie uma nova senha para sua conta',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w100,
                    color: Color(0xFF000000),
                  ),
                ),

                // ✅ Mostra o email que foi verificado
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 8),
                        Text(
                          'Email verificado: $_emailUsuario',
                          style: TextStyle(
                            color: Colors.green[800],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Form(
                    key: _formSenhaKey,
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
                        SizedBox(height: 30),

                        // ✅ ERRO AO REDEFINIR SENHA
                        if (authProvider.errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red[50],
                                border: Border.all(color: Colors.red),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      authProvider.errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        Row(
                          children: [
                            // Botão Voltar
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _emailVerificado = false;
                                    _novaSenhaController.clear();
                                    _confirmarSenhaController.clear();
                                    authProvider.clearError();
                                  });
                                },
                                child: Text(
                                  'Voltar',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),

                            // Botão Redefinir
                            Expanded(
                              child: authProvider.isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : AppButton(
                                      onPressed: () async {
                                        if (_formSenhaKey.currentState!.validate()) {
                                          // ✅ CORREÇÃO: Use o método EXISTENTE redefinirSenha
                                          final success = await authProvider.redefinirSenha(
                                            _emailUsuario!,
                                            _novaSenhaController.text,
                                          );

                                          if (success) {
                                            _mostrarSucesso('Senha redefinida com sucesso!');
                                            await Future.delayed(Duration(seconds: 2));
                                            GoRouter.of(context).go('/');
                                          } else {
                                            _mostrarErro(
                                                authProvider.errorMessage ?? 'Erro ao redefinir senha');
                                          }
                                        }
                                      },
                                      label: 'Redefinir',
                                    ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _novaSenhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  void _mostrarSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text(mensagem)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text(mensagem)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}