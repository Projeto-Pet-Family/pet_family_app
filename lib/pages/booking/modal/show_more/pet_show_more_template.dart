import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/booking/template/pet_icon_bookin_template.dart';

class PetShowMoreTemplate extends StatefulWidget {
  final String petName;

  const PetShowMoreTemplate({
    super.key,
    required this.petName,
  });

  @override
  State<PetShowMoreTemplate> createState() => _PetShowMoreTemplateState();
}

class _PetShowMoreTemplateState extends State<PetShowMoreTemplate> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF8692DE),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PetIconBookingTemplate(petName: widget.petName),
      ),
    );
  }
}
