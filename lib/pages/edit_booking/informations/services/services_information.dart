import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';

class ServicesInformation extends StatefulWidget {
  final ContratoModel contrato;
  final Function(ContratoModel, {String? tipoAlteracao})? onContratoAtualizado;
  final bool editavel;

  const ServicesInformation({
    super.key,
    required this.contrato,
    this.onContratoAtualizado,
    this.editavel = true,
  });

  @override
  State<ServicesInformation> createState() => _ServicesInformationState();
}

class _ServicesInformationState extends State<ServicesInformation> {
  // Método para extrair todos os serviços do contrato
  List<Map<String, dynamic>> _extrairTodosServicos() {
    final List<Map<String, dynamic>> todosServicos = [];

    // 1. Extrair serviços gerais
    final servicosGerais = widget.contrato.servicosGerais ?? [];
    for (var servico in servicosGerais) {
      if (servico is Map<String, dynamic>) {
        todosServicos.add({
          ...servico,
          'tipo': 'geral',
          'pet_nome': 'Serviço geral',
        });
      }
    }

    // 2. Extrair serviços dos pets
    final pets = widget.contrato.pets ?? [];
    for (var pet in pets) {
      if (pet is Map<String, dynamic>) {
        final petNome = pet['nome']?.toString() ?? 'Pet';
        final servicos = pet['servicos'];
        
        if (servicos is List) {
          for (var servico in servicos) {
            if (servico is Map<String, dynamic>) {
              todosServicos.add({
                ...servico,
                'tipo': 'pet',
                'pet_nome': petNome,
                'idpet': pet['idpet'],
              });
            }
          }
        }
      }
    }

    return todosServicos;
  }

  // Calcular valor total dos serviços
  double _calcularValorTotalServicos(List<Map<String, dynamic>> servicos) {
    double total = 0.0;
    for (var servico in servicos) {
      final precoTotal = servico['preco_total'];
      if (precoTotal != null) {
        if (precoTotal is double) {
          total += precoTotal;
        } else if (precoTotal is int) {
          total += precoTotal.toDouble();
        } else if (precoTotal is String) {
          total += double.tryParse(precoTotal) ?? 0.0;
        }
      } else {
        // Fallback: calcular com quantidade e preço unitário
        final quantidade = servico['quantidade'] ?? 1;
        final precoUnitario = servico['preco_unitario'] ?? 0.0;
        final qtd = quantidade is int ? quantidade : 1;
        final preco = precoUnitario is double 
            ? precoUnitario 
            : (precoUnitario is int 
                ? precoUnitario.toDouble() 
                : 0.0);
        total += qtd * preco;
      }
    }
    return total;
  }

  // Formatar moeda
  String _formatarMoeda(double valor) {
    return 'R\$${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Remover serviço
  Future<void> _removerServico(Map<String, dynamic> servico) async {
    try {
      print('🗑️ Tentando remover serviço: ${servico['descricao']}');
      
      // Verificar se é um serviço de pet
      final isServicoPet = servico['tipo'] == 'pet';
      final idPet = servico['idpet'];
      final idservico = servico['idservico'];
      
      if (isServicoPet && idPet != null && idservico != null) {
        print('📝 Removendo serviço do pet $idPet');
        
        // TODO: Implementar chamada à API para remover serviço de pet
        // Por enquanto, apenas mostra mensagem
        _mostrarMensagem(
          'Funcionalidade de remoção de serviços será implementada em breve',
          cor: Colors.orange,
        );
        
        return;
      }
      
      // Para serviços gerais
      print('📝 Removendo serviço geral');
      
      // TODO: Implementar chamada à API para remover serviço geral
      _mostrarMensagem(
        'Funcionalidade de remoção de serviços será implementada em breve',
        cor: Colors.orange,
      );
      
    } catch (e) {
      print('❌ Erro ao remover serviço: $e');
      _mostrarMensagem('Erro ao remover serviço: $e', cor: Colors.red);
    }
  }

  void _mostrarMensagem(String mensagem, {Color cor = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: cor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Widget para um item de serviço
  Widget _buildItemServico(Map<String, dynamic> servico, int index) {
    final descricao = servico['descricao']?.toString() ?? 'Serviço';
    final petNome = servico['pet_nome']?.toString() ?? 'Pet';
    final isServicoPet = servico['tipo'] == 'pet';
    
    // Extrair preço total
    double precoTotal = 0.0;
    final precoTotalValue = servico['preco_total'];
    if (precoTotalValue != null) {
      if (precoTotalValue is double) {
        precoTotal = precoTotalValue;
      } else if (precoTotalValue is int) {
        precoTotal = precoTotalValue.toDouble();
      } else if (precoTotalValue is String) {
        precoTotal = double.tryParse(precoTotalValue) ?? 0.0;
      }
    } else {
      // Fallback: calcular com quantidade e preço unitário
      final quantidade = servico['quantidade'] ?? 1;
      final precoUnitario = servico['preco_unitario'] ?? 0.0;
      final qtd = quantidade is int ? quantidade : 1;
      final preco = precoUnitario is double 
          ? precoUnitario 
          : (precoUnitario is int 
              ? precoUnitario.toDouble() 
              : 0.0);
      precoTotal = qtd * preco;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isServicoPet)
                        Row(
                          children: [
                            Icon(
                              Icons.pets,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Pet: $petNome',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              Icons.category,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Serviço geral',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
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
            
            // Detalhes do serviço
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantidade',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '${servico['quantidade'] ?? 1}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Preço unitário',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        _formatarMoeda((servico['preco_unitario'] is double
                            ? servico['preco_unitario'] as double
                            : (servico['preco_unitario'] is int
                                ? (servico['preco_unitario'] as int).toDouble()
                                : 0.0))),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Preço total',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        _formatarMoeda(precoTotal),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff8692DE),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Botão de remover (se editável)
            if (widget.editavel) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () => _removerServico(servico),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Remover'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todosServicos = _extrairTodosServicos();
    final valorTotal = _calcularValorTotalServicos(todosServicos);

    if (todosServicos.isEmpty) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.spa,
                size: 60,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              const Text(
                'Nenhum serviço adicional',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Adicione serviços para seu pet',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumo dos serviços
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[300]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total de serviços',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${todosServicos.length} serviço${todosServicos.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Valor total',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatarMoeda(valorTotal),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff8692DE),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Lista de serviços
        Text(
          'Serviços contratados',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),

        ...todosServicos.asMap().entries.map((entry) {
          return _buildItemServico(entry.value, entry.key);
        }),
      ],
    );
  }
}