import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/template/item_verification_template.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/template/title_verification_template.dart';

class TaxasInformations extends StatelessWidget {
  const TaxasInformations({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleVerification(
          icon: Icons.article,
          title: 'Taxas:',
        ),
        SizedBox(height: 10),
        ItemVerification(
          title: 'Taxa do hotel',
          informations: 'R\$ 5,00',
        ),
        ItemVerification(
          title: 'Taxa do serviço',
          informations: 'R\$ 5,00',
        ),
      ],
    );
  }
}
