import 'package:flutter/material.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class ConfirmedRemovePet extends StatefulWidget {
  const ConfirmedRemovePet({super.key});

  @override
  State<ConfirmedRemovePet> createState() => _ConfirmedRemovePetState();
}

class _ConfirmedRemovePetState extends State<ConfirmedRemovePet> {
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
              'Pet removido com sucesso',
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
          AppButton(
            onPressed: () {
              Navigator.pop(context);
            },
            label: 'Ok',
          ),
          SizedBox(width: 50)
        ],
      ),
    );
  }
}
