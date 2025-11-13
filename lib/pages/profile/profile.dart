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

  Future<void> _recarregarPerfil() async {
    setState(() {
      _carregando = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.recarregarUsuario();

    setState(() {
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final usuario = authProvider.usuarioLogado;

          if (usuario == null || _carregando) {
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

          final nome = usuario['nome'] ?? 'Usuário';
          final email = usuario['email'] ?? '';
          final telefone = usuario['telefone'] ?? '';

          return Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 50),

                  // Header com refresh
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: _recarregarPerfil,
                        tooltip: 'Atualizar perfil',
                      ),
                      Spacer(),
                      Text(
                        'Meu Perfil',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      SizedBox(width: 48), // Para balancear o layout
                    ],
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

                        // Dados
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nome,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              if (telefone != null && telefone.isNotEmpty) ...[
                                SizedBox(height: 4),
                                Text(
                                  telefone,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),

                  // Opções
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
              'Tem certeza que deseja sair? Você precisará fazer login novamente.'),
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
              child: Text('Sair', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
