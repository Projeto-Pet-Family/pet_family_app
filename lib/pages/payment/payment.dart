import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/providers/auth_provider.dart';
import 'package:pet_family_app/repository/contrato_repository.dart';
import 'package:pet_family_app/services/contrato_service.dart' as contrato_svc;
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Variáveis de estado
  String? selectedPaymentMethod;
  bool _isCreatingContract = false;
  bool _isLoading = true;
  bool _hasValidData = false;
  String _errorMessage = '';
  Map<String, dynamic> _cachedData = {};
  double _valorTotal = 0.0;
  late ContratoRepository _contratoRepository;

  // Método de formatação
  String _formatarMoeda(double valor) =>
      'R\$${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  void initState() {
    super.initState();
    _inicializarRepository();
    _carregarDadosDoCache();
  }

  void _inicializarRepository() {
    try {
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ));
      final contratoService = contrato_svc.ContratoService(dio);
      _contratoRepository =
          ContratoRepositoryImpl(contratoService: contratoService);
      log('✅ Repository inicializado');
    } catch (e) {
      log('❌ Erro ao inicializar repository: $e');
      final dio = Dio();
      final contratoService = contrato_svc.ContratoService(dio);
      _contratoRepository =
          ContratoRepositoryImpl(contratoService: contratoService);
    }
  }

  Future<void> _carregarDadosDoCache() async {
    try {
      log('📦 === CARREGANDO DADOS DO CACHE PARA PAGAMENTO ===');
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final prefs = await SharedPreferences.getInstance();
      final cachedData = <String, dynamic>{};

      // 1. Carregar pets selecionados
      final petIds = prefs.getStringList('selected_pet_ids') ??
          prefs.getStringList('selected_pets') ??
          [];
      final petNames = prefs.getStringList('selected_pet_names') ?? [];

      cachedData['selected_pets'] = {
        'ids': petIds,
        'names': petNames,
        'count': petIds.length,
      };

      log('🐾 Pets: ${petIds.length} pets carregados');

      // 2. Carregar datas
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
      };

      log('📅 Datas: $startDateStr até $endDateStr ($daysCount dias)');

      // 3. Carregar serviços
      final servicesJson = prefs.getString('servicos_por_pet_json');
      List<Map<String, dynamic>> servicosPorPet = [];
      if (servicesJson != null && servicesJson.isNotEmpty) {
        try {
          servicosPorPet =
              List<Map<String, dynamic>>.from(json.decode(servicesJson));
          log('🛒 ${servicosPorPet.length} pets com serviços carregados');
        } catch (e) {
          log('❌ Erro ao decodificar serviços JSON: $e');
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

      cachedData['selected_services'] = {
        'service_ids': serviceIds.toList(),
        'services_by_pet': servicosPorPet,
        'total_value': servicesTotal,
      };

      log('💰 Valor serviços: R\$${servicesTotal.toStringAsFixed(2)}');

      // 4. Carregar hotel info
      final dailyRateString = prefs.getString('hotel_daily_rate') ??
          prefs.getString('hotel_valor_diaria') ??
          '100.0';
      final dailyRate = double.tryParse(dailyRateString) ?? 100.0;

      cachedData['hotel_info'] = {
        'daily_rate': dailyRate,
        'name': prefs.getString('hotel_name') ?? 'Hotel',
      };

      log('🏨 Diária: R\$${dailyRate.toStringAsFixed(2)}');

      // 5. ID da hospedagem
      cachedData['idhospedagem'] =
          prefs.getInt('id_hospedagem_selecionada') ?? 1;

      // 6. Calcular valor total localmente
      final quantidadeDias = daysCount;
      final quantidadePets = petIds.length;
      final valorDiaria = dailyRate;
      final valorServicos = servicesTotal;

      final valorHospedagem = valorDiaria * quantidadeDias * quantidadePets;
      _valorTotal = valorHospedagem + valorServicos;

      log('🧮 Cálculo local:');
      log('   Diária: R\$$valorDiaria x $quantidadeDias dias x $quantidadePets pets');
      log('   Hospedagem: R\$${valorHospedagem.toStringAsFixed(2)}');
      log('   Serviços: R\$${valorServicos.toStringAsFixed(2)}');
      log('   TOTAL: R\$${_valorTotal.toStringAsFixed(2)}');

      // Validar dados mínimos
      final hasPets = petIds.isNotEmpty;
      final hasDates = startDate != null && endDate != null;

      _hasValidData = hasPets && hasDates;

      if (!_hasValidData) {
        _errorMessage =
            'Dados incompletos. É necessário selecionar pets e datas.';
        log('❌ Dados inválidos: Pets=$hasPets, Datas=$hasDates');
      }

      setState(() {
        _cachedData = cachedData;
        _isLoading = false;
      });

      log('✅ Cache carregado com sucesso. Dados válidos: $_hasValidData');
    } catch (e) {
      log('❌ ERRO ao carregar cache: $e');
      setState(() {
        _isLoading = false;
        _hasValidData = false;
        _errorMessage = 'Erro ao carregar dados. Tente novamente.';
      });
    }
  }

  // === MÉTODO PRINCIPAL: CRIAR CONTRATO NA API ===
  Future<void> _criarContratoEFinalizar() async {
    try {
      log('🚀 === INICIANDO CRIAÇÃO DO CONTRATO NA API ===');

      if (_isCreatingContract || !_hasValidData) return;

      setState(() {
        _isCreatingContract = true;
        _errorMessage = '';
      });

      // Obter ID do usuário do AuthProvider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final usuario = authProvider.usuario;

      int? idUsuario = usuario?.idUsuario;

      // Se não tiver no provider, tentar obter do cache
      if (idUsuario == null || idUsuario == 0) {
        log('⚠️ ID do usuário não encontrado no provider, buscando no cache...');
        try {
          final prefs = await SharedPreferences.getInstance();
          final cachedUserId = prefs.getInt('user_id');
          if (cachedUserId != null && cachedUserId > 0) {
            idUsuario = cachedUserId;
            log('✅ ID do usuário obtido do cache: $idUsuario');
          }
        } catch (e) {
          log('❌ Erro ao obter ID do usuário do cache: $e');
        }
      }

      if (idUsuario == null || idUsuario == 0) {
        _mostrarErroDialog('Usuário não identificado. Faça login novamente.');
        setState(() => _isCreatingContract = false);
        return;
      }

      log('👤 ID do usuário: $idUsuario');

      // Extrair dados do cache
      final pets = _cachedData['selected_pets']!;
      final dates = _cachedData['selected_dates']!;
      final services = _cachedData['selected_services']!;

      final prefs = await SharedPreferences.getInstance();
      final idHospedagem = prefs.getInt('id_hospedagem_selecionada') ?? 1;

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

      log('✅ Pets convertidos: $listaPets');

      // 2. Formatar serviços para API
      final servicosPorPet =
          services['services_by_pet'] as List<Map<String, dynamic>>?;
      List<Map<String, dynamic>>? servicosFormatados;

      if (servicosPorPet != null && servicosPorPet.isNotEmpty) {
        log('🛎️ Formatando serviços para API...');
        servicosFormatados = [];

        for (var item in servicosPorPet) {
          final dynamic petId = item['idPet'];
          final servicos = item['servicos'] as List<dynamic>?;

          if (petId != null && servicos != null && servicos.isNotEmpty) {
            final intPetId =
                petId is int ? petId : int.tryParse(petId.toString());

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
                // Formato EXATO que a API espera: {"idPet": X, "servicos": [Y, Z]}
                servicosFormatados.add({
                  'idPet': intPetId,
                  'servicos': servicosInt,
                });

                log('   ✅ Pet $intPetId - Serviços: $servicosInt');
              }
            }
          }
        }

        log('📦 Total de pets com serviços: ${servicosFormatados?.length ?? 0}');
      } else {
        log('ℹ️ Nenhum serviço para adicionar');
        servicosFormatados = null;
      }

      // 3. Formatar datas corretamente
      String _formatarDataParaAPI(DateTime date) =>
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final dataInicio = _formatarDataParaAPI(dates['start_date'] as DateTime);
      final dataFim = _formatarDataParaAPI(dates['end_date'] as DateTime);

      log('📅 Data início formatada: $dataInicio');
      log('📅 Data fim formatada: $dataFim');

      // 4. DEBUG: Mostrar exatamente o que será enviado
      log('🚀 === DADOS PARA ENVIAR À API ===');
      log('   idHospedagem: $idHospedagem');
      log('   idUsuario: $idUsuario');
      log('   status: em_aprovacao');
      log('   dataInicio: $dataInicio');
      log('   dataFim: $dataFim');
      log('   pets: $listaPets');
      log('   servicosPorPet: $servicosFormatados');

      // 5. Criar o contrato na API
      log('🚀 Enviando para API...');
      final contrato = await _contratoRepository.criarContrato(
        idHospedagem: idHospedagem,
        idUsuario: idUsuario,
        dataInicio: dataInicio,
        dataFim: dataFim,
        pets: listaPets,
        servicos: servicosFormatados,
        status: 'em_aprovacao',
      );

      final idContrato = contrato.idContrato;
      log('✅ ✅ CONTRATO CRIADO COM SUCESSO! ID: $idContrato');

      // 6. Verificar se os serviços foram incluídos
      if (servicosFormatados != null && servicosFormatados.isNotEmpty) {
        log('🔍 Verificando serviços no contrato criado...');
        if (contrato.servicosGerais != null &&
            contrato.servicosGerais!.isNotEmpty) {
          log('🎉 ${contrato.servicosGerais!.length} serviço(s) incluído(s) no contrato');
        }
      }

      // 7. Limpar cache após sucesso
      await _limparCache();

      // 8. Mostrar sucesso
      _mostrarSucessoDialog(contrato);
    } on DioException catch (e) {
      log('❌ DioException ao criar contrato:');
      log('   Type: ${e.type}');
      log('   Message: ${e.message}');
      log('   Response: ${e.response?.data}');
      log('   Status Code: ${e.response?.statusCode}');

      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        log('❌ Erro 400: $errorData');

        if (errorData is Map) {
          final errorMessage =
              errorData['message']?.toString() ?? 'Erro desconhecido';

          if (errorMessage.contains('Já existe um contrato idêntico ativo') ||
              errorMessage.contains('contrato idêntico')) {
            log('⚠️ Contrato duplicado detectado');
            _mostrarDialogContratoDuplicado();
            return;
          } else {
            _mostrarErroDialog(errorMessage);
          }
        } else {
          _mostrarErroDialog('Erro ao criar contrato: $errorData');
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        _mostrarErroDialog(
            'Tempo de conexão esgotado. Verifique sua internet.');
      } else {
        _mostrarErroDialog('Erro de comunicação: ${e.message}');
      }
    } catch (e) {
      log('❌ ERRO geral na criação do contrato: $e');
      log('🔍 Stack trace: ${e.toString()}');
      _mostrarErroDialog('Erro inesperado: $e');
    } finally {
      if (mounted) {
        setState(() => _isCreatingContract = false);
      }
    }
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
        'hotel_valor_diaria',
        'selected_pets_count',
        'stay_days_count',
        'id_hospedagem_selecionada',
        'servicos_por_pet',
        'servicos_por_pet_json',
        'hotel_name',
        'hotel_valor_diario',
      ];

      for (var key in keysToRemove) {
        await prefs.remove(key);
      }
      log('🗑️ Cache limpo com sucesso');
    } catch (e) {
      log('❌ Erro ao limpar cache: $e');
    }
  }

  // === DIÁLOGOS ===
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
            Text(
                'Verifique seus agendamentos ativos ou altere as datas/pets selecionados.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/core-navigation');
            },
            child: const Text('Ver meus agendamentos'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/choose-dates');
            },
            child: const Text('Alterar datas'),
          ),
        ],
      ),
    );
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
            Text('Sucesso!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Seu agendamento foi criado com sucesso!'),
            const SizedBox(height: 10),
            const Text(
              'Você escolheu pagar no hotel. Apresente-se no check-in com:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text('• Documento de identificação'),
            const Text('• Comprovante de vacinação do pet'),
            const Text('• Cartão ou dinheiro para pagamento'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Valor total: ${_formatarMoeda(_valorTotal)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/core-navigation');
            },
            child: const Text('Voltar para tela principal'),
          ),
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
    } else if (error.contains('Já existe um contrato')) {
      mensagemErro = error;
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

  // === WIDGETS DE UI ===
  Widget _buildResumoReserva() {
    if (!_hasValidData) return const SizedBox();

    final pets = _cachedData['selected_pets']!;
    final dates = _cachedData['selected_dates']!;
    final services = _cachedData['selected_services']!;

    final quantidadePets = (pets['count'] as int?) ?? 0;
    final quantidadeDias = (dates['days_count'] as int?) ?? 0;
    final hasServices = (services['service_ids'] as List).isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.summarize, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Resumo da Reserva',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildResumoItem(
              '🐾 Pets', '$quantidadePets pet${quantidadePets > 1 ? 's' : ''}'),
          _buildResumoItem('📅 Período',
              '$quantidadeDias dia${quantidadeDias > 1 ? 's' : ''}'),
          if (hasServices)
            _buildResumoItem('🛎️ Serviços',
                '${(services['service_ids'] as List).length} adicionais'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '💳 Valor Total:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Text(
                  _formatarMoeda(_valorTotal),
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

  Widget _buildResumoItem(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagamentoNoHotel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(Icons.hotel, color: Colors.blue, size: 24),
              SizedBox(width: 8),
              Text(
                'Pagamento no Hotel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Você poderá pagar diretamente no hotel no momento do check-in.',
            style: TextStyle(fontSize: 14, color: Colors.blue),
          ),
          const SizedBox(height: 8),
          _buildInfoItem('✅ Aceitamos cartão, dinheiro e PIX'),
          _buildInfoItem('✅ Check-in a partir das 14h'),
          _buildInfoItem('✅ Reserva confirmada instantaneamente'),
          _buildInfoItem('✅ Suporte presencial no hotel'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📋 Documentos necessários:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('• Documento de identificação'),
                Text('• Comprovante de vacinação do pet'),
                Text('• Cartão do plano de saúde (se houver)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagamentoNoApp() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.build, color: Colors.orange[700], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Pagamento no App',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.orange, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Funcionalidade em desenvolvimento',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Em breve você poderá pagar diretamente pelo app com:',
            style: TextStyle(fontSize: 14, color: Colors.orange),
          ),
          const SizedBox(height: 8),
          _buildInfoItemDesabilitada('• Cartão de Crédito'),
          _buildInfoItemDesabilitada('• PIX'),
          _buildInfoItemDesabilitada('• Cartão de Débito'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildInfoItemDesabilitada(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.lock, color: Colors.grey[400], size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'EM BREVE',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoPagamento(String metodo, bool selecionado,
      {bool desabilitado = false}) {
    return GestureDetector(
      onTap: !_hasValidData
          ? null
          : desabilitado
              ? () {
                  _mostrarMensagemDesenvolvimento();
                }
              : () {
                  setState(() {
                    selectedPaymentMethod = metodo;
                  });
                },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: !_hasValidData
              ? Colors.grey[100]
              : desabilitado
                  ? Colors.grey[100]
                  : selecionado
                      ? Colors.blue[50]
                      : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: !_hasValidData
                ? Colors.grey[300]!
                : desabilitado
                    ? Colors.grey[300]!
                    : selecionado
                        ? Colors.blue
                        : Colors.grey[300]!,
            width: selecionado ? 2 : 1,
          ),
          boxShadow: !_hasValidData || desabilitado
              ? []
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: !_hasValidData
                      ? Colors.grey
                      : desabilitado
                          ? Colors.grey
                          : selecionado
                              ? Colors.blue
                              : Colors.grey,
                  width: 2,
                ),
                color: !_hasValidData
                    ? Colors.grey[300]
                    : desabilitado
                        ? Colors.grey[300]
                        : selecionado
                            ? Colors.blue
                            : Colors.transparent,
              ),
              child: selecionado
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : desabilitado
                      ? const Icon(Icons.lock, size: 12, color: Colors.grey)
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    metodo,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: !_hasValidData
                          ? Colors.grey
                          : desabilitado
                              ? Colors.grey
                              : selecionado
                                  ? Colors.blue
                                  : Colors.black87,
                    ),
                  ),
                  if (desabilitado) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Em desenvolvimento',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (desabilitado)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'EM BREVE',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarMensagemDesenvolvimento() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.build, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text('Pagamento pelo app estará disponível em breve!'),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildLoading() {
    return const Column(
      children: [
        SizedBox(height: 100),
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text(
          'Carregando dados da reserva...',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          size: 60,
          color: Colors.red[300],
        ),
        const SizedBox(height: 16),
        const Text(
          'Erro ao cargar dados',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _errorMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            _carregarDadosDoCache();
          },
          child: const Text('Tentar Novamente'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            context.go('/choose-pet');
          },
          child: const Text('Voltar para Seleção de Pets'),
        ),
      ],
    );
  }

  Widget _buildNoDataState() {
    return Column(
      children: [
        Icon(
          Icons.warning_amber,
          size: 60,
          color: Colors.orange[300],
        ),
        const SizedBox(height: 16),
        const Text(
          'Dados incompletos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'É necessário selecionar pets e datas para continuar.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            context.go('/choose-pet');
          },
          child: const Text('Selecionar Pets'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            context.go('/choose-dates');
          },
          child: const Text('Selecionar Datas'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppBarReturn(route: '/final-verification'),
              const SizedBox(height: 20),

              // Título
              const Center(
                child: Text(
                  'Pagamento',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              const Center(
                child: Text(
                  'Finalize sua reserva',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Estado de carregamento
              if (_isLoading) _buildLoading(),

              // Estado de erro
              if (!_isLoading && _errorMessage.isNotEmpty && !_hasValidData)
                _buildErrorState(),

              // Estado sem dados
              if (!_isLoading && _errorMessage.isEmpty && !_hasValidData)
                _buildNoDataState(),

              // Conteúdo principal (quando tem dados válidos)
              if (!_isLoading && _hasValidData) ...[
                // Resumo da reserva
                _buildResumoReserva(),

                // Título métodos de pagamento
                const Text(
                  'Escolha o método de pagamento:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),

                // Botões de seleção de pagamento
                _buildBotaoPagamento(
                  'Pagar no hotel',
                  selectedPaymentMethod == 'Pagar no hotel',
                ),
                _buildBotaoPagamento(
                  'Pagar no app',
                  selectedPaymentMethod == 'Pagar no app',
                  desabilitado: true,
                ),

                const SizedBox(height: 20),

                const SizedBox(height: 40),

                // Botão de ação principal
                if (_isCreatingContract) ...[
                  const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Criando contrato e enviando para API...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ],

                AppButton(
                  onPressed: (_hasValidData &&
                          selectedPaymentMethod == 'Pagar no hotel' &&
                          !_isCreatingContract)
                      ? _criarContratoEFinalizar
                      : null,
                  label: _isCreatingContract
                      ? 'Processando...'
                      : 'Finalizar Reserva',
                  fontSize: 18,
                  buttonColor: (_hasValidData &&
                          selectedPaymentMethod == 'Pagar no hotel' &&
                          !_isCreatingContract)
                      ? Colors.green
                      : Colors.grey[400],
                ),

                const SizedBox(height: 16),

                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
