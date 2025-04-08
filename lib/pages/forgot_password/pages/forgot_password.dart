import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/forgot_password/widgets/choose_template.dart';
import 'package:pet_family_app/pages/forgot_password/widgets/modal/modal_send.dart';
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PetFamilyAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: Center(
          child: Column(
            children: [
              Text(
                'Recuperar senha',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF000000),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Escolha uma das opções a seguir para recuperar sua senha!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w100,
                  color: Color(0xFF000000),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChooseTemplate(
                      text: 'E-mail',
                      icon: Icons.email_outlined,
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) => ModalSend(
                          iconTitle: Icon(Icons.email_outlined),
                          textTitle: 'Iremos te enviar um token pelo seu E-mail digite abaixo seu endereço de e-mail',
                          label: 'E-mail',
                          hint: 'Digite seu E-mail',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 50),
                      child: Text(
                        'ou',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF000000),
                        ),
                      ),
                    ),
                    ChooseTemplate(
                      text: 'Celular',
                      icon: Icons.phone_android_outlined,
                      onTap: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (BuildContext context) => ModalSend(
                          iconTitle: Icon(Icons.phone_android_outlined),
                          textTitle: 'VIremos te enviar um token pelo seu SMS digite abaixo seu número de telefone:',
                          label: 'Telefone',
                          hint: 'Digite seu telefone',
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
