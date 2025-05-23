import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/pet_data_template.dart';
import 'package:pet_family_app/widgets/your_data_template.dart';

class ConfirmYourDatas extends StatelessWidget {
  const ConfirmYourDatas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PetFamilyAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  'confirmar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w200,
                    color: Colors.black,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Dados',
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Pets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w200,
                    color: Colors.black,
                  ),
                ),
              ),
              PetDataTemplate(),
              SizedBox(height: 16),
              Text(
                'Seus dados',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w200,
                    color: Colors.black),
              ),
              YourDataTemplate(),
              SizedBox(height: 20),
              AppButton(
                onPressed: () {
                  context.go('/core-navigation');
                },
                label: 'Confirmar',
              )
            ],
          ),
        ),
      ),
    );
  }
}
