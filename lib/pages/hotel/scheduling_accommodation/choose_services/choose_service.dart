import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/global_refresh_wrapper.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/models/service_model.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_services/choose_service_template.dart';
import 'package:pet_family_app/repository/service_repository.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/services/service_service.dart';
import 'dart:convert';

class ChooseService extends StatefulWidget {
  const ChooseService({super.key});

  @override
  State<ChooseService> createState() => _ChooseServiceState();
}

class _ChooseServiceState extends State<ChooseService> {
  late ServiceRepository _serviceRepository;
  List<ServiceModel> _services = [];

  // Mapa para armazenar quais pets estão associados a cada serviço
  final Map<int, Set<int>> _servicosPorPet = {};

  bool _isLoading = true;
  String _errorMessage = '';
  int? _idHospedagem;

  // Dados dos pets do cache (usamos somente do cache)
  Set<int> _selectedPetIds = {};
  List<String> _selectedPetNames = [];
  Map<int, String> _petNamesMap = {}; // Mapa de ID -> Nome
  Map<int, Map<String, dynamic>> _petDetails =
      {}; // Detalhes completos dos pets
  int _selectedPetCount = 0;

  @override
  void initState() {
    super.initState();
    print('🚀 ========== CHOOSE SERVICE INICIADO ==========');
    print('📱 Widget criado');

    _serviceRepository = ServiceRepositoryImpl(
        serviceService: ServiceService(client: http.Client()));

    print('🔧 Repositório inicializado');
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    try {
      print('🔄 Iniciando carregamento de dados...');
      setState(() {
        _isLoading = true;
      });

      // 1. Primeiro carrega pets selecionados do cache
      print('📦 Passo 1: Carregando pets do cache...');
      await _carregarPetsSelecionadosDoCache();

      // 2. Carrega ID da hospedagem
      print('🏨 Passo 2: Carregando ID da hospedagem...');
      final prefs = await SharedPreferences.getInstance();
      final idHospedagem = prefs.getInt('id_hospedagem_selecionada');

      if (idHospedagem == null) {
        print('❌ ERRO: Nenhuma hospedagem selecionada no cache');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Nenhuma hospedagem selecionada';
        });
        return;
      }

      print('✅ ID da hospedagem encontrado: $idHospedagem');
      setState(() {
        _idHospedagem = idHospedagem;
      });

      // 3. Carrega serviços da hospedagem
      print('⚙️ Passo 3: Carregando serviços da hospedagem...');
      await _carregarServicos(idHospedagem);

      // 4. Carrega serviços selecionados do cache
      print('🛒 Passo 4: Carregando serviços do cache...');
      await _carregarServicosSelecionadosDoCache();

      // 5. Resumo final
      print('📊 === RESUMO FINAL ===');
      print('📊 Pets no cache (IDs): $_selectedPetIds');
      print('📊 Pets no cache (nomes): $_selectedPetNames');
      print('📊 Pets no cache (quantidade): $_selectedPetCount');
      print('📊 Serviços disponíveis: ${_services.length}');
      print('📊 Serviços já selecionados: ${_servicosPorPet.length}');

      setState(() {
        _isLoading = false;
      });

      print('✅ Carregamento de dados concluído com sucesso!');
    } catch (e) {
      print('❌ ERRO CRÍTICO no carregamento de dados: $e');
      print('🔍 Stack trace: ${e.toString()}');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar dados. Tente novamente.';
      });
    }
  }

  Future<void> _carregarPetsSelecionadosDoCache() async {
    try {
      print('🔍 === INICIANDO LEITURA DO CACHE DE PETS ===');
      final prefs = await SharedPreferences.getInstance();

      // 1. Carrega IDs dos pets de múltiplas chaves possíveis
      final selectedPetsString = prefs.getStringList('selected_pets') ?? [];
      final selectedPetIdsString =
          prefs.getStringList('selected_pet_ids') ?? [];

      List<String> allIds = [];
      if (selectedPetIdsString.isNotEmpty) {
        allIds = selectedPetIdsString;
        print('✅ Usando "selected_pet_ids" como fonte principal');
      } else if (selectedPetsString.isNotEmpty) {
        allIds = selectedPetsString;
        print('✅ Usando "selected_pets" como fonte principal');
      } else {
        print('⚠️ Nenhuma chave de pets encontrada no cache!');
      }

      final loadedIds = allIds
          .where((id) => id.isNotEmpty && id != 'null')
          .map((id) => int.tryParse(id))
          .where((id) => id != null)
          .map((id) => id!)
          .toSet();

      print('🎯 IDs carregados do cache: $loadedIds');

      // 2. Carrega nomes dos pets
      final selectedPetNamesFromCache =
          prefs.getStringList('selected_pet_names') ?? [];

      // 3. Carrega quantidade
      final selectedPetsCountFromCache =
          prefs.getInt('selected_pets_count') ?? 0;

      // 4. Carrega detalhes individuais dos pets
      final petDetails = <int, Map<String, dynamic>>{};
      final petNamesMap = <int, String>{};

      for (final petId in loadedIds) {
        final petName = prefs.getString('pet_${petId}_name');
        final petSpecies = prefs.getInt('pet_${petId}_species');
        final petBreed = prefs.getInt('pet_${petId}_breed');

        if (petName != null) {
          petNamesMap[petId] = petName;

          petDetails[petId] = {
            'id': petId,
            'name': petName,
            'species': petSpecies,
            'breed': petBreed,
          };
        }
      }

      // 5. Se não conseguiu carregar os nomes individualmente, usa a lista geral
      if (petNamesMap.isEmpty && selectedPetNamesFromCache.isNotEmpty) {
        for (int i = 0;
            i < selectedPetNamesFromCache.length && i < loadedIds.length;
            i++) {
          final petId = loadedIds.elementAt(i);
          final petName = selectedPetNamesFromCache[i];
          petNamesMap[petId] = petName;

          petDetails[petId] = {
            'id': petId,
            'name': petName,
          };
        }
      }

      // 6. Se ainda não tem nomes, cria nomes genéricos
      if (petNamesMap.isEmpty) {
        int count = 1;
        for (final petId in loadedIds) {
          final petName = 'Pet $count';
          petNamesMap[petId] = petName;

          petDetails[petId] = {
            'id': petId,
            'name': petName,
          };
          count++;
        }
      }

      setState(() {
        _selectedPetIds = loadedIds;
        _selectedPetNames = petNamesMap.values.toList();
        _petNamesMap = petNamesMap;
        _petDetails = petDetails;
        _selectedPetCount = selectedPetsCountFromCache > 0
            ? selectedPetsCountFromCache
            : loadedIds.length;
      });

      print('📝 Nomes mapeados: $_petNamesMap');
      print('📦 Detalhes dos pets: $_petDetails');
      print('🔢 Quantidade: $_selectedPetCount');

      if (_selectedPetIds.isEmpty) {
        print('🚨 ALERTA: Nenhum pet selecionado encontrado no cache!');
      } else {
        print('✅ Cache de pets carregado com sucesso!');
      }

      print('📊 === FIM DA LEITURA DO CACHE ===');
    } catch (e) {
      print('❌ ERRO ao ler cache de pets: $e');
      setState(() {
        _selectedPetIds = {};
        _selectedPetNames = [];
        _petNamesMap = {};
        _petDetails = {};
        _selectedPetCount = 0;
      });
    }
  }

  Future<void> _carregarServicos(int idHospedagem) async {
    try {
      print('⚙️ === CARREGANDO SERVIÇOS DA HOSPEDAGEM ===');
      print('   Hospedagem ID: $idHospedagem');

      final servicos =
          await _serviceRepository.listarServicosPorHospedagem(idHospedagem);

      print('📦 Serviços recebidos: ${servicos.length}');

      // Log detalhado de cada serviço
      print('🔧 DETALHES DE CADA SERVIÇO:');
      for (var i = 0; i < servicos.length; i++) {
        final servico = servicos[i];
        print(
            '   [${i + 1}] ID: ${servico.idServico}, Nome: ${servico.descricao}, Preço: R\$${servico.preco}');
      }

      // Filtra serviços com preço válido
      final servicosValidos = servicos.where((s) => s.preco > 0).toList();

      print('✅ Serviços válidos: ${servicosValidos.length}');

      setState(() {
        _services = servicosValidos;
        _errorMessage =
            servicosValidos.isEmpty ? 'Nenhum serviço disponível' : '';
      });

      print('✅ === FIM DO CARREGAMENTO DE SERVIÇOS ===');
    } catch (e) {
      print('❌ ERRO ao carregar serviços: $e');
      print('🔍 Stack trace: ${e.toString()}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Não foi possível carregar os serviços')),
        );
      }
    }
  }

  Future<void> _carregarServicosSelecionadosDoCache() async {
    try {
      print('🛒 === CARREGANDO SERVIÇOS SELECIONADOS DO CACHE ===');

      final prefs = await SharedPreferences.getInstance();

      // Tenta carregar o novo formato JSON primeiro
      final jsonString = prefs.getString('servicos_por_pet_json');
      if (jsonString != null && jsonString.isNotEmpty) {
        print('📋 Carregando do formato JSON: $jsonString');

        final List<dynamic> servicosPorPetList = json.decode(jsonString);

        // Limpa o mapa antes de carregar
        _servicosPorPet.clear();

        for (var item in servicosPorPetList) {
          final map = item as Map<String, dynamic>;
          final petId = map['idPet'] as int;
          final servicos = (map['servicos'] as List<dynamic>).cast<int>();

          for (var servicoId in servicos) {
            _servicosPorPet.putIfAbsent(servicoId, () => {}).add(petId);
          }
        }

        print(
            '📊 Total de serviços carregados (novo formato): ${_servicosPorPet.length}');
        return;
      }

      // Fallback para o formato antigo (se existir)
      final servicosPorPetList = prefs.getStringList('servicos_por_pet') ?? [];
      if (servicosPorPetList.isNotEmpty) {
        print('📋 Carregando do formato antigo: $servicosPorPetList');

        _servicosPorPet.clear();

        for (var entryString in servicosPorPetList) {
          final parts = entryString.split(':');
          if (parts.length == 2) {
            final serviceId = int.tryParse(parts[0]);
            if (serviceId != null) {
              final petIdsString = parts[1];
              if (petIdsString.isNotEmpty) {
                final petIds = petIdsString
                    .split(',')
                    .where((id) => id.isNotEmpty)
                    .map((id) => int.tryParse(id))
                    .where((id) => id != null)
                    .map((id) => id!)
                    .toSet();
                _servicosPorPet[serviceId] = petIds;
              } else {
                _servicosPorPet[serviceId] = {};
              }
            }
          }
        }
      }

      print('📊 Total de serviços carregados: ${_servicosPorPet.length}');
      print('✅ === FIM DO CARREGAMENTO DE SERVIÇOS DO CACHE ===');
    } catch (e) {
      print('❌ ERRO ao carregar serviços do cache: $e');
    }
  }

  Future<void> _salvarServicosSelecionadosNoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Formata para o formato servicosPorPet
      final Map<int, List<int>> petsPorServico = {};
      for (final entry in _servicosPorPet.entries) {
        for (final petId in entry.value) {
          petsPorServico.putIfAbsent(petId, () => []).add(entry.key);
        }
      }

      final servicosPorPet = petsPorServico.entries.map((entry) {
        return {
          'idPet': entry.key,
          'servicos': entry.value,
        };
      }).toList();

      // Salva como JSON
      final jsonString = jsonEncode(servicosPorPet);
      await prefs.setString('servicos_por_pet_json', jsonString);

      print('💾 Serviços salvos no cache (formato JSON): $jsonString');
    } catch (e) {
      print('❌ ERRO ao salvar serviços no cache: $e');
    }
  }

  Future<void> _salvarDetalhesServicosNoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Salva o valor total
      await prefs.setDouble('selected_services_total', totalValue);

      // Salva os nomes dos serviços selecionados
      final selectedServiceNames = _services
          .where((service) => _servicosPorPet.containsKey(service.idServico))
          .map((service) => service.descricao)
          .toList();

      await prefs.setStringList('selected_service_names', selectedServiceNames);

      print('💾 Total de serviços salvo: R\$ ${totalValue.toStringAsFixed(2)}');
    } catch (e) {
      print('❌ Erro ao salvar detalhes dos serviços: $e');
    }
  }

  Future<void> _limparServicosSelecionados() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('servicos_por_pet');
      await prefs.remove('servicos_por_pet_json');
      await prefs.remove('selected_services_total');
      await prefs.remove('selected_service_names');

      setState(() {
        _servicosPorPet.clear();
      });

      print('🗑️ Serviços limpos do cache');
    } catch (e) {
      print('❌ Erro ao limpar serviços: $e');
    }
  }

  void _mostrarModalSelecaoPets(ServiceModel service) {
    print('🎯 === ABRINDO MODAL PARA SERVIÇO ===');
    print('   Serviço: ${service.descricao} (ID: ${service.idServico})');
    print('   Pets disponíveis no cache: $_selectedPetIds');

    if (_selectedPetIds.isEmpty) {
      print('❌ Nenhum pet selecionado no cache');
      _mostrarAlertaSemPets();
      return;
    }

    // Cria uma lista de pets baseada apenas no cache
    final petsDoCache = _selectedPetIds.map((petId) {
      final details = _petDetails[petId] ?? {};
      String especie = 'Não informada';
      if (details['species'] != null) {
        switch (details['species']) {
          case 1:
            especie = 'Cachorro';
            break;
          case 2:
            especie = 'Gato';
            break;
          case 3:
            especie = 'Pássaro';
            break;
          default:
            especie = 'Outro';
        }
      }

      String raca = 'Não informada';
      if (details['breed'] != null) {
        raca = 'Raça ${details['breed']}';
      }

      return {
        'id': petId,
        'nome': _petNamesMap[petId] ?? 'Pet $petId',
        'especie': especie,
        'raca': raca,
      };
    }).toList();

    print('🔍 Pets do cache para o modal: ${petsDoCache.length}');
    if (petsDoCache.isEmpty) {
      print('❌ Nenhum pet encontrado no cache');
      _mostrarAlertaSemPets();
      return;
    }

    print('✅ Pets disponíveis para seleção:');
    for (var pet in petsDoCache) {
      print('   🐾 ${pet['nome']} (ID: ${pet['id']})');
    }

    // Verifica quais pets já estão selecionados para este serviço
    final petsJaSelecionados = _servicosPorPet[service.idServico] ?? {};
    print('🐕 Pets já selecionados para este serviço: $petsJaSelecionados');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _buildModalContent(service, petsDoCache, petsJaSelecionados);
      },
    );
  }

  Widget _buildModalContent(
    ServiceModel service,
    List<Map<String, dynamic>> petsDoCache,
    Set<int> petsJaSelecionados,
  ) {
    // Cria uma cópia local para manipulação no modal
    final petsSelecionadosLocal = Set<int>.from(petsJaSelecionados);

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
                            color: Colors.blue,
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
                '${petsDoCache.length} pet(s) disponível(is)',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${petsSelecionadosLocal.length} pet(s) selecionado(s)',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: petsDoCache.length,
                  itemBuilder: (context, index) {
                    final pet = petsDoCache[index];
                    final petId = pet['id'] as int;
                    final isSelecionado = petsSelecionadosLocal.contains(petId);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color:
                              isSelecionado ? Colors.blue : Colors.transparent,
                          width: isSelecionado ? 2 : 0,
                        ),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelecionado
                              ? Colors.blue[100]
                              : Colors.grey[200],
                          child: Icon(
                            Icons.pets,
                            color: isSelecionado ? Colors.blue : Colors.grey,
                          ),
                        ),
                        title: Text(
                          pet['nome'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isSelecionado ? Colors.blue : Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${pet['especie']} - ${pet['raca']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelecionado
                                    ? Colors.blue[700]
                                    : Colors.grey[600],
                              ),
                            ),
                            if (isSelecionado)
                              Text(
                                'Selecionado • +R\$${service.preco.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        trailing: Checkbox(
                          value: isSelecionado,
                          onChanged: (value) {
                            setModalState(() {
                              if (value == true) {
                                petsSelecionadosLocal.add(petId);
                                print('✅ Pet $petId selecionado no modal');
                              } else {
                                petsSelecionadosLocal.remove(petId);
                                print('❌ Pet $petId removido no modal');
                              }
                            });
                          },
                          activeColor: Colors.blue,
                        ),
                        onTap: () {
                          setModalState(() {
                            if (petsSelecionadosLocal.contains(petId)) {
                              petsSelecionadosLocal.remove(petId);
                              print('❌ Pet $petId removido (tap)');
                            } else {
                              petsSelecionadosLocal.add(petId);
                              print('✅ Pet $petId adicionado (tap)');
                            }
                          });
                        },
                      ),
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
                          petsSelecionadosLocal.clear();
                          print('🗑️ Todos os pets removidos da seleção');
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('Limpar todos'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setModalState(() {
                          // Seleciona todos os pets
                          for (var pet in petsDoCache) {
                            petsSelecionadosLocal.add(pet['id'] as int);
                          }
                          print('✅ Todos os pets selecionados');
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text('Selecionar todos'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (petsSelecionadosLocal.isNotEmpty) {
                      _servicosPorPet[service.idServico] =
                          Set.from(petsSelecionadosLocal);
                      print(
                          '💾 Serviço ${service.idServico} salvo para pets: $petsSelecionadosLocal');
                    } else {
                      _servicosPorPet.remove(service.idServico);
                      print('🗑️ Serviço ${service.idServico} removido');
                    }

                    _salvarServicosSelecionadosNoCache();

                    // Força o rebuild da interface
                    if (mounted) {
                      setState(() {});
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: petsSelecionadosLocal.isNotEmpty
                        ? Colors.blue
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    petsSelecionadosLocal.isNotEmpty
                        ? 'Confirmar (${petsSelecionadosLocal.length} pet${petsSelecionadosLocal.length > 1 ? 's' : ''})'
                        : 'Confirmar',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleServiceSelection(ServiceModel service) {
    print('🎯 === CLICOU NO SERVIÇO ===');
    print('   Serviço: ${service.descricao} (ID: ${service.idServico})');
    print('   Pets selecionados atualmente: $_selectedPetIds');

    // Verifica se o serviço já está selecionado para algum pet
    final servicoJaSelecionado = _servicosPorPet.containsKey(service.idServico);
    print('   Serviço já selecionado? $servicoJaSelecionado');

    if (servicoJaSelecionado) {
      // Se já está selecionado, remove completamente
      print('➖ Removendo serviço ${service.idServico} da seleção');
      setState(() {
        _servicosPorPet.remove(service.idServico);
      });
      _salvarServicosSelecionadosNoCache();
    } else {
      // Se não está selecionado, abre o modal para selecionar pets
      print('➕ Abrindo modal para adicionar serviço ${service.idServico}');

      if (_selectedPetIds.isEmpty) {
        print('❌ Não há pets selecionados');
        _mostrarAlertaSemPets();
        return;
      }

      _mostrarModalSelecaoPets(service);
    }
  }

  void _mostrarAlertaSemPets() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nenhum pet selecionado'),
        content: const Text(
          'Você precisa selecionar pelo menos um pet antes de adicionar serviços.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/choose-pet');
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            child: const Text('Selecionar pets'),
          ),
        ],
      ),
    );
  }

  Future<void> _salvarServicosPorPetNoCache(
      List<Map<String, dynamic>> servicosPorPet) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Converte para string JSON
      final jsonString = json.encode(servicosPorPet);
      await prefs.setString('servicos_por_pet_json', jsonString);

      print('💾 Formato servicosPorPet salvo no cache: $jsonString');
    } catch (e) {
      print('❌ Erro ao salvar servicosPorPet no cache: $e');
    }
  }

  void _navigateToNext() {
    if (_selectedPetIds.isEmpty) {
      _mostrarAlertaSemPets();
      return;
    }

    // Salva serviços no cache (sem enviar para API)
    _salvarDetalhesServicosNoCache();

    if (!mounted) return;

    // Formata os serviços por pet para o cache
    final Map<int, List<int>> petsPorServico = {};
    for (final entry in _servicosPorPet.entries) {
      for (final petId in entry.value) {
        petsPorServico.putIfAbsent(petId, () => []).add(entry.key);
      }
    }

    final servicosPorPetFormatado = petsPorServico.entries.map((entry) {
      return {
        'idPet': entry.key,
        'servicos': entry.value,
      };
    }).toList();

    // Salva o formato serializado no cache
    _salvarServicosPorPetNoCache(servicosPorPetFormatado);

    // Navega sem enviar para API
    context.go('/final-verification', extra: {
      'servicosPorPet': servicosPorPetFormatado,
      'totalValue': totalValue,
    });
  }

  void _tryAgain() {
    _carregarDadosIniciais();
  }

  void _voltarParaSelecaoPets() {
    context.go('/choose-pet');
  }

  double get totalValue {
    return _servicosPorPet.keys.fold(0.0, (sum, serviceId) {
      final service = _services.firstWhere(
        (s) => s.idServico == serviceId,
        orElse: () => ServiceModel(
          idservico: 0,
          idhospedagem: 0,
          descricao: '',
          preco: 0,
        ),
      );
      final quantidadePets = _servicosPorPet[serviceId]?.length ?? 0;
      return sum + (service.preco * quantidadePets);
    });
  }

  int get totalServicosSelecionados {
    return _servicosPorPet.values.fold(0, (sum, pets) => sum + pets.length);
  }

  String _getDescricaoPetsParaServico(int serviceId) {
    final petsIds = _servicosPorPet[serviceId];
    if (petsIds == null || petsIds.isEmpty) return '';

    final petsNomes = petsIds.map((petId) {
      return _petNamesMap[petId] ?? 'Pet $petId';
    }).toList();

    return ' (${petsNomes.join(', ')})';
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 === BUILD DO CHOOSE SERVICE ===');
    print('   isLoading: $_isLoading');
    print('   selectedPetIds: $_selectedPetIds');
    print('   services: ${_services.length}');

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBarReturn(route: '/choose-data'),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Escolha o(s) serviço(s)',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w200,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Opcional',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w200,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _selectedPetIds.isEmpty
                          ? Colors.orange[50]
                          : Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedPetIds.isEmpty
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _selectedPetIds.isEmpty
                                  ? Icons.warning
                                  : Icons.check_circle,
                              color: _selectedPetIds.isEmpty
                                  ? Colors.orange
                                  : Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedPetIds.isEmpty
                                    ? 'Nenhum pet selecionado'
                                    : '${_selectedPetIds.length} pet(s) selecionado(s)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: _selectedPetIds.isEmpty
                                      ? Colors.orange[800]
                                      : Colors.green[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_selectedPetIds.isNotEmpty &&
                            _selectedPetNames.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 28),
                            child: Text(
                              _selectedPetNames.join(', '),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        if (_selectedPetIds.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: GestureDetector(
                              onTap: _voltarParaSelecaoPets,
                              child: Row(
                                children: [
                                  Icon(Icons.arrow_back,
                                      size: 14, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Voltar para seleção de pets',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue[600],
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (_servicosPorPet.isNotEmpty) ...[
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Serviços selecionados:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                onPressed: _limparServicosSelecionados,
                                icon: const Icon(Icons.clear,
                                    color: Colors.blue, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: 'Limpar serviços',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ..._servicosPorPet.entries.map((entry) {
                            final service = _services.firstWhere(
                              (s) => s.idServico == entry.key,
                              orElse: () => ServiceModel(
                                idservico: 0,
                                idhospedagem: 0,
                                descricao: 'Serviço não encontrado',
                                preco: 0,
                              ),
                            );

                            final petCount = entry.value.length;
                            final petText =
                                petCount == 1 ? '1 pet' : '$petCount pets';

                            final petNames = entry.value
                                .map((petId) =>
                                    _petNamesMap[petId] ?? 'Pet $petId')
                                .toList();

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ${service.descricao} ($petText)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  if (petNames.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(
                                        '  ${petNames.join(', ')}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Valor total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          'R\$${totalValue.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 50,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                            onPressed: _tryAgain,
                            label: 'Tentar Novamente',
                            fontSize: 16,
                          ),
                        ],
                      ),
                    )
                  else if (_services.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.construction,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Nenhum serviço disponível',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _services.map((service) {
                        final petsParaEsteServico =
                            _servicosPorPet[service.idServico];
                        final isSelecionado = petsParaEsteServico != null &&
                            petsParaEsteServico.isNotEmpty;
                        final petCount =
                            isSelecionado ? petsParaEsteServico!.length : 0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: ChooseServiceTemplate(
                            key: ValueKey(service.idServico),
                            name:
                                '${service.descricao} - R\$${service.preco.toStringAsFixed(2)}${petCount > 0 ? '\n($petCount pet${petCount > 1 ? 's' : ''} selecionado${petCount > 1 ? 's' : ''})' : ''}',
                            isSelected: isSelecionado,
                            onTap: () => _toggleServiceSelection(service),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 30),
                  if (_servicosPorPet.isNotEmpty)
                    Column(
                      children: [
                        AppButton(
                          onPressed: () async {
                            await _limparServicosSelecionados();
                            setState(() {});
                          },
                          label: 'Limpar serviços',
                          fontSize: 17,
                          buttonColor: Colors.redAccent,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  AppButton(
                    onPressed: _selectedPetIds.isEmpty
                        ? _voltarParaSelecaoPets
                        : _navigateToNext,
                    label: _selectedPetIds.isEmpty
                        ? 'Voltar para seleção de pets'
                        : 'Próximo',
                    fontSize: 17,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
