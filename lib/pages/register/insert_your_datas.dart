import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';

class InsertYourDatas extends StatefulWidget {
  const InsertYourDatas({super.key});

  @override
  State<InsertYourDatas> createState() => _InsertYourDatasState();
}

class _InsertYourDatasState extends State<InsertYourDatas> {
  TextEditingController nameController = TextEditingController();
  TextEditingController cpfController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordControler = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PetFamilyAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Insira seus dados',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                AppTextField(
                  controller: nameController,
                  labelText: 'Nome completo',
                  hintText: 'Digite seu nome completo',
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: cpfController,
                  labelText: 'CPF',
                  hintText: 'Digite seu CPF',
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: phoneController,
                  labelText: 'Telefone',
                  hintText: 'Digite seu telefone',
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: emailController,
                  labelText: 'E-mail',
                  hintText: 'Digite seu E-mail',
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: passwordController,
                  labelText: 'Senha',
                  hintText: 'Digite sua senha',
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: confirmPasswordControler,
                  labelText: 'Confirmar senha',
                  hintText: 'Confirme sua senha',
                ),
                const SizedBox(height: 30),
                AppButton(
                  onPressed: () {
                    context.go('/insert-your-address');
                  },
                  label: 'Próximo',
                  fontSize: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
