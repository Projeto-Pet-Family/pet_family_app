import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/pages/booking/modal/show_more/pet_show_more_template.dart';

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
  String _formatarData(DateTime? date) {
    if (date == null) return '--/--/----';
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
        return double.parse(value.replaceAll('R\$', '').replaceAll(',', '.'));
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  // ========== MÉTODOS PARA EXTRAIR DADOS DO NOVO FORMATO ==========

  // Extrair nome da hospedagem
  String get _hospedagemNome {
    // Tenta do campo hospedagem do modelo (que é um Map)
    if (widget.contrato.hospedagem != null) {
      final nome = widget.contrato.hospedagem!['nome'];
      if (nome != null && nome.toString().isNotEmpty) {
        return nome.toString();
      }
    }
    
    // Tenta do campo hospedagemNome do modelo
    if (widget.contrato.hospedagemNome != null) {
      return widget.contrato.hospedagemNome!;
    }
    
    // Tenta do campo formatado
    if (widget.contrato.formatado != null && 
        widget.contrato.formatado!['hospedagem'] != null) {
      final nomeFormatado = widget.contrato.formatado!['hospedagem'];
      if (nomeFormatado != null && nomeFormatado.toString().isNotEmpty) {
        return nomeFormatado.toString();
      }
    }
    
    return 'Hospedagem';
  }

  // Extrair valor da diária
  double get _valorDiaria {
    // Tenta do campo hospedagem
    if (widget.contrato.hospedagem != null && 
        widget.contrato.hospedagem!['valorDiaria'] != null) {
      return _parseDouble(widget.contrato.hospedagem!['valorDiaria']);
    }
    
    // Tenta do campo valorDiaria do modelo
    if (widget.contrato.valorDiaria != null) {
      return widget.contrato.valorDiaria!;
    }
    
    // Tenta dos cálculos
    if (widget.contrato.calculos != null && 
        widget.contrato.calculos!['valor_diaria'] != null) {
      return _parseDouble(widget.contrato.calculos!['valor_diaria']);
    }
    
    return 100.0; // Valor padrão
  }

  // Extrair quantidade de dias
  int get _quantidadeDias {
    // Tenta dos cálculos
    if (widget.contrato.calculos != null && 
        widget.contrato.calculos!['quantidadeDias'] != null) {
      return _parseInt(widget.contrato.calculos!['quantidadeDias']);
    }
    
    // Tenta calcular pelas datas
    final dataFim = widget.contrato.dataFim;
    if (dataFim != null) {
      final diff = dataFim.difference(widget.contrato.dataInicio).inDays;
      return diff > 0 ? diff : 1;
    }
    
    // Tenta do campo formatado
    if (widget.contrato.formatado != null && 
        widget.contrato.formatado!['periodo'] != null) {
      final periodo = widget.contrato.formatado!['periodo'].toString();
      // Extrair número do texto "5 dia(s)"
      final match = RegExp(r'(\d+)').firstMatch(periodo);
      if (match != null) {
        return _parseInt(match.group(1));
      }
    }
    
    return 1;
  }

  // Extrair valor da hospedagem
  double get _valorHospedagem {
    // Tenta dos cálculos
    if (widget.contrato.calculos != null && 
        widget.contrato.calculos!['valorHospedagem'] != null) {
      return _parseDouble(widget.contrato.calculos!['valorHospedagem']);
    }
    
    // Calcula manualmente
    return _valorDiaria * _quantidadeDias * _quantidadePets;
  }

  // Extrair valor dos serviços
  double get _valorServicos {
    // Tenta dos cálculos
    if (widget.contrato.calculos != null && 
        widget.contrato.calculos!['valorServicos'] != null) {
      return _parseDouble(widget.contrato.calculos!['valorServicos']);
    }
    
    // Calcula manualmente pelos pets
    double total = 0.0;
    if (widget.contrato.pets != null) {
      for (var pet in widget.contrato.pets!) {
        if (pet is Map<String, dynamic> && pet['valor_total_servicos'] != null) {
          total += _parseDouble(pet['valor_total_servicos']);
        }
      }
    }
    return total;
  }

  // Extrair valor total
  double get _valorTotal {
    // Tenta dos cálculos
    if (widget.contrato.calculos != null && 
        widget.contrato.calculos!['valorTotal'] != null) {
      return _parseDouble(widget.contrato.calculos!['valorTotal']);
    }
    
    // Calcula manualmente
    return _valorHospedagem + _valorServicos;
  }

  // Extrair quantidade de pets
  int get _quantidadePets {
    // Tenta dos cálculos
    if (widget.contrato.calculos != null && 
        widget.contrato.calculos!['quantidadePets'] != null) {
      return _parseInt(widget.contrato.calculos!['quantidadePets']);
    }
    
    // Tenta contar os pets da lista
    if (widget.contrato.pets != null) {
      return widget.contrato.pets!.length;
    }
    
    return 0;
  }

  // Extrair valores formatados
  String _obterValorFormatado(String campo) {
    // Tenta do campo formatado
    if (widget.contrato.formatado != null) {
      final valor = widget.contrato.formatado![campo];
      if (valor != null && valor.toString().isNotEmpty) {
        return valor.toString();
      }
    }
    
    // Fallback: formata manualmente
    switch (campo) {
      case 'valorDiaria':
        return _formatarMoeda(_valorDiaria);
      case 'valorHospedagem':
        return _formatarMoeda(_valorHospedagem);
      case 'valorServicos':
        return _formatarMoeda(_valorServicos);
      case 'valorTotal':
        return _formatarMoeda(_valorTotal);
      default:
        return '';
    }
  }

  // Extrair período formatado
  String get _periodoFormatado {
    // Tenta do campo formatado
    if (widget.contrato.formatado != null && 
        widget.contrato.formatado!['periodo'] != null) {
      return widget.contrato.formatado!['periodo'].toString();
    }
    
    // Formata manualmente
    return '$_quantidadeDias ${_quantidadeDias == 1 ? 'dia' : 'dias'}';
  }

  // Extrair endereço
  String? get _endereco {
    // Tenta do campo hospedagem
    if (widget.contrato.hospedagem != null && 
        widget.contrato.hospedagem!['endereco'] is Map) {
      final enderecoMap = widget.contrato.hospedagem!['endereco'] as Map;
      
      final parts = <String>[];
      
      if (enderecoMap['logradouro'] != null) {
        parts.add(enderecoMap['logradouro'].toString());
      }
      
      if (enderecoMap['numero'] != null) {
        parts.add(enderecoMap['numero'].toString());
      }
      
      if (enderecoMap['complemento'] != null && 
          enderecoMap['complemento'].toString().isNotEmpty) {
        parts.add(enderecoMap['complemento'].toString());
      }
      
      if (enderecoMap['bairro'] != null) {
        parts.add(enderecoMap['bairro'].toString());
      }
      
      if (enderecoMap['cidade'] != null) {
        parts.add(enderecoMap['cidade'].toString());
      }
      
      if (enderecoMap['sigla'] != null) {
        parts.add(enderecoMap['sigla'].toString());
      }
      
      if (enderecoMap['cep'] != null) {
        parts.add('CEP: ${enderecoMap['cep']}');
      }
      
      return parts.isNotEmpty ? parts.join(', ') : null;
    }
    
    // Tenta do campo hospedagemEndereco antigo
    return 'hospedagem';
  }

  // ========== WIDGETS ==========

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
      
      if (pet is Map<String, dynamic>) {
        petName = pet['nome']?.toString() ?? 'Pet';
      } else if (pet is String) {
        petName = pet;
      }
      
      return PetShowMoreTemplate(
        petName: petName,
      );
    }).toList();
  }

  Widget _buildServicosList() {
    // Primeiro, verifica se tem serviços gerais
    final servicosGerais = widget.contrato.servicosGerais ?? [];
    final temServicosGerais = servicosGerais.isNotEmpty;
    
    // Depois, verifica serviços dos pets
    final temServicosNosPets = widget.contrato.pets?.any((pet) {
      if (pet is Map<String, dynamic>) {
        final servicos = pet['servicos'];
        return servicos is List && servicos.isNotEmpty;
      }
      return false;
    }) ?? false;
    
    if (!temServicosGerais && !temServicosNosPets) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(50),
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
    
    final List<Widget> servicosWidgets = [];
    
    // Adiciona serviços gerais
    for (var servico in servicosGerais) {
      if (servico is Map<String, dynamic>) {
        final descricao = servico['descricao']?.toString() ?? 'Serviço';
        final precoTotal = _parseDouble(servico['preco_total']);
        
        servicosWidgets.add(
          _buildItemServico(descricao, precoTotal, isGeral: true),
        );
      }
    }
    
    // Adiciona serviços dos pets
    if (widget.contrato.pets != null) {
      for (var pet in widget.contrato.pets!) {
        if (pet is Map<String, dynamic>) {
          final petNome = pet['nome']?.toString() ?? 'Pet';
          final servicos = pet['servicos'];
          
          if (servicos is List && servicos.isNotEmpty) {
            // Adiciona header do pet
            servicosWidgets.add(
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  'Pet: $petNome',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xff8692DE),
                  ),
                ),
              ),
            );
            
            // Adiciona serviços deste pet
            for (var servico in servicos) {
              if (servico is Map<String, dynamic>) {
                final descricao = servico['descricao']?.toString() ?? 'Serviço';
                final precoTotal = _parseDouble(servico['preco_total']);
                
                servicosWidgets.add(
                  _buildItemServico(descricao, precoTotal, petNome: petNome),
                );
              }
            }
          }
        }
      }
    }
    
    return Column(
      children: servicosWidgets,
    );
  }
  
  Widget _buildItemServico(String descricao, double precoTotal, 
      {bool isGeral = false, String? petNome}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(50),
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
                if (petNome != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Pet: $petNome',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ] else if (isGeral) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Serviço geral',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            _formatarMoeda(precoTotal),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xff8692DE),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoFinanceiro() {
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
            _obterValorFormatado('valorDiaria'),
          ),
          const SizedBox(height: 8),

          // Período
          _buildItemFinanceiro(
            '📅 Período da hospedagem',
            _periodoFormatado,
          ),
          const SizedBox(height: 12),

          // Quantidade de pets
          _buildItemFinanceiro(
            '🐈 Quantidade de pets',
            _quantidadePets.toString(),
          ),
          const SizedBox(height: 12),

          // Cálculo da hospedagem
          if (_quantidadePets > 0) ...[
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
                    '${_formatarMoeda(_valorDiaria)} × $_quantidadeDias dias × $_quantidadePets pets',
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
            _obterValorFormatado('valorHospedagem'),
            isSubtotal: true,
          ),
          const SizedBox(height: 12),

          // Serviços adicionais
          if (_valorServicos > 0) ...[
            _buildItemFinanceiro(
              '🛎️ Serviços adicionais',
              _obterValorFormatado('valorServicos'),
              isSubtotal: true,
            ),
            const SizedBox(height: 12),
          ],

          // Total
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
                  _obterValorFormatado('valorTotal'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
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

  @override
  Widget build(BuildContext context) {
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
                    onTap: () => Navigator.pop(context),
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

              // Container de informações da hospedagem
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
                                _hospedagemNome,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
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
                            '${_formatarData(widget.contrato.dataInicio)} - ${_formatarData(widget.contrato.dataFim)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Endereço
                    if (_endereco != null) ...[
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
                              _endereco!,
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
              if (_valorServicos > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Serviços Adicionais',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff8692DE),
                      ),
                    ),
                    Text(
                      'Total: ${_obterValorFormatado('valorServicos')}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildServicosList(),
                const SizedBox(height: 20),
              ],

              // Pets Incluídos
              if (_quantidadePets > 0) ...[
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
                  children: _buildPetIconsForModal(),
                ),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      ),
    );
  }
}