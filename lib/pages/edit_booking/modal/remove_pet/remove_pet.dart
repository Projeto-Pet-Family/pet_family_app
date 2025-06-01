import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/edit_booking/modal/remove_pet/confirmed_remove_pet.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class RemovePet extends StatefulWidget {
  const RemovePet({super.key});

  @override
  State<RemovePet> createState() => _RemovePetState();
}

class _RemovePetState extends State<RemovePet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Icon(Icons.close),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Deseja remover pet do agendamento?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w200,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color(0xFF8692DE),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(
                Icons.pets,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            'Nana',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w200,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) => ConfirmedRemovePet(),
                    );
                  },
                  label: 'Sim',
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  label: 'Não',
                  buttonColor: Colors.white,
                  textButtonColor: Colors.black,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
