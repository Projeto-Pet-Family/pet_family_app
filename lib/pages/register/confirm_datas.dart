import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import './templates/pet_data_template.dart';
import './templates/your_data_template.dart';
import '../../services/user_service.dart';
import '../../services/pet/pet_service.dart';
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
      // Carrega dados do cache e constrói os objetos
      final user = await _buildUserData();
      final pet = await _buildPetData();

      // 1. Faz o POST do usuário
      final userService = UserService(client: http.Client());
      final createdUser = await userService.registerUser(user);

      // 2. Se o pet tem dados válidos, registra o pet
      if (_hasPetData(pet)) {
        try {
          // Cria o serviço para cadastrar pet
          final petService = PetService(client: http.Client());

          // Atualiza o pet com o ID do usuário criado
          final petWithUserId = pet.copyWith(idusuario: createdUser.id);

          // Converte para Map e remove campos nulos
          final petData = petWithUserId.toJson();
          petData.removeWhere((key, value) => value == null);

          // Registra o pet
          await petService.registerPet(petData);

          print('✅ Pet cadastrado com sucesso!');
        } catch (e) {
          print('⚠️ Erro ao cadastrar pet, mas usuário foi criado: $e');
          _showWarningDialog(
              'Usuário criado com sucesso, mas houve um erro ao cadastrar o pet. Você pode adicionar o pet posteriormente. Erro: $e');
        }
      } else {
        print('ℹ️ Nenhum pet para cadastrar');
      }

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
      idusuario: null, // Será preenchido após criar o usuário
      idporte: prefs.getInt('pet_id_porte'),
      idespecie: prefs.getInt('pet_id_especie'),
      idraca: prefs.getInt('pet_id_raca'),
      nome: prefs.getString('pet_name') ?? '',
      sexo: prefs.getString('pet_sex') ?? '', // 'm' ou 'f'
      nascimento: null,
      observacoes: prefs.getString('pet_observation'),
    );
  }

  bool _hasPetData(PetModel pet) {
    return pet.nome?.isNotEmpty == true &&
        pet.nome != '' &&
        pet.idespecie != null &&
        pet.idespecie! > 0 &&
        pet.idraca != null &&
        pet.idraca! > 0 &&
        pet.idporte != null &&
        pet.idporte! > 0;
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

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aviso'),
          content: Text(message),
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

    // Limpa os IDs do pet
    await prefs.remove('pet_id_especie');
    await prefs.remove('pet_id_raca');
    await prefs.remove('pet_id_porte');

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
