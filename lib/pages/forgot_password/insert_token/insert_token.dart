/* import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/pages/forgot_password/insert_token/modal/typing_new_password.dart';
import 'package:pet_family_app/providers/auth_provider.dart';
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
    final authProvider = Provider.of<AuthProvider>(context);

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
              
              // ✅ Mensagem de instrução
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'O token foi exibido no console do backend',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Pinput(
                  controller: pinController,
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
              
              if (authProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    authProvider.errorMessage!,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              authProvider.isLoading
                  ? CircularProgressIndicator()
                  : AppButton(
                      onPressed: () {
                        if (pinController.text.length == 5) {
                          // ✅ Abre o modal para digitar nova senha, passando o token
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (BuildContext context) => TypingNewPassword(
                              token: pinController.text,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Digite um token válido de 5 caracteres'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      label: 'Continuar',
                      fontSize: 40,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }
} */