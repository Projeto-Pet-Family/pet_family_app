// lib/screens/edit_profile/edit_profile.dart
import 'package:flutter/material.dart';
import 'package:pet_family_app/models/user_model.dart';
import 'package:pet_family_app/pages/profile/edit/edit_profile/edited_profile_modal.dart';
import 'package:pet_family_app/providers/user_provider.dart';
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
  bool _isSalvando = false;
  bool _dadosCarregados = false;
  bool _carregandoUsuario = true;
  bool _erroCarregamento = false;
  String _mensagemErro = '';

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _telefoneController = TextEditingController();
    _cpfController = TextEditingController();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarUsuario(context);
    });
  }

  Future<void> _carregarUsuario(BuildContext context) async {
    try {
      print('🔄 Iniciando carregamento do usuário...');
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
      
      // Verificar status do AuthProvider
      print('👤 AuthProvider status:');
      print('  - isLoggedIn: ${authProvider.isLoggedIn}');
      print('  - usuarioId: ${authProvider.usuarioId}');
      print('  - usuario: ${authProvider.usuario?.nome}');
      print('  - isLoading: ${authProvider.isLoading}');
      
      if (!authProvider.hasCheckedAuth) {
        print('⏳ Aguardando verificação de autenticação...');
        await authProvider.checkAuthentication();
      }
      
      if (authProvider.isLoggedIn && authProvider.usuarioId != null) {
        print('✅ Usuário autenticado. ID: ${authProvider.usuarioId}');
        
        // Se o AuthProvider já tem os dados do usuário
        if (authProvider.usuario != null) {
          print('📋 Usando dados do AuthProvider: ${authProvider.usuario!.nome}');
          usuarioProvider.setUsuario(authProvider.usuario!);
        } 
        // Se não, busca do UsuarioProvider
        else if (usuarioProvider.usuarioLogado == null) {
          print('🔍 Buscando dados do usuário via UsuarioProvider...');
          await usuarioProvider.buscarUsuarioPorId(authProvider.usuarioId!);
        }
        
        // Verificar se conseguiu obter os dados
        if (usuarioProvider.usuarioLogado != null) {
          print('✅ Dados do usuário carregados: ${usuarioProvider.usuarioLogado!.nome}');
        } else {
          print('⚠️ Não foi possível carregar dados do usuário');
          _erroCarregamento = true;
          _mensagemErro = 'Não foi possível carregar seus dados. Tente novamente.';
        }
      } else {
        print('❌ Usuário não autenticado no AuthProvider');
        _erroCarregamento = true;
        _mensagemErro = 'Você precisa fazer login para acessar esta página.';
      }
    } catch (e, stackTrace) {
      print('❌ Erro ao carregar usuário: $e');
      print('Stack trace: $stackTrace');
      _erroCarregamento = true;
      _mensagemErro = 'Erro ao carregar perfil: $e';
    } finally {
      if (mounted) {
        setState(() {
          _carregandoUsuario = false;
        });
      }
    }
  }

  void _carregarDadosParaEdicao(UsuarioModel usuario) {
    if (!_dadosCarregados && usuario.nome.isNotEmpty) {
      print('📝 Carregando dados para edição: ${usuario.nome}');
      _nomeController.text = usuario.nome;
      _emailController.text = usuario.email ?? '';
      _telefoneController.text = usuario.telefone ?? '';
      _cpfController.text = usuario.cpf ?? '';
      _dadosCarregados = true;
    }
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
      // Recarrega os dados após salvar
      _dadosCarregados = false;
      if (mounted) {
        await _recarregarUsuario(context);
      }
    }
  }

  Future<void> _salvarAlteracoes(BuildContext context) async {
    print('💾 Iniciando salvamento das alterações...');
    
    setState(() {
      _isSalvando = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
      
      // Verificar autenticação antes de salvar
      if (!authProvider.isLoggedIn || authProvider.usuarioId == null) {
        print('❌ Usuário não autenticado');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro: Sessão expirada. Faça login novamente.'),
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
        'idUsuario': authProvider.usuarioId,
      };

      print('📤 Enviando dados atualizados: $dadosAtualizados');
      
      // Atualizar no UsuarioProvider
      final sucesso = await usuarioProvider.atualizarPerfil(dadosAtualizados);

      if (sucesso && context.mounted) {
        print('✅ Perfil atualizado com sucesso!');
        
        // Atualizar também no AuthProvider
        if (usuarioProvider.usuarioLogado != null) {
          authProvider.atualizarDadosUsuario(usuarioProvider.usuarioLogado!);
        }
        
        Navigator.pop(context, true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else if (context.mounted) {
        print('❌ Erro ao atualizar perfil');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao atualizar perfil. Tente novamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Exceção ao salvar: $e');
      print('Stack trace: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
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

  Future<void> _recarregarUsuario(BuildContext context) async {
    if (mounted) {
      setState(() {
        _carregandoUsuario = true;
        _erroCarregamento = false;
        _mensagemErro = '';
        _dadosCarregados = false;
      });
      
      await _carregarUsuario(context);
    }
  }

  void _tentarNovamente(BuildContext context) {
    _recarregarUsuario(context);
  }

  void _irParaLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context, 
      '/', 
      (route) => false
    );
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
    return Scaffold(
      body: Consumer2<AuthProvider, UsuarioProvider>(
        builder: (context, authProvider, usuarioProvider, child) {
          // Obter usuário de ambas as fontes
          UsuarioModel? usuario = authProvider.usuario ?? usuarioProvider.usuarioLogado;
          
          print('=== Status do EditProfile ===');
          print('Carregando: $_carregandoUsuario');
          print('Erro: $_erroCarregamento');
          print('Mensagem erro: $_mensagemErro');
          print('AuthProvider.usuario: ${authProvider.usuario?.nome}');
          print('UsuarioProvider.usuarioLogado: ${usuarioProvider.usuarioLogado?.nome}');
          print('=============================');

          // Tela de loading
          if (_carregandoUsuario || authProvider.isLoading || usuarioProvider.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Carregando seu perfil...'),
                ],
              ),
            );
          }

          // Tela de erro
          if (_erroCarregamento || usuario == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _mensagemErro.contains('login') 
                        ? Icons.login 
                        : Icons.error_outline,
                      size: 64,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _mensagemErro.contains('login') 
                        ? 'Sessão expirada' 
                        : 'Erro ao carregar',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _mensagemErro,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    if (_mensagemErro.contains('login'))
                      ElevatedButton(
                        onPressed: () => _irParaLogin(context),
                        child: const Text('Fazer Login'),
                      )
                    else
                      ElevatedButton(
                        onPressed: () => _tentarNovamente(context),
                        child: const Text('Tentar Novamente'),
                      ),
                  ],
                ),
              ),
            );
          }

          // Carrega os dados quando o usuário estiver disponível
          _carregarDadosParaEdicao(usuario);

          return EditProfileView(
            usuario: usuario,
            onEditarPressed: () => _abrirModalEdicao(context, usuario),
            isLoading: false,
          );
        },
      ),
    );
  }
}