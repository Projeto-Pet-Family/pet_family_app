import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/profile/edit/edit_pet/modal/modal_edit_pet.dart';
import 'package:pet_family_app/pages/profile/edit/edit_pet/pet_edit_template.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';

class EditPet extends StatelessWidget {
  const EditPet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBarReturn(route: '/core-navigation'),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'veja',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w100,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'seus pets',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                PetEditTemplate(
                  name: 'Tico Tico',
                  onTap: () => showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) => ModalEditPet(),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
