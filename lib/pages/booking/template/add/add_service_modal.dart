// pages/edit_booking/modal/add_service_modal.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:pet_family_app/models/service_model.dart';
import 'package:pet_family_app/services/contrato_service.dart';
import 'package:pet_family_app/services/service_service.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:http/http.dart' as http;

class AddServiceModal extends StatefulWidget {
  final int idContrato;
  final int idHospedagem;
  final List<dynamic> servicosNoContrato;
  final List<dynamic> petsNoContrato;
  final Function(ContratoModel) onServicoAdicionado;

  const AddServiceModal({
    super.key,
    required this.idContrato,
    required this.idHospedagem,
    required this.servicosNoContrato,
    required this.petsNoContrato,
    required this.onServicoAdicionado,
  });

  @override
  State<AddServiceModal> createState() => _AddServiceModalState();
}

class _AddServiceModalState extends State<AddServiceModal> {
  late ServiceService _serviceService;
  late ContratoService _contratoService;
  List<ServiceModel> _servicosDisponiveis = [];
  
  // Mapa para armazenar pets selecionados por serviço (novas seleções)
  final Map<int, Set<int>> _novosServicosPorPet = {};
  
  // Mapa para armazenar pets que já têm o serviço no contrato
  final Map<int, Set<int>> _servicosExistentesPorPet = {};
  
  final List<int> _petsNoContrato = [];
  bool _carregando = true;
  bool _enviando = false;
  Map<int, String> _nomesPets = {};

  @override
  void initState() {
    super.initState();
    final dio = Dio();
    _serviceService = ServiceService(client: http.Client());
    _contratoService = ContratoService(dio: dio, client: http.Client());
    _extrairPetsDoContrato();
    _carregarServicosDisponiveis();
  }

  void _extrairPetsDoContrato() {
    print('🐾 Extraindo pets do contrato...');

    for (var item in widget.petsNoContrato) {
      if (item is Map<String, dynamic>) {
        final idPet = item['idpet'] ?? item['idPet'];
        final nomePet = item['nome'] ?? item['nomePet'] ?? 'Pet';

        if (idPet != null) {
          final id = int.tryParse(idPet.toString()) ?? 0;
          if (id > 0) {
            _petsNoContrato.add(id);
            _nomesPets[id] = nomePet.toString();
            print('✅ Pet encontrado: $id - $nomePet');
          }
        }
      }
    }

    print('📊 Total de pets no contrato: ${_petsNoContrato.length}');
    print('📊 IDs dos pets: $_petsNoContrato');
  }

  Future<void> _carregarServicosDisponiveis() async {
    try {
      print('🔄 Iniciando carregamento de serviços disponíveis...');
      print('📊 ID Hospedagem: ${widget.idHospedagem}');
      print('📊 ID Contrato: ${widget.idContrato}');
      print('📊 Pets no contrato: $_petsNoContrato');

      final dio = Dio();
      final response = await dio.get(
        'https://bepetfamily.onrender.com/hospedagens/${widget.idHospedagem}/servicos',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('📊 Total de serviços da API: ${data.length}');

        final todosServicos = data.map((json) {
          try {
            return ServiceModel.fromJson(json);
          } catch (e) {
            print('⚠️ Erro ao converter JSON: $json');
            print('⚠️ Erro: $e');
            return ServiceModel(
              idservico: json['idservico'] ?? 0,
              idhospedagem: widget.idHospedagem,
              descricao: json['descricao']?.toString() ?? 'Serviço',
              preco: (json['preco'] is String)
                  ? double.tryParse(json['preco']) ?? 0.0
                  : (json['preco'] as num?)?.toDouble() ?? 0.0,
            );
          }
        }).toList();

        // Analisar serviços existentes no contrato
        _analisarServicosExistentes();

        // Filtrar serviços disponíveis (excluindo os que todos os pets já têm)
        final servicosDisponiveis = todosServicos
            .where((servico) => _podeAdicionarServico(servico.idServico))
            .toList();

        print('📊 Total de serviços disponíveis: ${servicosDisponiveis.length}');

        setState(() {
          _servicosDisponiveis = servicosDisponiveis;
          _carregando = false;
        });
      } else {
        print('❌ Erro na API: ${response.statusCode}');
        throw Exception('Erro ao carregar serviços: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao carregar serviços: $e');
      _mostrarErro('Erro ao carregar serviços: $e');
      setState(() {
        _carregando = false;
      });
    }
  }

  void _analisarServicosExistentes() {
    print('📊 Analisando serviços existentes no contrato...');
    
    for (var item in widget.servicosNoContrato) {
      if (item is ServiceModel) {
        final servicoId = item.idServico;
        // Verificar se há relação pet-serviço na estrutura
        _processarRelacaoPetServico(item, servicoId);
      } else if (item is Map<String, dynamic>) {
        final servicoId = item['idservico'] ?? item['idServico'];
        if (servicoId != null) {
          final idServico = int.tryParse(servicoId.toString()) ?? 0;
          _processarRelacaoPetServico(item, idServico);
        }
      }
    }
    
    print('📊 Serviços existentes por pet: $_servicosExistentesPorPet');
  }

  void _processarRelacaoPetServico(dynamic item, int servicoId) {
    // Verificar diferentes formatos possíveis de relação pet-serviço
    if (item is Map<String, dynamic>) {
      // Formato 1: petServicos no próprio item
      if (item['petServicos'] != null && item['petServicos'] is List) {
        for (var petServico in item['petServicos']) {
          if (petServico is Map<String, dynamic>) {
            final petId = petServico['idpet'] ?? petServico['idPet'];
            if (petId != null) {
              final idPet = int.tryParse(petId.toString()) ?? 0;
              if (idPet > 0) {
                _servicosExistentesPorPet
                    .putIfAbsent(servicoId, () => {})
                    .add(idPet);
              }
            }
          }
        }
      }
      // Formato 2: pets no próprio item
      else if (item['pets'] != null && item['pets'] is List) {
        for (var pet in item['pets']) {
          if (pet is Map<String, dynamic>) {
            final petId = pet['idpet'] ?? pet['idPet'];
            if (petId != null) {
              final idPet = int.tryParse(petId.toString()) ?? 0;
              if (idPet > 0) {
                _servicosExistentesPorPet
                    .putIfAbsent(servicoId, () => {})
                    .add(idPet);
              }
            }
          }
        }
      }
      // Formato 3: idpet no próprio item
      else if (item['idpet'] != null || item['idPet'] != null) {
        final petId = item['idpet'] ?? item['idPet'];
        if (petId != null) {
          final idPet = int.tryParse(petId.toString()) ?? 0;
          if (idPet > 0) {
            _servicosExistentesPorPet
                .putIfAbsent(servicoId, () => {})
                .add(idPet);
          }
        }
      }
    }
  }

  bool _podeAdicionarServico(int servicoId) {
    final petsComServico = _servicosExistentesPorPet[servicoId] ?? {};
    return petsComServico.length < _petsNoContrato.length;
  }

  Future<void> _adicionarServicos() async {
    if (_novosServicosPorPet.isEmpty) {
      _mostrarMensagem('Selecione serviços para pelo menos um pet');
      return;
    }

    // Verificar se todos os serviços selecionados têm pelo menos um pet
    final servicosSemPet = _novosServicosPorPet.entries
        .where((entry) => entry.value.isEmpty)
        .toList();
    if (servicosSemPet.isNotEmpty) {
      _mostrarMensagem('Selecione pets para todos os serviços');
      return;
    }

    setState(() => _enviando = true);

    try {
      // Agrupar por pet para enviar à API
      final Map<int, List<int>> petsPorServico = {};

      for (final entry in _novosServicosPorPet.entries) {
        final servicoId = entry.key;
        for (final petId in entry.value) {
          petsPorServico.putIfAbsent(petId, () => []).add(servicoId);
        }
      }

      final servicosPorPet = petsPorServico.entries.map((entry) {
        return {
          'idPet': entry.key,
          'servicos': entry.value,
        };
      }).toList();

      print('📤 Enviando para API:');
      print('   ID Contrato: ${widget.idContrato}');
      print('   Formato: $servicosPorPet');

      final contratoAtualizado =
          await _contratoService.adicionarServicoContrato(
        idContrato: widget.idContrato,
        servicosPorPet: servicosPorPet,
      );

      widget.onServicoAdicionado(contratoAtualizado as ContratoModel);
      Navigator.of(context).pop();
      _mostrarMensagemSucesso('Serviço(s) adicionado(s) com sucesso!');
    } catch (e) {
      print('❌ Erro ao adicionar serviços: $e');
      _mostrarErro('Erro ao adicionar serviços: $e');
    } finally {
      setState(() => _enviando = false);
    }
  }

  void _mostrarModalSelecaoPets(ServiceModel service) {
    if (_petsNoContrato.isEmpty) {
      _mostrarMensagem('Não há pets no contrato');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _buildModalSelecaoPets(service);
      },
    );
  }

  Widget _buildModalSelecaoPets(ServiceModel service) {
    final petsExistentesParaEsteServico =
        _servicosExistentesPorPet[service.idServico] ?? {};
    final novosPetsParaEsteServico =
        _novosServicosPorPet[service.idServico] ?? {};
    final todosPetsComServico = {
      ...petsExistentesParaEsteServico,
      ...novosPetsParaEsteServico
    };

    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selecionar pets para:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          service.descricao,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff8692DE),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'R\$${service.preco.toStringAsFixed(2)} por pet',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${_petsNoContrato.length} pet(s) disponível(is)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (petsExistentesParaEsteServico.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${petsExistentesParaEsteServico.length} pet(s) já tem este serviço',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _petsNoContrato.length,
                  itemBuilder: (context, index) {
                    final petId = _petsNoContrato[index];
                    final petNome = _nomesPets[petId] ?? 'Pet $petId';
                    
                    // Verificar se o pet já tem este serviço
                    final jaTemServico = petsExistentesParaEsteServico.contains(petId);
                    final isSelecionado = novosPetsParaEsteServico.contains(petId);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: jaTemServico
                            ? Colors.green.withOpacity(0.2)
                            : (isSelecionado
                                ? const Color(0xff8692DE).withOpacity(0.2)
                                : Colors.grey[200]),
                        child: Icon(
                          Icons.pets,
                          color: jaTemServico
                              ? Colors.green
                              : (isSelecionado
                                  ? const Color(0xff8692DE)
                                  : Colors.grey),
                        ),
                      ),
                      title: Text(
                        petNome,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: jaTemServico
                              ? Colors.green
                              : (isSelecionado
                                  ? const Color(0xff8692DE)
                                  : Colors.black),
                          decoration: jaTemServico
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: jaTemServico
                          ? const Text(
                              'Já tem este serviço',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            )
                          : null,
                      trailing: jaTemServico
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                          : Checkbox(
                              value: isSelecionado,
                              onChanged: (value) {
                                setModalState(() {
                                  if (value == true) {
                                    novosPetsParaEsteServico.add(petId);
                                  } else {
                                    novosPetsParaEsteServico.remove(petId);
                                  }
                                });
                              },
                              activeColor: const Color(0xff8692DE),
                            ),
                      onTap: jaTemServico
                          ? null
                          : () {
                              setModalState(() {
                                if (novosPetsParaEsteServico.contains(petId)) {
                                  novosPetsParaEsteServico.remove(petId);
                                } else {
                                  novosPetsParaEsteServico.add(petId);
                                }
                              });
                            },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          novosPetsParaEsteServico.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Limpar'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (novosPetsParaEsteServico.isNotEmpty) {
                          _novosServicosPorPet[service.idServico] =
                              Set.from(novosPetsParaEsteServico);
                        } else {
                          _novosServicosPorPet.remove(service.idServico);
                        }

                        // Verificar se ainda pode adicionar mais pets
                        if (!_podeAdicionarServico(service.idServico)) {
                          _removerServicoDaLista(service.idServico);
                        }

                        setState(() {});
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff8692DE),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Confirmar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildItemServico(ServiceModel servico) {
    final petsExistentesParaEsteServico =
        _servicosExistentesPorPet[servico.idServico] ?? {};
    final novosPetsParaEsteServico =
        _novosServicosPorPet[servico.idServico] ?? {};
    final totalPetsParaEsteServico = petsExistentesParaEsteServico.length +
        novosPetsParaEsteServico.length;
    final podeAdicionarMaisPets =
        totalPetsParaEsteServico < _petsNoContrato.length;
    final precoFormatado = servico.preco.toStringAsFixed(2);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: petsExistentesParaEsteServico.isNotEmpty
              ? Colors.green.withOpacity(0.5)
              : (novosPetsParaEsteServico.isNotEmpty
                  ? const Color(0xff8692DE)
                  : Colors.grey[300]!),
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: petsExistentesParaEsteServico.isNotEmpty
                ? Colors.green.withOpacity(0.1)
                : const Color(0xff8692DE).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            petsExistentesParaEsteServico.isNotEmpty
                ? Icons.check_circle
                : Icons.room_service,
            color: petsExistentesParaEsteServico.isNotEmpty
                ? Colors.green
                : const Color(0xff8692DE),
            size: 30,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    servico.descricao,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (totalPetsParaEsteServico > 0)
                    Row(
                      children: [
                        if (petsExistentesParaEsteServico.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Text(
                              '${petsExistentesParaEsteServico.length} já tem',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        if (petsExistentesParaEsteServico.isNotEmpty &&
                            novosPetsParaEsteServico.isNotEmpty)
                          const SizedBox(width: 4),
                        if (novosPetsParaEsteServico.isNotEmpty)
                          Text(
                            '+${novosPetsParaEsteServico.length} novo(s)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xff8692DE),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
            if (!podeAdicionarMaisPets)
              const Tooltip(
                message: 'Todos os pets já têm este serviço',
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 24,
                ),
              )
            else if (novosPetsParaEsteServico.isNotEmpty)
              IconButton(
                onPressed: () {
                  setState(() {
                    _novosServicosPorPet.remove(servico.idServico);
                  });
                },
                icon: const Icon(
                  Icons.clear,
                  color: Colors.red,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              )
            else
              IconButton(
                onPressed: () => _mostrarModalSelecaoPets(servico),
                icon: const Icon(
                  Icons.add_circle,
                  color: Color(0xff8692DE),
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'R\$$precoFormatado por pet',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff8692DE),
                ),
              ),
              if (!podeAdicionarMaisPets)
                const Text(
                  'Completo',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else if (!novosPetsParaEsteServico.isNotEmpty)
                TextButton(
                  onPressed: () => _mostrarModalSelecaoPets(servico),
                  child: const Text(
                    'Selecionar pets',
                    style: TextStyle(
                      color: Color(0xff8692DE),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _removerServicoDaLista(int servicoId) {
    setState(() {
      _servicosDisponiveis.removeWhere((servico) => servico.idServico == servicoId);
    });
  }

  Widget _buildListaServicos() {
    if (_carregando) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 100),
          child: CircularProgressIndicator(
            color: Color(0xff8692DE),
          ),
        ),
      );
    }

    if (_servicosDisponiveis.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                size: 80,
                color: Colors.green[400],
              ),
              const SizedBox(height: 20),
              const Text(
                'Todos os serviços já foram adicionados!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Não há serviços disponíveis para adicionar.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: _servicosDisponiveis.length,
      itemBuilder: (context, index) =>
          _buildItemServico(_servicosDisponiveis[index]),
    );
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _mostrarMensagemSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
      ),
    );
  }

  int _getTotalNovosServicosSelecionados() {
    return _novosServicosPorPet.values.fold(
        0, (sum, pets) => sum + pets.length);
  }

  @override
  Widget build(BuildContext context) {
    final totalServicos = _getTotalNovosServicosSelecionados();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.only(top: 20),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[100],
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 24,
                      color: Colors.black54,
                    ),
                  ),
                ),
                const Text(
                  'Adicionar Serviços',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff8692DE),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Contador
          if (totalServicos > 0)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xff8692DE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: const Color(0xff8692DE),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$totalServicos serviço(s) selecionado(s) para ${_petsNoContrato.length} pet(s)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff8692DE),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Aviso sobre múltiplos pets
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[800], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selecione quais pets receberão cada serviço',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Pets que já têm o serviço aparecem em verde',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Lista de serviços
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildListaServicos(),
            ),
          ),

          // Botões
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                AppButton(
                  onPressed: _enviando || totalServicos == 0
                      ? null
                      : _adicionarServicos,
                  label: _enviando
                      ? 'Adicionando...'
                      : 'Adicionar Serviços ($totalServicos)',
                  fontSize: 16,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  buttonColor: const Color(0xff8692DE),
                  textButtonColor: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                ),
                const SizedBox(height: 12),
                AppButton(
                  onPressed: _enviando ? null : () => Navigator.pop(context),
                  label: 'Cancelar',
                  fontSize: 16,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  buttonColor: Colors.white,
                  textButtonColor: Colors.black,
                  borderSide: BorderSide(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(50),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}