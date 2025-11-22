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
  Map<String, dynamic> _cachedData = {};
  bool _isLoading = true;
  bool _isCreatingContract = false;
  bool _isCalculating = false;
  Map<String, dynamic>? _calculoContrato;
  final ContratoRepository _contratoRepository = ContratoRepository();

  @override
  void initState() {
    super.initState();
    _carregarDadosDoCache().then((_) {
      _calcularValorContrato();
    });
  }

  Future<void> _carregarDadosDoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Carrega todos os dados do cache
      final cachedData = <String, dynamic>{};

      // Pets selecionados
      final selectedPetIds = prefs.getStringList('selected_pets') ?? [];
      final selectedPetNames = prefs.getStringList('selected_pet_names') ?? [];
      cachedData['selected_pets'] = {
        'ids': selectedPetIds,
        'names': selectedPetNames,
      };

      // Datas selecionadas
      final startDateMillis = prefs.getInt('selected_start_date');
      final endDateMillis = prefs.getInt('selected_end_date');
      final startDateStr = prefs.getString('selected_start_date_str');
      final endDateStr = prefs.getString('selected_end_date_str');
      final daysCount = prefs.getInt('selected_days_count') ?? 0;

      cachedData['selected_dates'] = {
        'start_date': startDateMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(startDateMillis)
            : null,
        'end_date': endDateMillis != null
            ? DateTime.fromMillisecondsSinceEpoch(endDateMillis)
            : null,
        'start_date_str': startDateStr,
        'end_date_str': endDateStr,
        'days_count': daysCount,
      };

      // Serviços selecionados (OPCIONAL)
      final selectedServiceIds = prefs.getStringList('selected_services') ?? [];
      final selectedServiceNames =
          prefs.getStringList('selected_service_names') ?? [];
      final selectedServicePrices =
          prefs.getStringList('selected_service_prices') ?? [];
      final totalValue = prefs.getDouble('selected_services_total') ?? 0.0;

      cachedData['selected_services'] = {
        'ids': selectedServiceIds,
        'names': selectedServiceNames,
        'prices': selectedServicePrices,
        'total_value': totalValue,
      };

      setState(() {
        _cachedData = cachedData;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erro ao carregar dados do cache: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _calcularValorContrato() async {
    if (!_hasData) return;

    try {
      setState(() {
        _isCalculating = true;
      });

      final pets = _cachedData['selected_pets'] as Map<String, dynamic>?;
      final dates = _cachedData['selected_dates'] as Map<String, dynamic>?;
      final services =
          _cachedData['selected_services'] as Map<String, dynamic>?;

      // Extrair dados do cache
      final petIds = (pets!['ids'] as List<String>).map(int.parse).toList();
      final startDate = dates!['start_date'] as DateTime;
      final endDate = dates['end_date'] as DateTime;

      // Formatar datas para o formato da API (YYYY-MM-DD)
      final dataInicio = _formatarDataParaAPI(startDate);
      final dataFim = _formatarDataParaAPI(endDate);

      // Preparar serviços apenas se existirem
      List<Map<String, dynamic>>? servicosFormatados;
      if (services != null &&
          services['ids'] != null &&
          (services['ids'] as List).isNotEmpty) {
        final serviceIds =
            (services['ids'] as List<String>).map(int.parse).toList();
        servicosFormatados = serviceIds.map((id) {
          return {
            'idservico': id,
            'quantidade': 1,
          };
        }).toList();
      }

      // ID fixo da hospedagem (ajuste conforme sua aplicação)
      const idHospedagem = 1;

      // Calcular valor do contrato
      final calculo = await _contratoRepository.calcularValorContrato(
        idHospedagem: idHospedagem,
        dataInicio: dataInicio,
        dataFim: dataFim,
        servicos: servicosFormatados,
      );

      setState(() {
        _calculoContrato = calculo;
        _isCalculating = false;
      });

      print('💰 Cálculo realizado: $_calculoContrato');
    } catch (e) {
      print('❌ Erro ao calcular valor do contrato f: $e');
      setState(() {
        _isCalculating = false;
      });
      // Mostra erro mas não impede a continuação
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao calcular valores: $e'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _criarContrato() async {
    try {
      setState(() {
        _isCreatingContract = true;
      });

      final pets = _cachedData['selected_pets'] as Map<String, dynamic>?;
      final dates = _cachedData['selected_dates'] as Map<String, dynamic>?;
      final services =
          _cachedData['selected_services'] as Map<String, dynamic>?;

      // Validar dados necessários (APENAS PETS E DATAS SÃO OBRIGATÓRIOS)
      if (pets == null || dates == null) {
        throw Exception('Dados incompletos para criar contrato');
      }

      // Extrair dados do cache
      final petIds = (pets['ids'] as List<String>).map(int.parse).toList();
      final startDate = dates['start_date'] as DateTime;
      final endDate = dates['end_date'] as DateTime;

      // Formatar datas para o formato da API (YYYY-MM-DD)
      final dataInicio = _formatarDataParaAPI(startDate);
      final dataFim = _formatarDataParaAPI(endDate);

      // Preparar serviços apenas se existirem
      List<Map<String, dynamic>>? servicosFormatados;
      if (services != null &&
          services['ids'] != null &&
          (services['ids'] as List).isNotEmpty) {
        final serviceIds =
            (services['ids'] as List<String>).map(int.parse).toList();
        servicosFormatados = serviceIds.map((id) {
          return {
            'idservico': id,
            'quantidade': 1,
          };
        }).toList();
      }

      // ID fixo da hospedagem
      const idHospedagem = 1;

      // Criar contrato
      final response = await _contratoRepository.criarContrato(
        idHospedagem: idHospedagem,
        dataInicio: dataInicio,
        dataFim: dataFim,
        pets: petIds,
        servicos: servicosFormatados,
      );

      print('✅ Contrato criado com sucesso: $response');

      // Limpar cache após criar contrato com sucesso
      await _limparCache();

      // Navegar para tela de sucesso
      if (mounted) {
        _mostrarSucessoDialog(context);
      }
    } catch (e) {
      print('❌ Erro ao criar contrato: $e');
      if (mounted) {
        _mostrarErroDialog(context, e.toString());
      }
    } finally {
      setState(() {
        _isCreatingContract = false;
      });
    }
  }

  String _formatarDataParaAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _limparCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Limpar dados de seleção
      await prefs.remove('selected_pets');
      await prefs.remove('selected_pet_names');
      await prefs.remove('selected_start_date');
      await prefs.remove('selected_end_date');
      await prefs.remove('selected_start_date_str');
      await prefs.remove('selected_end_date_str');
      await prefs.remove('selected_days_count');
      await prefs.remove('selected_services');
      await prefs.remove('selected_service_names');
      await prefs.remove('selected_service_prices');
      await prefs.remove('selected_services_total');

      print('🗑️ Cache limpo com sucesso');
    } catch (e) {
      print('❌ Erro ao limpar cache: $e');
    }
  }

  void _mostrarSucessoDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Contrato Criado!'),
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
            ),
          ],
        );
      },
    );
  }

  void _mostrarErroDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Erro ao Criar Contrato'),
            ],
          ),
          content: Text('Não foi possível criar o contrato: $error'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoading() {
    return const Column(
      children: [
        SizedBox(height: 20),
        Center(child: CircularProgressIndicator()),
        SizedBox(height: 10),
        Text(
          'Carregando dados...',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildCalculating() {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        const Text(
          'Calculando valores...',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
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
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'É necessário selecionar pets e datas para continuar',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            context.go('/choose-pet');
          },
          child: const Text('Voltar para Seleção de Pets'),
        ),
      ],
    );
  }

  Widget _buildResumoFinanceiro() {
    if (_calculoContrato == null) return const SizedBox();

    final valores = _calculoContrato!['valores'] as Map<String, dynamic>;
    final periodo = _calculoContrato!['periodo'] as Map<String, dynamic>;
    final hospedagem = _calculoContrato!['hospedagem'] as Map<String, dynamic>;

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
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),

          // Diária e período
          _buildResumoItem(
            '🏨 Valor da diária',
            'R\$${hospedagem['valor_diaria'].toStringAsFixed(2)}',
          ),
          _buildResumoItem(
            '📅 Período da hospedagem',
            '${periodo['quantidade_dias']} ${periodo['quantidade_dias'] == 1 ? 'dia' : 'dias'}',
          ),

          // Cálculo detalhado da hospedagem
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cálculo da hospedagem:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${hospedagem['valor_diaria'].toStringAsFixed(2)} × ${periodo['quantidade_dias']} dias',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                Text(
                  'R\$${valores['hospedagem'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Serviços (se houver)
          if (valores['servicos'] > 0) ...[
            const SizedBox(height: 12),
            _buildResumoItem(
              '🛎️ Serviços adicionais',
              'R\$${valores['servicos'].toStringAsFixed(2)}',
              subtotal: true,
            ),

            // Detalhamento dos serviços
            if (_calculoContrato?['servicos'] != null &&
                (_calculoContrato!['servicos'] as List).isNotEmpty) ...[
              const SizedBox(height: 8),
              ...(_calculoContrato!['servicos'] as List<dynamic>)
                  .map((servico) {
                final servicoMap = servico as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '• ${servicoMap['descricao']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'R\$${servicoMap['subtotal'].toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],

          // Total
          const Divider(height: 20),
          _buildResumoItem(
            '💳 Total do contrato',
            'R\$${valores['total'].toStringAsFixed(2)}',
            isTotal: true,
          ),

          // Informação adicional sobre o cálculo
          if (_calculoContrato?['usando_dados_mock'] == true) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange[700], size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Usando valores estimados para cálculo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResumoItem(String title, String value,
      {bool subtotal = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal
                  ? FontWeight.bold
                  : (subtotal ? FontWeight.w500 : FontWeight.normal),
              color: isTotal
                  ? Colors.green
                  : (subtotal ? Colors.blue : Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvisoModoOffline() {
    if (_calculoContrato?['usando_dados_mock'] == true) {
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange),
        ),
        child: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.orange[700]),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modo Offline',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                  Text(
                    'Usando valores estimados. Os valores reais serão confirmados quando a conexão estiver disponível.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }

  Widget _buildDataSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Aviso de modo offline
        _buildAvisoModoOffline(),

        // Resumo financeiro
        _buildResumoFinanceiro(),
        const SizedBox(height: 30),

        // Detalhes dos componentes
        PetInformations(cachedData: _cachedData),
        const SizedBox(height: 30),
        DatasInformations(cachedData: _cachedData),
        const SizedBox(height: 30),
        ServicesInformation(cachedData: _cachedData),
        const SizedBox(height: 30),
        TaxasInformations(cachedData: _cachedData),
      ],
    );
  }

  bool get _hasData {
    final pets = _cachedData['selected_pets'] as Map<String, dynamic>?;
    final dates = _cachedData['selected_dates'] as Map<String, dynamic>?;

    final hasPets = pets?['names'] != null && pets!['names'].isNotEmpty;
    final hasDates =
        dates?['start_date_str'] != null && dates?['end_date_str'] != null;

    return hasPets && hasDates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBarReturn(route: '/choose-service'),
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
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Confirme todos os dados da sua reserva',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Conteúdo principal
                  if (_isLoading)
                    _buildLoading()
                  else if (!_hasData)
                    _buildEmptyState()
                  else if (_isCalculating)
                    _buildCalculating()
                  else
                    _buildDataSummary(),

                  const SizedBox(height: 40),

                  // Indicador de criação do contrato
                  if (_isCreatingContract)
                    Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        const Text(
                          'Criando contrato...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),

                  // Botões de ação
                  if (_hasData &&
                      !_isLoading &&
                      !_isCreatingContract &&
                      !_isCalculating)
                    Column(
                      children: [
                        AppButton(
                          onPressed: () {
                            context.go('/payment');
                          },
                          label: 'Escolher Método de Pagamento',
                          fontSize: 18,
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
