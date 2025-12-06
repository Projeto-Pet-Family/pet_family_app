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
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 70,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        child: Row(
          children: [
            Icon(Icons.pets, color: Colors.black, size: 25),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.petName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
