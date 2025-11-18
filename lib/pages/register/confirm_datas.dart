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

  Future<void> _confirmarCadastro() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🎯 ===== INICIANDO PROCESSO DE CADASTRO =====');

      // 1. Primeiro cadastra o usuário
      final userId = await _registerUser();

      // 2. Verifica se obteve um ID válido
      if (userId == null) {
        print('⚠️ Não foi possível obter o ID do usuário');
        _showSuccessDialog(false, hasUserIdError: true);
      } else {
        // 3. Tenta cadastrar o pet apenas se tiver um ID válido
        try {
          await _registerPet(userId);
        } catch (petError) {
          print('⚠️ Erro ao cadastrar pet, mas usuário foi criado: $petError');
          _showSuccessDialog(false, hasPetError: true);
        }
      }
    } catch (e) {
      print('❌ ERRO NO CADASTRO: $e');
      _showErrorDialog('Erro ao cadastrar: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _registerUser() async {
    print('👤 ===== CADASTRANDO USUÁRIO =====');

    final user = await _buildUserData();
    final userService = UserService(client: http.Client());

    _debugUserData(user);

    final resultado = await userService.registerUser(user);

    print('✅ Resposta da API: $resultado');

    // ✅ CORREÇÃO: Retorna null se não conseguir o ID, em vez de string temporária
    String? userId;

    // Tenta acessar em diferentes níveis da estrutura
    if (resultado['data'] != null &&
        resultado['data'] is Map<String, dynamic> &&
        resultado['data']['usuario'] != null &&
        resultado['data']['usuario'] is Map<String, dynamic>) {
      final usuarioData = resultado['data']['usuario'] as Map<String, dynamic>;
      userId = usuarioData['idusuario']?.toString();
    }

    if (userId != null) {
      // Salva o ID do usuário no cache
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', userId);
      print('📝 ID do usuário obtido: $userId');
      return userId;
    } else {
      print('⚠️ ID do usuário não encontrado na resposta');
      return null; // ✅ Retorna null em vez de string temporária
    }
  }

  Future<void> _registerPet(String userId) async {
    print('🐕 ===== CADASTRANDO PET =====');

    final petData = await _prepararDadosPetParaEnvio(userId);
    final hasPet = _hasPetData(petData);

    if (hasPet) {
      final petService = PetService(client: http.Client());

      // Valida se todos os campos obrigatórios estão preenchidos
      final camposObrigatorios = _validarCamposObrigatorios(petData);
      if (camposObrigatorios.isNotEmpty) {
        print('❌ Campos obrigatórios faltando: $camposObrigatorios');
        _showWarningDialog(
            'Campos obrigatórios do pet não preenchidos: ${camposObrigatorios.join(', ')}');
        return;
      }

      print('📦 Dados do pet para envio:');
      print('   👤 ID Usuário: ${petData['idusuario']}');
      print('   🐾 Nome: ${petData['nome']}');
      print('   ⚧️ Sexo: ${petData['sexo']}');
      print('   🐶 Espécie ID: ${petData['idespecie']}');
      print('   🐕 Raça ID: ${petData['idraca']}');
      print('   📏 Porte ID: ${petData['idporte']}');
      print('   📝 Observações: ${petData['observacoes']}');

      // Cadastra o pet
      final resultado = await petService.criarPet(petData);

      if (resultado['success'] == true) {
        print('✅ Pet cadastrado com sucesso!');
        _showSuccessDialog(true);
      } else {
        print('⚠️ Pet não cadastrado: ${resultado['message']}');
        _showSuccessDialog(false);
      }
    } else {
      print('ℹ️ Nenhum pet para cadastrar');
      _showSuccessDialog(false);
    }
  }

  Future<Map<String, dynamic>> _prepararDadosPetParaEnvio(String userId) async {
    final prefs = await SharedPreferences.getInstance();

    // Obtém os dados do pet do SharedPreferences
    final petData = {
      'idusuario':
          userId, // Campo OBRIGATÓRIO - usa o ID do usuário recém-criado
      'nome': prefs.getString('pet_name')?.trim() ?? '', // Campo OBRIGATÓRIO
      'sexo': prefs.getString('pet_sex')?.trim() ?? '', // Campo OBRIGATÓRIO
      'idespecie': prefs.getInt('pet_id_especie'), // Campo OBRIGATÓRIO
      'idraca': prefs.getInt('pet_id_raca'), // Campo OBRIGATÓRIO
      'idporte': prefs.getInt('pet_id_porte'), // Campo OBRIGATÓRIO
      'observacoes': prefs.getString('pet_observation')?.trim(),
    };

    // Remove apenas campos de observações se forem nulos (mantém obrigatórios)
    if (petData['observacoes'] == null) {
      petData.remove('observacoes');
    }

    return petData;
  }

  bool _hasPetData(Map<String, dynamic> petData) {
    final hasData = (petData['nome']?.isNotEmpty == true) &&
        (petData['idespecie'] != null && petData['idespecie']! > 0) &&
        (petData['idraca'] != null && petData['idraca']! > 0) &&
        (petData['idporte'] != null && petData['idporte']! > 0);

    print('🔍 Verificação de dados do pet:');
    print('   ✅ Nome preenchido: ${petData['nome']?.isNotEmpty == true}');
    print(
        '   ✅ Espécie ID válido: ${petData['idespecie'] != null && petData['idespecie']! > 0}');
    print(
        '   ✅ Raça ID válido: ${petData['idraca'] != null && petData['idraca']! > 0}');
    print(
        '   ✅ Porte ID válido: ${petData['idporte'] != null && petData['idporte']! > 0}');
    print('   🔍 Pet tem dados suficientes: $hasData');

    return hasData;
  }

  List<String> _validarCamposObrigatorios(Map<String, dynamic> petData) {
    final camposFaltantes = <String>[];

    // Campos obrigatórios conforme a mensagem de erro
    if (petData['idusuario'] == null ||
        petData['idusuario'].toString().isEmpty) {
      camposFaltantes.add('idusuario');
    }
    if (petData['nome'] == null || petData['nome'].toString().isEmpty) {
      camposFaltantes.add('nome');
    }
    if (petData['sexo'] == null || petData['sexo'].toString().isEmpty) {
      camposFaltantes.add('sexo');
    }
    if (petData['idespecie'] == null || petData['idespecie'] <= 0) {
      camposFaltantes.add('idespecie');
    }
    if (petData['idraca'] == null || petData['idraca'] <= 0) {
      camposFaltantes.add('idraca');
    }
    if (petData['idporte'] == null || petData['idporte'] <= 0) {
      camposFaltantes.add('idporte');
    }

    return camposFaltantes;
  }

  void _showSuccessDialog(bool hasPet,
      {bool hasUserIdError = false, bool hasPetError = false}) {
    String message;
    String buttonText = 'Fazer Login';

    if (hasUserIdError) {
      message = 'Usuário criado com sucesso! '
          'Não foi possível cadastrar seu pet agora, mas você pode adicioná-lo depois no aplicativo.';
    } else if (hasPetError) {
      message = 'Usuário criado com sucesso! '
          'Houve um problema ao cadastrar seu pet, mas você pode adicioná-lo depois.';
    } else if (hasPet) {
      message = 'Usuário e pet cadastrados com sucesso!';
    } else {
      message = 'Usuário criado com sucesso!';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cadastro Confirmado!'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearCacheAndNavigate();
              },
              child: Text(buttonText),
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
          title: const Text('Atenção'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Permite que o usuário edite os dados do pet
                context.go('/want-host-pet');
              },
              child: const Text('Editar Dados do Pet'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showSuccessDialog(false); // Apenas usuário criado
              },
              child: const Text('Continuar sem Pet'),
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

  Future<UserModel> _buildUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // DEBUG: Mostra todos os dados salvos no SharedPreferences
    _debugSharedPreferences(prefs);

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
      idusuario: '', // Será gerado pelo backend
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

  // DEBUG METHODS
  void _debugSharedPreferences(SharedPreferences prefs) {
    print('🔍 ===== DADOS DO SHARED PREFERENCES =====');
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith('user_') || key.startsWith('pet_')) {
        final value = prefs.get(key);
        print('   $key: $value');
      }
    }
    print('🔍 ===== FIM DOS DADOS DO SHARED PREFERENCES =====');
  }

  void _debugUserData(UserModel user) {
    print('🔍 ===== DADOS DO USUÁRIO PARA CADASTRO =====');
    print('   👤 Nome: ${user.nome}');
    print('   📧 Email: ${user.email}');
    print('   📞 Telefone: ${user.telefone}');
    print('   🆔 CPF: ${user.cpf}');
    print('   🔐 Senha: ${user.senha?.isNotEmpty == true ? "***" : "vazia"}');
    print('   📍 CEP: ${user.endereco.cep}');
    print('   🏠 Rua: ${user.endereco.rua}');
    print('   🏢 Número: ${user.endereco.numero}');
    print('   🏙️ Cidade: ${user.endereco.cidade}');
    print('   🏙️ Estado: ${user.endereco.estado}');
    print('🔍 ===== FIM DOS DADOS DO USUÁRIO =====');
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
    await prefs.remove('user_id');

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
                onPressed: _isLoading ? null : _confirmarCadastro,
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
