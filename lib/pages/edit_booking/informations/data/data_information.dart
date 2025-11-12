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

  Future<void> _selecionarData(BuildContext context, bool isDataInicio) async {
    final DateTime dataAtual = isDataInicio
        ? widget.contrato.dataInicio
        : widget.contrato.dataFim ?? widget.contrato.dataInicio;

    final DateTime primeiraData =
        isDataInicio ? DateTime.now() : widget.contrato.dataInicio;

    // Cria um novo contexto para o date picker
    final BuildContext dialogContext = context;

    final DateTime? dataSelecionada = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: DatePickerDialog(
            initialDate: dataAtual,
            firstDate: primeiraData,
            lastDate: DateTime(DateTime.now().year + 2),
          ),
        );
      },
    );

    if (dataSelecionada != null) {
      ContratoModel contratoAtualizado;

      if (isDataInicio) {
        contratoAtualizado = widget.contrato.copyWith(
          dataInicio: dataSelecionada,
          dataFim: widget.contrato.dataFim != null &&
                  widget.contrato.dataFim!.isBefore(dataSelecionada)
              ? dataSelecionada
              : widget.contrato.dataFim,
        );
      } else {
        contratoAtualizado = widget.contrato.copyWith(
          dataFim: dataSelecionada,
        );
      }

      if (widget.onContratoAtualizado != null) {
        widget.onContratoAtualizado!(contratoAtualizado);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const TitleInformationTemplate(description: 'Data Início:'),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () => _selecionarData(context, true),
            borderRadius: BorderRadius.circular(8),
            child: DataTemplate(
              data: _formatarDataCompleta(widget.contrato.dataInicio),
              isClickable: true,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const TitleInformationTemplate(description: 'Data Fim:'),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: () => _selecionarData(context, false),
            borderRadius: BorderRadius.circular(8),
            child: DataTemplate(
              data: widget.contrato.dataFim != null
                  ? _formatarDataCompleta(widget.contrato.dataFim!)
                  : 'Não definida',
              isClickable: true,
            ),
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
