// lib/screens/edit_profile/edit_profile_view.dart
import 'package:flutter/material.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'profile_info_item.dart';

class EditProfileView extends StatelessWidget {
  final Map<String, dynamic> usuario;
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

                    // Foto de perfil
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                            ),
                            child: isLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.grey[600],
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey[600],
                                  ),
                          ),
                          if (!isLoading)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFFC0C9FF),
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 20,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Informações do usuário
                    ProfileInfoItem(
                      label: 'Nome',
                      value: usuario['nome']?.toString() ?? '',
                      isLoading: isLoading,
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    ProfileInfoItem(
                      label: 'CPF',
                      value: usuario['cpf']?.toString() ?? '',
                      isLoading: isLoading,
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),

                    ProfileInfoItem(
                      label: 'Email',
                      value: usuario['email']?.toString() ?? '',
                      isLoading: isLoading,
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),

                    ProfileInfoItem(
                      label: 'Telefone',
                      value: usuario['telefone']?.toString() ?? '',
                      isLoading: isLoading,
                      icon: Icons.phone_outlined,
                    ),
                    const SizedBox(height: 16),

                    if (usuario['datacadastro'] != null)
                      Column(
                        children: [
                          ProfileInfoItem(
                            label: 'Data de Cadastro',
                            value: usuario['datacadastro']?.toString() ?? '',
                            isLoading: isLoading,
                            icon: Icons.calendar_today_outlined,
                          ),
                          const SizedBox(height: 16),
                        ],
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
