import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/booking/modal/show_more/service_for_pet_template.dart';
import 'package:pet_family_app/pages/booking/template/pet_icon_bookin_template.dart';

class PetShowMoreTemplate extends StatefulWidget {
  const PetShowMoreTemplate({super.key});

  @override
  State<PetShowMoreTemplate> createState() => _PetShowMoreTemplateState();
}

class _PetShowMoreTemplateState extends State<PetShowMoreTemplate> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF8692DE),
        borderRadius: BorderRadius.circular(30)
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            PetIconBookingTemplate(petName: 'Tico Tico'),
            ServiceForPetTemplate(),
            ServiceForPetTemplate(),
          ],
        ),
      ),
    );
  }
}