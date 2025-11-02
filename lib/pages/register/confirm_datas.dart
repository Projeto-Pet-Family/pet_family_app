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
      final user = await _buildUserData();
      final userService = UserService(client: http.Client());

      print('🎯 ===== INICIANDO CADASTRO DO USUÁRIO =====');
      await userService.registerUser(user);
      print('✅ Usuário cadastrado com sucesso!');

      // Tenta cadastrar o pet imediatamente após o usuário
      await _cadastrarPetAposUsuario();
    } catch (e) {
      print('❌ ERRO NO CADASTRO: $e');
      _showErrorDialog('Erro ao cadastrar: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cadastrarPetAposUsuario() async {
    try {
      final pet = await _buildPetData();
      final hasPet = _hasPetData(pet);

      if (hasPet) {
        print('🐕 ===== TENTANDO CADASTRAR PET DIRETAMENTE =====');

        final petService = PetService(client: http.Client());

        // Prepara os dados do pet SEM o idusuario
        final petData = await _prepararDadosPetParaEnvioSimplificado();

        print('📦 Dados do pet para envio:');
        print('   🐾 Nome: ${petData['nome']}');
        print('   ⚧️ Sexo: ${petData['sexo']}');
        print('   🐶 Espécie ID: ${petData['idespecie']}');
        print('   🐕 Raça ID: ${petData['idraca']}');
        print('   📏 Porte ID: ${petData['idporte']}');
        print('   📝 Observações: ${petData['observacoes']}');

        // Tenta cadastrar o pet mesmo sem o ID do usuário
        final resultado = await petService.criarPetDireto(petData);

        if (resultado['success'] == true) {
          print('✅ Pet cadastrado com sucesso!');
          _showSuccessDialogWithPetOption(true);
        } else {
          print('⚠️ Pet não cadastrado: ${resultado['message']}');
          _showSuccessDialogWithPetOption(false); // Apenas usuário criado
        }
      } else {
        print('ℹ️ Nenhum pet para cadastrar');
        _showSuccessDialogWithPetOption(false);
      }
    } catch (e) {
      print('❌ Erro no cadastro do pet: $e');
      _showSuccessDialogWithPetOption(false); // Usuário foi criado, pet não
    }
  }

  Future<Map<String, dynamic>> _prepararDadosPetParaEnvioSimplificado() async {
    final prefs = await SharedPreferences.getInstance();

    final petData = {
      'nome': prefs.getString('pet_name'),
      'sexo': prefs.getString('pet_sex'),
      'idespecie': prefs.getInt('pet_id_especie'),
      'idraca': prefs.getInt('pet_id_raca'),
      'idporte': prefs.getInt('pet_id_porte'),
      'observacoes': prefs.getString('pet_observation'),
      // Não inclui idusuario - vamos tentar sem ele
    };

    // Remove campos nulos
    petData.removeWhere((key, value) => value == null);

    return petData;
  }

  void _showSuccessDialogWithPetOption(bool hasPet) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cadastro Confirmado!'),
          content: Text(hasPet
              ? 'Usuário e pet cadastrados com sucesso!'
              : 'Usuário criado com sucesso!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearCacheAndNavigate();
              },
              child: const Text('Fazer Login'),
            ),
          ],
        );
      },
    );
  }

  Future<UserModel> _buildUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // DEBUG: Mostra todos os dados salvos no SharedPreferences
    print('🔍 ===== DADOS DO SHARED PREFERENCES =====');
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith('user_') || key.startsWith('pet_')) {
        final value = prefs.get(key);
        print('   $key: $value');
      }
    }
    print('🔍 ===== FIM DOS DADOS DO SHARED PREFERENCES =====');

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
      idusuario: prefs.getString('user_id') ?? '',
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
      idporte: prefs.getInt('pet_id_porte'),
      idespecie: prefs.getInt('pet_id_especie'),
      idraca: prefs.getInt('pet_id_raca'),
      nome: prefs.getString('pet_name') ?? '',
      sexo: prefs.getString('pet_sex') ?? '',
      nascimento: null,
      observacoes: prefs.getString('pet_observation'),
    );
  }

  bool _hasPetData(PetModel pet) {
    final hasData = pet.nome?.isNotEmpty == true &&
        pet.nome != '' &&
        pet.idespecie != null &&
        pet.idespecie! > 0 &&
        pet.idraca != null &&
        pet.idraca! > 0 &&
        pet.idporte != null &&
        pet.idporte! > 0;

    print('🔍 Verificação de dados do pet:');
    print(
        '   ✅ Nome preenchido: ${pet.nome?.isNotEmpty == true && pet.nome != ''}');
    print(
        '   ✅ Espécie ID válido: ${pet.idespecie != null && pet.idespecie! > 0}');
    print('   ✅ Raça ID válido: ${pet.idraca != null && pet.idraca! > 0}');
    print('   ✅ Porte ID válido: ${pet.idporte != null && pet.idporte! > 0}');
    print('   🔍 Pet tem dados suficientes: $hasData');

    return hasData;
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

    print('🗑️ Limpando cache do SharedPreferences...');

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
    await prefs.remove('has_pet_to_register');

    print('✅ Cache limpo com sucesso!');

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
