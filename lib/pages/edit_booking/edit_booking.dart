import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/pages/edit_booking/informations/data/data_information.dart';
import 'package:pet_family_app/pages/edit_booking/informations/hotel/hotel_information.dart';
import 'package:pet_family_app/pages/edit_booking/informations/services/services_information.dart';
import 'package:pet_family_app/pages/edit_booking/informations/your_pets/your_pets_informations.dart';
import 'package:pet_family_app/pages/edit_booking/modal/booking_edited.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class EditBooking extends StatefulWidget {
  final ContratoModel contrato;
  final Function(ContratoModel)? onContratoEditado;

  const EditBooking({
    super.key,
    required this.contrato,
    this.onContratoEditado,
  });

  @override
  State<EditBooking> createState() => _EditBookingState();
}

class _EditBookingState extends State<EditBooking> {
  late ContratoModel _contratoEditado;

  @override
  void initState() {
    super.initState();
    // Cria uma cópia do contrato para edição
    _contratoEditado = ContratoModel.fromJson(widget.contrato.toJson());
  }

  void _onContratoAtualizado(ContratoModel contratoAtualizado) {
    setState(() {
      _contratoEditado = contratoAtualizado;
    });
  }

  void _onSalvarAlteracoes() {
    // Chama o callback para atualizar o contrato
    if (widget.onContratoEditado != null) {
      widget.onContratoEditado!(_contratoEditado);
    }

    // Mostra o modal de confirmação
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => BookingEdited(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBarReturn(route: '/core-navigation'),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Text(
                    'Editando agendamento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w200,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    widget.contrato.hospedagemNome ?? 'Agendamento',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Hotel Information - passa o contrato e callback
                  HotelInformation(
                    contrato: _contratoEditado,
                    onContratoAtualizado: _onContratoAtualizado,
                  ),

                  const SizedBox(height: 40),

                  // Data Information - passa o contrato e callback
                  DataInformation(
                    contrato: _contratoEditado,
                    onContratoAtualizado: _onContratoAtualizado,
                  ),

                  const SizedBox(height: 40),

                  // Services Information - passa o contrato e callback
                  ServicesInformation(
                    contrato: _contratoEditado,
                    onContratoAtualizado: _onContratoAtualizado,
                  ),

                  const SizedBox(height: 40),

                  // Your Pets Information - passa o contrato e callback
                  YourPetsInformations(
                    contrato: _contratoEditado,
                    onContratoAtualizado: _onContratoAtualizado,
                  ),

                  const SizedBox(height: 40),

                  AppButton(
                    onPressed: _onSalvarAlteracoes,
                    label: 'Salvar Alterações',
                    fontSize: 25,
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
