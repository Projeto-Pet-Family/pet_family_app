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
  final ContratoRepository _contratoRepository = ContratoRepository();

  @override
  void initState() {
    super.initState();
    _carregarDadosDoCache();
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

      // Serviços selecionados
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

      // DEBUG: Mostra todos os dados carregados
      print('📦 DADOS CARREGADOS DO CACHE:');
      print('🐾 Pets: ${cachedData['selected_pets']}');
      print('📅 Datas: ${cachedData['selected_dates']}');
      print('🛎️ Serviços: ${cachedData['selected_services']}');

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

  Future<void> _criarContrato() async {
    try {
      setState(() {
        _isCreatingContract = true;
      });

      final pets = _cachedData['selected_pets'] as Map<String, dynamic>?;
      final dates = _cachedData['selected_dates'] as Map<String, dynamic>?;
      final services = _cachedData['selected_services'] as Map<String, dynamic>?;

      // Validar dados necessários
      if (pets == null || dates == null || services == null) {
        throw Exception('Dados incompletos para criar contrato');
      }

      // Extrair dados do cache
      final petIds = (pets['ids'] as List<String>).map(int.parse).toList();
      final startDate = dates['start_date'] as DateTime;
      final endDate = dates['end_date'] as DateTime;
      final serviceIds = (services['ids'] as List<String>).map(int.parse).toList();

      // Formatar datas para o formato da API (YYYY-MM-DD)
      final dataInicio = _formatarDataParaAPI(startDate);
      final dataFim = _formatarDataParaAPI(endDate);

      // Preparar serviços no formato esperado pela API
      final servicosFormatados = serviceIds.map((id) {
        return {
          'idservico': id,
          'quantidade': 1, // Quantidade padrão, ajuste conforme necessário
        };
      }).toList();

      print('🚀 Criando contrato com os dados:');
      print('🐾 Pets IDs: $petIds');
      print('📅 Data Início: $dataInicio');
      print('📅 Data Fim: $dataFim');
      print('🛎️ Serviços: $servicosFormatados');

      // ID fixo da hospedagem (ajuste conforme sua aplicação)
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

      // Navegar para tela de sucesso ou pagamento
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
          content: const Text('Seu contrato foi criado com sucesso e está em aprovação.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/core-navigation'); // Navegar para tela de agendamentos
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
          'Nenhum dado encontrado',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Volte e selecione pets, datas e serviços',
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

  Widget _buildDataSummary() {
    final pets = _cachedData['selected_pets'] as Map<String, dynamic>?;
    final dates = _cachedData['selected_dates'] as Map<String, dynamic>?;
    final services = _cachedData['selected_services'] as Map<String, dynamic>?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumo geral
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📋 Resumo da Reserva',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 12),
              if (pets?['names'] != null && pets!['names'].isNotEmpty)
                _buildSummaryItem(
                  '🐾 Pets',
                  '${pets['names'].length} pet(s) selecionado(s)',
                ),
              if (dates?['start_date_str'] != null &&
                  dates?['end_date_str'] != null)
                _buildSummaryItem(
                  '📅 Período',
                  '${dates!['days_count']} dias',
                ),
              if (services?['names'] != null && services!['names'].isNotEmpty)
                _buildSummaryItem(
                  '🛎️ Serviços',
                  '${services['names'].length} serviço(s)',
                ),
              if (services?['total_value'] != null)
                _buildSummaryItem(
                  '💰 Valor Total',
                  'R\$${services!['total_value'].toStringAsFixed(2)}',
                  isTotal: true,
                ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // Componentes detalhados
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

  Widget _buildSummaryItem(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  bool get _hasData {
    final pets = _cachedData['selected_pets'] as Map<String, dynamic>?;
    final dates = _cachedData['selected_dates'] as Map<String, dynamic>?;
    final services = _cachedData['selected_services'] as Map<String, dynamic>?;

    final hasPets = pets?['names'] != null && pets!['names'].isNotEmpty;
    final hasDates =
        dates?['start_date_str'] != null && dates?['end_date_str'] != null;
    final hasServices =
        services?['names'] != null && services!['names'].isNotEmpty;

    return hasPets && hasDates && hasServices;
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
                  if (_hasData && !_isLoading && !_isCreatingContract)
                    Column(
                      children: [
                        AppButton(
                          onPressed: _criarContrato,
                          label: 'Confirmar e Criar Contrato',
                          fontSize: 18,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            context.go('/core-navigation');
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.grey,
                            side: const BorderSide(color: Colors.grey),
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Voltar e Editar'),
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