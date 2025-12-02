// lib/screens/edit_profile/edit_profile.dart
import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/profile/edit/edit_profile/edited_profile_modal.dart';
import 'package:pet_family_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'edit_profile_view.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  late TextEditingController _cpfController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _telefoneController = TextEditingController();
    _cpfController = TextEditingController();
  }

  void _carregarDadosParaEdicao(Map<String, dynamic> usuario) {
    _nomeController.text = usuario['nome']?.toString() ?? '';
    _emailController.text = usuario['email']?.toString() ?? '';
    _telefoneController.text = usuario['telefone']?.toString() ?? '';
    _cpfController.text = usuario['cpf']?.toString() ?? '';
  }

  Future<void> _abrirModalEdicao(
      BuildContext context, Map<String, dynamic> usuario) async {
    _carregarDadosParaEdicao(usuario);

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: EditProfileModal(
              nomeController: _nomeController,
              emailController: _emailController,
              telefoneController: _telefoneController,
              cpfController: _cpfController,
              onSalvar: () => _salvarAlteracoes(context),
            ),
          ),
        );
      },
    );

    if (result == true) {
      _mostrarLoadingEAtualizar();
    }
  }

  void _mostrarLoadingEAtualizar() {
    setState(() {
      _isRefreshing = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    });
  }

  Future<void> _salvarAlteracoes(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final dadosAtualizados = {
      'nome': _nomeController.text.trim(),
      'email': _emailController.text.trim(),
      'telefone': _telefoneController.text.trim(),
      'cpf': _cpfController.text.trim(),
    };

    final sucesso = await authProvider.atualizarPerfil(dadosAtualizados);

    if (sucesso && context.mounted) {
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${authProvider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final usuario = authProvider.usuarioLogado;

        if (usuario == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (_isRefreshing) {
          return Stack(
            children: [
              EditProfileView(
                usuario: usuario,
                onEditarPressed: () => _abrirModalEdicao(context, usuario),
                isLoading: true,
              ),
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Atualizando perfil...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return EditProfileView(
          usuario: usuario,
          onEditarPressed: () => _abrirModalEdicao(context, usuario),
          isLoading: false,
        );
      },
    );
  }
}
