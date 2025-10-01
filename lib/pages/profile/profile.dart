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
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final usuario = authProvider.usuarioLogado;

    if (usuario == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final nome = usuario['nome'] ?? 'Usuário';
    final email = usuario['email'] ?? '';

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 50),
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nome,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFC0C9FF),
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            onPressed: () {
                              context.go('/edit-profile');
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Color(0xFF000000),
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Editar perfil',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: 50),
                
                // ✅ APENAS OS BOTÕES DE OPÇÕES PERMANECEM
                ButtonOptionProfileTemplate(
                  icon: Icons.person,
                  title: 'Seu perfil',
                  description: 'Veja todos os detalhes do seu perfil',
                  onTap: () {
                    context.go('/edit-profile');
                  },
                ),
                SizedBox(height: 8),
                ButtonOptionProfileTemplate(
                  icon: Icons.pets,
                  title: 'Seu(s) pet(s)',
                  description: 'Veja todos os seus pets',
                  onTap: () {
                    context.go('/edit-pet');
                  },
                ),
                SizedBox(height: 8),
                ButtonOptionProfileTemplate(
                  icon: Icons.security,
                  title: 'Segurança',
                  description: 'Altere sua senha e configurações de segurança',
                  onTap: () {
                    // context.go('/security');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}