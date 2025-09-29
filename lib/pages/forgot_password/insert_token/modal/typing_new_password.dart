import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/forgot_password/insert_token/modal/new_password_confirmed.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';

class TypingNewPassword extends StatefulWidget {
  const TypingNewPassword({super.key});

  @override
  State<TypingNewPassword> createState() => _TypingNewPasswordState();
}

class _TypingNewPasswordState extends State<TypingNewPassword> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        height: 500,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Digite sua nova senha',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 25,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: AppTextField(
                  labelText: 'Nova senha',
                  hintText: 'Digite sua nova senha',
                  controller: newPasswordController,
                  keyboardType: TextInputType.text,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: AppTextField(
                  labelText: 'Confirmar nova senha',
                  hintText: 'Confirme sua nova senha',
                  controller: confirmNewPasswordController,
                  keyboardType: TextInputType.text,
                ),
              ),
              SizedBox(height: 30),
              AppButton(
                onPressed: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) => NewPasswordConfirmed(),
                  );
                },
                label: 'Enviar',
                fontSize: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
