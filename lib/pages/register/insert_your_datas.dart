import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InsertYourDatas extends StatefulWidget {
  const InsertYourDatas({super.key});

  @override
  State<InsertYourDatas> createState() => _InsertYourDatasState();
}

class _InsertYourDatasState extends State<InsertYourDatas> {
  TextEditingController nameController = TextEditingController();
  TextEditingController cpfController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Chaves para o cache
  static const String _nameKey = 'user_name';
  static const String _cpfKey = 'user_cpf';
  static const String _phoneKey = 'user_phone';
  static const String _emailKey = 'user_email';
  static const String _passwordKey = 'user_password';
  static const String _confirmPasswordKey = 'user_confirm_password';

  bool _passwordsMatch = true;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Carrega dados salvos ao iniciar
  }

  // Salvar todos os dados no cache
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_nameKey, nameController.text);
    await prefs.setString(_cpfKey, cpfController.text);
    await prefs.setString(_phoneKey, phoneController.text);
    await prefs.setString(_emailKey, emailController.text);
    await prefs.setString(_passwordKey, passwordController.text);
    await prefs.setString(_confirmPasswordKey, confirmPasswordController.text);
  }

  // Carregar dados do cache
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      nameController.text = prefs.getString(_nameKey) ?? '';
      cpfController.text = prefs.getString(_cpfKey) ?? '';
      phoneController.text = prefs.getString(_phoneKey) ?? '';
      emailController.text = prefs.getString(_emailKey) ?? '';
      passwordController.text = prefs.getString(_passwordKey) ?? '';
      confirmPasswordController.text = prefs.getString(_confirmPasswordKey) ?? '';
    });
    
    // Verificar senhas após carregar
    _checkPasswords();
  }

  // Verificar se as senhas coincidem
  void _checkPasswords() {
    setState(() {
      _passwordsMatch = passwordController.text == confirmPasswordController.text;
    });
  }

  // Limpar todos os dados do cache
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_nameKey);
    await prefs.remove(_cpfKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
    await prefs.remove(_confirmPasswordKey);
    
    setState(() {
      nameController.clear();
      cpfController.clear();
      phoneController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      _passwordsMatch = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados limpos do cache')),
    );
  }

  // Verificar se o formulário está válido
  bool get _isFormValid {
    return nameController.text.isNotEmpty &&
        cpfController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        _passwordsMatch;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBarReturn(route: '/'),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Center(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Insira seus dados',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    AppTextField(
                      controller: nameController,
                      labelText: 'Nome completo',
                      hintText: 'Digite seu nome completo',
                      onChanged: (value) {
                        _saveUserData();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: cpfController,
                      labelText: 'CPF',
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CpfInputFormatter()
                      ],
                      hintText: 'Digite seu CPF',
                      onChanged: (value) {
                        _saveUserData();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: phoneController,
                      labelText: 'Telefone',
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TelefoneInputFormatter()
                      ],
                      hintText: 'Digite seu telefone',
                      onChanged: (value) {
                        _saveUserData();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: emailController,
                      labelText: 'E-mail',
                      keyboardType: TextInputType.emailAddress,
                      hintText: 'Digite seu E-mail',
                      onChanged: (value) {
                        _saveUserData();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: passwordController,
                      labelText: 'Senha',
                      hintText: 'Digite sua senha',
                      obscureText: true,
                      onChanged: (value) {
                        _saveUserData();
                        _checkPasswords();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 15),
                    AppTextField(
                      controller: confirmPasswordController,
                      labelText: 'Confirmar senha',
                      hintText: 'Confirme sua senha',
                      obscureText: true,
                      onChanged: (value) {
                        _saveUserData();
                        _checkPasswords();
                        setState(() {});
                      },
                    ),
                    
                    // Mensagem de erro para senhas
                    if (!_passwordsMatch && confirmPasswordController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'As senhas não coincidem',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 30),
                    
                    // Debug: Mostrar estado do formulário (pode remover depois)
                    // Text('Formulário válido: $_isFormValid'),
                    // Text('Senhas coincidem: $_passwordsMatch'),
                    // Text('Senha: ${passwordController.text}'),
                    // Text('Confirmar: ${confirmPasswordController.text}'),
                    
                    AppButton(
                      onPressed: _isFormValid
                          ? () async {
                              await _saveUserData(); // Garante que tudo está salvo
                              context.go('/insert-your-address');
                            }
                          : null,
                      label: 'Próximo',
                      fontSize: 20,
                    ),
                    
                    const SizedBox(height: 20),
                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    cpfController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}