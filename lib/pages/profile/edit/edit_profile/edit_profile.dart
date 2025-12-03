// lib/screens/edit_profile/edit_profile.dart
import 'package:flutter/material.dart';
import 'package:pet_family_app/models/user_model.dart';
import 'package:pet_family_app/pages/profile/edit/edit_profile/edited_profile_modal.dart';
import 'package:pet_family_app/providers/user_provider.dart'; // Importe apenas o UserProvider
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
  bool _isSalvando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _telefoneController = TextEditingController();
    _cpfController = TextEditingController();
    
    // Carregar os dados assim que o widget for inicializado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDadosIniciais(context);
    });
  }

  void _carregarDadosIniciais(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
    
    // Se não tem usuário logado, tenta buscar do ID no cache
    if (usuarioProvider.usuarioLogado == null) {
      print('🔄 Buscando usuário logado no provider...');
      // Você pode adicionar lógica aqui para buscar o usuário se necessário
    }
  }

  void _carregarDadosParaEdicao(UsuarioModel usuario) {
    print('📝 Carregando dados para edição: ${usuario.nome}');
    _nomeController.text = usuario.nome;
    _emailController.text = usuario.email;
    _telefoneController.text = usuario.telefone;
    _cpfController.text = usuario.cpf;
  }

  Future<void> _abrirModalEdicao(
      BuildContext context, UsuarioModel usuario) async {
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
              isSalvando: _isSalvando,
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
    print('💾 Iniciando salvamento das alterações...');
    
    setState(() {
      _isSalvando = true;
    });

    try {
      final usuarioProvider =
          Provider.of<UsuarioProvider>(context, listen: false);

      if (usuarioProvider.usuarioLogado == null) {
        print('❌ Nenhum usuário logado no UsuarioProvider');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro: Nenhum usuário logado'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final dadosAtualizados = {
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'cpf': _cpfController.text.trim(),
      };

      print('📤 Enviando dados atualizados: $dadosAtualizados');
      
      final sucesso = await usuarioProvider.atualizarPerfil(dadosAtualizados);

      if (sucesso && context.mounted) {
        print('✅ Perfil atualizado com sucesso!');
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (context.mounted) {
        print('❌ Erro ao atualizar perfil: ${usuarioProvider.error}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${usuarioProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Exceção ao salvar: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      print('🏁 Finalizando processo de salvamento');
      if (mounted) {
        setState(() {
          _isSalvando = false;
        });
      }
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
    return Consumer<UsuarioProvider>(
      builder: (context, usuarioProvider, child) {
        final usuario = usuarioProvider.usuarioLogado;

        print('👤 UsuarioProvider.usuarioLogado: $usuario');
        print('🔄 UsuarioProvider.loading: ${usuarioProvider.loading}');

        if (usuario == null) {
          print('⚠️ Nenhum usuário encontrado no UsuarioProvider');
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  const Text('Carregando perfil...'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Tentar recarregar
                      usuarioProvider.buscarUsuarioPorId(3); // ID do cache
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            ),
          );
        }

        if (_isRefreshing || usuarioProvider.loading) {
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