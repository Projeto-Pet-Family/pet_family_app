import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class EditedPetModal extends StatefulWidget {
  const EditedPetModal({super.key});

  @override
  State<EditedPetModal> createState() => _EditedPetModalState();
}

class _EditedPetModalState extends State<EditedPetModal> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {},
              child: Icon(Icons.close),
            ),
          ),
          SizedBox(height: 30),
          Text(
            'Dados de Tico Tico foram alterados com sucesso!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w200,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 30),
          Icon(
            Icons.edit,
            size: 80,
          ),
          SizedBox(height: 30),
          AppButton(
            fontSize: 20,
            onPressed: () {
              Navigator.pop(context);
              context.go('/core-navigation');
            },
            label: 'Ok',
          )
        ],
      ),
    );
  }
}
