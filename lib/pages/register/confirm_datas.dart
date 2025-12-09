import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/models/user_model.dart' hide PetModel;
import 'package:pet_family_app/providers/pet/pet_provider.dart';
import 'package:pet_family_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import './templates/pet_data_template.dart';
import './templates/your_data_template.dart';

class ConfirmYourDatas extends StatefulWidget {
  const ConfirmYourDatas({super.key});

  @override
  State<ConfirmYourDatas> createState() => _ConfirmYourDatasState();
}

class _ConfirmYourDatasState extends State<ConfirmYourDatas> {
  bool _isLoading = false;
  bool _showSuccessPopup = false;

  @override
  void initState() {
    super.initState();
    // Limpar estados dos providers quando a tela for iniciada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usuarioProvider = context.read<UsuarioProvider>();
      final petProvider = context.read<PetProvider>();
      usuarioProvider.clearSuccess();
      usuarioProvider.clearError();
      petProvider.clearSuccess();
      petProvider.clearError();
    });
  }

  Future<void> _confirmarCadastro() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _showSuccessPopup = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioProvider = context.read<UsuarioProvider>();
      final petProvider = context.read<PetProvider>();

      // Limpar estados anteriores
      usuarioProvider.clearError();
      petProvider.clearError();

      print('🚀 Iniciando cadastro...');

      // 1. Criar usuário
      final usuario = await _buildUserData();
      await usuarioProvider.criarUsuario(usuario);

      if (!usuarioProvider.success) {
        _showErrorDialog(usuarioProvider.error ?? 'Erro ao cadastrar usuário');
        return;
      }

      // 2. Salvar ID do usuário no cache
      final idUsuario = usuarioProvider.usuarioLogado?.idUsuario;
      if (idUsuario != null) {
        await prefs.setInt('user_id', idUsuario);
        print('✅ ID do usuário salvo no cache: $idUsuario');
      } else {
        throw Exception('ID do usuário não foi gerado');
      }

      // 3. Criar pet
      final pet = await _buildPetData();
      print('🐕 Pet a ser criado: ${pet.toJson()}');
      await petProvider.criarPet(pet);

      if (!petProvider.success) {
        _showErrorDialog(petProvider.error ?? 'Erro ao cadastrar pet');
        return;
      }

      // 4. Mostrar pop-up de sucesso
      print('🎉 Cadastro concluído com sucesso!');
      _showSuccessPopupAndRedirect();
    } catch (e) {
      _showErrorDialog('Erro ao cadastrar: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _buildPetPayload() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'nome': prefs.getString('pet_name')?.trim() ?? '',
      'sexo': prefs.getString('pet_sex')?.trim() ?? '',
      'idEspecie': prefs.getInt('pet_id_especie'),
      'idRaca': prefs.getInt('pet_id_raca'),
      'idPorte': prefs.getInt('pet_id_porte'),
      'observacoes': prefs.getString('pet_observation')?.trim(),
    };
  }

  Future<UsuarioModel> _buildUserData() async {
    final prefs = await SharedPreferences.getInstance();

    return UsuarioModel(
      nome: prefs.getString('user_name') ?? '',
      cpf: prefs.getString('user_cpf') ?? '',
      email: prefs.getString('user_email') ?? '',
      telefone: prefs.getString('user_phone') ?? '',
      senha: prefs.getString('user_password') ?? '',
      esqueceuSenha: false,
      dataCadastro: DateTime.now(),
    );
  }

  Future<PetModel> _buildPetData() async {
    final prefs = await SharedPreferences.getInstance();

    // Debug: mostrar todos os valores do cache
    print('🔍 DEBUG _buildPetData:');
    print('  pet_name: ${prefs.getString('pet_name')}');
    print('  user_id: ${prefs.getInt('user_id')}');
    print('  pet_sex: ${prefs.getString('pet_sex')}');
    print('  pet_id_especie: ${prefs.getInt('pet_id_especie')}');
    print('  pet_id_raca: ${prefs.getInt('pet_id_raca')}');
    print('  pet_id_porte: ${prefs.getInt('pet_id_porte')}');

    final idUsuario = prefs.getInt('user_id');
    if (idUsuario == null) {
      throw Exception('ID do usuário não encontrado no cache');
    }

    return PetModel(
      nome: prefs.getString('pet_name')?.trim() ?? '',
      idUsuario: idUsuario,
      sexo: prefs.getString('pet_sex')?.trim() ?? '',
      idEspecie: prefs.getInt('pet_id_especie'),
      idRaca: prefs.getInt('pet_id_raca'),
      idPorte: prefs.getInt('pet_id_porte'),
      observacoes: prefs.getString('pet_observation')?.trim(),
    );
  }

  bool _hasValidPetData(PetModel? petData) {
    if (petData == null) return false;

    return petData.nome!.isNotEmpty && petData.sexo!.isNotEmpty;
  }

  // ✅ NOVO MÉTODO: Pop-up de sucesso com redirecionamento
  void _showSuccessPopupAndRedirect() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 10),
            Text(
              'Cadastro Concluído!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Icon(
                Icons.celebration,
                color: Colors.amber,
                size: 50,
              ),
              const SizedBox(height: 20),
              const Text(
                '🎉 Parabéns!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Seu cadastro e o do seu pet foram realizados com sucesso!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Agora você pode fazer login e começar a usar o PetFamily.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.pets, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Seu pet já está cadastrado e pronto para encontrar uma família amorosa!',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _clearCacheAndNavigate();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'FAZER LOGIN AGORA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  void _showSuccessDialog(bool hasPet) {
    // Reutilizar o novo método
    _showSuccessPopupAndRedirect();
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atenção'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/want-host-pet');
            },
            child: const Text('Editar Dados do Pet'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSuccessDialog(false);
            },
            child: const Text('Continuar sem Pet'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Erro no Cadastro'),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            message,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearCacheAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final keysToRemove = [
      'user_name',
      'user_cpf',
      'user_phone',
      'user_email',
      'user_password',
      'user_confirm_password',
      'user_id',
      'user_cep',
      'user_street',
      'user_number',
      'user_complement',
      'user_neighborhood',
      'user_city',
      'user_state',
      'pet_name',
      'pet_species',
      'pet_race',
      'pet_sex',
      'pet_observation',
      'pet_id_especie',
      'pet_id_raca',
      'pet_id_porte',
      'has_pet_to_register',
    ];

    print('🧹 Limpando cache...');
    for (final key in keysToRemove) {
      await prefs.remove(key);
      print('  - $key removido');
    }

    print('✅ Cache limpo com sucesso!');

    // Aguardar um momento para a transição
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      print('🔄 Redirecionando para / (login)...');
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
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const PetDataTemplate(),
              const SizedBox(height: 24),
              const Text(
                'Seus dados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w200,
                ),
              ),
              const SizedBox(height: 8),
              const YourDataTemplate(),
              const SizedBox(height: 30),

              // Botão de confirmar com Consumer para ambos providers
              Consumer2<UsuarioProvider, PetProvider>(
                builder: (context, usuarioProvider, petProvider, child) {
                  // Verificar se deve mostrar pop-up automático (fallback)
                  if (usuarioProvider.success &&
                      petProvider.success &&
                      !_showSuccessPopup &&
                      !_isLoading) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _showSuccessPopup = true;
                      });
                      _showSuccessPopupAndRedirect();
                      // Limpar estados após mostrar
                      Future.delayed(const Duration(seconds: 1), () {
                        usuarioProvider.clearSuccess();
                        petProvider.clearSuccess();
                      });
                    });
                  }

                  return Column(
                    children: [
                      AppButton(
                        onPressed: (_isLoading ||
                                usuarioProvider.loading ||
                                petProvider.loading)
                            ? null
                            : _confirmarCadastro,
                        label: (_isLoading ||
                                usuarioProvider.loading ||
                                petProvider.loading)
                            ? 'Cadastrando...'
                            : 'Confirmar',
                      ),

                      // Exibir erros
                      if (usuarioProvider.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[100]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Usuário: ${usuarioProvider.error!}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      if (petProvider.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[100]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.pets,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Pet: ${petProvider.error!}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),

              // Botão de editar dados
              if (!_isLoading)
                Consumer<UsuarioProvider>(
                  builder: (context, usuarioProvider, child) {
                    return OutlinedButton(
                      onPressed: usuarioProvider.loading
                          ? null
                          : () => context.go('/want-host-pet'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        side: const BorderSide(color: Colors.grey),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Editar Dados'),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}