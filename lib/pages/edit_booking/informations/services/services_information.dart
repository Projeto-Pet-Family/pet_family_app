import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/models/service_model.dart';
import 'package:pet_family_app/pages/edit_booking/informations/services/services_template.dart';
import 'package:pet_family_app/pages/edit_booking/informations/title_information_template.dart';
import 'package:pet_family_app/services/api_service.dart'; // Importe seu serviço de API

class ServicesInformation extends StatefulWidget {
  final ContratoModel contrato;
  final Function(ContratoModel, {String? tipoAlteracao})? onContratoAtualizado;
  final bool editavel;

  const ServicesInformation({
    super.key,
    required this.contrato,
    this.onContratoAtualizado,
    this.editavel = false,
  });

  @override
  State<ServicesInformation> createState() => _ServicesInformationState();
}

class _ServicesInformationState extends State<ServicesInformation> {
  bool _carregando = false;

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      String cleanedValue = value
          .replaceAll('R\$', '')
          .replaceAll(',', '.')
          .replaceAll(RegExp(r'[^\d.]'), '');

      try {
        return double.parse(cleanedValue);
      } catch (e) {
        return 0.0;
      }
    }

    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 1;

    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 1;
      }
    }

    return 1;
  }

  double _calcularTotalServicos() {
    if (widget.contrato.servicos == null || widget.contrato.servicos!.isEmpty) {
      return 0.0;
    }

    double total = 0.0;
    for (var servico in widget.contrato.servicos!) {
      double precoUnitario = 0;
      int quantidade = 1;

      if (servico is Map<String, dynamic>) {
        precoUnitario = _parseDouble(servico['preco_unitario']);
        quantidade = _parseInt(servico['quantidade']);
      } else if (servico is ServiceModel) {
        precoUnitario = servico.preco;
        quantidade = 1;
      }

      total += precoUnitario * quantidade;
    }
    return total;
  }

  Future<void> _removerServico(int index) async {
    if (!widget.editavel || _carregando) return;

    if (widget.contrato.servicos == null ||
        index >= widget.contrato.servicos!.length) {
      return;
    }

    final servicoParaRemover = widget.contrato.servicos![index];
    int? idServico;

    // Extrai o ID do serviço baseado no tipo
    if (servicoParaRemover is Map<String, dynamic>) {
      idServico = servicoParaRemover['idservico'] as int?;
    } else if (servicoParaRemover is ServiceModel) {
      idServico = servicoParaRemover.idServico;
    }

    if (idServico == null) {
      print('❌ ID do serviço não encontrado');
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      print('🗑️ Removendo serviço ID: $idServico');

      // Chama a API para remover o serviço
      final bool sucesso = await ApiService().removerServicoContrato(
        idContrato: widget.contrato.idContrato!,
        idServico: idServico,
      );

      if (sucesso) {
        print('✅ Serviço removido com sucesso na API');

        // Atualiza a lista localmente
        final List<dynamic> novosServicos =
            List.from(widget.contrato.servicos!);
        novosServicos.removeAt(index);

        final contratoAtualizado = widget.contrato.copyWith(
          servicos: novosServicos.isEmpty ? null : novosServicos,
        );

        // Notifica o componente pai sobre a atualização
        if (widget.onContratoAtualizado != null) {
          widget.onContratoAtualizado!(contratoAtualizado,
              tipoAlteracao: 'servico_removido');
        }

        // Mostra mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Serviço removido com sucesso'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Falha ao remover serviço na API');
      }
    } catch (e) {
      print('❌ Erro ao remover serviço: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover serviço: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  void _adicionarServico() {
    if (!widget.editavel || _carregando) return;

    // Implemente a lógica para adicionar serviço
    // Pode ser um modal para selecionar serviços disponíveis
  }

  void _confirmarRemocaoServico(int index) {
    String nomeServico = 'Serviço';

    if (index < widget.contrato.servicos!.length) {
      final servico = widget.contrato.servicos![index];
      if (servico is Map<String, dynamic>) {
        nomeServico = servico['descricao'] as String? ?? 'Serviço';
      } else if (servico is ServiceModel) {
        nomeServico = servico.descricao;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Remover Serviço",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Tem certeza que deseja remover o serviço \"$nomeServico\"?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removerServico(index);
              },
              child: _carregando
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      "Remover",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool temServicos = widget.contrato.servicos != null &&
        widget.contrato.servicos!.isNotEmpty;
    final double totalServicos = _calcularTotalServicos();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const TitleInformationTemplate(description: 'Serviço(s)'),
            if (widget.editavel) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Editável',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        if (_carregando) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CircularProgressIndicator(),
          ),
        ] else if (temServicos) ...[
          ...widget.contrato.servicos!.asMap().entries.map((entry) {
            final int index = entry.key;
            final dynamic servico = entry.value;

            String descricao = 'Serviço';
            double preco = 0.0;
            int quantidade = 1;

            if (servico is Map<String, dynamic>) {
              descricao = servico['descricao'] as String? ?? 'Serviço';
              preco = _parseDouble(servico['preco_unitario']);
              quantidade = _parseInt(servico['quantidade']);
            } else if (servico is ServiceModel) {
              descricao = servico.descricao;
              preco = servico.preco;
              quantidade = 1;
            }

            return Column(
              children: [
                ServicesTemplate(
                  price: preco,
                  service: descricao,
                  onRemover: widget.editavel
                      ? () => _confirmarRemocaoServico(index)
                      : null,
                ),
                const SizedBox(height: 8),
              ],
            );
          }).toList(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff8692DE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total dos serviços:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'R\$${totalServicos.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff8692DE),
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          const Text(
            'Nenhum serviço contratado',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (widget.editavel && !_carregando) ...[
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _adicionarServico,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[600],
              side: BorderSide(color: Colors.blue[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 18, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(
                  'Adicionar Serviço',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
