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
  Map<String, dynamic> _dadosCalculoCache = {};
  bool _isLoading = true;
  bool _isCreatingContract = false;
  bool _isCalculating = false;
  Map<String, dynamic>? _calculoContrato;
  final ContratoRepository _contratoRepository = ContratoRepository();

  // MÉTODOS DE FORMATAÇÃO E PARSE
  String _formatarMoeda(double valor) {
    return 'R\$${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 1;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 1;
      }
    }
    return 1;
  }

  // MÉTODO PARA CARREGAR DADOS DE CÁLCULO DO CACHE
  Future<void> _carregarDadosCalculoDoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Carrega todos os dados necessários para o cálculo
      final valorDiariaStr = prefs.getString('hotel_daily_rate') ?? '0.00';
      final quantidadePets = prefs.getInt('selected_pets_count') ?? 1;
      final diasHospedagem = prefs.getInt('stay_days_count') ?? 1;

      // Converte valor da diária para double
      final valorDiaria = double.tryParse(valorDiariaStr) ?? 0.0;

      // Calcula o valor total da hospedagem
      final valorTotalHospedagem =
          valorDiaria * quantidadePets * diasHospedagem;

      setState(() {
        _dadosCalculoCache = {
          'valor_diaria': valorDiaria,
          'quantidade_pets': quantidadePets,
          'dias_hospedagem': diasHospedagem,
          'valor_total_hospedagem': valorTotalHospedagem,
        };
      });

      print('🧮 Dados de cálculo carregados do cache:');
      print('   - Valor diária: $valorDiaria');
      print('   - Quantidade pets: $quantidadePets');
      print('   - Dias hospedagem: $diasHospedagem');
      print('   - Valor total hospedagem: $valorTotalHospedagem');
    } catch (e) {
      print('❌ Erro ao carregar dados de cálculo: $e');
    }
  }

  // OBTER QUANTIDADE DE PETS
  int _obterQuantidadePets() {
    final pets = _cachedData['selected_pets'] as Map<String, dynamic>?;
    if (pets != null && pets['names'] != null) {
      return (pets['names'] as List).length;
    }
    return _dadosCalculoCache['quantidade_pets'] ?? 1;
  }

  // VERIFICA SE TEM DADOS DA API
  bool get _temDadosCalculadosAPI {
    return _calculoContrato != null && _calculoContrato!['valores'] != null;
  }

  // OBTER VALOR DA DIÁRIA POR PET - PRIORIDADE API
  double _obterValorDiariaPorPet() {
    // 1. Tenta dos dados calculados da API
    if (_temDadosCalculadosAPI) {
      final valores = _calculoContrato!['valores'] as Map<String, dynamic>;
      final hospedagem =
          _calculoContrato!['hospedagem'] as Map<String, dynamic>;

      // Tenta do campo valor_diaria da hospedagem
      if (hospedagem['valor_diaria'] != null) {
        return _parseDouble(hospedagem['valor_diaria']);
      }

      // Tenta calcular a partir do valor total da hospedagem
      if (valores['hospedagem'] != null) {
        final dias = _obterQuantidadeDias();
        final pets = _obterQuantidadePets();
        if (dias > 0 && pets > 0) {
          return _parseDouble(valores['hospedagem']) / (dias * pets);
        }
      }
    }

    // 2. Tenta do cache
    if (_dadosCalculoCache.isNotEmpty) {
      return _dadosCalculoCache['valor_diaria'] ?? 89.90;
    }

    // 3. Fallback para valor padrão
    return 89.90;
  }

  // OBTER QUANTIDADE DE DIAS - PRIORIDADE API
  int _obterQuantidadeDias() {
    // 1. Tenta da API (periodo)
    if (_temDadosCalculadosAPI) {
      final periodo = _calculoContrato!['periodo'] as Map<String, dynamic>;
      if (periodo['quantidade_dias'] != null) {
        return _parseInt(periodo['quantidade_dias']);
      }
    }

    // 2. Tenta do cache
    if (_dadosCalculoCache.isNotEmpty) {
      return _dadosCalculoCache['dias_hospedagem'] ?? 1;
    }

    // 3. Tenta do cache de datas
    final dates = _cachedData['selected_dates'] as Map<String, dynamic>?;
    if (dates != null && dates['days_count'] != null) {
      return _parseInt(dates['days_count']);
    }

    // 4. Calcula manualmente
    return _calcularDiasHospedagem();
  }

  // OBTER VALOR HOSPEDAGEM - PRIORIDADE API (agora considerando pets)
  double _obterValorHospedagem() {
    // 1. Tenta da API (valores)
    if (_temDadosCalculadosAPI) {
      final valores = _calculoContrato!['valores'] as Map<String, dynamic>;
      if (valores['hospedagem'] != null) {
        return _parseDouble(valores['hospedagem']);
      }
    }

    // 2. Tenta do cache
    if (_dadosCalculoCache.isNotEmpty) {
      return _dadosCalculoCache['valor_total_hospedagem'] ?? 0.0;
    }

    // 3. Calcula manualmente considerando pets
    final valorDiariaPorPet = _obterValorDiariaPorPet();
    final quantidadeDias = _obterQuantidadeDias();
    final quantidadePets = _obterQuantidadePets();

    return valorDiariaPorPet * quantidadeDias * quantidadePets;
  }

  // OBTER VALOR SERVIÇOS - PRIORIDADE API
  double _obterValorServicos() {
    // 1. Tenta da API (valores)
    if (_temDadosCalculadosAPI) {
      final valores = _calculoContrato!['valores'] as Map<String, dynamic>;
      if (valores['servicos'] != null) {
        return _parseDouble(valores['servicos']);
      }
    }

    // 2. Tenta do cache
    final services = _cachedData['selected_services'] as Map<String, dynamic>?;
    if (services != null && services['total_value'] != null) {
      return _parseDouble(services['total_value']);
    }

    // 3. Calcula manualmente
    return _calcularTotalServicosManual();
  }

  // OBTER VALOR TOTAL - PRIORIDADE API
  double _obterValorTotal() {
    // 1. Tenta da API (valores)
    if (_temDadosCalculadosAPI) {
      final valores = _calculoContrato!['valores'] as Map<String, dynamic>;
      if (valores['total'] != null) {
        return _parseDouble(valores['total']);
      }
    }

    // 2. Calcula manualmente
    return _obterValorHospedagem() + _obterValorServicos();
  }

  // OBTER VALORES FORMATADOS
  String _obterValorFormatado(String campo) {
    // Tenta da API primeiro
    if (_temDadosCalculadosAPI) {
      final valores = _calculoContrato!['valores'] as Map<String, dynamic>;
      switch (campo) {
        case 'valor_diaria':
          return _formatarMoeda(_obterValorDiariaPorPet());
        case 'valor_total_hospedagem':
          if (valores['hospedagem'] != null) {
            return _formatarMoeda(_parseDouble(valores['hospedagem']));
          }
          break;
        case 'valor_total_servicos':
          if (valores['servicos'] != null) {
            return _formatarMoeda(_parseDouble(valores['servicos']));
          }
          break;
        case 'valor_total_contrato':
          if (valores['total'] != null) {
            return _formatarMoeda(_parseDouble(valores['total']));
          }
          break;
      }
    }

    // Fallback: formata localmente
    switch (campo) {
      case 'valor_diaria':
        return _formatarMoeda(_obterValorDiariaPorPet());
      case 'valor_total_hospedagem':
        return _formatarMoeda(_obterValorHospedagem());
      case 'valor_total_servicos':
        return _formatarMoeda(_obterValorServicos());
      case 'valor_total_contrato':
        return _formatarMoeda(_obterValorTotal());
      default:
        return '';
    }
  }

  // OBTER PERÍODO FORMATADO
  String _obterPeriodoFormatado() {
    // Tenta da API primeiro
    if (_temDadosCalculadosAPI) {
      final periodo = _calculoContrato!['periodo'] as Map<String, dynamic>;
      if (periodo['quantidade_dias'] != null) {
        final dias = _parseInt(periodo['quantidade_dias']);
        return '$dias ${dias == 1 ? 'dia' : 'dias'}';
      }
    }

    // Fallback: formata localmente
    final dias = _obterQuantidadeDias();
    return '$dias ${dias == 1 ? 'dia' : 'dias'}';
  }

  // MÉTODOS DE FALLBACK
  int _calcularDiasHospedagem() {
    final dates = _cachedData['selected_dates'] as Map<String, dynamic>?;
    if (dates == null) return 1;

    final dataInicio = dates['start_date'] as DateTime?;
    final dataFim = dates['end_date'] as DateTime?;

    if (dataInicio == null || dataFim == null) return 1;

    final dias = dataFim.difference(dataInicio).inDays;
    return dias > 0 ? dias : 1;
  }

  double _calcularTotalServicosManual() {
    double totalServicos = 0;
    final services = _cachedData['selected_services'] as Map<String, dynamic>?;

    if (services != null && services['prices'] != null) {
      final prices = services['prices'] as List<String>;
      for (var price in prices) {
        totalServicos += _parseDouble(price);
      }
    }

    return totalServicos;
  }

  @override
  void initState() {
    super.initState();
    _carregarDadosDoCache().then((_) {
      _carregarDadosCalculoDoCache(); // Novo método
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

      // ID fixo da hospedagem
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
      print('❌ Erro ao calcular valor do contrato: $e');
      setState(() {
        _isCalculating = false;
      });
      // Mostra erro mas não impede a continuação
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao calcular valores: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // MÉTODO PARA CONSTRUIR O RESUMO FINANCEIRO (COM CÁLCULO DE PETS)
  Widget _buildResumoFinanceiro() {
    // Se temos dados do cache, usamos eles para construir o resumo
    if (_dadosCalculoCache.isNotEmpty) {
      return _buildResumoComCache();
    }

    // Se não, usa o método original (com API ou fallback)
    return _buildResumoComAPI();
  }

  // NOVO MÉTODO PARA CONSTRUIR RESUMO COM DADOS DO CACHE
  Widget _buildResumoComCache() {
    final valorDiaria = _dadosCalculoCache['valor_diaria'] ?? 0.0;
    final quantidadePets = _dadosCalculoCache['quantidade_pets'] ?? 1;
    final diasHospedagem = _dadosCalculoCache['dias_hospedagem'] ?? 1;
    final valorHospedagem = _dadosCalculoCache['valor_total_hospedagem'] ?? 0.0;
    final valorServicos = _obterValorServicos();
    final valorTotal = valorHospedagem + valorServicos;

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
          const SizedBox(height: 16),

          // Detalhamento do cálculo
          _buildItemFinanceiro(
            '🏨 Valor da diária por pet',
            _formatarMoeda(valorDiaria),
          ),
          const SizedBox(height: 8),

          _buildItemFinanceiro(
            '🐕 Quantidade de pets',
            '$quantidadePets ${quantidadePets == 1 ? 'pet' : 'pets'}',
          ),
          const SizedBox(height: 8),

          _buildItemFinanceiro(
            '📅 Dias de hospedagem',
            '$diasHospedagem ${diasHospedagem == 1 ? 'dia' : 'dias'}',
          ),

          const SizedBox(height: 16),
          _buildItemFinanceiro(
            '🏠 Total da hospedagem',
            _formatarMoeda(valorHospedagem),
            isSubtotal: true,
          ),
          const SizedBox(height: 12),

          // Serviços adicionais
          if (valorServicos > 0) ...[
            _buildItemFinanceiro(
              '🛎️ Serviços adicionais',
              _formatarMoeda(valorServicos),
              isSubtotal: true,
            ),
            const SizedBox(height: 12),
          ],

          // Total
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
                    color: Colors.green,
                  ),
                ),
                Text(
                  _formatarMoeda(valorTotal),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // Informação sobre origem dos dados
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // MÉTODO ORIGINAL PARA RESUMO COM API
  Widget _buildResumoComAPI() {
    final valorDiariaFormatado = _obterValorFormatado('valor_diaria');
    final valorHospedagemFormatado =
        _obterValorFormatado('valor_total_hospedagem');
    final valorServicosFormatado = _obterValorFormatado('valor_total_servicos');
    final valorTotalFormatado = _obterValorFormatado('valor_total_contrato');
    final periodoFormatado = _obterPeriodoFormatado();

    // Dados para o cálculo
    final valorDiariaPorPet = _obterValorDiariaPorPet();
    final quantidadeDias = _obterQuantidadeDias();
    final quantidadePets = _obterQuantidadePets();

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
          Text(
            '💰 Resumo Financeiro',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),

          // Valor da diária POR PET
          _buildItemFinanceiro(
            '🏨 Valor da diária por pet',
            valorDiariaFormatado,
          ),
          const SizedBox(height: 8),

          // Quantidade de pets
          _buildItemFinanceiro(
            '🐕 Pets hospedados',
            '$quantidadePets ${quantidadePets == 1 ? 'pet' : 'pets'}',
          ),
          const SizedBox(height: 8),

          // Período
          _buildItemFinanceiro(
            '📅 Período da hospedagem',
            periodoFormatado,
          ),
          const SizedBox(height: 12),

          // Cálculo detalhado da hospedagem (só mostra se não veio pronto da API)
          if (!_temDadosCalculadosAPI) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[100]!),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Cálculo da hospedagem:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_formatarMoeda(valorDiariaPorPet)} × $quantidadePets pets × $quantidadeDias dias',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detalhamento:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        '${_formatarMoeda(valorDiariaPorPet * quantidadePets)}/dia × $quantidadeDias dias',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Subtotal da hospedagem
          _buildItemFinanceiro(
            '🏠 Subtotal da hospedagem',
            valorHospedagemFormatado,
            isSubtotal: true,
          ),
          const SizedBox(height: 12),

          // Serviços adicionais
          if (_obterValorServicos() > 0) ...[
            _buildItemFinanceiro(
              '🛎️ Serviços adicionais',
              valorServicosFormatado,
              isSubtotal: true,
            ),
            const SizedBox(height: 12),
          ],

          // Total - DESTAQUE PRINCIPAL
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
                    color: Colors.green,
                  ),
                ),
                Text(
                  valorTotalFormatado,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // Informação sobre origem dos dados
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildItemFinanceiro(String titulo, String valor,
      {bool isSubtotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: isSubtotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            fontSize: 14,
            color: isSubtotal ? Colors.blue : Colors.black,
            fontWeight: isSubtotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
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

      // Validar dados necessários
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

      // Calcular valores finais (usando cache como fallback)
      final valorHospedagem = _temDadosCalculadosAPI
          ? _obterValorHospedagem()
          : _dadosCalculoCache['valor_total_hospedagem'] ??
              _obterValorHospedagem();

      final valorServicos = _obterValorServicos();
      final valorTotal = valorHospedagem + valorServicos;

      print('💰 Valores calculados para envio:');
      print('   - Hospedagem: $valorHospedagem');
      print('   - Serviços: $valorServicos');
      print('   - Total: $valorTotal');

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

      // Limpar dados de cálculo
      await prefs.remove('hotel_daily_rate');
      await prefs.remove('selected_pets_count');
      await prefs.remove('stay_days_count');

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

  Widget _buildDataSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Resumo financeiro (implementação nova)
        _buildResumoFinanceiro(),
        const SizedBox(height: 30),

        // Detalhes dos componentes (mantidos)
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
                          onPressed: _criarContrato,
                          label: 'Confirmar e Criar Contrato',
                          fontSize: 18,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            context.go('/choose-service');
                          },
                          child: const Text('Voltar para Serviços'),
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
