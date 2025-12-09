// lib/screens/edit_profile/edit_profile.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/models/user_model.dart';
import 'package:pet_family_app/pages/profile/edit/edit_profile/edited_profile_modal.dart';
import 'package:pet_family_app/providers/auth_provider.dart';
import 'package:pet_family_app/services/user_service.dart';
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
  late UserService _userService;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _telefoneController = TextEditingController();
    _cpfController = TextEditingController();
    _userService = UserService(client: http.Client());
    
    // Carregar os dados assim que o widget for inicializado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDadosIniciais();
    });
  }

  void _carregarDadosIniciais() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Se não tem usuário, tenta recarregar
    if (authProvider.usuario == null) {
      print('🔄 Nenhum usuário no AuthProvider, tentando recarregar...');
      authProvider.recarregarUsuario();
    } else {
      // Já tem usuário, carregar dados nos controllers
      _carregarDadosParaEdicao(authProvider.usuario!);
    }
  }

  void _carregarDadosParaEdicao(UsuarioModel usuario) {
    print('📝 Carregando dados para edição: ${usuario.nome}');
    _nomeController.text = usuario.nome;
    _emailController.text = usuario.email ?? '';
    _telefoneController.text = usuario.telefone ?? '';
    _cpfController.text = usuario.cpf ?? '';
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.usuario == null || authProvider.usuario!.idUsuario == null) {
        print('❌ Nenhum usuário logado no AuthProvider');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro: Nenhum usuário logado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final usuarioId = authProvider.usuario!.idUsuario!;
      final dadosAtualizados = {
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'cpf': _cpfController.text.trim(),
      };

      print('📤 Enviando dados atualizados para API: $dadosAtualizados');
      print('👤 ID do usuário: $usuarioId');
      
      // Chamar a API para atualizar o perfil
      final resultado = await _userService.atualizarPerfil(usuarioId, dadosAtualizados);
      
      if (resultado['success'] == true) {
        print('✅ Perfil atualizado na API com sucesso!');
        
        // Atualizar localmente no provider
        final usuarioAtualizado = resultado['usuario'] ?? authProvider.usuario!.copyWith(
          nome: dadosAtualizados['nome'],
          email: dadosAtualizados['email'],
          telefone: dadosAtualizados['telefone'],
          cpf: dadosAtualizados['cpf'],
        );
        
        if (usuarioAtualizado is UsuarioModel) {
          authProvider.atualizarDadosUsuario(usuarioAtualizado);
        }

        if (context.mounted) {
          Navigator.pop(context, true);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil atualizado com sucesso!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('❌ Erro da API: ${resultado['message']}');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${resultado['message'] ?? "Erro desconhecido"}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Exceção ao salvar: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final usuario = authProvider.usuario;

        print('👤 AuthProvider.usuario: $usuario');
        print('🔄 AuthProvider.isLoading: ${authProvider.isLoading}');

        // Se está carregando
        if (authProvider.isLoading && usuario == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  const Text('Carregando perfil...'),
                ],
              ),
            ),
          );
        }

        // Se não tem usuário
        if (usuario == null) {
          print('⚠️ Nenhum usuário encontrado no AuthProvider');
          
          // Aguarda um pouco e tenta redirecionar
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context, 
                '/login', 
                (route) => false
              );
            }
          });
          
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Usuário não encontrado',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Redirecionando para login...',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          );
        }

        // Se está atualizando
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

        // Tela normal
        return EditProfileView(
          usuario: usuario,
          onEditarPressed: () => _abrirModalEdicao(context, usuario),
          isLoading: false,
        );
      },
    );
  }
}