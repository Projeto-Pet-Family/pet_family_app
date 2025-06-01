import 'package:flutter/material.dart';

class PetIconBookinTemplate extends StatefulWidget {
  const PetIconBookinTemplate({super.key});

  @override
  State<PetIconBookinTemplate> createState() => _PetIconBookinTemplateState();
}

class _PetIconBookinTemplateState extends State<PetIconBookinTemplate> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Padding(
            padding: const EdgeInsets.all(11),
            child: Icon(
              Icons.pets,
              size: 25,
            ),
          ),
        ),
        Text(
          'Tico Tico',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w200,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
