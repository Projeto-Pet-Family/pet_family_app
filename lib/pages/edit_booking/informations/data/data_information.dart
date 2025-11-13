import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/pages/edit_booking/informations/data/data_template.dart';
import 'package:pet_family_app/pages/edit_booking/informations/title_information_template.dart';
import 'package:pet_family_app/services/api_service.dart';

class DataInformation extends StatefulWidget {
  final ContratoModel contrato;
  final Function(ContratoModel, {String? tipoAlteracao})? onContratoAtualizado;
  final bool editavel;

  const DataInformation({
    super.key,
    required this.contrato,
    this.onContratoAtualizado,
    this.editavel = false,
  });

  @override
  State<DataInformation> createState() => _DataInformationState();
}

class _DataInformationState extends State<DataInformation> {
  bool _salvando = false;
  bool _salvandoLocal = false;

  String _formatarData(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  String _formatarDataCompleta(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatarDataParaAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selecionarData(BuildContext context, bool isDataInicio) async {
    if (!widget.editavel || _salvando || _salvandoLocal) return;

    final DateTime dataAtual = isDataInicio
        ? widget.contrato.dataInicio
        : widget.contrato.dataFim ?? widget.contrato.dataInicio;

    final DateTime primeiraData =
        isDataInicio ? DateTime.now() : widget.contrato.dataInicio;

    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: dataAtual,
      firstDate: primeiraData,
      lastDate: DateTime(DateTime.now().year + 2),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (dataSelecionada != null) {
      await _atualizarData(dataSelecionada, isDataInicio);
    }
  }

  Future<void> _atualizarData(DateTime novaData, bool isDataInicio) async {
    if (!widget.editavel) return;

    // Verifica se pode editar
    if (!widget.contrato.podeEditar) {
      _mostrarMensagem('Este contrato não pode ser editado', Colors.orange);
      return;
    }

    setState(() {
      _salvandoLocal = true;
    });

    try {
      ContratoModel contratoAtualizado;

      if (isDataInicio) {
        // Validações
        if (novaData.isBefore(DateTime.now())) {
          throw Exception('Data início não pode ser anterior à data atual');
        }

        contratoAtualizado = widget.contrato.copyWith(
          dataInicio: novaData,
          // Ajusta a data fim se necessário
          dataFim: widget.contrato.dataFim != null &&
                  widget.contrato.dataFim!.isBefore(novaData)
              ? novaData
              : widget.contrato.dataFim,
        );
      } else {
        // Validações
        if (novaData.isBefore(widget.contrato.dataInicio)) {
          throw Exception('Data fim não pode ser anterior à data início');
        }

        contratoAtualizado = widget.contrato.copyWith(
          dataFim: novaData,
        );
      }

      print('💾 Atualizando cache local...');

      // Notifica o callback com o tipo de alteração
      if (widget.onContratoAtualizado != null) {
        widget.onContratoAtualizado!(
          contratoAtualizado,
          tipoAlteracao: isDataInicio ? 'data_inicio' : 'data_fim',
        );
      }

      // Agora salva na API
      await _salvarDataNaAPI(novaData, isDataInicio);

      _mostrarMensagem(
        'Data ${isDataInicio ? 'de início' : 'de fim'} atualizada com sucesso!',
        Colors.green,
      );
    } catch (e) {
      print('❌ Erro ao atualizar data: $e');
      _mostrarMensagem('Erro: ${e.toString()}', Colors.red);

      // Reverte a alteração local em caso de erro na API
      if (widget.onContratoAtualizado != null) {
        widget.onContratoAtualizado!(
          widget.contrato,
          tipoAlteracao: 'reverter_alteracao',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _salvandoLocal = false;
        });
      }
    }
  }

  Future<void> _salvarDataNaAPI(DateTime novaData, bool isDataInicio) async {
    setState(() {
      _salvando = true;
    });

    try {
      final bool sucesso = await ApiService().atualizarDatasContrato(
        idContrato: widget.contrato.idContrato!,
        dataInicio: isDataInicio ? _formatarDataParaAPI(novaData) : null,
        dataFim: !isDataInicio ? _formatarDataParaAPI(novaData) : null,
      );

      if (!sucesso) {
        throw Exception('Falha ao salvar data na API');
      }

      print('✅ Data salva com sucesso na API');
    } catch (e) {
      print('❌ Erro ao salvar data na API: $e');
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _salvando = false;
        });
      }
    }
  }

  void _mostrarMensagem(String mensagem, Color cor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(mensagem, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: cor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Data Início
        _buildCampoData(
          titulo: 'Data Início:',
          data: widget.contrato.dataInicio,
          isDataInicio: true,
        ),
        const SizedBox(height: 16),

        // Data Fim
        _buildCampoData(
          titulo: 'Data Fim:',
          data: widget.contrato.dataFim,
          isDataInicio: false,
        ),
        const SizedBox(height: 8),

        // Período
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

  Widget _buildCampoData({
    required String titulo,
    required DateTime? data,
    required bool isDataInicio,
  }) {
    final bool podeEditar = widget.editavel && widget.contrato.podeEditar;
    final bool carregando = _salvando || _salvandoLocal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TitleInformationTemplate(description: titulo),
            if (podeEditar) ...[
              const SizedBox(width: 8),
            
            ] else if (widget.editavel && !widget.contrato.podeEditar) ...[
              const SizedBox(width: 8),

            ],
          ],
        ),
        const SizedBox(height: 4),
        carregando
            ? _buildLoadingIndicator(isDataInicio)
            : InkWell(
                onTap: podeEditar && !carregando
                    ? () => _selecionarData(context, isDataInicio)
                    : null,
                borderRadius: BorderRadius.circular(8),
                child: DataTemplate(
                  data: data != null
                      ? _formatarDataCompleta(data)
                      : 'Não definida',
                  isClickable: podeEditar && !carregando,
                ),
              ),
      ],
    );
  }

  Widget _buildLoadingIndicator(bool isDataInicio) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _salvando
                ? 'Salvando ${isDataInicio ? 'data início' : 'data fim'}...'
                : 'Processando...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
