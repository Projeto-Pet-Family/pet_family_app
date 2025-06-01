import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/edit_booking/modal/remove_pet/remove_pet.dart';

class PetsBookingTemplate extends StatefulWidget {
  final String name;
  const PetsBookingTemplate({
    super.key,
    required this.name,
  });

  @override
  State<PetsBookingTemplate> createState() => _PetsBookingTemplateState();
}

class _PetsBookingTemplateState extends State<PetsBookingTemplate> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF0FFFE),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.pets,
                    size: 15,
                  ),
                  SizedBox(width: 8),
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w200,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) => RemovePet(),
                  );
                },
                child: Icon(Icons.remove),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
