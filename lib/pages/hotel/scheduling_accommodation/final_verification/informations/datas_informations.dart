import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/template/item_verification_template.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/template/title_verification_template.dart';

class DatasInformations extends StatelessWidget {
  const DatasInformations({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleVerification(
          icon: Icons.calendar_month,
          title: 'Datas:',
        ),
        SizedBox(height: 10),
        ItemVerification(
          title: 'Início',
          informations: '03/06/2025',
        ),
        ItemVerification(
          title: 'Fim',
          informations: '04/06/2025',
        ),
      ],
    );
  }
}
