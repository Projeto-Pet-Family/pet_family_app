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
      try {
        return double.parse(value);
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

  // VERIFICA SE TEM DADOS DA API
  bool get _temDadosCalculadosAPI {
    return widget.contrato.temValoresCalculadosAPI;
  }

  // OBTER VALOR DA DIÁRIA - PRIORIDADE API
  double _obterValorDiaria() {
    // 1. Tenta dos dados calculados da API
    if (_temDadosCalculadosAPI) {
      final valorDiariaAPI = widget.contrato.calculoValores!['valor_diaria'];
      if (valorDiariaAPI != null) {
        return _parseDouble(valorDiariaAPI);
      }
    }

    // 2. Tenta do campo direto da API
    if (widget.contrato.valorDiaria != null) {
      return widget.contrato.valorDiaria!;
    }

    // 3. Fallback
    return 89.90;
  }

  // OBTER QUANTIDADE DE DIAS - PRIORIDADE API
  int _obterQuantidadeDias() {
    // 1. Tenta da API (calculo_valores)
    if (widget.contrato.quantidadeDiasAPI != null) {
      return widget.contrato.quantidadeDiasAPI!;
    }

    // 2. Tenta do campo duracaoDias
    if (widget.contrato.duracaoDias != null) {
      return widget.contrato.duracaoDias!;
    }

    // 3. Calcula manualmente
    return _calcularDiasHospedagem();
  }

  // OBTER VALOR HOSPEDAGEM - PRIORIDADE API
  double _obterValorHospedagem() {
    // 1. Tenta da API (calculo_valores)
    if (widget.contrato.valorTotalHospedagem != null) {
      return widget.contrato.valorTotalHospedagem!;
    }

    // 2. Calcula manualmente
    return _obterValorDiaria() * _obterQuantidadeDias();
  }

  // OBTER VALOR SERVIÇOS - PRIORIDADE API
  double _obterValorServicos() {
    // 1. Tenta da API (calculo_valores)
    if (widget.contrato.valorTotalServicos != null) {
      return widget.contrato.valorTotalServicos!;
    }

    // 2. Tenta do campo totalServicos
    if (widget.contrato.totalServicos != null) {
      return widget.contrato.totalServicos!;
    }

    // 3. Calcula manualmente
    return _calcularTotalServicosManual();
  }

  // OBTER VALOR TOTAL - PRIORIDADE API
  double _obterValorTotal() {
    // 1. Tenta da API (calculo_valores)
    if (widget.contrato.valorTotalContrato != null) {
      return widget.contrato.valorTotalContrato!;
    }

    // 2. Calcula manualmente
    return _obterValorHospedagem() + _obterValorServicos();
  }

  // OBTER VALORES FORMATADOS DA API
  String _obterValorFormatado(String campo) {
    // Tenta da API primeiro
    final valorFormatadoAPI = widget.contrato.getValorFormatado(campo);
    if (valorFormatadoAPI != null) {
      return valorFormatadoAPI;
    }

    // Fallback: formata localmente
    switch (campo) {
      case 'valor_diaria':
        return _formatarMoeda(_obterValorDiaria());
      case 'valor_total_hospedagem':
        return _formatarMoeda(_obterValorHospedagem());
      case 'valor_total_servicos':
        return _formatarMoeda(_obterValorServicos());
      case 'valor_total_contrato':
        return _formatarMoeda(_obterValorTotal());
      default:
        return '';
    }
  }

  // OBTER PERÍODO FORMATADO
  String _obterPeriodoFormatado() {
    // Tenta da API primeiro
    if (widget.contrato.periodoFormatadoAPI != null) {
      return widget.contrato.periodoFormatadoAPI!;
    }

    // Fallback: formata localmente
    final dias = _obterQuantidadeDias();
    return '$dias ${dias == 1 ? 'dia' : 'dias'}';
  }

  // MÉTODOS DE FALLBACK
  int _calcularDiasHospedagem() {
    final dataInicio = widget.contrato.dataInicio;
    final dataFim =
        widget.contrato.dataFim ?? dataInicio.add(const Duration(days: 1));
    final dias = dataFim.difference(dataInicio).inDays;
    return dias > 0 ? dias : 1;
  }

  double _calcularTotalServicosManual() {
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
    // Usar serviços do contrato (já vêm formatados da API)
    if (widget.contrato.servicos == null || widget.contrato.servicos!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Center(
          child: Text(
            'Nenhum serviço adicional contratado',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.contrato.servicos!.map((servico) {
        double precoUnitario = 0;
        int quantidade = 1;
        String descricao = 'Serviço';
        double subtotal = 0;

        if (servico is Map<String, dynamic>) {
          precoUnitario = _parseDouble(servico['preco_unitario']);
          quantidade = _parseInt(servico['quantidade']);
          descricao = servico['descricao'] as String? ?? 'Serviço';
          subtotal =
              _parseDouble(servico['subtotal']) ?? (precoUnitario * quantidade);
        } else if (servico is ServiceModel) {
          precoUnitario = servico.preco;
          quantidade = 1;
          descricao = servico.descricao;
          subtotal = precoUnitario * quantidade;
        }

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

  Widget _buildResumoFinanceiro() {
    // OBTER TODOS OS VALORES JÁ FORMATADOS
    final valorDiariaFormatado = _obterValorFormatado('valor_diaria');
    final valorHospedagemFormatado =
        _obterValorFormatado('valor_total_hospedagem');
    final valorServicosFormatado = _obterValorFormatado('valor_total_servicos');
    final valorTotalFormatado = _obterValorFormatado('valor_total_contrato');
    final periodoFormatado = _obterPeriodoFormatado();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💰 Resumo Financeiro',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),

          // Valor da diária
          _buildItemFinanceiro(
            '🏨 Valor da diária',
            valorDiariaFormatado,
          ),
          const SizedBox(height: 8),

          // Período
          _buildItemFinanceiro(
            '📅 Período da hospedagem',
            periodoFormatado,
          ),
          const SizedBox(height: 12),

          // Cálculo da hospedagem (só mostra se não veio pronto da API)
          if (!_temDadosCalculadosAPI) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[100]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Cálculo da hospedagem:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${_formatarMoeda(_obterValorDiaria())} × ${_obterQuantidadeDias()} dias',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Subtotal da hospedagem
          _buildItemFinanceiro(
            '🏠 Subtotal da hospedagem',
            valorHospedagemFormatado,
            isSubtotal: true,
          ),
          const SizedBox(height: 12),

          // Serviços adicionais
          if (_obterValorServicos() > 0) ...[
            _buildItemFinanceiro(
              '🛎️ Serviços adicionais',
              valorServicosFormatado,
              isSubtotal: true,
            ),
            const SizedBox(height: 12),
          ],

          // Total - DESTAQUE PRINCIPAL
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '💳 Total do contrato:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  valorTotalFormatado,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // Informação sobre origem dos dados
          const SizedBox(height: 12),
          _buildInfoOrigemDados(),
        ],
      ),
    );
  }

  Widget _buildInfoOrigemDados() {
    String origem;
    Color cor;
    IconData icone;

    if (_temDadosCalculadosAPI) {
      origem = 'Valores calculados pela API';
      cor = Colors.green;
      icone = Icons.check_circle;
    } else if (widget.contrato.valorDiaria != null) {
      origem = 'Valor da diária da API + cálculo local';
      cor = Colors.blue;
      icone = Icons.info;
    } else {
      origem = 'Valores calculados localmente';
      cor = Colors.orange;
      icone = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200], // CORRIGIDO: Usar a cor correspondente
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cor),
      ),
      child: Row(
        children: [
          Icon(
            icone,
            color: Colors.black, // CORRIGIDO: Usar a cor correspondente
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              origem,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black, // CORRIGIDO: Usar a cor correspondente
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemFinanceiro(String titulo, String valor,
      {bool isSubtotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: isSubtotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            fontSize: 14,
            color: isSubtotal ? Colors.blue : Colors.black,
            fontWeight: isSubtotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Atualizando o build do ShowMoreModalTemplate para agrupar as informações
  @override
  Widget build(BuildContext context) {
    final List<Widget> petIcons = _buildPetIconsForModal();

    return Container(
      color: Colors.white,
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
                  const SizedBox(width: 30),
                ],
              ),

              const SizedBox(height: 24),

              // CONTAINER UNIFICADO: Nome da Hospedagem, Status, Datas e Endereço
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xff8692DE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome da Hospedagem e Status
                    Row(
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
                                child: Text(
                                  widget.contrato.statusFormatado,
                                  style: const TextStyle(
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

                    const SizedBox(height: 16),

                    // Divisor
                    Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.3),
                    ),

                    const SizedBox(height: 16),

                    // Datas
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${_formatarData(widget.contrato.dataInicio)} - ${_formatarData(widget.contrato.dataFim ?? widget.contrato.dataInicio)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Endereço (se disponível)
                    if (widget.contrato.hospedagemEndereco != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.location_on,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.contrato.hospedagemEndereco!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Resumo Financeiro
              _buildResumoFinanceiro(),

              const SizedBox(height: 20),

              // Serviços Contratados
              const Text(
                'Serviços Adicionais',
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
