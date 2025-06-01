import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/booking/modal/cancel/booking_canceled.dart';
import 'package:pet_family_app/pages/booking/modal/show_more/pet_show_more_template.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class CancelModal extends StatefulWidget {
  const CancelModal({super.key});

  @override
  State<CancelModal> createState() => _CancelModalState();
}

class _CancelModalState extends State<CancelModal> {
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
                'Deseja cancelar agendamento em Hotel?',
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
                PetShowMoreTemplate(),
                PetShowMoreTemplate(),
                PetShowMoreTemplate(),
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) => BookingCanceled(),
                      );
                    },
                    label: 'Sim',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    label: 'Não',
                    buttonColor: Colors.white,
                    textButtonColor: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 50)
          ],
        ),
      ),
    );
  }
}
