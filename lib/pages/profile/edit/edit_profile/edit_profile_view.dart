// lib/screens/edit_profile/edit_profile_view.dart
import 'package:flutter/material.dart';
import 'package:pet_family_app/models/user_model.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'profile_info_item.dart';

class EditProfileView extends StatelessWidget {
  final UsuarioModel usuario; // Mudar de Map<String, dynamic> para UsuarioModel
  final VoidCallback onEditarPressed;
  final bool isLoading;

  const EditProfileView({
    super.key,
    required this.usuario,
    required this.onEditarPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppBarReturn(route: '/core-navigation'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Meu',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w100,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      'Perfil',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),

                    const SizedBox(height: 40),

                    // Informações do usuário
                    ProfileInfoItem(
                      label: 'Nome',
                      value: usuario.nome,
                      isLoading: isLoading,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    ProfileInfoItem(
                      label: 'CPF',
                      value: usuario.cpf,
                      isLoading: isLoading,
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),

                    ProfileInfoItem(
                      label: 'Email',
                      value: usuario.email,
                      isLoading: isLoading,
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),

                    ProfileInfoItem(
                      label: 'Telefone',
                      value: usuario.telefone,
                      isLoading: isLoading,
                      icon: Icons.phone_outlined,
                    ),

                    const SizedBox(height: 40),

                    // Botão Editar Dados
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : onEditarPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC0C9FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.black,
                              ),
                        label: isLoading
                            ? const Text(
                                'Atualizando...',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : const Text(
                                'Editar Dados',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
