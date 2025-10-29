import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import './templates/pet_data_template.dart';
import './templates/your_data_template.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../../models/pet/pet_model.dart';

class ConfirmYourDatas extends StatefulWidget {
  const ConfirmYourDatas({super.key});

  @override
  State<ConfirmYourDatas> createState() => _ConfirmYourDatasState();
}

class _ConfirmYourDatasState extends State<ConfirmYourDatas> {
  bool _isLoading = false;

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Carrega dados do cache e constrói o objeto de usuário
      final user = await _buildUserData();

      // Faz o POST para a API usando UserService
      final userService = UserService(client: http.Client());
      await userService.registerUser(user);

      // Se chegou aqui, o cadastro foi bem-sucedido
      _showSuccessDialog();
    } catch (e) {
      _showErrorDialog('Erro ao cadastrar: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<UserModel> _buildUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Dados do endereço
    final address = AddressModel(
      cep: prefs.getString('user_cep') ?? '',
      rua: prefs.getString('user_street') ?? '',
      numero: prefs.getString('user_number') ?? '',
      complemento: prefs.getString('user_complement'),
      bairro: prefs.getString('user_neighborhood') ?? '',
      cidade: prefs.getString('user_city') ?? '',
      estado: prefs.getString('user_state') ?? '',
    );

    // Dados do usuário
    return UserModel(
      nome: prefs.getString('user_name') ?? '',
      cpf: prefs.getString('user_cpf') ?? '',
      email: prefs.getString('user_email') ?? '',
      telefone: prefs.getString('user_phone') ?? '',
      senha: prefs.getString('user_password') ?? '',
      ativado: false,
      desativado: false,
      esqueceuSenha: false,
      dataCadastro: DateTime.now(),
      endereco: address,
    );
  }

  Future<PetModel> _buildPetData() async {
    final prefs = await SharedPreferences.getInstance();

    return PetModel(
      idusuario: null,
      idporte: null,
      idespecie: null,
      idraca: null,
      nome: prefs.getString('pet_name') ?? '',
      sexo: prefs.getString('pet_sex') ?? '',
      nascimento: null,
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cadastro Confirmado!'),
          content: const Text('Seus dados foram salvos com sucesso.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearCacheAndNavigate();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Erro no Cadastro'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearCacheAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();

    // Limpa todos os dados do cache
    await prefs.remove('user_name');
    await prefs.remove('user_cpf');
    await prefs.remove('user_phone');
    await prefs.remove('user_email');
    await prefs.remove('user_password');
    await prefs.remove('user_confirm_password');

    await prefs.remove('user_cep');
    await prefs.remove('user_street');
    await prefs.remove('user_number');
    await prefs.remove('user_complement');
    await prefs.remove('user_neighborhood');
    await prefs.remove('user_city');
    await prefs.remove('user_state');

    await prefs.remove('pet_name');
    await prefs.remove('pet_species');
    await prefs.remove('pet_race');
    await prefs.remove('pet_sex');
    await prefs.remove('pet_observation');

    // Navega para a tela inicial
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PetFamilyAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'confirmar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w200,
                    color: Colors.black,
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.center,
                child: Text(
                  'Dados',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Seção Pets
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w200,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const PetDataTemplate(),

              const SizedBox(height: 24),

              // Seção Dados Pessoais
              const Text(
                'Seus dados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w200,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const YourDataTemplate(),

              const SizedBox(height: 30),

              AppButton(
                onPressed: _isLoading ? null : _registerUser,
                label: _isLoading ? 'Cadastrando...' : 'Confirmar',
              ),

              const SizedBox(height: 16),

              // Botão para editar dados
              if (!_isLoading)
                OutlinedButton(
                  onPressed: () {
                    context.go('/want-host-pet');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: const BorderSide(color: Colors.grey),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Editar Dados'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
