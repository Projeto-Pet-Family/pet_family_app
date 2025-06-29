import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/template/item_verification_template.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/template/title_verification_template.dart';

class ServicesInformation extends StatelessWidget {
  const ServicesInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleVerification(
          icon: Icons.cleaning_services,
          title: 'Serviço(s):',
        ),
        SizedBox(height: 10),
        ItemVerification(
          title: 'Banho & tosa',
          subTitle: 'Tico Tico',
          informations: 'R\$ 80,00',
        ),
      ],
    );
  }
}
