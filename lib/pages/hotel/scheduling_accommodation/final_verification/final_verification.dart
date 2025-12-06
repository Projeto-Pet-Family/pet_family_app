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
  bool _isLoading = true, _isCreatingContract = false, _isCalculating = false;
  int? _idUsuario;

  // === MÉTODOS PRINCIPAIS ===
  @override
  void initState() {
    super.initState();
    _inicializarRepository();
    _carregarDados();
  }

  void _inicializarRepository() {
    try {
      // Inicializar o Dio
      final dio = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ));

      // Inicializar o serviço
      final contratoService = ContratoService(dio: dio, client: http.Client());

      // Inicializar o repository
      _contratoRepository =
          ContratoRepositoryImpl(contratoService: contratoService);

      print('✅ ContratoRepository inicializado com sucesso');
    } catch (e) {
      print('❌ Erro ao inicializar ContratoRepository: $e');
      // Fallback para evitar erro de late initialization
      final dio = Dio();
      final contratoService = ContratoService(dio: dio, client: http.Client());
      _contratoRepository =
          ContratoRepositoryImpl(contratoService: contratoService);
    }
  }

  Future<void> _carregarDados() async {
    await _carregarDadosDoCache();
    await _obterIdUsuario();
    _calcularValorContrato();
  }

  Future<void> _obterIdUsuario() async {
    try {
      final authProvider = AuthProvider();
      final authService = AuthService();
      final idUsuario = await authService.getUserIdFromCache();

      if (idUsuario == null) {
        print('⚠️ Usuário não encontrado no cache do AuthProvider');

        // Tentar alternativas
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
      final prefs = await SharedPreferences.getInstance();
      final cachedData = <String, dynamic>{};

      // Carregar ID da hospedagem
      cachedData['idhospedagem'] =
          prefs.getInt('id_hospedagem_selecionada') ?? 1;
      print(
          '🏨 ID da hospedagem carregado do cache: ${cachedData['idhospedagem']}');

      // Carregar pets
      cachedData['selected_pets'] = {
        'ids': prefs.getStringList('selected_pets') ?? [],
        'names': prefs.getStringList('selected_pet_names') ?? [],
      };

      // Carregar datas
      final startDateMillis = prefs.getInt('selected_start_date');
      final endDateMillis = prefs.getInt('selected_end_date');
      cachedData['selected_dates'] = {
        'start_date': startDateMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(startDateMillis)
            : null,
        'end_date': endDateMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(endDateMillis)
            : null,
        'start_date_str': prefs.getString('selected_start_date_str'),
        'end_date_str': prefs.getString('selected_end_date_str'),
        'days_count': prefs.getInt('selected_days_count') ?? 0,
      };

      // Carregar serviços
      cachedData['selected_services'] = {
        'ids': prefs.getStringList('selected_services') ?? [],
        'names': prefs.getStringList('selected_service_names') ?? [],
        'prices': prefs.getStringList('selected_service_prices') ?? [],
        'total_value': prefs.getDouble('selected_services_total') ?? 0.0,
      };

      setState(() {
        _cachedData = cachedData;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erro ao carregar cache: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _calcularValorContrato() async {
    try {
      setState(() => _isCalculating = true);

      final dates = _cachedData['selected_dates']!;
      final services = _cachedData['selected_services'];

      final prefs = await SharedPreferences.getInstance();
      final idHospedagem = prefs.getInt('id_hospedagem_selecionada') ?? 1;

      final calculo = await _contratoRepository.calcularValorContrato(
        idHospedagem: idHospedagem,
        dataInicio: _formatarDataParaAPI(dates['start_date'] as DateTime),
        dataFim: _formatarDataParaAPI(dates['end_date'] as DateTime),
        servicos: services != null && (services['ids'] as List).isNotEmpty
            ? (services['ids'] as List<String>)
                .map((id) => {'idservico': int.parse(id), 'quantidade': 1})
                .toList()
            : null,
      );

      setState(() {
        _calculoContrato = calculo;
        _isCalculating = false;
      });
    } catch (e) {
      print('❌ Erro no cálculo: $e');
      setState(() => _isCalculating = false);
      // Usar fallback se necessário
    }
  }

  Future<void> _criarContrato() async {
    try {
      setState(() => _isCreatingContract = true);

      // Verificar se temos o ID do usuário
      if (_idUsuario == null || _idUsuario == 0) {
        await _obterIdUsuario();

        if (_idUsuario == null || _idUsuario == 0) {
          throw Exception('❌ Usuário não identificado. Faça login novamente.');
        }
      }

      final pets = _cachedData['selected_pets']!;
      final dates = _cachedData['selected_dates']!;
      final services = _cachedData['selected_services'];

      final prefs = await SharedPreferences.getInstance();
      final idHospedagem = prefs.getInt('id_hospedagem_selecionada') ?? 1;

      print('📝 Criando contrato com os seguintes dados:');
      print('👤 ID Usuário: $_idUsuario');
      print('🏨 ID Hospedagem: $idHospedagem');
      print('📅 Data início: ${dates['start_date']}');
      print('📅 Data fim: ${dates['end_date']}');
      print('🐾 Pets: ${pets['ids']}');
      print('🛎️ Serviços: ${services?['ids'] ?? []}');

      final contrato = await _contratoRepository.criarContrato(
        idHospedagem: idHospedagem,
        idUsuario: _idUsuario!,
        dataInicio: _formatarDataParaAPI(dates['start_date'] as DateTime),
        dataFim: _formatarDataParaAPI(dates['end_date'] as DateTime),
        pets: (pets['ids'] as List<String>).map(int.parse).toList(),
        servicos: services != null && (services['ids'] as List).isNotEmpty
            ? (services['ids'] as List<String>)
                .map((id) => {'idservico': int.parse(id), 'quantidade': 1})
                .toList()
            : null,
        status: 'em_aprovacao',
      );

      print('✅ Contrato criado com sucesso: ${contrato.idContrato}');
      await _limparCache();

      if (mounted) {
        _mostrarSucessoDialog(contrato);
      }
    } catch (e) {
      print('❌ Erro criar contrato: $e');
      if (mounted) {
        _mostrarErroDialog(e.toString());
      }
    } finally {
      setState(() => _isCreatingContract = false);
    }
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
        'selected_pets_count',
        'stay_days_count',
        'id_hospedagem_selecionada',
      ];

      for (var key in keysToRemove) {
        await prefs.remove(key);
      }
      print('🗑️ Cache limpo com sucesso');
    } catch (e) {
      print('❌ Erro ao limpar cache: $e');
    }
  }

  void _mostrarSucessoDialog(contrato) {
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

    // Melhorar mensagens de erro específicas
    if (error.contains('Usuário não identificado')) {
      mensagemErro = 'Por favor, faça login novamente para continuar.';
    } else if (error.contains('Connection') || error.contains('timeout')) {
      mensagemErro =
          'Problema de conexão. Verifique sua internet e tente novamente.';
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
                // Redirecionar para login
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
    return (pets?['names'] != null && pets!['names'].isNotEmpty) &&
        (dates?['start_date_str'] != null && dates?['end_date_str'] != null);
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
    if (dates != null && dates['days_count'] != null && pets != null) {
      final prefs = await SharedPreferences.getInstance();
      final valorDiaria =
          double.tryParse(prefs.getString('hotel_daily_rate') ?? '0') ?? 0.0;
      final quantidadePets = (pets['names'] as List).length;
      return valorDiaria * _parseInt(dates['days_count']) * quantidadePets;
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
        PetInformations(cachedData: _cachedData),
        const SizedBox(height: 30),
        DatasInformations(cachedData: _cachedData),
        const SizedBox(height: 30),
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
                  else if (_isCalculating)
                    _buildCalculating()
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
                        /* AppButton(
                          onPressed: _criarContrato,
                          label: 'Confirmar e Criar Contrato',
                          fontSize: 18,
                        ), */
                        AppButton(
                          onPressed: () {
                            context.go('/payment');
                          },
                          label: 'Ir para pagamento',
                          fontSize: 18,
                        ),
                        const SizedBox(height: 16),
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
