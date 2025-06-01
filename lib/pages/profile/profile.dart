import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/pages/profile/button_option_profile_template.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
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
                    Icon(
                      Icons.person,
                      size: 100,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tutor da Silva',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w200,
                            color: Colors.black,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFC0C9FF)),
                          onPressed: () {
                            context.go('/edit-profile');
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit,
                                size: 24,
                                color: Color(0xFF000000),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Editar perfil',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w200,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(height: 50),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
