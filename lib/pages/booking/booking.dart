import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/pages/booking/template/booking_template.dart';
import 'package:pet_family_app/repository/contrato_repository.dart';
import 'package:pet_family_app/widgets/app_drop_down.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_family_app/providers/auth_provider.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  String? _optionSelected;
  final ContratoRepository _contratoRepository = ContratoRepository();
  List<ContratoModel> _contratos = [];
  bool _isLoading = false;
  bool _isCreating = false;
  String _errorMessage = '';

  List<String> listOptions = [
    'em aprovação',
    'aprovado',
    'em execução',
    'concluido',
    'Negado',
    'Cancelado'
  ];

  // Mapeamento de status para IDs
  final Map<String, int> _statusMap = {
    'em aprovação': 1,
    'aprovado': 2,
    'em execução': 3,
    'concluido': 4,
    'Negado': 5,
    'Cancelado': 6,
  };

  @override
  void initState() {
    super.initState();
    _criarContratoComCache();
    _carregarContratos();
  }

  // Cria contrato automaticamente com dados do cache
  Future<void> _criarContratoComCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idUsuario = await AuthProvider.getUserIdFromCache();

      if (idUsuario == null) {
        print('❌ Usuário não autenticado');
        return;
      }

      // Verifica se já existe um contrato criado
      final contratoCriado = prefs.getBool('contrato_criado') ?? false;
      if (contratoCriado) {
        print('✅ Contrato já foi criado anteriormente');
        return;
      }

      // Busca dados do cache
      final startDateMillis = prefs.getInt('selected_start_date');
      final endDateMillis = prefs.getInt('selected_end_date');

      if (startDateMillis == null || endDateMillis == null) {
        print('❌ Datas não encontradas no cache');
        return;
      }

      final startDate = DateTime.fromMillisecondsSinceEpoch(startDateMillis);
      final endDate = DateTime.fromMillisecondsSinceEpoch(endDateMillis);

      setState(() {
        _isCreating = true;
      });

      // Cria o contrato
      final contrato = ContratoModel(
        idHospedagem: 1, // ID fixo da hospedagem - ajuste conforme necessário
        idUsuario: idUsuario,
        idStatus: 1, // "em aprovação"
        dataInicio: startDate,
        dataFim: endDate,
      );

      final contratoCriadoResponse =
          await _contratoRepository.criarContrato(contrato);

      // Marca como criado no cache
      await prefs.setBool('contrato_criado', true);

      print(
          '✅ Contrato criado com sucesso: ${contratoCriadoResponse.idContrato}');

      setState(() {
        _isCreating = false;
      });

      // Recarrega a lista de contratos
      _carregarContratos();
    } catch (e) {
      print('❌ Erro ao criar contrato: $e');
      setState(() {
        _isCreating = false;
        _errorMessage = 'Erro ao criar agendamento: $e';
      });
    }
  }

  // Carrega contratos do usuário
  Future<void> _carregarContratos() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final idUsuario = await AuthProvider.getUserIdFromCache();

      if (idUsuario == null) {
        throw Exception('Usuário não autenticado');
      }

      final contratos =
          await _contratoRepository.buscarContratosPorUsuario(idUsuario);

      setState(() {
        _contratos = contratos;
        _isLoading = false;
      });

      print('✅ ${contratos.length} contratos carregados');
    } catch (e) {
      print('❌ Erro ao carregar contratos: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar agendamentos: $e';
        _contratos = [];
      });
    }
  }

  // Filtra contratos por status selecionado
  Future<void> _filtrarContratosPorStatus(String? status) async {
    try {
      if (status == null) {
        await _carregarContratos();
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final idStatus = _statusMap[status];
      if (idStatus == null) {
        throw Exception('Status inválido: $status');
      }

      final contratosFiltrados =
          await _contratoRepository.buscarContratosPorStatus(idStatus);

      setState(() {
        _contratos = contratosFiltrados;
        _isLoading = false;
      });

      print(
          '✅ ${contratosFiltrados.length} contratos encontrados para status: $status');
    } catch (e) {
      print('❌ Erro ao filtrar contratos: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao filtrar agendamentos: $e';
      });
    }
  }

  String _formatarData(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _obterNomeStatus(int idStatus) {
    return _statusMap.entries
        .firstWhere((entry) => entry.value == idStatus,
            orElse: () => MapEntry('Desconhecido', 0))
        .key;
  }

  Color _obterCorStatus(int idStatus) {
    switch (idStatus) {
      case 1: // em aprovação
        return Colors.orange;
      case 2: // aprovado
        return Colors.green;
      case 3: // em execução
        return Colors.blue;
      case 4: // concluido
        return Colors.grey;
      case 5: // negado
        return Colors.red;
      case 6: // cancelado
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Center(
                child: Column(
                  children: [
                    Text(
                      'seus',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w200,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Agendamentos',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Filtro por status
              AppDropDown<String>(
                value: _optionSelected,
                items: listOptions,
                label: 'Filtrar por status',
                hint: 'Todos os agendamentos',
                onChanged: (newValue) {
                  setState(() => _optionSelected = newValue);
                  _filtrarContratosPorStatus(newValue);
                },
                isRequired: false,
              ),

              const SizedBox(height: 20),

              // Indicadores de carregamento
              if (_isCreating) ...[
                const LinearProgressIndicator(),
                const SizedBox(height: 10),
                const Text(
                  'Criando agendamento...',
                  style: TextStyle(color: Colors.blue),
                ),
                const SizedBox(height: 20),
              ],

              if (_isLoading) ...[
                const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 20),
                const Text(
                  'Carregando agendamentos...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
              ],

              // Mensagem de erro
              if (_errorMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => _errorMessage = '');
                          _carregarContratos();
                        },
                        icon: const Icon(Icons.refresh, color: Colors.red),
                      ),
                    ],
                  ),
                ),

              // Lista de contratos
              if (!_isLoading && _contratos.isEmpty && _errorMessage.isEmpty)
                _buildEmptyState()
              else if (!_isLoading && _contratos.isNotEmpty)
                _buildContratosList(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          const Text(
            'Nenhum agendamento encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Seus agendamentos aparecerão aqui',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _carregarContratos,
            child: const Text('Recarregar'),
          ),
        ],
      ),
    );
  }

  Widget _buildContratosList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_contratos.length} agendamento(s) encontrado(s)',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        ..._contratos.map((contrato) {
          return BookingTemplate(
            contrato: contrato,
            onTap: () {
              // Ação quando clicar no contrato
              _mostrarDetalhesContrato(contrato);
            },
          );
        }).toList(),
      ],
    );
  }

  void _mostrarDetalhesContrato(ContratoModel contrato) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes do Agendamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailItem('ID', contrato.idContrato?.toString() ?? 'N/A'),
            _buildDetailItem('Status', _obterNomeStatus(contrato.idStatus)),
            _buildDetailItem('Check-in', _formatarData(contrato.dataInicio)),
            _buildDetailItem('Check-out', _formatarData(contrato.dataFim)),
            _buildDetailItem('Hospedagem', 'ID: ${contrato.idHospedagem}'),
            if (contrato.dataCriacao != null)
              _buildDetailItem(
                  'Criado em', _formatarData(contrato.dataCriacao!)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
