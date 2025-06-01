import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/edit_booking/informations/title_information_template.dart';
import 'package:pet_family_app/pages/edit_booking/informations/your_pets/pets_booking_template.dart';

class YourPetsInformations extends StatefulWidget {
  const YourPetsInformations({super.key});

  @override
  State<YourPetsInformations> createState() => _YourPetsInformationsState();
}

class _YourPetsInformationsState extends State<YourPetsInformations> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleInformationTemplate(description: 'Seu(s) pet(s)'),
        PetsBookingTemplate(name: 'Tico Tico')
      ],
    );
  }
}
