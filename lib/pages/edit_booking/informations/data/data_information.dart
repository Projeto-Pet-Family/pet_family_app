import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/edit_booking/informations/data/data_template.dart';
import 'package:pet_family_app/pages/edit_booking/informations/title_information_template.dart';
class DataInformation extends StatefulWidget {
  const DataInformation({super.key});

  @override
  State<DataInformation> createState() => _DataInformationState();
}

class _DataInformationState extends State<DataInformation> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleInformationTemplate(description: 'Data Início:'),
        Align(
          alignment: Alignment.centerLeft,
          child: DataTemplate(data: '25/07'),
        ),
        SizedBox(height: 10),
        TitleInformationTemplate(description: 'Data Fim:'),
        Align(
          alignment: Alignment.centerLeft,
          child: DataTemplate(data: '30/07'),
        ),
      ],
    );
  }
}
