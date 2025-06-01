import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/profile/edit/edit_pet/modal/edited_pet_modal.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';

class ModalEditPet extends StatefulWidget {
  const ModalEditPet({super.key});

  @override
  State<ModalEditPet> createState() => _ModalEditPetState();
}

class _ModalEditPetState extends State<ModalEditPet> {
  final TextEditingController specieController = TextEditingController();
  final TextEditingController raceController = TextEditingController();
  final TextEditingController sexController = TextEditingController();
  final TextEditingController observationsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.close,
                  size: 30,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                const Icon(Icons.pets, size: 40),
                const SizedBox(width: 16),
                const Text(
                  'Tico Tico',
                  style: TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            AppTextField(
              controller: specieController,
              labelText: 'Espécie',
            ),
            SizedBox(height: 10),
            AppTextField(
              controller: raceController,
              labelText: 'Raça',
            ),
            SizedBox(height: 10),
            AppTextField(
              controller: sexController,
              labelText: 'Sexo',
            ),
            SizedBox(height: 10),
            AppTextField(
              controller: observationsController,
              labelText: 'Observações',
            ),
            SizedBox(height: 30),
            AppButton(
              onPressed: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) => EditedPetModal(),
                );
              },
              label: 'Salvar',
              fontSize: 30,
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
