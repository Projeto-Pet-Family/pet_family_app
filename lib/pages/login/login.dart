import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailOrCpfController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
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
                SizedBox(height: 20),
                AppTextField(
                  controller: emailOrCpfController,
                  labelText: 'Email ou CPF',
                  hintText: 'Digite seu Email ou CPF',
                ),
                SizedBox(height: 5),
                AppTextField(
                  controller: passwordController,
                  labelText: 'Senha',
                  hintText: 'Digite sua senha',
                  obscureText: true, //ocultando o texto digitado
                  isPasswordField: true, //ativa a visibilidade de senha
                ),
                SizedBox(height: 10),
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
                          style: TextStyle(
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: AppButton(
                    label: 'Entrar',
                    fontSize: 30,
                    onPressed: () {},
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.go('/who-many-pets');
                  },
                  child: Text.rich(
                    TextSpan(
                      text: 'Não tem conta? ',
                      style: TextStyle(
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    thickness: 1,
                    color: Color(0xFFCCCCCC),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
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
                        'assets/icons/ic_gmail.png',
                        width: 50,
                        height: 50,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailOrCpfController.dispose();
    super.dispose();
  }
}
