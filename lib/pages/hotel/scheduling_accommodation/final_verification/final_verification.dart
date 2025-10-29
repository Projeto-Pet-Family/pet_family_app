import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/informations/datas_informations.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/informations/pet_informations.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/informations/services_information.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/informations/taxas_informations.dart';
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

                  // Botão próximo (só aparece se tiver dados)
                  if (_hasData && !_isLoading)
                    AppButton(
                      onPressed: () {
                        context.go('/payment');
                      },
                      label: 'Confirmar e Ir para Pagamento',
                      fontSize: 18,
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
