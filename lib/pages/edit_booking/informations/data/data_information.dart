import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/pages/edit_booking/informations/data/data_template.dart';
import 'package:pet_family_app/pages/edit_booking/informations/title_information_template.dart';
import 'package:pet_family_app/services/api_service.dart';
import 'package:pet_family_app/services/contrato_service.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

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
    final String dataFormatada =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    print('🔧 Formatando data para API:');
    print('  📅 Data original: $date');
    print('  📅 Data formatada: $dataFormatada');
    print('  📅 Tipo da formatada: ${dataFormatada.runtimeType}');
    print('  📅 Tamanho: ${dataFormatada.length} caracteres');

    return dataFormatada;
  }

  Future<void> _selecionarData(BuildContext context, bool isDataInicio) async {
    if (!widget.editavel || _salvando || _salvandoLocal) return;

    final DateTime dataAtual = isDataInicio
        ? widget.contrato.dataInicio
        : widget.contrato.dataFim ?? widget.contrato.dataInicio;

    // CORREÇÃO: Garantir que o initialDate não seja anterior ao firstDate
    DateTime primeiraData;
    if (isDataInicio) {
      primeiraData = DateTime.now();
    } else {
      // Para data de fim, a primeira data deve ser a data de início
      primeiraData = widget.contrato.dataInicio;
    }

    // CORREÇÃO: Ajustar o initialDate se ele for anterior ao firstDate
    DateTime initialDateAjustado = dataAtual;
    if (initialDateAjustado.isBefore(primeiraData)) {
      initialDateAjustado = primeiraData;
    }

    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: initialDateAjustado, // Usar a data ajustada
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
      final String dataFormatada = _formatarDataParaAPI(novaData);
      print('📤 Enviando data para API:');
      print('  📅 Data original: $novaData');
      print('  📅 Data formatada: $dataFormatada');
      print('  📅 Tipo: ${isDataInicio ? "Início" : "Fim"}');

      final ContratoModel contratoAtualizado = await ContratoService(
        dio: Dio(),
        client: http.Client(),
      ).atualizarDatasContrato(
        idContrato: widget.contrato.idContrato!,
        dataInicio: isDataInicio ? dataFormatada : null,
        dataFim: !isDataInicio ? dataFormatada : null,
      );

      print('✅ Data salva com sucesso na API');
      print('📄 Contrato atualizado: ${contratoAtualizado.idContrato}');

      // Atualiza o contrato local com os dados retornados da API
      if (widget.onContratoAtualizado != null) {
        widget.onContratoAtualizado!(
          contratoAtualizado,
          tipoAlteracao: isDataInicio ? 'data_inicio' : 'data_fim',
        );
      }
    } catch (e) {
      print('❌ Erro ao salvar data na API: $e');

      // Reverte a alteração local em caso de erro na API
      if (widget.onContratoAtualizado != null) {
        widget.onContratoAtualizado!(
          widget.contrato,
          tipoAlteracao: 'reverter_alteracao',
        );
      }

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
        content: Text(
          mensagem,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
