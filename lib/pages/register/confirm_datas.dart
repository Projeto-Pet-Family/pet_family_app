import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/models/user_model.dart' hide PetModel;
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

  Future<void> _confirmarCadastro() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final usuarioProvider = context.read<UsuarioProvider>();
      final usuario = await _buildUserData();
      final petData = await _buildPetData();

      // Cria o usuário com o provider
      await usuarioProvider.criarUsuario(usuario);

      if (usuarioProvider.success) {
        // Se o usuário foi criado com sucesso
        final hasPet = _hasValidPetData(petData);

        if (hasPet) {
          _showSuccessDialog(true);
        } else {
          _showSuccessDialog(false);
        }
      } else {
        _showErrorDialog(usuarioProvider.error ?? 'Erro ao cadastrar usuário');
      }
    } catch (e) {
      _showErrorDialog('Erro ao cadastrar: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      // Note: O endereço não está na estrutura atual do UsuarioModel
      // Você precisará adaptar conforme sua necessidade
    );
  }

  Future<PetModel?> _buildPetData() async {
    final prefs = await SharedPreferences.getInstance();

    final nome = prefs.getString('pet_name')?.trim() ?? '';
    final sexo = prefs.getString('pet_sex')?.trim() ?? '';
    final especie = prefs.getInt('pet_id_especie');
    final raca = prefs.getInt('pet_id_raca');
    final porte = prefs.getInt('pet_id_porte');
    final observacoes = prefs.getString('pet_observation')?.trim();

    // Verifica se tem dados mínimos para criar um pet
    if (nome.isEmpty ||
        sexo.isEmpty ||
        especie == null ||
        raca == null ||
        porte == null) {
      return null;
    }

    return PetModel(
      nome: nome,
      sexo: sexo,
      // Adicione outros campos conforme necessário
      // idEspecie: especie,
      // idRaca: raca,
      // idPorte: porte,
      // observacoes: observacoes,
    );
  }

  bool _hasValidPetData(PetModel? petData) {
    if (petData == null) return false;

    return petData.nome!.isNotEmpty && petData.sexo!.isNotEmpty;
    // && petData.idEspecie != null && petData.idEspecie! > 0 &&
    //    petData.idRaca != null && petData.idRaca! > 0 &&
    //    petData.idPorte != null && petData.idPorte! > 0;
  }

  void _showSuccessDialog(bool hasPet) {
    String message = hasPet
        ? 'Usuário e pet cadastrados com sucesso!'
        : 'Usuário criado com sucesso!';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Cadastro Confirmado!'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _clearCacheAndNavigate();
            },
            child: const Text('Fazer Login'),
          ),
        ],
      ),
    );
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
        title: const Text('Erro no Cadastro'),
        content: Text(message),
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

    for (final key in keysToRemove) {
      await prefs.remove(key);
    }

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

              // Consumer para acessar o estado do provider
              Consumer<UsuarioProvider>(
                builder: (context, usuarioProvider, child) {
                  return Column(
                    children: [
                      AppButton(
                        onPressed: (_isLoading || usuarioProvider.loading)
                            ? null
                            : _confirmarCadastro,
                        label: (_isLoading || usuarioProvider.loading)
                            ? 'Cadastrando...'
                            : 'Confirmar',
                      ),

                      // Exibir erro do provider se houver
                      if (usuarioProvider.error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            usuarioProvider.error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),
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
