import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/informations/datas_informations.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/informations/pet_informations.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/informations/services_information.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/informations/taxas_informations.dart';
import 'package:pet_family_app/providers/auth_provider.dart';
import 'package:pet_family_app/repository/contrato_repository.dart';
import 'package:pet_family_app/services/auth_service.dart';
import 'package:pet_family_app/services/contrato_service.dart';
import 'package:dio/dio.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FinalVerification extends StatefulWidget {
  const FinalVerification({super.key});

  @override
  State<FinalVerification> createState() => _FinalVerificationState();
}

class _FinalVerificationState extends State<FinalVerification> {
  late final ContratoRepository _contratoRepository;
  final TextEditingController _messageController = TextEditingController();

  Map<String, dynamic> _cachedData = {};
  Map<String, dynamic>? _calculoContrato;
  bool _isLoading = true,
      _isCreatingContract = false,
      _isCalculating = false,
      _calculationError = false;
  int? _idUsuario;
  String _calculationErrorMessage = '';

  // === MÉTODOS PRINCIPAIS ===
  @override
  void initState() {
    super.initState();
    _inicializarRepository();
    _carregarDados();
  }

  void _inicializarRepository() {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ));

      final contratoService = ContratoService(dio);
      _contratoRepository =
          ContratoRepositoryImpl(contratoService: contratoService);

      print('✅ ContratoRepository inicializado com sucesso');
    } catch (e) {
      print('❌ Erro ao inicializar ContratoRepository: $e');
      final dio = Dio();
      final contratoService = ContratoService(dio);
      _contratoRepository =
          ContratoRepositoryImpl(contratoService: contratoService);
    }
  }

  Future<void> _carregarDados() async {
    await _carregarDadosDoCache();
    await _obterIdUsuario();
    await _calcularValorContrato();
  }

  Future<void> _obterIdUsuario() async {
    try {
      final authProvider = AuthProvider();
      final authService = AuthService();
      final idUsuario = await authService.getUserIdFromCache();

      if (idUsuario == null) {
        print('⚠️ Usuário não encontrado no cache do AuthProvider');

        final prefs = await SharedPreferences.getInstance();
        final cachedUserId = prefs.getInt('user_id');

        if (cachedUserId != null) {
          _idUsuario = cachedUserId;
          print('✅ ID do usuário obtido do SharedPreferences: $_idUsuario');
        } else {
          print('❌ ID do usuário não encontrado em nenhum local');
        }
      } else {
        _idUsuario = idUsuario;
        print('✅ ID do usuário obtido do AuthProvider: $_idUsuario');
      }
    } catch (e) {
      print('❌ Erro ao obter ID do usuário: $e');
    }
  }

  Future<void> _carregarDadosDoCache() async {
    try {
      print('📦 === INICIANDO CARREGAMENTO DO CACHE ===');
      final prefs = await SharedPreferences.getInstance();
      final cachedData = <String, dynamic>{};

      // Carregar ID da hospedagem
      cachedData['idhospedagem'] =
          prefs.getInt('id_hospedagem_selecionada') ?? 1;
      print('🏨 ID da hospedagem: ${cachedData['idhospedagem']}');

      // Carregar pets
      final petIds = prefs.getStringList('selected_pet_ids') ??
          prefs.getStringList('selected_pets') ??
          [];
      final petNames = prefs.getStringList('selected_pet_names') ?? [];

      print('🐾 Pets IDs: $petIds');
      print('🐾 Pets nomes: $petNames');

      cachedData['selected_pets'] = {
        'ids': petIds,
        'names': petNames,
        'count': petIds.length,
      };

      // Carregar datas
      final startDateMillis = prefs.getInt('selected_start_date');
      final endDateMillis = prefs.getInt('selected_end_date');
      final startDateStr = prefs.getString('selected_start_date_str');
      final endDateStr = prefs.getString('selected_end_date_str');
      final daysCount = prefs.getInt('selected_days_count') ??
          prefs.getInt('stay_days_count') ??
          0;

      print('📅 Start date millis: $startDateMillis');
      print('📅 End date millis: $endDateMillis');
      print('📅 Start date string: $startDateStr');
      print('📅 End date string: $endDateStr');
      print('📅 Days count: $daysCount');

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
      };

      // Carregar serviços
      final servicesJson = prefs.getString('servicos_por_pet_json');
      List<Map<String, dynamic>> servicosPorPet = [];
      if (servicesJson != null && servicesJson.isNotEmpty) {
        try {
          servicosPorPet =
              List<Map<String, dynamic>>.from(json.decode(servicesJson));
          print('🛒 Serviços JSON carregados: $servicosPorPet');
        } catch (e) {
          print('❌ Erro ao decodificar serviços JSON: $e');
        }
      }

      // Extrair IDs de serviços únicos
      final Set<int> serviceIds = {};
      for (var item in servicosPorPet) {
        if (item['servicos'] is List) {
          final servicos = item['servicos'] as List;
          for (var servico in servicos) {
            if (servico is int) {
              serviceIds.add(servico);
            } else if (servico is String) {
              final id = int.tryParse(servico);
              if (id != null) serviceIds.add(id);
            }
          }
        }
      }

      final servicesTotal = prefs.getDouble('selected_services_total') ?? 0.0;
      print('💰 Valor total dos serviços: $servicesTotal');

      cachedData['selected_services'] = {
        'ids': serviceIds.map((id) => id.toString()).toList(),
        'service_ids': serviceIds.toList(),
        'services_by_pet': servicosPorPet,
        'total_value': servicesTotal,
      };

      // Carregar hotel info
      final dailyRateString = prefs.getString('hotel_daily_rate') ??
          prefs.getString('hotel_valor_diaria') ??
          '100.0';
      final dailyRate = double.tryParse(dailyRateString) ?? 100.0;

      print('🏨 Hotel daily rate string: $dailyRateString');
      print('🏨 Hotel daily rate double: $dailyRate');

      cachedData['hotel_info'] = {
        'daily_rate': dailyRate,
        'name': prefs.getString('hotel_name') ?? 'Hotel',
      };

      // Log completo para debug
      print('📊 === RESUMO DOS DADOS CARREGADOS ===');
      print('   Pets IDs: ${cachedData['selected_pets']['ids']}');
      print('   Pets nomes: ${cachedData['selected_pets']['names']}');
      print('   Pets count: ${cachedData['selected_pets']['count']}');
      print('   Data início: ${cachedData['selected_dates']['start_date']}');
      print('   Data fim: ${cachedData['selected_dates']['end_date']}');
      print('   Dias: ${cachedData['selected_dates']['days_count']}');
      print(
          '   Serviços IDs: ${cachedData['selected_services']['service_ids']}');
      print('   Valor diária: ${cachedData['hotel_info']['daily_rate']}');

      // Verificar se tem dados mínimos
      final hasPets = (cachedData['selected_pets']['ids'] as List).isNotEmpty;
      final hasDates = cachedData['selected_dates']['start_date'] != null &&
          cachedData['selected_dates']['end_date'] != null;

      print('✅ Pets válidos: $hasPets');
      print('✅ Datas válidas: $hasDates');
      print('✅ Tem dados completos: ${hasPets && hasDates}');

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
        _calculationErrorMessage =
            'Erro ao carregar dados. Por favor, reinicie o processo.';
      });
    }
  }

  Future<void> _calcularValorContrato() async {
    try {
      if (_isCalculating) return;

      setState(() {
        _isCalculating = true;
        _calculationError = false;
        _calculationErrorMessage = '';
      });

      final dates = _cachedData['selected_dates']!;
      final startDate = dates['start_date'] as DateTime?;
      final endDate = dates['end_date'] as DateTime?;

      if (startDate == null || endDate == null) {
        print('❌ Datas inválidas: start=$startDate, end=$endDate');
        throw Exception('Datas de hospedagem inválidas');
      }

      final services = _cachedData['selected_services'];
      final idHospedagem = _cachedData['idhospedagem'] as int;

      print('🧮 === INICIANDO CÁLCULO ===');
      print('   Hospedagem ID: $idHospedagem');
      print('   Data início: ${_formatarDataParaAPI(startDate)}');
      print('   Data fim: ${_formatarDataParaAPI(endDate)}');
      print('   Serviços: ${services['service_ids']}');

      // Tentar cálculo pela API
      try {
        final calculo = await _contratoRepository.calcularValorContrato(
          idHospedagem: idHospedagem,
          dataInicio: _formatarDataParaAPI(startDate),
          dataFim: _formatarDataParaAPI(endDate),
          servicos: services['services_by_pet'] != null &&
                  (services['services_by_pet'] as List).isNotEmpty
              ? _formatarServicosParaCalculo(
                  services['services_by_pet'] as List<Map<String, dynamic>>)
              : null,
        );

        print('✅ Cálculo API realizado com sucesso!');
        print('   Resultado: $calculo');

        setState(() {
          _calculoContrato = calculo;
          _isCalculating = false;
        });
      } catch (apiError) {
        print('⚠️ Erro na API, usando cálculo local: $apiError');
        await _calcularValorLocalmente();
      }
    } catch (e) {
      print('❌ ERRO no cálculo: $e');
      print('🔍 Stack trace: ${e.toString()}');

      try {
        await _calcularValorLocalmente();
      } catch (localError) {
        setState(() {
          _isCalculating = false;
          _calculationError = true;
          _calculationErrorMessage =
              'Erro ao calcular valores. Por favor, verifique os dados.';
        });
      }
    }
  }

  Future<void> _calcularValorLocalmente() async {
    try {
      print('🧮 === INICIANDO CÁLCULO LOCAL ===');

      final dates = _cachedData['selected_dates']!;
      final pets = _cachedData['selected_pets']!;
      final services = _cachedData['selected_services']!;
      final hotelInfo = _cachedData['hotel_info']!;

      print('📊 Dados para cálculo local:');
      print('   Dates: $dates');
      print('   Pets: $pets');
      print('   Services: $services');
      print('   Hotel info: $hotelInfo');

      final quantidadeDias = (dates['days_count'] as int?) ?? 1;
      final quantidadePets =
          (pets['count'] as int?) ?? ((pets['ids'] as List).length) ?? 1;
      final valorDiaria = (hotelInfo['daily_rate'] as double?) ?? 100.0;
      final valorServicos = (services['total_value'] as double?) ?? 0.0;

      print('🔢 Valores extraídos:');
      print('   Dias: $quantidadeDias');
      print('   Pets: $quantidadePets');
      print('   Diária: $valorDiaria');
      print('   Serviços: $valorServicos');

      final valorHospedagem = valorDiaria * quantidadeDias * quantidadePets;
      final valorTotal = valorHospedagem + valorServicos;

      print('🧮 Resultados do cálculo:');
      print('   Hospedagem: R\$$valorHospedagem');
      print('   + Serviços: R\$$valorServicos');
      print('   = Total: R\$$valorTotal');

      final calculoLocal = {
        'valores': {
          'hospedagem': valorHospedagem,
          'servicos': valorServicos,
          'total': valorTotal,
          'valor_diaria': valorDiaria,
          'dias': quantidadeDias,
        },
        'resumo': {
          'valor_diaria': valorDiaria,
          'quantidade_dias': quantidadeDias,
          'quantidade_pets': quantidadePets,
          'servicos_selecionados':
              ((services['service_ids'] as List?)?.length ?? 0),
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

      print('✅ Cálculo local realizado com sucesso!');
      print('   Resultado: $calculoLocal');

      setState(() {
        _calculoContrato = calculoLocal;
        _isCalculating = false;
        _calculationError = false;
      });
    } catch (e) {
      print('❌ ERRO CRÍTICO no cálculo local: $e');

      final calculoFallback = {
        'valores': {
          'hospedagem': 0.0,
          'servicos': 0.0,
          'total': 0.0,
          'valor_diaria': 100.0,
          'dias': 1,
        },
        'resumo': {
          'valor_diaria': 100.0,
          'quantidade_dias': 1,
          'quantidade_pets': 1,
          'servicos_selecionados': 0,
        },
        'formatado': {
          'valor_diaria': 'R\$100,00',
          'valor_hospedagem': 'R\$0,00',
          'valor_servicos': 'R\$0,00',
          'valor_total': 'R\$0,00',
          'periodo': '1 dia',
          'pets': '1 pet',
        },
      };

      setState(() {
        _calculoContrato = calculoFallback;
        _isCalculating = false;
        _calculationError = false;
        _calculationErrorMessage = 'Usando valores estimados.';
      });
    }
  }

  List<Map<String, dynamic>> _formatarServicosParaCalculo(
      List<Map<String, dynamic>> servicosPorPet) {
    final Map<int, int> contagemServicos = {};

    for (var item in servicosPorPet) {
      final petId = item['idPet'] as int?;
      final servicos = item['servicos'] as List<dynamic>?;

      if (petId != null && servicos != null) {
        for (var servico in servicos) {
          if (servico is int) {
            contagemServicos[servico] = (contagemServicos[servico] ?? 0) + 1;
          } else if (servico is String) {
            final id = int.tryParse(servico);
            if (id != null) {
              contagemServicos[id] = (contagemServicos[id] ?? 0) + 1;
            }
          }
        }
      }
    }

    return contagemServicos.entries.map((entry) {
      return {
        'idservico': entry.key,
        'quantidade': entry.value,
      };
    }).toList();
  }

  // === MÉTODO PRINCIPAL CORRIGIDO - CRIAR CONTRATO ===
  Future<void> _criarContrato() async {
    try {
      if (_isCreatingContract) return;
      
      setState(() => _isCreatingContract = true);

      // Verificar se temos o ID do usuário
      if (_idUsuario == null || _idUsuario == 0) {
        await _obterIdUsuario();
        if (_idUsuario == null || _idUsuario == 0) {
          if (mounted) {
            _mostrarErroDialog('Usuário não identificado. Faça login novamente.');
          }
          setState(() => _isCreatingContract = false);
          return;
        }
      }

      final pets = _cachedData['selected_pets']!;
      final dates = _cachedData['selected_dates']!;
      final services = _cachedData['selected_services']!;

      final prefs = await SharedPreferences.getInstance();
      final idHospedagem = prefs.getInt('id_hospedagem_selecionada') ?? 1;

      print('📝 === CRIANDO CONTRATO ===');
      print('👤 ID Usuário: $_idUsuario');
      print('🏨 ID Hospedagem: $idHospedagem');
      print('📅 Data início: ${dates['start_date']}');
      print('📅 Data fim: ${dates['end_date']}');
      print('🐾 Pets IDs: ${pets['ids']}');

      // 1. Converter IDs de pets para lista de inteiros
      final List<int> listaPets = [];
      for (var petIdString in (pets['ids'] as List<String>)) {
        final petId = int.tryParse(petIdString);
        if (petId != null && petId > 0) {
          listaPets.add(petId);
        }
      }

      if (listaPets.isEmpty) {
        throw Exception('Nenhum pet válido selecionado');
      }

      print('✅ Pets convertidos para int: $listaPets');

      // 2. Formatar serviços no formato que a API espera
      final servicosPorPet = services['services_by_pet'] as List<Map<String, dynamic>>?;
      List<Map<String, dynamic>>? servicosFormatados;
      
      if (servicosPorPet != null && servicosPorPet.isNotEmpty) {
        print('🛎️ Formatando serviços para criação do contrato...');
        servicosFormatados = [];
        
        for (var item in servicosPorPet) {
          final dynamic petId = item['idPet'];
          final servicos = item['servicos'] as List<dynamic>?;
          
          if (petId != null && servicos != null && servicos.isNotEmpty) {
            final intPetId = petId is int ? petId : int.tryParse(petId.toString());
            
            if (intPetId != null && intPetId > 0) {
              final servicosInt = servicos
                  .map((s) {
                    if (s is int) return s;
                    if (s is String) {
                      final id = int.tryParse(s);
                      return id ?? 0;
                    }
                    return 0;
                  })
                  .where((id) => id > 0)
                  .toList();
              
              if (servicosInt.isNotEmpty) {
                // Formato EXATO: {"idPet": X, "servicos": [Y, Z]}
                servicosFormatados.add({
                  'idPet': intPetId,
                  'servicos': servicosInt,
                });
                
                print('   ✅ Pet $intPetId - Serviços: $servicosInt');
              }
            }
          }
        }
        
        print('📦 Total de pets com serviços: ${servicosFormatados?.length ?? 0}');
      } else {
        print('ℹ️ Nenhum serviço para adicionar');
        servicosFormatados = null;
      }

      // 3. Formatar datas corretamente
      final dataInicio = _formatarDataParaAPI(dates['start_date'] as DateTime);
      final dataFim = _formatarDataParaAPI(dates['end_date'] as DateTime);
      
      print('📅 Data início formatada: $dataInicio');
      print('📅 Data fim formatada: $dataFim');

      // 4. DEBUG: Mostrar exatamente o que será enviado
      print('🚀 === DADOS PARA CRIAÇÃO DO CONTRATO ===');
      print('   idHospedagem: $idHospedagem');
      print('   idUsuario: $_idUsuario');
      print('   status: em_aprovacao');
      print('   dataInicio: $dataInicio');
      print('   dataFim: $dataFim');
      print('   pets: $listaPets');
      print('   servicosPorPet: $servicosFormatados');
      
      // 5. Criar o contrato COM serviços (se existirem) de uma vez só
      print('🚀 Enviando para API...');
      
      try {
        final contrato = await _contratoRepository.criarContrato(
          idHospedagem: idHospedagem,
          idUsuario: _idUsuario!,
          dataInicio: dataInicio,
          dataFim: dataFim,
          pets: listaPets,
          servicos: servicosFormatados,
          status: 'em_aprovacao',
        );

        final idContrato = contrato.idContrato;
        print('✅ ✅ CONTRATO CRIADO COM SUCESSO! ID: $idContrato');
        
        // 6. Verificar se os serviços foram incluídos
        if (servicosFormatados != null && servicosFormatados.isNotEmpty) {
          print('🔍 Verificando serviços no contrato criado...');
          
          // Apenas logar sem tentar chamar toJson()
          if (contrato.servicosGerais != null && contrato.servicosGerais!.isNotEmpty) {
            print('🎉 ${contrato.servicosGerais!.length} serviço(s) incluído(s) no contrato');
          } else {
            print('⚠️ API não retornou detalhes dos serviços');
          }
        }

        // 7. Limpar cache
        await _limparCache();

        if (mounted) {
          _mostrarSucessoDialog(contrato);
        }
      } on DioException catch (e) {
        print('❌ DioException ao criar contrato:');
        print('   Type: ${e.type}');
        print('   Message: ${e.message}');
        print('   Response: ${e.response?.data}');
        print('   Status Code: ${e.response?.statusCode}');

        if (e.response?.statusCode == 400) {
          final errorData = e.response?.data;
          print('❌ Erro 400: $errorData');
          
          if (errorData is Map) {
            final errorMessage = errorData['message']?.toString() ?? 'Erro desconhecido';
            
            if (errorMessage.contains('Já existe um contrato idêntico ativo') ||
                errorMessage.contains('contrato idêntico')) {
              print('⚠️ Contrato duplicado detectado');
              if (mounted) {
                _mostrarDialogContratoDuplicado();
                setState(() => _isCreatingContract = false);
                return;
              }
            } else {
              if (mounted) {
                _mostrarErroDialog(errorMessage);
              }
            }
          } else {
            if (mounted) {
              _mostrarErroDialog('Erro ao criar contrato: $errorData');
            }
          }
        } else if (e.type == DioExceptionType.connectionTimeout ||
                   e.type == DioExceptionType.receiveTimeout) {
          if (mounted) {
            _mostrarErroDialog('Tempo de conexão esgotado. Verifique sua internet.');
          }
        } else {
          if (mounted) {
            _mostrarErroDialog('Erro de comunicação: ${e.message}');
          }
        }
      } catch (e) {
        print('❌ ERRO geral na criação do contrato: $e');
        print('🔍 Stack trace: ${e.toString()}');
        
        if (mounted) {
          _mostrarErroDialog('Erro inesperado: $e');
        }
      }
    } catch (e) {
      print('❌ ERRO ao criar contrato: $e');
      
      if (mounted) {
        _mostrarErroDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingContract = false);
      }
    }
  }

  // Diálogo para contrato duplicado
  void _mostrarDialogContratoDuplicado() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Contrato já existe'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Já existe um contrato ativo com essas informações.'),
            SizedBox(height: 10),
            Text('Verifique seus agendamentos ativos ou altere as datas/pets selecionados.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/core-navigation'); // Ir para meus agendamentos
            },
            child: const Text('Ver meus agendamentos'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Voltar para datas para alterar
              context.go('/choose-dates');
            },
            child: const Text('Alterar datas'),
          ),
        ],
      ),
    );
  }

  // === MÉTODOS AUXILIARES ===
  String _formatarDataParaAPI(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _formatarMoeda(double valor) =>
      'R\$${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 1;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }

  Future<void> _limparCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysToRemove = [
        'selected_pets',
        'selected_pet_names',
        'selected_start_date',
        'selected_end_date',
        'selected_start_date_str',
        'selected_end_date_str',
        'selected_days_count',
        'selected_services',
        'selected_service_names',
        'selected_service_prices',
        'selected_services_total',
        'hotel_daily_rate',
        'hotel_valor_diario',
        'selected_pets_count',
        'stay_days_count',
        'id_hospedagem_selecionada',
        'servicos_por_pet',
        'servicos_por_pet_json',
      ];

      for (var key in keysToRemove) {
        await prefs.remove(key);
      }
      print('🗑️ Cache limpo com sucesso');
    } catch (e) {
      print('❌ Erro ao limpar cache: $e');
    }
  }

  void _mostrarSucessoDialog(dynamic contrato) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Sucesso!')
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Seu agendamento foi criado com sucesso!'),
            const SizedBox(height: 10),
            const Text('Status: Em Aprovação'),
            const SizedBox(height: 10),
            if (contrato.idContrato != null)
              Text('ID do Contrato: ${contrato.idContrato}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navegar para a tela de agendamentos
              context.go('/core-navigation');
            },
            child: const Text('Ver Meus Agendamentos'),
          )
        ],
      ),
    );
  }

  void _mostrarErroDialog(String error) {
    String mensagemErro = error;

    if (error.contains('Usuário não identificado')) {
      mensagemErro = 'Por favor, faça login novamente para continuar.';
    } else if (error.contains('Connection') || error.contains('timeout')) {
      mensagemErro =
          'Problema de conexão. Verifique sua internet e tente novamente.';
    } else if (error.contains('Recurso não encontrado')) {
      mensagemErro =
          'O serviço de cálculo está temporariamente indisponível. Seus dados foram salvos e o valor foi calculado localmente.';
    } else if (error.contains('Já existe um contrato')) {
      mensagemErro = error; // Manter a mensagem original
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: 8),
          Text('Atenção')
        ]),
        content: Text(mensagemErro),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (error.contains('Usuário não identificado'))
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/login');
              },
              child: const Text('Ir para Login'),
            ),
        ],
      ),
    );
  }

  // === GETTERS PARA DADOS ===
  bool get _hasData {
    final pets = _cachedData['selected_pets'] as Map<String, dynamic>?;
    final dates = _cachedData['selected_dates'] as Map<String, dynamic>?;
    return (pets?['ids'] != null && pets!['ids'].isNotEmpty) &&
        (dates?['start_date'] != null && dates?['end_date'] != null);
  }

  bool get _temDadosCalculadosAPI =>
      _calculoContrato != null && _calculoContrato!['valores'] != null;

  Future<double> _obterValorHospedagem() async {
    if (_temDadosCalculadosAPI) {
      final valores = _calculoContrato!['valores'] as Map<String, dynamic>;
      if (valores['hospedagem'] != null)
        return _parseDouble(valores['hospedagem']);
    }

    // Fallback: cálculo manual
    final dates = _cachedData['selected_dates'] as Map<String, dynamic>?;
    final pets = _cachedData['selected_pets'] as Map<String, dynamic>?;
    final hotelInfo = _cachedData['hotel_info'] as Map<String, dynamic>?;

    if (dates != null &&
        dates['days_count'] != null &&
        pets != null &&
        hotelInfo != null) {
      final valorDiaria = hotelInfo['daily_rate'] as double? ?? 100.0;
      final quantidadePets = pets['count'] as int? ?? 1;
      final quantidadeDias = dates['days_count'] as int? ?? 1;
      return valorDiaria * quantidadeDias * quantidadePets;
    }
    return 0.0;
  }

  double _obterValorServicos() {
    if (_temDadosCalculadosAPI) {
      final valores = _calculoContrato!['valores'] as Map<String, dynamic>;
      if (valores['servicos'] != null) return _parseDouble(valores['servicos']);
    }

    final services = _cachedData['selected_services'] as Map<String, dynamic>?;
    if (services != null && services['total_value'] != null) {
      return _parseDouble(services['total_value']);
    }
    return 0.0;
  }

  Future<double> _obterValorTotal() async =>
      await _obterValorHospedagem() + _obterValorServicos();

  // === WIDGETS ===
  Widget _buildResumoFinanceiro() {
    return FutureBuilder<double>(
      future: _obterValorHospedagem(),
      builder: (context, snapshotHospedagem) {
        return FutureBuilder<double>(
          future: _obterValorTotal(),
          builder: (context, snapshotTotal) {
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

            if (!snapshotHospedagem.hasData || !snapshotTotal.hasData) {
              return const CircularProgressIndicator();
            }

            final valorHospedagem = snapshotHospedagem.data ?? 0.0;
            final valorServicos = _obterValorServicos();
            final valorTotal = snapshotTotal.data ?? 0.0;

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
                        color: Colors.green),
                  ),
                  const SizedBox(height: 16),
                  _buildItemFinanceiro(
                      '🏠 Total da hospedagem', _formatarMoeda(valorHospedagem),
                      isSubtotal: true),
                  if (valorServicos > 0) ...[
                    const SizedBox(height: 12),
                    _buildItemFinanceiro('🛎️ Serviços adicionais',
                        _formatarMoeda(valorServicos),
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
                          '💳 Total do contrato:',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                        Text(
                          _formatarMoeda(valorTotal),
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '* Cálculo realizado localmente',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
          'Carregando...',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        )
      ]);

  Widget _buildCalculating() => Column(children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        const Text(
          'Calculando...',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 20)
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
        if (_cachedData['selected_services'] != null &&
            (_cachedData['selected_services']['service_ids'] as List)
                .isNotEmpty)
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

                  // Verificar se usuário está logado
                  if (_idUsuario == null || _idUsuario == 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(height: 10),
                          const Text(
                            'Usuário não identificado',
                            style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'É necessário estar logado para criar um agendamento.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              context.go('/login');
                            },
                            child: const Text('Fazer Login'),
                          ),
                        ],
                      ),
                    ),

                  if (_isLoading)
                    _buildLoading()
                  else if (!_hasData)
                    _buildEmptyState()
                  else if (_idUsuario != null && _idUsuario! > 0)
                    _buildDataSummary(),

                  const SizedBox(height: 40),
                  if (_isCreatingContract)
                    Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text(
                          'Criando contrato...',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 20)
                      ],
                    ),
                  if (_hasData &&
                      !_isLoading &&
                      !_isCreatingContract &&
                      !_isCalculating &&
                      _idUsuario != null &&
                      _idUsuario! > 0)
                    Column(
                      children: [
                        AppButton(
                          onPressed: _criarContrato,
                          label: 'Confirmar e Criar Contrato',
                          fontSize: 18,
                        ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            _calcularValorContrato();
                          },
                          child: const Text('Recalcular valores'),
                        ),
                      ],
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}