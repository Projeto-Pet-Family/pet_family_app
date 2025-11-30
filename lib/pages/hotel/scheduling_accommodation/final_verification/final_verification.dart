import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/informations/datas_informations.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/informations/pet_informations.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/informations/services_information.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/informations/taxas_informations.dart';
import 'package:pet_family_app/repository/contrato_repository.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinalVerification extends StatefulWidget {
  const FinalVerification({super.key});

  @override
  State<FinalVerification> createState() => _FinalVerificationState();
}

class _FinalVerificationState extends State<FinalVerification> {
  final ContratoRepository _contratoRepository = ContratoRepository();
  final TextEditingController _messageController = TextEditingController();

  Map<String, dynamic> _cachedData = {};
  Map<String, dynamic>? _calculoContrato;
  bool _isLoading = true, _isCreatingContract = false, _isCalculating = false;

  // === MÉTODOS PRINCIPAIS ===
  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    await _carregarDadosDoCache();
    _calcularValorContrato();
  }

  Future<void> _carregarDadosDoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = <String, dynamic>{};

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
    if (!_hasData) return;

    try {
      setState(() => _isCalculating = true);

      final pets = _cachedData['selected_pets']!;
      final dates = _cachedData['selected_dates']!;
      final services = _cachedData['selected_services'];
      final idhospedagem = _cachedData['idhospedagem'];

      final calculo = await _contratoRepository.calcularValorContrato(
        idHospedagem: idhospedagem,
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao calcular: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _criarContrato() async {
    try {
      setState(() => _isCreatingContract = true);

      final pets = _cachedData['selected_pets']!;
      final dates = _cachedData['selected_dates']!;
      final services = _cachedData['selected_services'];

      // Obter idhospedagem do cache
      final prefs = await SharedPreferences.getInstance();
      final idHospedagem = prefs.getInt('current_hotel_id') ?? 1;

      final response = await _contratoRepository.criarContrato(
        idHospedagem: idHospedagem,
        dataInicio: _formatarDataParaAPI(dates['start_date'] as DateTime),
        dataFim: _formatarDataParaAPI(dates['end_date'] as DateTime),
        pets: (pets['ids'] as List<String>).map(int.parse).toList(),
        servicos: services != null && (services['ids'] as List).isNotEmpty
            ? (services['ids'] as List<String>)
                .map((id) => {'idservico': int.parse(id), 'quantidade': 1})
                .toList()
            : null,
      );

      await _limparCache();
      if (mounted) _mostrarSucessoDialog();
    } catch (e) {
      print('❌ Erro criar contrato: $e');
      if (mounted) _mostrarErroDialog(e.toString());
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
        'current_hotel_id'
      ];

      for (var key in keysToRemove) {
        await prefs.remove(key);
      }
      print('🗑️ Cache limpo');
    } catch (e) {
      print('❌ Erro limpar cache: $e');
    }
  }

  void _mostrarSucessoDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Contrato Criado!')
          ],
        ),
        content: const Text(
            'Seu contrato foi criado com sucesso e está em aprovação.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/core-navigation');
            },
            child: const Text('Ver Meus Agendamentos'),
          )
        ],
      ),
    );
  }

  void _mostrarErroDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: 8),
          Text('Erro')
        ]),
        content: Text('Erro ao criar contrato: $error'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          )
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
                  if (_isLoading)
                    _buildLoading()
                  else if (!_hasData)
                    _buildEmptyState()
                  else if (_isCalculating)
                    _buildCalculating()
                  else
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
                      !_isCalculating)
                    Column(
                      children: [
                        AppButton(
                            onPressed: _criarContrato,
                            label: 'Confirmar e Criar Contrato',
                            fontSize: 18),
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
