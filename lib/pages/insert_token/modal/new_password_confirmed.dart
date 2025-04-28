import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class NewPasswordConfirmed extends StatefulWidget {
  const NewPasswordConfirmed({super.key});

  @override
  State<NewPasswordConfirmed> createState() => _NewPasswordConfirmedState();
}

class _NewPasswordConfirmedState extends State<NewPasswordConfirmed> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        height: 450,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Text(
                'Pronto!',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Icon(
                  Icons.pets,
                  size: 100,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Sua nova senha foi criada com sucesso!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w200,
                    color: Colors.black,
                  ),
                ),
              ),
              AppButton(
                onPressed: () {
                  context.go('/login');
                },
                label: 'Voltar para login',
                fontSize: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
