// pages/edit_booking/informations/services/excluir_servico_modal.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/services/contrato_service.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class ExcluirServicoModal extends StatefulWidget {
  final int idContrato;
  final ContratoModel contrato;
  final Function(ContratoModel) onServicosExcluidos;
  final ContratoService contratoService;

  const ExcluirServicoModal({
    super.key,
    required this.idContrato,
    required this.contrato,
    required this.onServicosExcluidos,
    required this.contratoService,
  });

  @override
  State<ExcluirServicoModal> createState() => _ExcluirServicoModalState();
}

class _ExcluirServicoModalState extends State<ExcluirServicoModal> {
  // Mapa para armazenar serviços selecionados por pet
  final Map<int?, List<int>> _servicosSelecionadosPorPet = {};
  bool _excluindo = false;

  // Pets que têm serviços para excluir
  late List<Map<String, dynamic>> _petsComServicos;

  @override
  void initState() {
    super.initState();
    _inicializarDados();
  }

  void _inicializarDados() {
    // Inicializar mapa vazio para cada pet
    _servicosSelecionadosPorPet.clear();

    // Coletar todos os pets que têm serviços
    _petsComServicos = [];

    if (widget.contrato.pets != null) {
      for (var pet in widget.contrato.pets!) {
        if (pet is Map) {
          final dynamic petId = pet['idpet'] ?? pet['idPet'] ?? pet['id'];
          final int? idPet = petId is int
              ? petId
              : (petId is String ? int.tryParse(petId) : null);

          if (idPet != null) {
            final servicos = pet['servicos'];
            if (servicos is List && servicos.isNotEmpty) {
              _petsComServicos.add({
                'id': idPet,
                'nome': pet['nome'] ?? 'Pet $idPet',
                'servicos': List<Map<String, dynamic>>.from(servicos),
              });
              _servicosSelecionadosPorPet[idPet] = [];
            }
          }
        }
      }
    }

    // Adicionar serviços gerais (petId = null)
    if (widget.contrato.servicosGerais != null &&
        widget.contrato.servicosGerais!.isNotEmpty) {
      _petsComServicos.add({
        'id': null, // null para serviços gerais
        'nome': 'Serviços Gerais',
        'servicos':
            List<Map<String, dynamic>>.from(widget.contrato.servicosGerais!),
      });
      _servicosSelecionadosPorPet[null] = [];
    }
  }

  // Contar total de serviços selecionados
  int get _totalServicosSelecionados {
    int total = 0;
    _servicosSelecionadosPorPet.forEach((petId, servicos) {
      total += servicos.length;
    });
    return total;
  }

  // Calcular valor total dos serviços selecionados
  double get _valorTotalSelecionado {
    double total = 0;

    _servicosSelecionadosPorPet.forEach((petId, servicosIds) {
      if (servicosIds.isNotEmpty) {
        final petInfo = _petsComServicos.firstWhere(
          (p) => p['id'] == petId,
          orElse: () => {'servicos': []},
        );

        final List<dynamic> servicosPet = petInfo['servicos'];

        for (var servico in servicosPet) {
          final idServico = servico['idservico'] ?? servico.idservico;
          if (servicosIds.contains(idServico)) {
            final precoUnitario = servico['preco_unitario'] ??
                servico.precoUnitario ??
                servico.preco;
            final quantidade = servico['quantidade'] ?? servico.quantidade ?? 1;
            total += (precoUnitario * quantidade);
          }
        }
      }
    });

    return total;
  }

  // Formatar dados para API
  List<Map<String, dynamic>> _formatarParaAPI() {
    final List<Map<String, dynamic>> resultado = [];

    _servicosSelecionadosPorPet.forEach((petId, servicosIds) {
      if (servicosIds.isNotEmpty) {
        resultado.add({
          'idPet': petId, // pode ser null para serviços gerais
          'servicos': servicosIds,
        });
      }
    });

    return resultado;
  }

  Future<void> _confirmarExclusao() async {
    if (_totalServicosSelecionados == 0) return;

    setState(() => _excluindo = true);

    try {
      final servicosParaExcluir = _formatarParaAPI();

      print('🗑️ Excluindo serviços:');
      print('   - Contrato ID: ${widget.idContrato}');
      print('   - Total de serviços: ${_totalServicosSelecionados}');
      print('   - Pets afetados: ${servicosParaExcluir.length}');
      print('   - Payload: $servicosParaExcluir');

      final contratoAtualizado =
          await widget.contratoService.excluirServicosContrato(
        idContrato: widget.idContrato,
        servicosPorPet: servicosParaExcluir,
      );

      print('✅ Serviços excluídos com sucesso!');

      if (mounted) {
        Navigator.of(context).pop();
        widget.onServicosExcluidos(contratoAtualizado);

        _mostrarMensagemSucesso(
            '${_totalServicosSelecionados} serviço(s) excluído(s) com sucesso!');
      }
    } catch (e, stackTrace) {
      print('❌ Erro ao excluir serviços: $e');
      print('📝 Stack trace: $stackTrace');

      if (mounted) {
        _mostrarErro('Erro ao excluir serviços: ${e.toString()}');
        setState(() => _excluindo = false);
      }
    }
  }

  Widget _buildItemServico(dynamic servico, int? petId) {
    final idServico = servico['idservico'] ?? servico.idservico;
    final descricao = servico['descricao'] ?? servico.descricao;
    final precoUnitario =
        servico['preco_unitario'] ?? servico.precoUnitario ?? servico.preco;
    final quantidade = servico['quantidade'] ?? servico.quantidade ?? 1;
    final precoTotal = (precoUnitario * quantidade);

    final isSelecionado =
        _servicosSelecionadosPorPet[petId]?.contains(idServico) ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelecionado ? Colors.red : Colors.grey[300]!,
          width: isSelecionado ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Checkbox(
              value: isSelecionado,
              onChanged: (value) {
                setState(() {
                  final lista = _servicosSelecionadosPorPet[petId] ?? [];
                  if (value == true) {
                    lista.add(idServico);
                  } else {
                    lista.remove(idServico);
                  }
                  _servicosSelecionadosPorPet[petId!] = lista;
                });
              },
              activeColor: Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    descricao.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quantidade: $quantidade',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'R\$${precoTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaPet(Map<String, dynamic> petInfo) {
    final int? petId = petInfo['id'];
    final String petNome = petInfo['nome'];
    final List<dynamic> servicos = petInfo['servicos'];
    final servicosSelecionados =
        _servicosSelecionadosPorPet[petId]?.length ?? 0;

    return ExpansionTile(
      title: Row(
        children: [
          if (petId != null)
            Icon(
              Icons.pets,
              size: 20,
              color: Colors.blue[600],
            ),
          if (petId == null)
            Icon(
              Icons.category,
              size: 20,
              color: Colors.orange[600],
            ),
          const SizedBox(width: 8),
          Text(
            petNome,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          if (servicosSelecionados > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$servicosSelecionados selecionado(s)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.red[800],
                ),
              ),
            ),
        ],
      ),
      children:
          servicos.map((servico) => _buildItemServico(servico, petId)).toList(),
    );
  }

  Widget _buildResumo() {
    if (_totalServicosSelecionados == 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.red[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning,
                size: 24,
                color: Colors.red[700],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$_totalServicosSelecionados serviço(s) selecionado(s)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[700],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            'Valor total a remover: R\$${_valorTotalSelecionado.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),

          const SizedBox(height: 4),

          // Mostrar resumo por pet
          ..._servicosSelecionadosPorPet.entries
              .where((entry) => entry.value.isNotEmpty)
              .map(
            (entry) {
              final petId = entry.key;
              final petNome = petId == null
                  ? 'Serviços Gerais'
                  : _petsComServicos.firstWhere(
                      (p) => p['id'] == petId,
                      orElse: () => {'nome': 'Pet $petId'},
                    )['nome'];

              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '• $petNome: ${entry.value.length} serviço(s)',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.red[600],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _excluindo ? null : () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: 30,
                    color: _excluindo ? Colors.grey[400] : Colors.black,
                  ),
                ),
                const Text(
                  'Excluir Serviços',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(width: 30),
              ],
            ),
          ),

          // Instruções
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  size: 20,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Selecione os serviços que deseja excluir. '
                    'É possível excluir serviços de múltiplos pets de uma só vez.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[600],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de pets com serviços
          Expanded(
            child: _petsComServicos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cleaning_services_outlined,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhum serviço para excluir',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: _petsComServicos
                          .map((pet) => _buildListaPet(pet))
                          .toList(),
                    ),
                  ),
          ),

          // Resumo
          _buildResumo(),

          // Botões
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    onPressed: _excluindo ? null : () => Navigator.pop(context),
                    label: 'Cancelar',
                    fontSize: 16,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    buttonColor: Colors.white,
                    textButtonColor: Colors.black,
                    borderSide: BorderSide(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    onPressed: _excluindo || _totalServicosSelecionados == 0
                        ? null
                        : _confirmarExclusao,
                    label: _excluindo ? 'Excluindo...' : 'Excluir Selecionados',
                    fontSize: 16,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    buttonColor: _totalServicosSelecionados == 0
                        ? Colors.grey[300]
                        : Colors.red,
                    textButtonColor: _totalServicosSelecionados == 0
                        ? Colors.grey
                        : Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarMensagemSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
