import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/models/service_model.dart';
import 'package:pet_family_app/pages/booking/template/pet_icon_bookin_template.dart';
import 'pet_show_more_template.dart';

class ShowMoreModalTemplate extends StatefulWidget {
  final ContratoModel contrato;

  const ShowMoreModalTemplate({
    super.key,
    required this.contrato,
  });

  @override
  State<ShowMoreModalTemplate> createState() => _ShowMoreModalTemplateState();
}

class _ShowMoreModalTemplateState extends State<ShowMoreModalTemplate> {
  String _formatarData(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatarMoeda(double valor) {
    return 'R\$${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

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
        print('Erro ao converter valor: $value - $e');
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
        print('Erro ao converter quantidade: $value - $e');
        return 1;
      }
    }

    return 1;
  }

  double _calcularTotalServicos() {
    double totalServicos = 0;

    if (widget.contrato.servicos != null) {
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

        totalServicos += precoUnitario * quantidade;
      }
    }

    return totalServicos;
  }

  List<Widget> _buildPetIconsForModal() {
    if (widget.contrato.pets == null || widget.contrato.pets!.isEmpty) {
      return [
        const PetShowMoreTemplate(
          petName: 'Nenhum pet',
        ),
      ];
    }

    return widget.contrato.pets!.map((pet) {
      String petName = 'Pet';

      // Extrai nome do pet
      if (pet is Map<String, dynamic>) {
        petName = pet['nome'] as String? ?? 'Pet';
      } else if (pet is PetModel) {
        petName = pet.nome ?? 'Pet';
      } else if (pet is String) {
        petName = pet;
      }

      return PetShowMoreTemplate(
        petName: petName,
      );
    }).toList();
  }

  Widget _buildServicosList() {
    if (widget.contrato.servicos == null || widget.contrato.servicos!.isEmpty) {
      return const Text(
        'Nenhum serviço contratado',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.contrato.servicos!.map((servico) {
        double precoUnitario = 0;
        int quantidade = 1;
        String descricao = 'Serviço';

        if (servico is Map<String, dynamic>) {
          precoUnitario = _parseDouble(servico['preco_unitario']);
          quantidade = _parseInt(servico['quantidade']);
          descricao = servico['descricao'] as String? ?? 'Serviço';
        } else if (servico is ServiceModel) {
          precoUnitario = servico.preco;
          quantidade = 1;
          descricao = servico.descricao;
        }

        double subtotal = precoUnitario * quantidade;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      descricao,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${quantidade}x ${_formatarMoeda(precoUnitario)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatarMoeda(subtotal),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xff8692DE),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalServicos = _calcularTotalServicos();
    final List<Widget> petIcons = _buildPetIconsForModal();

    return Container(
      color: Colors.white, // Fundo branco para todo o modal
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    'PetFamily',
                    style: TextStyle(
                      fontWeight: FontWeight.w100,
                      color: Color(0xFF8F8F8F),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 30), // Para balancear o layout
                ],
              ),

              const SizedBox(height: 24),

              // Nome da Hospedagem e Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xff8692DE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.house,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.contrato.hospedagemNome ?? 'Hospedagem',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Em Aprovação',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Período
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Color(0xff8692DE),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatarData(widget.contrato.dataInicio)} - ${_formatarData(widget.contrato.dataFim ?? widget.contrato.dataInicio)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Endereço
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 20,
                      color: Color(0xff8692DE),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.contrato.hospedagemEndereco ??
                            'Endereço não informado',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF1C1B1F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Valor Total
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xff8692DE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xff8692DE)),
                ),
                child: Center(
                  child: Text(
                    _formatarMoeda(totalServicos),
                    style: const TextStyle(
                      fontSize: 28,
                      color: Color(0xff8692DE),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Serviços Contratados
              const Text(
                'Serviços Contratados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff8692DE),
                ),
              ),
              const SizedBox(height: 12),
              _buildServicosList(),

              const SizedBox(height: 24),

              // Pets Incluídos
              const Text(
                'Pets Incluídos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff8692DE),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: petIcons,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
