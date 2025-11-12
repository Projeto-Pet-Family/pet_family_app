import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/pages/edit_booking/informations/data/data_template.dart';
import 'package:pet_family_app/pages/edit_booking/informations/title_information_template.dart';

class DataInformation extends StatefulWidget {
  final ContratoModel contrato;
  final Function(ContratoModel)? onContratoAtualizado;

  const DataInformation({
    super.key,
    required this.contrato,
    this.onContratoAtualizado,
  });

  @override
  State<DataInformation> createState() => _DataInformationState();
}

class _DataInformationState extends State<DataInformation> {
  String _formatarData(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  String _formatarDataCompleta(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TitleInformationTemplate(description: 'Data Início:'),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: DataTemplate(
            data: _formatarDataCompleta(widget.contrato.dataInicio),
          ),
        ),
        const SizedBox(height: 16),
        const TitleInformationTemplate(description: 'Data Fim:'),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: DataTemplate(
            data: widget.contrato.dataFim != null
                ? _formatarDataCompleta(widget.contrato.dataFim!)
                : 'Não definida',
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Período: ${_formatarData(widget.contrato.dataInicio)} - ${widget.contrato.dataFim != null ? _formatarData(widget.contrato.dataFim!) : _formatarData(widget.contrato.dataInicio)}',
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
