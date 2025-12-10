import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/informations/datas_informations.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/informations/pet_informations.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/informations/services_information.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/informations/taxas_informations.dart';
import 'package:pet_family_app/providers/auth_provider.dart';
import 'package:pet_family_app/services/auth_service.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinalVerification extends StatefulWidget {
  const FinalVerification({super.key});

  @override
  State<FinalVerification> createState() => _FinalVerificationState();
}

class _FinalVerificationState extends State<FinalVerification> {
  final TextEditingController _messageController = TextEditingController();

  Map<String, dynamic> _cachedData = {};
  Map<String, dynamic>? _calculoContrato;
  bool _isLoading = true, _isCalculating = false, _calculationError = false;
  int? _idUsuario;
  String _calculationErrorMessage = '';

  // === MÉTODOS PRINCIPAIS ===
  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    await _carregarDadosDoCache();
    await _calcularValorLocalmente(); // Apenas cálculo local
  }

  Future<void> _carregarDadosDoCache() async {
    try {
      print('📦 === CARREGANDO DADOS PARA VISUALIZAÇÃO ===');
      final prefs = await SharedPreferences.getInstance();
      final cachedData = <String, dynamic>{};

      // 1. Carregar ID da hospedagem
      cachedData['idhospedagem'] =
          prefs.getInt('id_hospedagem_selecionada') ?? 1;
      print('🏨 ID da hospedagem: ${cachedData['idhospedagem']}');

      // 2. Carregar pets selecionados - TRATANDO NULL
      final petIds = (prefs.getStringList('selected_pet_ids') ??
              prefs.getStringList('selected_pets') ??
              [])
          .where((id) => id != null && id.isNotEmpty && id != 'null')
          .toList();

      final petNames = (prefs.getStringList('selected_pet_names') ?? [])
          .where((name) => name != null && name.isNotEmpty)
          .toList();

      // Carregar detalhes individuais dos pets
      final petDetails = <int, Map<String, dynamic>>{};
      for (final petIdStr in petIds) {
        final petId = int.tryParse(petIdStr);
        if (petId != null) {
          final petName = prefs.getString('pet_${petId}_name') ??
              _findPetName(petId, petIds, petNames);
          final petSpecies = prefs.getInt('pet_${petId}_species');
          final petBreed = prefs.getInt('pet_${petId}_breed');

          petDetails[petId] = {
            'id': petId,
            'name': petName,
            'species': petSpecies,
            'breed': petBreed,
          };
        }
      }

      print('🐾 Pets IDs: $petIds');
      print('🐾 Pets nomes: $petNames');
      print('🐾 Detalhes dos pets: $petDetails');

      cachedData['selected_pets'] = {
        'ids': petIds,
        'names': petNames,
        'details': petDetails,
        'count': petIds.length,
      };

      // 3. Carregar datas da hospedagem
      final startDateMillis = prefs.getInt('selected_start_date');
      final endDateMillis = prefs.getInt('selected_end_date');
      final startDateStr = prefs.getString('selected_start_date_str');
      final endDateStr = prefs.getString('selected_end_date_str');
      final daysCount = prefs.getInt('selected_days_count') ??
          prefs.getInt('stay_days_count') ??
          0;

      DateTime? startDate;
      DateTime? endDate;

      if (startDateMillis != null) {
        startDate = DateTime.fromMillisecondsSinceEpoch(startDateMillis);
      } else if (startDateStr != null) {
        startDate = DateTime.tryParse(startDateStr);
      }

      if (endDateMillis != null) {
        endDate = DateTime.fromMillisecondsSinceEpoch(endDateMillis);
      } else if (endDateStr != null) {
        endDate = DateTime.tryParse(endDateStr);
      }

      cachedData['selected_dates'] = {
        'start_date': startDate,
        'end_date': endDate,
        'start_date_str': startDateStr,
        'end_date_str': endDateStr,
        'days_count': daysCount,
        'start_millis': startDateMillis,
        'end_millis': endDateMillis,
      };

      // 4. Carregar serviços adicionais (COM TRATAMENTO DE NULL)
      final servicesJson = prefs.getString('servicos_por_pet_json');
      List<Map<String, dynamic>> servicosPorPet = [];
      List<Map<String, dynamic>> servicesDetailed = [];
      double servicesTotal = 0.0;
      Map<int, String> serviceNamesMap = {};
      Map<int, double> servicePricesMap = {};

      if (servicesJson != null && servicesJson.isNotEmpty) {
        try {
          print('🛒 Serviços JSON encontrado: $servicesJson');

          // DECODIFICAÇÃO SEGURA DO JSON
          final decodedData = json.decode(servicesJson);
          print('📋 Dados decodificados: $decodedData');

          // VERIFICA SE É UMA LISTA ANTES DE FAZER CAST
          if (decodedData is List) {
            servicosPorPet = decodedData
                .where((item) => item is Map<String, dynamic>)
                .map((item) => item as Map<String, dynamic>)
                .toList();

            print(
                '✅ Serviços processados como lista: ${servicosPorPet.length} itens');
          } else if (decodedData is Map<String, dynamic>) {
            // Se for um mapa, converte para lista
            servicosPorPet = [decodedData];
            print('⚠️ Serviços convertidos de mapa para lista');
          } else {
            print(
                '⚠️ Formato inesperado de serviços: ${decodedData.runtimeType}');
          }

          // Carregar detalhes dos serviços (preços e nomes) - COM VERIFICAÇÃO DE NULL
          final selectedServiceIds =
              prefs.getStringList('selected_service_ids') ?? [];
          print('🔍 IDs de serviços no cache: $selectedServiceIds');

          for (final serviceIdStr in selectedServiceIds) {
            if (serviceIdStr.isNotEmpty) {
              final serviceId = int.tryParse(serviceIdStr);
              if (serviceId != null) {
                final price =
                    prefs.getDouble('service_${serviceId}_price') ?? 0.0;
                final name = prefs.getString('service_${serviceId}_name') ??
                    'Serviço $serviceId';
                serviceNamesMap[serviceId] = name;
                servicePricesMap[serviceId] = price;
                print('💰 Serviço $serviceId: $name - R\$$price');
              }
            }
          }

          // Processar serviços por pet para criação do formato detalhado
          for (var item in servicosPorPet) {
            try {
              final petId = _parseToInt(item['idPet']);
              final servicosRaw = item['servicos'];

              // TRATAMENTO SEGURO PARA A LISTA DE SERVIÇOS
              List<int> servicos = [];
              if (servicosRaw is List) {
                servicos = servicosRaw
                    .map((e) => _parseToInt(e))
                    .where((id) => id != null)
                    .map((id) => id!)
                    .toList();
              } else if (servicosRaw is String) {
                // Se for string, tenta dividir por vírgula
                servicos = servicosRaw
                    .split(',')
                    .map((id) => _parseToInt(id.trim()))
                    .where((id) => id != null)
                    .map((id) => id!)
                    .toList();
              }

              if (petId != null && servicos.isNotEmpty) {
                final petName = petDetails[petId]?['name'] ?? 'Pet $petId';
                final petServices = <Map<String, dynamic>>[];
                double petServicesTotal = 0.0;

                for (final serviceId in servicos) {
                  final serviceName =
                      serviceNamesMap[serviceId] ?? 'Serviço $serviceId';
                  final servicePrice = servicePricesMap[serviceId] ?? 0.0;

                  petServices.add({
                    'id': serviceId,
                    'name': serviceName,
                    'price': servicePrice,
                  });

                  petServicesTotal += servicePrice;
                  servicesTotal += servicePrice;
                }

                servicesDetailed.add({
                  'pet_id': petId,
                  'pet_name': petName,
                  'services': petServices,
                  'total': petServicesTotal,
                });

                print(
                    '🐕 Pet $petId ($petName): ${servicos.length} serviços - R\$$petServicesTotal');
              }
            } catch (e) {
              print('⚠️ Erro ao processar item de serviço: $e');
              print('   Item: $item');
            }
          }
        } catch (e) {
          print('❌ Erro ao decodificar serviços JSON: $e');
          print('🔍 Stack trace: ${e.toString()}');
        }
      } else {
        print('📭 Nenhum JSON de serviços encontrado no cache');
        // Fallback: tenta carregar do formato antigo
        await _loadServicesFromLegacyFormat(
            prefs, petDetails, servicesDetailed, servicesTotal);
      }

      // Carrega também o valor total do cache
      final cachedServicesTotal =
          prefs.getDouble('selected_services_total') ?? 0.0;
      if (cachedServicesTotal > 0) {
        servicesTotal = cachedServicesTotal;
      }

      // Carrega nomes dos serviços - COM VERIFICAÇÃO
      final serviceNames = (prefs.getStringList('selected_service_names') ?? [])
          .where((name) => name != null && name.isNotEmpty)
          .toList();

      cachedData['selected_services'] = {
        'services_by_pet': servicosPorPet,
        'services_detailed': servicesDetailed,
        'service_names': serviceNames,
        'service_names_map': serviceNamesMap,
        'service_prices_map': servicePricesMap,
        'total_value': servicesTotal,
        'has_services': servicesDetailed.isNotEmpty,
        'service_count': servicesDetailed.fold(
            0, (sum, pet) => sum + ((pet['services'] as List?)?.length ?? 0)),
      };

      // 5. Carregar informações do hotel
      final dailyRateString = prefs.getString('hotel_daily_rate') ??
          prefs.getString('hotel_valor_diaria') ??
          '100.0';
      final dailyRate = double.tryParse(dailyRateString) ?? 100.0;

      cachedData['hotel_info'] = {
        'daily_rate': dailyRate,
        'name': prefs.getString('hotel_name') ?? 'Hotel',
        'address': prefs.getString('hotel_address'),
        'phone': prefs.getString('hotel_phone'),
      };

      // 6. Carregar taxas e outras informações
      cachedData['tax_info'] = {
        'tax_rate': prefs.getDouble('tax_rate') ?? 0.0,
        'cleaning_fee': prefs.getDouble('cleaning_fee') ?? 0.0,
      };

      // Log resumido
      print('\n📊 === RESUMO DOS DADOS CARREGADOS ===');
      print('🏨 Hotel: ${cachedData['hotel_info']['name']}');
      print('💰 Diária: R\$${cachedData['hotel_info']['daily_rate']}');
      print('🐾 Pets: ${petIds.length} (${petNames.join(', ')})');
      print('📅 Período: ${startDateStr ?? "N/D"} até ${endDateStr ?? "N/D"}');
      print('📅 Dias: $daysCount');
      print(
          '🛒 Serviços: ${cachedData['selected_services']['service_count']} serviços para ${servicesDetailed.length} pets');
      print('💵 Valor serviços: R\$$servicesTotal');
      print('📋 Serviços detalhados: $servicesDetailed');
      print('=====================================\n');

      setState(() {
        _cachedData = cachedData;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ ERRO ao carregar cache: $e');
      print('🔍 Stack trace: ${e.toString()}');
      setState(() {
        _isLoading = false;
        _calculationError = true;
        _calculationErrorMessage = 'Erro ao carregar dados para visualização.';
      });
    }
  }

// Método auxiliar para carregar serviços do formato legado
  Future<void> _loadServicesFromLegacyFormat(
    SharedPreferences prefs,
    Map<int, Map<String, dynamic>> petDetails,
    List<Map<String, dynamic>> servicesDetailed,
    double servicesTotal,
  ) async {
    try {
      final servicosPorPetList = prefs.getStringList('servicos_por_pet') ?? [];
      if (servicosPorPetList.isNotEmpty) {
        print(
            '📋 Carregando serviços do formato antigo: ${servicosPorPetList.length} itens');

        final Map<int, List<int>> servicesByPetMap = {};

        for (var entryString in servicosPorPetList) {
          if (entryString.isNotEmpty) {
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
                      .toList();

                  for (var petId in petIds) {
                    servicesByPetMap
                        .putIfAbsent(petId, () => [])
                        .add(serviceId);
                  }
                }
              }
            }
          }
        }

        // Converter para o novo formato
        for (final entry in servicesByPetMap.entries) {
          final petId = entry.key;
          final serviceIds = entry.value;
          final petName = petDetails[petId]?['name'] ?? 'Pet $petId';
          final petServices = <Map<String, dynamic>>[];
          double petServicesTotal = 0.0;

          for (final serviceId in serviceIds) {
            final servicePrice =
                prefs.getDouble('service_${serviceId}_price') ?? 0.0;
            final serviceName = prefs.getString('service_${serviceId}_name') ??
                'Serviço $serviceId';

            petServices.add({
              'id': serviceId,
              'name': serviceName,
              'price': servicePrice,
            });

            petServicesTotal += servicePrice;
            servicesTotal += servicePrice;
          }

          servicesDetailed.add({
            'pet_id': petId,
            'pet_name': petName,
            'services': petServices,
            'total': petServicesTotal,
          });
        }
      }
    } catch (e) {
      print('❌ Erro ao carregar formato legado: $e');
    }
  }

// Método auxiliar para converter valores para int
  int? _parseToInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

// Método auxiliar para encontrar nome do pet
  String _findPetName(int petId, List<String> petIds, List<String> petNames) {
    for (int i = 0; i < petIds.length; i++) {
      if (i < petNames.length && int.tryParse(petIds[i]) == petId) {
        return petNames[i];
      }
    }
    return 'Pet $petId';
  }

  // APENAS CÁLCULO LOCAL (não chama API)
  Future<void> _calcularValorLocalmente() async {
    try {
      setState(() {
        _isCalculating = true;
        _calculationError = false;
      });

      final dates = _cachedData['selected_dates']!;
      final pets = _cachedData['selected_pets']!;
      final services = _cachedData['selected_services']!;
      final hotelInfo = _cachedData['hotel_info']!;

      final quantidadeDias = (dates['days_count'] as int?) ?? 1;
      final quantidadePets = (pets['count'] as int?) ?? 1;
      final valorDiaria = (hotelInfo['daily_rate'] as double?) ?? 100.0;
      final valorServicos = (services['total_value'] as double?) ?? 0.0;

      final valorHospedagem = valorDiaria * quantidadeDias * quantidadePets;
      final valorTotal = valorHospedagem + valorServicos;

      final calculoLocal = {
        'valores': {
          'hospedagem': valorHospedagem,
          'servicos': valorServicos,
          'total': valorTotal,
          'valor_diaria': valorDiaria,
          'dias': quantidadeDias,
        },
        'formatado': {
          'valor_diaria': _formatarMoeda(valorDiaria),
          'valor_hospedagem': _formatarMoeda(valorHospedagem),
          'valor_servicos': _formatarMoeda(valorServicos),
          'valor_total': _formatarMoeda(valorTotal),
          'periodo': '$quantidadeDias dia${quantidadeDias > 1 ? 's' : ''}',
          'pets': '$quantidadePets pet${quantidadePets > 1 ? 's' : ''}',
        },
      };

      print('🧮 Cálculo local realizado: R\$${valorTotal.toStringAsFixed(2)}');

      setState(() {
        _calculoContrato = calculoLocal;
        _isCalculating = false;
      });
    } catch (e) {
      print('❌ ERRO no cálculo local: $e');
      setState(() {
        _isCalculating = false;
        _calculationError = true;
        _calculationErrorMessage = 'Erro ao calcular valores localmente.';
      });
    }
  }

  // === MÉTODOS AUXILIARES (apenas formatação) ===
  String _formatarMoeda(double valor) =>
      'R\$${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // === WIDGETS DE VISUALIZAÇÃO ===
  Widget _buildResumoFinanceiro() {
    if (_isCalculating) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('Calculando valores...'),
            ],
          ),
        ),
      );
    }

    if (_calculationError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange),
        ),
        child: Column(
          children: [
            const Icon(Icons.warning, color: Colors.orange),
            const SizedBox(height: 10),
            Text(
              _calculationErrorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.orange),
            ),
          ],
        ),
      );
    }

    if (_calculoContrato == null) {
      return const SizedBox();
    }

    final valores = _calculoContrato!['valores'] as Map<String, dynamic>;
    final formatado = _calculoContrato!['formatado'] as Map<String, dynamic>;

    final valorHospedagem = _parseDouble(valores['hospedagem']);
    final valorServicos = _parseDouble(valores['servicos']);
    final valorTotal = _parseDouble(valores['total']);

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
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 16),
          _buildItemFinanceiro(
              '🏠 Total da hospedagem', formatado['valor_hospedagem'],
              isSubtotal: true),
          if (valorServicos > 0) ...[
            const SizedBox(height: 12),
            _buildItemFinanceiro(
                '🛎️ Serviços adicionais', formatado['valor_servicos'],
                isSubtotal: true),
          ],
          const SizedBox(height: 12),
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
                  '💳 Total estimado:',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                Text(
                  formatado['valor_total'],
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildItemFinanceiro(String titulo, String valor,
          {bool isSubtotal = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: isSubtotal ? FontWeight.w600 : FontWeight.normal),
          ),
          Text(
            valor,
            style: TextStyle(
                fontSize: 14,
                color: isSubtotal ? Colors.blue : Colors.black,
                fontWeight: isSubtotal ? FontWeight.w600 : FontWeight.normal),
          ),
        ],
      );

  Widget _buildLoading() => const Column(children: [
        SizedBox(height: 20),
        Center(child: CircularProgressIndicator()),
        SizedBox(height: 10),
        Text(
          'Carregando dados...',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        )
      ]);

  Widget _buildEmptyState() => Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.orange[300],
          ),
          const SizedBox(height: 16),
          const Text(
            'Dados incompletos',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text('Selecione pets e datas para continuar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go('/choose-pet'),
            child: const Text('Voltar para Pets'),
          )
        ],
      );

  Widget _buildDataSummary() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildResumoFinanceiro(),
        const SizedBox(height: 30),
        if (_cachedData['selected_pets'] != null)
          PetInformations(cachedData: _cachedData),
        const SizedBox(height: 30),
        if (_cachedData['selected_dates'] != null)
          DatasInformations(cachedData: _cachedData),
        const SizedBox(height: 30),
        // CORREÇÃO AQUI: Verifica se há serviços usando 'has_services'
        if (_cachedData['selected_services'] != null &&
            (_cachedData['selected_services']['has_services'] as bool? ??
                false))
          ServicesInformation(cachedData: _cachedData),
        const SizedBox(height: 30),
        TaxasInformations(cachedData: _cachedData)
      ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppBarReturn(route: '/choose-service'),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Verificação final',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w200,
                          color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Confirme todos os dados da sua reserva',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 40),

                  if (_isLoading)
                    _buildLoading()
                  else if (_cachedData.isEmpty ||
                      (_cachedData['selected_pets']?['ids'] as List?)
                              ?.isEmpty ==
                          true ||
                      _cachedData['selected_dates']?['start_date'] == null)
                    _buildEmptyState()
                  else
                    _buildDataSummary(),

                  const SizedBox(height: 40),

                  // BOTÃO PARA IR PARA PAGAMENTO
                  AppButton(
                    onPressed: (_cachedData.isNotEmpty &&
                            (_cachedData['selected_pets']?['ids'] as List?)
                                    ?.isNotEmpty ==
                                true &&
                            _cachedData['selected_dates']?['start_date'] !=
                                null)
                        ? () {
                            print('➡️ Indo para tela de pagamento...');
                            context.go('/payment');
                          }
                        : null,
                    label: 'Ir para Pagamento',
                    fontSize: 18,
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
