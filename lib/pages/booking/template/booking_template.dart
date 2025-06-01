import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/pages/booking/modal/cancel/cancel_modal.dart';
import 'package:pet_family_app/pages/booking/template/pet_icon_bookin_template.dart';
import 'package:pet_family_app/pages/booking/modal/show_more/show_more_modal.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class BookingTemplate extends StatefulWidget {
  const BookingTemplate({super.key});

  @override
  State<BookingTemplate> createState() => _BookingTemplateState();
}

class _BookingTemplateState extends State<BookingTemplate> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF8692DE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(
              Icons.house,
              size: 150,
              color: Colors.white,
            ),
            Text(
              'Hotel 1',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w200,
                color: Colors.white,
              ),
            ),
            Text(
              '25/07 - 30-07',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w200,
                color: Colors.white,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: PetIconBookinTemplate(),
                )
              ],
            ),
            AppButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) => ShowMoreModalTemplate(),
                );
              },
              label: 'Ver mais',
              fontSize: 18,
              buttonColor: Color(0xFFEDEDED),
              textButtonColor: Colors.black,
            ),
            SizedBox(height: 5),
            AppButton(
              onPressed: () {
                context.go('/edit-booking');
              },
              label: 'Editar',
              fontSize: 18,
              buttonColor: Color(0xFFEDEDED),
              textButtonColor: Colors.black,
            ),
            SizedBox(height: 5),
            AppButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) => CancelModal(),
                );
              },
              label: 'Cancelar',
              fontSize: 18,
              buttonColor: Color(0xFFEDEDED),
              textButtonColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
