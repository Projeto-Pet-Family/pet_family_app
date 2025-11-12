import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/pages/edit_booking/informations/title_information_template.dart';

class HotelInformation extends StatefulWidget {
  final ContratoModel contrato;
  final Function(ContratoModel)? onContratoAtualizado;

  const HotelInformation({
    super.key,
    required this.contrato,
    this.onContratoAtualizado,
  });

  @override
  State<HotelInformation> createState() => _HotelInformationState();
}

class _HotelInformationState extends State<HotelInformation> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TitleInformationTemplate(description: 'Hospedagem'),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.contrato.hospedagemNome ?? 'Hospedagem não informada',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w200,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.contrato.hospedagemEndereco ?? 'Endereço não informado',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
