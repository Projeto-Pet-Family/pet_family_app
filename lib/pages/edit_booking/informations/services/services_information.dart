import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/edit_booking/informations/services/services_template.dart';
import 'package:pet_family_app/pages/edit_booking/informations/title_information_template.dart';

class ServicesInformation extends StatefulWidget {
  const ServicesInformation({super.key});

  @override
  State<ServicesInformation> createState() => _ServicesInformationState();
}

class _ServicesInformationState extends State<ServicesInformation> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleInformationTemplate(description: 'Serviço(s)'),
        ServicesTemplate(price: 30.00, service: 'Banho'),
        ServicesTemplate(price: 150.00, service: 'Massagem'),
      ],
    );
  }
}
