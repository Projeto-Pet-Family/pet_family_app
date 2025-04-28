import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/insert_token/modal/typing_new_password.dart';
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pinput/pinput.dart';

class InsertToken extends StatefulWidget {
  const InsertToken({super.key});

  @override
  State<InsertToken> createState() => _InsertTokenState();
}

class _InsertTokenState extends State<InsertToken> {
  final TextEditingController pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PetFamilyAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              Text(
                'Insira o token',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 13),
              Text(
                'Digite o token que lhe enviamos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w100,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Pinput(
                  length: 5,
                  defaultPinTheme: PinTheme(
                    width: 50,
                    height: 90,
                    textStyle: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFF0FFFE),
                      border: Border.all(
                        color: Color(0xFFCCCCCC),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              AppButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) => TypingNewPassword(),
                  );
                },
                label: 'Enviar',
                fontSize: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
