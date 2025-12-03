import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/providers/auth_provider.dart';
import 'package:pet_family_app/repository/contrato_repository.dart';
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
  String? selectedPaymentMethod;
  bool _isCreatingContract = false;
  late ContratoRepository _contratoRepository;
  Map<String, dynamic> _cachedData = {};

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

      setState(() {
        _cachedData = cachedData;
      });
    } catch (e) {
      print('❌ Erro ao carregar dados do cache: $e');
    }
  }

  // Widget para "Pagar no hotel"
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
          Row(
            children: [
              Icon(Icons.hotel, color: Colors.blue[700], size: 24),
              const SizedBox(width: 8),
              const Text(
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
          _buildInfoItem('• Aceitamos cartão, dinheiro e PIX'),
          _buildInfoItem('• Check-in a partir das 14h'),
          _buildInfoItem('• Documentação do pet necessária'),
          _buildInfoItem('• Reserva confirmada instantaneamente'),
        ],
      ),
    );
  }

  // Widget para "Pagar no app" (EM DESENVOLVIMENTO)
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

          // Banner de em desenvolvimento
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.orange[800], size: 20),
                const SizedBox(width: 8),
                const Expanded(
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

          const SizedBox(height: 8),
          _buildInfoItemDesabilitada('• Pagamento 100% seguro'),
          _buildInfoItemDesabilitada('• Confirmação instantânea'),
          _buildInfoItemDesabilitada('• Comprovante por email'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  Widget _buildInfoItemDesabilitada(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
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

  // Botão de seleção de pagamento
  Widget _buildBotaoPagamento(String metodo, bool selecionado,
      {bool desabilitado = false}) {
    return GestureDetector(
      onTap: desabilitado
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
          color: desabilitado
              ? Colors.grey[100]
              : selecionado
                  ? Colors.blue[50]
                  : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: desabilitado
                ? Colors.grey[300]!
                : selecionado
                    ? Colors.blue
                    : Colors.grey[300]!,
            width: selecionado ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: desabilitado
                      ? Colors.grey
                      : selecionado
                          ? Colors.blue
                          : Colors.grey,
                  width: 2,
                ),
                color: desabilitado
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
                      color: desabilitado
                          ? Colors.grey
                          : selecionado
                              ? Colors.blue
                              : Colors.grey[700],
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
                child: Text(
                  'EM BREVE',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Função para mostrar mensagem de desenvolvimento
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

  // Função para criar contrato e finalizar reserva
  Future<void> _criarContratoEFinalizar() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final prefs = await SharedPreferences.getInstance();

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
      final idHospedagem = prefs.getInt('selected_hotel_id') ?? 1;
      final idUsuario = authProvider.usuario?.idUsuario ?? 1;

      // Criar contrato
      final response = await _contratoRepository.criarContrato(
        idHospedagem: idHospedagem,
        dataInicio: dataInicio,
        dataFim: dataFim,
        pets: petIds,
        servicos: servicosFormatados, 
        idUsuario: idUsuario, 
      
      );

      print('✅ Contrato criado com sucesso: $response');

      // Limpar cache após criar contrato com sucesso
      await _limparCache();

      // Mostrar diálogo de sucesso
      _mostrarSucessoDialog(context);
    } catch (e) {
      print('❌ Erro ao criar contrato: $e');
      _mostrarErroDialog(context, e.toString());
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
              Text('Reserva Confirmada!'),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Seu contrato foi criado com sucesso e está em aprovação.'),
                SizedBox(height: 12),
                Text(
                  'Você escolheu pagar no hotel. Apresente-se no check-in com:',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 8),
                Text('• Documento de identificação'),
                Text('• Comprovante de vacinação do pet'),
                Text('• Cartão ou dinheiro para pagamento'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/core-navigation');
              },
              child: const Text('Ver Minhas Reservas'),
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
                  ),
                ),
              ),
              const SizedBox(height: 8),

              const Center(
                child: Text(
                  'Escolha como deseja pagar',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Aviso sobre pagamento em desenvolvimento
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'No momento, apenas o pagamento no hotel está disponível',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Botões de seleção
              _buildBotaoPagamento(
                'Pagar no hotel',
                selectedPaymentMethod == 'Pagar no hotel',
              ),
              _buildBotaoPagamento(
                'Pagar no app',
                selectedPaymentMethod == 'Pagar no app',
                desabilitado: true, // DESABILITADO
              ),

              const SizedBox(height: 20),

              // Widget dinâmico baseado na seleção
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: selectedPaymentMethod == 'Pagar no hotel'
                    ? _buildPagamentoNoHotel()
                    : selectedPaymentMethod == 'Pagar no app'
                        ? _buildPagamentoNoApp()
                        : const SizedBox.shrink(),
              ),

              const SizedBox(height: 40),

              // Loading durante criação do contrato
              if (_isCreatingContract) ...[
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Criando contrato...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ],

              // Botão finalizar reserva
              AppButton(
                onPressed: (selectedPaymentMethod == 'Pagar no hotel' &&
                        !_isCreatingContract)
                    ? () {
                        _criarContratoEFinalizar();
                      }
                    : null,
                label: _isCreatingContract
                    ? 'Processando...'
                    : 'Finalizar Reserva',
                buttonColor: (selectedPaymentMethod == 'Pagar no hotel' &&
                        !_isCreatingContract)
                    ? null
                    : Colors.grey[400],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
