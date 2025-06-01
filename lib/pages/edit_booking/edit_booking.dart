import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/edit_booking/informations/data/data_information.dart';
import 'package:pet_family_app/pages/edit_booking/informations/hotel/hotel_information.dart';
import 'package:pet_family_app/pages/edit_booking/informations/services/services_information.dart';
import 'package:pet_family_app/pages/edit_booking/informations/your_pets/your_pets_informations.dart';
import 'package:pet_family_app/pages/edit_booking/modal/booking_edited.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class EditBooking extends StatefulWidget {
  const EditBooking({super.key});

  @override
  State<EditBooking> createState() => _EditBookingState();
}

class _EditBookingState extends State<EditBooking> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBarReturn(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Text(
                    'alterando dados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w200,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Agendamento Hotel 1',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 40),
                  HotelInformation(),
                  SizedBox(height: 40),
                  DataInformation(),
                  SizedBox(height: 40),
                  ServicesInformation(),
                  SizedBox(height: 40),
                  YourPetsInformations(),
                  SizedBox(height: 40),
                  AppButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) => BookingEdited(),
                      );
                    },
                    label: 'Alterar',
                    fontSize: 25,
                  ),
                  SizedBox(height: 50),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
