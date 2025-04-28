import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class InsertYourAddress extends StatefulWidget {
  const InsertYourAddress({super.key});

  @override
  State<InsertYourAddress> createState() => _InsertYourAddressState();
}

class _InsertYourAddressState extends State<InsertYourAddress> {
  late GoogleMapController mapController;
  final LatLng _initialPosition = const LatLng(-23.654381527390164, -46.56828075384198);
  final CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(-23.654381527390164, -46.56828075384198),
    zoom: 14,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PetFamilyAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Insira seu endereço',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: GoogleMap(
                    onMapCreated: (controller) => mapController = controller,
                    initialCameraPosition: initialCameraPosition,
                    markers: {
                      Marker(
                        markerId: const MarkerId('selected_location'),
                        position: _initialPosition,
                      ),
                    },
                  ),
                ),
                const SizedBox(height: 30),
                AppButton(
                  onPressed: () {},
                  label: 'Próximo',
                  fontSize: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}