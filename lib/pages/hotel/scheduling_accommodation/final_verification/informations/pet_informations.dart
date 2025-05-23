import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/template/item_verification_template.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/template/title_verification_template.dart';

class PetInformations extends StatelessWidget {
  const PetInformations({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleVerification(
          icon: Icons.pets,
          title: 'Pet(s):',
        ),
        SizedBox(height: 10),
        ItemVerification(title: 'Tico Tico'),
      ],
    );
  }
}
