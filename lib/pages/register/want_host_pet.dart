import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';

class WantHostPet extends StatelessWidget {
  const WantHostPet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PetFamilyAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  ),
                ),
                onPressed: () {
                  context.go('/login');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.pets,
                      size: 50,
                      color: Colors.black,
                    ),
                    Text(
                      'Quero hospedar meu pet',
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 17,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox()
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
