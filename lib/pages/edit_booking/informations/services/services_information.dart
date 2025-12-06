import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/models/service_model.dart';
import 'package:pet_family_app/pages/edit_booking/informations/services/services_template.dart';
import 'package:pet_family_app/pages/edit_booking/informations/title_information_template.dart';
import 'package:pet_family_app/services/api_service.dart';

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
  List<ServiceModel> _servicosDisponiveis = [];

  @override
  void initState() {
    super.initState();
    _carregarServicosDisponiveis();
  }

  Future<void> _carregarServicosDisponiveis() async {
    if (!widget.editavel) return;

    try {
      // TODO: Implementar API para buscar serviços disponíveis da hospedagem
      // Por enquanto, vamos simular alguns serviços
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _servicosDisponiveis = [
          ServiceModel(
            idservico: 1,
            descricao: 'Banho e Tosa',
            preco: 50.0,
          ),
          ServiceModel(
            idservico: 2,
            descricao: 'Hospedagem Diária',
            preco: 80.0,
          ),
          ServiceModel(
            idservico: 3,
            descricao: 'Passeio com Pet',
            preco: 30.0,
          ),
          ServiceModel(
            idservico: 4,
            descricao: 'Veterinário',
            preco: 100.0,
          ),
        ];
      });
    } catch (e) {
      print('❌ Erro ao carregar serviços disponíveis: $e');
    }
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

  // Verifica se um serviço já existe no contrato
  bool _servicoJaExiste(int idServico) {
    if (widget.contrato.servicos == null) return false;

    for (var servico in widget.contrato.servicos!) {
      if (servico is Map<String, dynamic>) {
        if (servico['idservico'] == idServico) {
          return true;
        }
      } else if (servico is ServiceModel) {
        if (servico.idservico == idServico) {
          return true;
        }
      }
    }
    return false;
  }

  // Filtra serviços disponíveis (remove os que já estão no contrato)
  List<ServiceModel> get _servicosParaAdicionar {
    return _servicosDisponiveis.where((servico) {
      return !_servicoJaExiste(servico.idservico!);
    }).toList();
  }

  Future<void> _adicionarServico(ServiceModel servico) async {
    if (!widget.editavel || _carregando) return;

    setState(() {
      _carregando = true;
    });

    try {
      print('➕ Adicionando serviço ${servico.descricao} ao contrato');

      // TODO: Implementar API para adicionar serviço ao contrato
      // Por enquanto, vamos simular a adição local

      final List<dynamic> novosServicos =
          List.from(widget.contrato.servicos ?? []);
      novosServicos.add({
        'idservico': servico.idservico,
        'descricao': servico.descricao,
        'preco_unitario': servico.preco,
        'quantidade': 1,
      });

      final contratoAtualizado = widget.contrato.copyWith(
        servicos: novosServicos,
      );

      if (widget.onContratoAtualizado != null) {
        widget.onContratoAtualizado!(contratoAtualizado,
            tipoAlteracao: 'servico_adicionado');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Serviço "${servico.descricao}" adicionado com sucesso'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('❌ Erro ao adicionar serviço: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar serviço: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  Future<void> _removerServico(int index) async {
    if (!widget.editavel || _carregando) return;

    if (widget.contrato.servicos == null ||
        index >= widget.contrato.servicos!.length) {
      return;
    }

    final servicoParaRemover = widget.contrato.servicos![index];
    int? idServico;

    if (servicoParaRemover is Map<String, dynamic>) {
      idServico = servicoParaRemover['idservico'] as int?;
    } else if (servicoParaRemover is ServiceModel) {
      idServico = servicoParaRemover.idservico;
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

      final bool sucesso = await ApiService().removerServicoContrato(
        idContrato: widget.contrato.idContrato!,
        idServico: idServico,
      );

      if (sucesso) {
        print('✅ Serviço removido com sucesso na API');

        final List<dynamic> novosServicos =
            List.from(widget.contrato.servicos!);
        novosServicos.removeAt(index);

        final contratoAtualizado = widget.contrato.copyWith(
          servicos: novosServicos.isEmpty ? null : novosServicos,
        );

        if (widget.onContratoAtualizado != null) {
          widget.onContratoAtualizado!(contratoAtualizado,
              tipoAlteracao: 'servico_removido');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
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
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _carregando = false;
      });
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
              child: _carregando
                  ? const SizedBox(
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

  void _mostrarModalAdicionarServico() {
    if (_servicosParaAdicionar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todos os serviços disponíveis já foram adicionados'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, size: 24, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Adicionar Serviço',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _servicosParaAdicionar.length,
                itemBuilder: (context, index) {
                  final servico = _servicosParaAdicionar[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(
                        Icons.room_service,
                        color: Colors.blue,
                      ),
                      title: Text(
                        servico.descricao,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'R\$${servico.preco.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () => _adicionarServico(servico),
                        icon: const Icon(Icons.add, color: Colors.green),
                      ),
                      onTap: () => _adicionarServico(servico),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool temServicos = widget.contrato.servicos != null &&
        widget.contrato.servicos!.isNotEmpty;
    final double totalServicos = _calcularTotalServicos();
    final bool podeAdicionar = _servicosParaAdicionar.isNotEmpty;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total dos serviços:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF727272),
              ),
            ),
            Text(
              'R\$${totalServicos.toStringAsFixed(2).replaceAll('.', ',')}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF727272),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_carregando) ...[
          const Padding(
            padding: EdgeInsets.all(16.0),
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
          /* OutlinedButton(
            onPressed: podeAdicionar ? _mostrarModalAdicionarServico : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: podeAdicionar ? Colors.blue[600] : Colors.grey,
              side: BorderSide(
                color: podeAdicionar ? Colors.blue[300]! : Colors.grey[300]!,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 18,
                  color: podeAdicionar ? Colors.blue[600] : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  podeAdicionar
                      ? 'Adicionar Serviço'
                      : 'Todos os serviços adicionados',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: podeAdicionar ? Colors.blue[600] : Colors.grey,
                  ),
                ),
              ],
            ),
          ), */
        ],
      ],
    );
  }
}
