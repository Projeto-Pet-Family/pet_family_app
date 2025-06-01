import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/booking/template/booking_template.dart';
import 'package:pet_family_app/widgets/app_drop_down.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  String? _optionSelected;

  List<String> listOptions = [
    'em aprovação',
    'aprovado',
    'em execução',
    'concluido',
    'Negado',
    'Cancelado'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 50),
          child: Column(
            children: [
              Text(
                'seus',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w200,
                  color: Colors.black,
                ),
              ),
              Text(
                'Agendamentos',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              AppDropDown<String>(
                value: _optionSelected,
                items: listOptions,
                label: '',
                hint: 'Selecione uma opção',
                onChanged: (newValue) {
                  setState(() => _optionSelected = newValue);
                },
                isRequired: true,
                errorMessage: 'Por favor, selecione uma opção',
              ),
              BookingTemplate(),
            ],
          ),
        ),
      ),
    );
  }
}
