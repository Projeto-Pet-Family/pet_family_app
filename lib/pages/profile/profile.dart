import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/pages/profile/button_option_profile_template.dart';
import 'package:pet_family_app/providers/auth_provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _carregando = false;
  bool _erroCarregamento = false;

  @override
  void initState() {
    super.initState();
    _verificarAutenticacao();
  }

  Future<void> _verificarAutenticacao() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Se não tem usuário, tenta verificar se está autenticado
    if (authProvider.usuario == null) {
      setState(() {
        _carregando = true;
      });

      try {
        // Usar o método correto do AuthProvider
        await authProvider.checkAuthentication();

        // Verificar se agora tem usuário
        if (authProvider.usuario == null) {
          // Se ainda não tem usuário, redireciona para login
          if (mounted) {
            Future.delayed(Duration.zero, () {
              context.go('/login');
            });
          }
        }
      } catch (e) {
        setState(() {
          _erroCarregamento = true;
        });

        print('❌ Erro ao verificar autenticação: $e');
      } finally {
        if (mounted) {
          setState(() {
            _carregando = false;
          });
        }
      }
    }
  }

  Future<void> _recarregarPerfil() async {
    setState(() {
      _carregando = true;
      _erroCarregamento = false;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.recarregarUsuario();
    } catch (e) {
      setState(() {
        _erroCarregamento = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar perfil: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final usuario = authProvider.usuario;

          // Se tem erro de carregamento
          if (_erroCarregamento) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Erro ao carregar perfil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Não foi possível carregar as informações do seu perfil.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _recarregarPerfil,
                      child: Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          // Se está carregando (apenas no primeiro carregamento)
          if (usuario == null && _carregando) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Carregando perfil...'),
                ],
              ),
            );
          }

          // Se não tem usuário nem está carregando, tenta redirecionar
          if (usuario == null) {
            // Aguarda um pouco e tenta redirecionar
            Future.delayed(Duration.zero, () {
              if (mounted) {
                context.go('/login');
              }
            });

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Redirecionando para login...'),
                ],
              ),
            );
          }

          // Se chegou aqui, tem usuário e pode mostrar o perfil
          final nome = usuario.nome;
          final email = usuario.email;
          final telefone = usuario.telefone;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 50),

                  Text(
                    'Meu Perfil',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: 30),

                  // Informações do usuário
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFC0C9FF),
                          ),
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 16),

                        // Dados do usuário
                        Text(
                          nome,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),

                  // Opções do perfil
                  _buildOpcoesPerfil(context, authProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOpcoesPerfil(BuildContext context, AuthProvider authProvider) {
    return Column(
      children: [
        ButtonOptionProfileTemplate(
          icon: Icons.person_outline,
          title: 'Editar Perfil',
          description: 'Altere seus dados pessoais',
          onTap: () {
            context.go('/edit-profile');
          },
        ),
        SizedBox(height: 12),
        ButtonOptionProfileTemplate(
          icon: Icons.pets,
          title: 'Meus Pets',
          description: 'Gerencie seus animais de estimação',
          onTap: () {
            context.go('/edit-pet');
          },
        ),
        SizedBox(height: 12),
        ButtonOptionProfileTemplate(
          icon: Icons.exit_to_app,
          title: 'Sair',
          description: 'Encerrar sessão',
          onTap: () {
            _mostrarDialogoSair(context, authProvider);
          },
        ),
      ],
    );
  }

  void _mostrarDialogoSair(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text('Sair da Conta'),
            ],
          ),
          content: Text(
            'Tem certeza que deseja sair? Você precisará fazer login novamente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await authProvider.logout();
                if (context.mounted) {
                  context.go('/');
                }
              },
              child: Text(
                'Sair',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
