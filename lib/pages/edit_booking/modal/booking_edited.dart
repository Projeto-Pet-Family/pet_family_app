import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/pages/booking/modal/show_more/pet_show_more_template.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class BookingEdited extends StatefulWidget {
  const BookingEdited({super.key});

  @override
  State<BookingEdited> createState() => _BookingEditedState();
}

class _BookingEditedState extends State<BookingEdited> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.close,
                    size: 30,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'PetFamily',
                  style: TextStyle(
                    fontWeight: FontWeight.w100,
                    color: Color(0xFF8F8F8F),
                  ),
                ),
                SizedBox(width: 30),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Text(
                'Agendamento alterado com sucesso!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Text(
                    '25/07 - 30/07',
                    style: TextStyle(
                      fontWeight: FontWeight.w100,
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Rua dos Pinguins, 24, Kennedy,São Caetano, São Paulo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w200,
                    color: Color(0xFF1C1B1F),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'R\$ 200,00',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              ),
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.spaceBetween,
              children: [
                PetShowMoreTemplate(petName: '',),
                PetShowMoreTemplate(petName: '',),
                PetShowMoreTemplate(petName: '',),
              ],
            ),
            SizedBox(height: 30),
            AppButton(
              onPressed: () {
                Navigator.pop(context);
                context.go('/core-navigation');
              },
              label: 'Ok',
            ),
            SizedBox(height: 50)
          ],
        ),
      ),
    );
  }
}
