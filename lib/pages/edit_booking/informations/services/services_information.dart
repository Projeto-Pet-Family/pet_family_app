import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/models/service_model.dart';
import 'package:pet_family_app/pages/edit_booking/informations/services/services_template.dart';
import 'package:pet_family_app/pages/edit_booking/informations/title_information_template.dart';

class ServicesInformation extends StatefulWidget {
  final ContratoModel contrato;
  final Function(ContratoModel)? onContratoAtualizado;

  const ServicesInformation({
    super.key,
    required this.contrato,
    this.onContratoAtualizado,
  });

  @override
  State<ServicesInformation> createState() => _ServicesInformationState();
}

class _ServicesInformationState extends State<ServicesInformation> {
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

  void _removerServico(int index) {
    if (widget.contrato.servicos == null ||
        index >= widget.contrato.servicos!.length) {
      return;
    }

    final List<dynamic> novosServicos = List.from(widget.contrato.servicos!);
    novosServicos.removeAt(index);

    final contratoAtualizado = widget.contrato.copyWith(
      servicos: novosServicos.isEmpty ? null : novosServicos,
    );

    if (widget.onContratoAtualizado != null) {
      widget.onContratoAtualizado!(contratoAtualizado);
    }
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
              child: const Text(
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
        const TitleInformationTemplate(description: 'Serviço(s)'),
        const SizedBox(height: 12),
        if (temServicos) ...[
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
                  onRemover: () => _confirmarRemocaoServico(index),
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
      ],
    );
  }
}
