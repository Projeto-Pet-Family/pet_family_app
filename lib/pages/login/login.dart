import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';
import '../../providers/auth_provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Carregar credenciais salvas quando a tela for aberta
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    // Este método poderia ser expandido para carregar credenciais
    // criptografadas se necessário no futuro
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Verificar se "Lembrar de mim" está ativo
      if (authProvider.rememberMe) {
        // Aqui você pode carregar credenciais salvas
        // Por enquanto, apenas mantém o checkbox marcado
        print('📝 "Lembrar de mim" está ativo');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.pets,
                    size: 50,
                  ),
                  const Text(
                    'PetFamily',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'Bem vindo tutor',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF474343),
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Campo Email
                  AppTextField(
                    controller: emailController,
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
                  const SizedBox(height: 5),

                  // Campo Senha
                  AppTextField(
                    controller: passwordController,
                    labelText: 'Senha',
                    hintText: 'Digite sua senha',
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, digite sua senha';
                      }
                      if (value.length < 6) {
                        return 'A senha deve ter pelo menos 6 caracteres';
                      }
                      return null;
                    },
                  ),

                  // Checkbox "Lembrar de mim"
                  Row(
                    children: [
                      Checkbox(
                        value: authProvider.rememberMe,
                        onChanged: (value) async {
                          await authProvider.setRememberMe(value ?? false);
                        },
                        activeColor: Color(0xFF8692DE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Lembrar de mim',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF474343),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  // Mensagem de erro
                  if (authProvider.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        authProvider.errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Link esqueceu senha
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: GestureDetector(
                        onTap: () {
                          context.go('/forgot-password');
                        },
                        child: Text.rich(
                          TextSpan(
                            text: 'Esqueceu a senha? ',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w200,
                              color: Color(0xFF858383),
                            ),
                            children: [
                              TextSpan(
                                text: 'Clique aqui',
                                style: TextStyle(
                                  color: Color(0xFF8692DE),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Botão Entrar
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: authProvider.isLoading
                        ? const CircularProgressIndicator()
                        : AppButton(
                            label: 'Entrar',
                            fontSize: 30,
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final success = await authProvider.login(
                                  emailController.text.trim(),
                                  passwordController.text,
                                );

                                if (success && mounted) {
                                  context.go('/core-navigation');
                                }
                              }
                            },
                          ),
                  ),

                  // Link cadastro
                  GestureDetector(
                    onTap: () {
                      context.go('/insert-datas-pet');
                    },
                    child: Text.rich(
                      TextSpan(
                        text: 'Não tem conta? ',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w200,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(
                            text: 'Clique aqui',
                            style: TextStyle(
                              color: Color(0xFF8692DE),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  /* const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      thickness: 1,
                      color: Color(0xFFCCCCCC),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'Ou entrar com:',
                      style: TextStyle(
                        color: Color(0xFF636363),
                        fontSize: 12,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/ic_google.png',
                          width: 50,
                          height: 50,
                        ),
                        Image.asset(
                          'assets/icons/ic_facebook.png',
                          width: 50,
                          height: 50,
                        ),
                      ],
                    ),
                  ), */
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
