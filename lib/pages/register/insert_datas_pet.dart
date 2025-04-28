import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_drop_down.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';

class InsertDatasPet extends StatefulWidget {
  const InsertDatasPet({super.key});

  @override
  State<InsertDatasPet> createState() => _InsertDatasPetState();
}

class _InsertDatasPetState extends State<InsertDatasPet> {
  TextEditingController nameController = TextEditingController();
  String? _speciesAnimalsType;
  String? _raceAnimalType;
  String? _sexAnimalType;
  TextEditingController observationAnimalController = TextEditingController();

  List<String> speciesAnimalsList = [
    'Gato',
    'Cachorro',
    'Passáro',
    'Peixe',
  ];

  List<String> raceAnimalList = [
    'Sem raça',
    'Rotwailer',
    'Munchikin',
  ];

  List<String> sexAnimalList = [
    'Macho',
    'Fêmea',
  ];

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
                    'Insira os dados do pet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                AppTextField(
                  controller: nameController,
                  labelText: 'Nome do pet',
                  hintText: 'Digite o nome do pet',
                ),
                AppDropDown<String>(
                  value: _speciesAnimalsType,
                  items: speciesAnimalsList,
                  label: 'Espécie',
                  hint: 'Selecione a espécie',
                  onChanged: (newValue) {
                    setState(() => _speciesAnimalsType = newValue);
                  },
                  isRequired: true,
                  errorMessage: 'Por favor, selecione a espécie do pet',
                ),
                AppDropDown<String>(
                  value: _raceAnimalType,
                  items: raceAnimalList,
                  label: 'Raça',
                  hint: 'Selecione a raça',
                  onChanged: (newValue) {
                    setState(() => _raceAnimalType = newValue);
                  },
                  isRequired: true,
                  errorMessage: 'Por favor, selecione a raça do pet',
                ),
                AppDropDown<String>(
                  value: _sexAnimalType,
                  items: sexAnimalList,
                  label: 'Sexo',
                  hint: 'Selecione a sexo',
                  onChanged: (newValue) {
                    setState(() => _sexAnimalType = newValue);
                  },
                  isRequired: true,
                  errorMessage: 'Por favor, selecione o sexo do pet',
                ),
                AppTextField(
                  controller: observationAnimalController,
                  labelText: 'Observações (opcional)',
                  hintText: 'Digite mais sobre seu pet',
                ),
                SizedBox(height: 30),
                AppButton(
                  onPressed: () {
                    context.go('/insert-your-datas');
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
