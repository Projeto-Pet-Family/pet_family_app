// pages/edit_booking/informations/your_pets/your_pets_informations.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/pages/edit_booking/excluir_servico_modal.dart';
import 'package:pet_family_app/services/contrato_service.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class YourPetsInformations extends StatefulWidget {
  final ContratoModel contrato;
  final Function(ContratoModel, {String? tipoAlteracao}) onContratoAtualizado;
  final bool editavel;
  final Dio dio;

  const YourPetsInformations({
    super.key,
    required this.contrato,
    required this.onContratoAtualizado,
    required this.editavel,
    required this.dio,
  });

  @override
  State<YourPetsInformations> createState() => _YourPetsInformationsState();
}

class _YourPetsInformationsState extends State<YourPetsInformations> {
  final Map<int, bool> _expandedPets = {};
  late ContratoService _contratoService;
  bool _isExcluindoPet = false;
  bool _isRecarregando = false;
  int? _ultimoPetExcluidoId;

  @override
  void initState() {
    super.initState();
    _contratoService = ContratoService(widget.dio);
  }

  @override
  void didUpdateWidget(YourPetsInformations oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Verificar se os pets mudaram
    final novosPets = widget.contrato.pets ?? [];
    final petsAntigos = oldWidget.contrato.pets ?? [];

  }

  // Método para resetar o estado quando o contrato muda
  void _resetarEstado() {
    if (!mounted) return;

    setState(() {
      _expandedPets.clear();
      _isExcluindoPet = false;
      _isRecarregando = false;
    });
  }

  // Método auxiliar para converter Map<dynamic, dynamic> para Map<String, dynamic>
  Map<String, dynamic> _convertMap(dynamic map) {
    if (map is Map<String, dynamic>) {
      return map;
    } else if (map is Map<dynamic, dynamic>) {
      final Map<String, dynamic> converted = {};
      for (final key in map.keys) {
        if (key is String) {
          converted[key] = map[key];
        } else if (key != null) {
          converted[key.toString()] = map[key];
        }
      }
      return converted;
    }
    return {};
  }

  // Obter serviços de um pet
  List<Map<String, dynamic>> _getServicosDoPet(Map<String, dynamic> pet) {
    final List<Map<String, dynamic>> servicosList = [];
    final servicos = pet['servicos'];

    if (servicos is List) {
      for (final servico in servicos) {
        final servicoConvertido = _convertMap(servico);
        if (servicoConvertido.isNotEmpty) {
          servicosList.add(servicoConvertido);
        }
      }
    }

    return servicosList;
  }

  // Obter quantidade de serviços de um pet
  int _getQuantidadeServicosPet(Map<String, dynamic> pet) {
    final servicos = pet['servicos'];
    if (servicos is List) return servicos.length;
    return 0;
  }

  // Calcular valor total dos serviços de um pet
  double _calcularValorTotalPet(Map<String, dynamic> pet) {
    double total = 0.0;
    final servicos = _getServicosDoPet(pet);

    for (final servico in servicos) {
      final precoUnitario =
          servico['preco_unitario'] ?? servico['preco'] ?? 0.0;
      final quantidade = servico['quantidade'] ?? 1;

      final preco = precoUnitario is num ? precoUnitario.toDouble() : 0.0;
      final qtd = quantidade is num ? quantidade.toDouble() : 1.0;

      total += preco * qtd;
    }

    return total;
  }

  // Formatar preço
  String _formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Abrir modal para excluir serviços de um pet
  void _abrirModalExcluirServicosPet(
      BuildContext context, Map<String, dynamic> pet) {
    final idPet = pet['idpet'];
    final petNome = pet['nome'] ?? 'Pet';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExcluirServicoModal(
        contrato: widget.contrato,
        idContrato: widget.contrato.idContrato ?? 0,
        contratoService: ContratoService(widget.dio),
        onServicosExcluidos: (contratoAtualizado, {tipoAlteracao}) {
          widget.onContratoAtualizado(contratoAtualizado,
              tipoAlteracao: 'servico_removido');
          setState(() {
            if (idPet is int) {
              _expandedPets[idPet] = false;
            } else if (idPet != null) {
              final intId = int.tryParse(idPet.toString());
              if (intId != null) {
                _expandedPets[intId] = false;
              }
            }
          });
        },
      ),
    );
  }

  // Excluir pet completo usando a API
  Future<void> _excluirPetCompleto(
      BuildContext context, Map<String, dynamic> pet) async {
    final idPet = pet['idpet'];
    final petNome = pet['nome'] ?? 'Pet';
    final quantidadeServicos = _getQuantidadeServicosPet(pet);
    final idContrato = widget.contrato.idContrato;

    if (idContrato == null || idPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ID do contrato ou pet não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Converter idPet para int
    final int idPetInt;
    if (idPet is int) {
      idPetInt = idPet;
    } else if (idPet is String) {
      idPetInt = int.tryParse(idPet) ?? 0;
    } else {
      idPetInt = 0;
    }

    if (idPetInt == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ID do pet inválido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Deseja realmente remover $petNome do contrato?'),
            if (quantidadeServicos > 0) ...[
              const SizedBox(height: 8),
              Text(
                'ATENÇÃO: $quantidadeServicos serviço(s) serão removidos junto.',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isExcluindoPet ? null : () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: _isExcluindoPet
                ? null
                : () async {
                    Navigator.pop(context);
                    await _executarExclusaoPet(context, idContrato, idPetInt,
                        petNome, quantidadeServicos);
                  },
            child: _isExcluindoPet
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  )
                : Text(
                    'Remover Pet',
                    style: TextStyle(color: Colors.red),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _executarExclusaoPet(BuildContext context, int idContrato,
      int idPet, String petNome, int quantidadeServicos) async {
    setState(() {
      _isExcluindoPet = true;
      _ultimoPetExcluidoId = idPet;
    });

    // Guardar uma referência ao contexto antes de operações assíncronas
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final currentContext = context;

    try {
      // Verificar se o widget ainda está montado
      if (!mounted) return;

      // Mostrar indicador de carregamento
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Excluindo pet...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 30),
        ),
      );

      print('🗑️ Iniciando exclusão do pet $idPet do contrato $idContrato');

      // Chamar o método do serviço para excluir o pet
      final contratoAtualizado = await _contratoService.excluirPetDoContrato(
        idContrato: idContrato,
        idPet: idPet,
      );

      print('✅ Pet excluído com sucesso via API');

      // Verificar se o widget ainda está montado
      if (!mounted) return;

      // Fechar o snackbar de carregamento
      scaffoldMessenger.hideCurrentSnackBar();

      // Atualizar o estado com o contrato atualizado
      widget.onContratoAtualizado(contratoAtualizado,
          tipoAlteracao: 'pet_removido');

      // Forçar recarregamento do widget
      _iniciarRecarregamento();

      // Mostrar mensagem de sucesso
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('$petNome removido com sucesso!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('❌ Erro ao excluir pet: $e');

      // Verificar se o widget ainda está montado
      if (!mounted) return;

      // Fechar o snackbar de carregamento
      scaffoldMessenger.hideCurrentSnackBar();

      // Mostrar mensagem de erro
      String errorMessage = 'Erro ao excluir pet';

      if (e.toString().contains('404')) {
        errorMessage = 'Pet não encontrado no contrato';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Dados inválidos para exclusão';
      } else if (e.toString().contains('500') ||
          e.toString().contains('calculo_valores')) {
        // Tratamento especial para erro 500
        errorMessage = 'Pet removido, mas houve um erro no cálculo.';

        // Mesmo com erro 500, tentar atualizar localmente
        if (mounted) {
          // Criar um novo contrato sem o pet removido (simulação local)
          final novosPets =
              List<dynamic>.from(widget.contrato.pets ?? []).where((p) {
            final pConvertido = _convertMap(p);
            final pid = pConvertido['idpet'];
            final pidInt = pid is int ? pid : int.tryParse(pid.toString());
            return pidInt != idPet;
          }).toList();

          final contratoSimulado = widget.contrato.copyWith(pets: novosPets);
          widget.onContratoAtualizado(contratoSimulado,
              tipoAlteracao: 'pet_removido');

          // Forçar recarregamento do widget
          _iniciarRecarregamento();

          // Mostrar mensagem informativa
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                  '$petNome removido (atualização local devido a erro no servidor)'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
          return; // Saia aqui se tratou o erro 500 localmente
        }
      } else if (e.toString().contains('Connection refused') ||
          e.toString().contains('timeout') ||
          e.toString().contains('connection')) {
        errorMessage = 'Erro de conexão. Tente novamente.';
      } else if (e.toString().contains('Erro no servidor')) {
        errorMessage = 'Erro no servidor. Tente novamente mais tarde.';
      }

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      // Verificar se o widget ainda está montado antes de setState
      if (mounted) {
        setState(() {
          _isExcluindoPet = false;
        });
      }
    }
  }

  // Método para iniciar o recarregamento do widget
  void _iniciarRecarregamento() {
    if (!mounted) return;

    setState(() {
      _isRecarregando = true;
    });

    // Simular um pequeno delay para mostrar o efeito de recarregamento
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isRecarregando = false;
          // Limpar o mapa de expansão para o pet removido
          if (_ultimoPetExcluidoId != null) {
            _expandedPets.remove(_ultimoPetExcluidoId);
          }
          _ultimoPetExcluidoId = null;
        });
      }
    });
  }

  // Toggle expansão do pet
  void _toggleExpansaoPet(int idPet) {
    if (!mounted) return;
    setState(() {
      _expandedPets[idPet] = !(_expandedPets[idPet] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Se estiver recarregando, mostrar indicador
    if (_isRecarregando) {
      return _buildRecarregando();
    }

    final pets = widget.contrato.pets ?? [];
    final temPets = pets.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (temPets)
          ...pets.asMap().entries.map((entry) {
            final index = entry.key;
            final pet = entry.value;

            // Converter pet para Map<String, dynamic>
            final petConvertido = _convertMap(pet);
            if (petConvertido.isEmpty) return const SizedBox.shrink();

            final idPet = petConvertido['idpet'];
            final idPetInt =
                idPet is int ? idPet : int.tryParse(idPet.toString());
            if (idPetInt == null) return const SizedBox.shrink();

            final petNome = petConvertido['nome']?.toString() ?? 'Pet';
            final especie =
                petConvertido['especie']?.toString() ?? 'Não informado';
            final raca = petConvertido['raca']?.toString() ?? 'Não informado';
            final sexo = petConvertido['sexo']?.toString() ?? 'Não informado';
            final nascimento = petConvertido['nascimento'];
            final servicos = _getServicosDoPet(petConvertido);
            final quantidadeServicos = servicos.length;
            final valorTotalPet = _calcularValorTotalPet(petConvertido);
            final isExpanded = _expandedPets[idPetInt] ?? false;

            // Calcular idade aproximada
            String? idade;
            if (nascimento != null) {
              try {
                final nascDate = DateTime.parse(nascimento.toString());
                final hoje = DateTime.now();
                final diferenca = hoje.difference(nascDate);
                final anos = diferenca.inDays ~/ 365;

                if (anos > 0) {
                  idade = '$anos ano${anos > 1 ? 's' : ''}';
                } else {
                  final meses = diferenca.inDays ~/ 30;
                  idade = '$meses mês${meses > 1 ? 'es' : ''}';
                }
              } catch (e) {
                idade = null;
              }
            }

            // Se este for o pet que está sendo excluído, mostrar versão "fantasma"
            if (_ultimoPetExcluidoId == idPetInt && _isExcluindoPet) {
              return _buildPetExcluindo(petNome, idPetInt);
            }

            return Card(
              elevation: 2,
              margin: EdgeInsets.only(
                bottom: 16,
                top: index == 0 ? 0 : 0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Header do pet
                  InkWell(
                    onTap: quantidadeServicos > 0
                        ? () => _toggleExpansaoPet(idPetInt)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? Color(0xff8692DE).withOpacity(0.05)
                            : Colors.transparent,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xff8692DE).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Icon(
                              Icons.pets,
                              color: Color(0xff8692DE),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  petNome,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$especie • $raca',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (idade != null)
                                  Text(
                                    idade,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Indicador de serviços
                          if (quantidadeServicos > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Color(0xff8692DE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.cleaning_services,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$quantidadeServicos',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (quantidadeServicos > 0)
                                    Icon(
                                      isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Detalhes expandidos (serviços)
                  if (isExpanded && quantidadeServicos > 0)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: [
                          const Divider(),
                          const SizedBox(height: 8),

                          const Row(
                            children: [
                              Icon(
                                Icons.cleaning_services,
                                size: 16,
                                color: Color(0xff8692DE),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Serviços deste Pet',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff8692DE),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Lista de serviços
                          ...servicos.map((servico) {
                            final descricao =
                                servico['descricao']?.toString() ?? 'Serviço';
                            final precoUnitario =
                                servico['preco_unitario'] ?? 0.0;
                            final quantidade = servico['quantidade'] ?? 1;
                            final precoTotal = (precoUnitario is num
                                    ? precoUnitario.toDouble()
                                    : 0.0) *
                                (quantidade is num
                                    ? quantidade.toDouble()
                                    : 1.0);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          descricao,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              'R\$ ${(precoUnitario is num ? precoUnitario.toDouble() : 0.0).toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '× $quantidade',
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
                                    'R\$ ${precoTotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),

                          const Divider(),

                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _formatarPreco(valorTotalPet),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff8692DE),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Botões de ação
                  if (widget.editavel)
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          if (quantidadeServicos > 0)
                            Expanded(
                              child: AppButton(
                                onPressed: () => _abrirModalExcluirServicosPet(
                                    context, petConvertido),
                                label: 'Remover Serviços',
                                fontSize: 14,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                buttonColor: Colors.orange[800],
                                textButtonColor: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          if (quantidadeServicos > 0) const SizedBox(width: 8),
                          Expanded(
                            child: AppButton(
                              onPressed: _isExcluindoPet
                                  ? null
                                  : () => _excluirPetCompleto(
                                      context, petConvertido),
                              label: _isExcluindoPet
                                  ? 'Excluindo...'
                                  : 'Remover Pet',
                              fontSize: 14,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              buttonColor: Colors.red,
                              textButtonColor: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }).toList()
        else
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.pets,
                      size: 60,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhum pet adicionado',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Adicione pets para visualizá-los aqui',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Resumo geral
        if (temPets)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Color(0xff8692DE).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.summarize,
                          color: Color(0xff8692DE),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Resumo dos Pets',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff8692DE),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Estatísticas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total de Pets:',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${pets.length}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff8692DE),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Pets com serviços:',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              '${pets.where((p) {
                                final pConvertido = _convertMap(p);
                                final servicos = pConvertido['servicos'];
                                return servicos is List &&
                                    (servicos as List).isNotEmpty;
                              }).length}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    const Divider(),

                    const SizedBox(height: 8),

                    // Pets individualmente
                    ...pets.map((pet) {
                      final petConvertido = _convertMap(pet);
                      final petNome =
                          petConvertido['nome']?.toString() ?? 'Pet';
                      final servicosList = petConvertido['servicos'];
                      final quantidadeServicos =
                          servicosList is List ? servicosList.length : 0;
                      final valorTotalPet =
                          _calcularValorTotalPet(petConvertido);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              petNome,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                if (quantidadeServicos > 0)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.cleaning_services,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$quantidadeServicos',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                  ),
                                Text(
                                  quantidadeServicos > 0
                                      ? _formatarPreco(valorTotalPet)
                                      : 'Sem serviços',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: quantidadeServicos > 0
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Widget para mostrar estado de recarregamento
  Widget _buildRecarregando() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Color(0xff8692DE),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Atualizando lista de pets...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para mostrar pet sendo excluído
  Widget _buildPetExcluindo(String petNome, int idPet) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      color: Colors.red.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    petNome,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Removendo pet...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
