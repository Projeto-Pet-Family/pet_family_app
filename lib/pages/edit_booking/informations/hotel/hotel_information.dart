import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/edit_booking/informations/title_information_template.dart';

class HotelInformation extends StatefulWidget {
  const HotelInformation({super.key});

  @override
  State<HotelInformation> createState() => _HotelInformationState();
}

class _HotelInformationState extends State<HotelInformation> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitleInformationTemplate(description: 'Hospedagem'),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Hotel 1',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w200,
              color: Colors.black,
            ),
          ),
        )
      ],
    );
  }
}
