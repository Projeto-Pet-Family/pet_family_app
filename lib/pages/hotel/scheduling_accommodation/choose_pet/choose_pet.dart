import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_pet/pet_template.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class ChoosePet extends StatefulWidget {
  const ChoosePet({super.key});

  @override
  State<ChoosePet> createState() => _ChoosePetState();
}

class _ChoosePetState extends State<ChoosePet> {
  final Set<int> _selectedPets = {};

  final List<String> _pets = ['Tico Tico', 'Nana', 'Joseph'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBarReturn(route: '/core-navigation',),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'Escolha o(s) pet(s)',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w200,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Lista de pets
                  ..._pets.asMap().entries.map((entry) {
                    final index = entry.key;
                    final petName = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: PetTemplate(
                        name: petName,
                        isSelected: _selectedPets.contains(index),
                        onTap: () {
                          setState(() {
                            if (_selectedPets.contains(index)) {
                              _selectedPets.remove(
                                  index); // Desmarca se já estava selecionado
                            } else {
                              _selectedPets.add(
                                  index); // Marca se não estava selecionado
                            }
                          });
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 60),
                  if (_selectedPets.isNotEmpty)
                    AppButton(
                      onPressed: () {
                        context.go('/choose-data');
                      },
                      label: 'Próximo',
                      fontSize: 18,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
