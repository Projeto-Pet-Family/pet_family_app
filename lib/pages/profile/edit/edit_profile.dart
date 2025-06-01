import 'package:flutter/material.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cpfController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              AppBarReturn(route: '/core-navigation',),
              SizedBox(height: 50),
              Text(
                'editando',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w100,
                  color: Colors.black,
                ),
              ),
              Text(
                'Seu Perfil',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 40),
              AppTextField(
                controller: nameController,
                labelText: 'Nome completo',
              ),
              SizedBox(height: 20),
              AppTextField(
                controller: emailController,
                labelText: 'E-mail',
              ),
              SizedBox(height: 20),
              AppTextField(
                controller: cpfController,
                labelText: 'CPF',
              ),
              SizedBox(height: 20),
              AppTextField(
                controller: phoneController,
                labelText: 'Telefone',
              ),
              SizedBox(height: 20),
              AppTextField(
                controller: addressController,
                labelText: 'Endereço',
              ),
              SizedBox(height: 50),
              AppButton(
                onPressed: () {},
                label: 'Alterar seus dados',
                fontSize: 25,
              ),
              SizedBox(height: 70),
            ],
          ),
        ),
      ),
    ));
  }
}
