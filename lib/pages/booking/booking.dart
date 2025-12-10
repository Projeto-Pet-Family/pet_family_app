// pages/booking/booking.dart - CÓDIGO COMPLETO ATUALIZADO
import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/pages/booking/template/booking_template.dart';
import 'package:pet_family_app/repository/contrato_repository.dart';
import 'package:pet_family_app/services/auth_service.dart';
import 'package:pet_family_app/services/contrato_service.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_family_app/services/status_service.dart';

class Booking extends StatefulWidget {
  const Booking({super.key});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  String? _optionSelected;
  late ContratoRepository _contratoRepository;
  final StatusService _statusService = StatusService(); // SEM PARÂMETRO
  List<ContratoModel> _contratos = [];
  bool _isLoading = false;
  bool _isCreating = false;
  String _errorMessage = '';

  List<String> listOptions = [
    'em aprovação',
    'aprovado',
    'em execução',
    'concluido',
    'negado',
    'cancelado'
  ];

  final Map<String, String> _statusMap = {
    'em aprovação': 'em_aprovacao',
    'aprovado': 'aprovado',
    'em execução': 'em_execucao',
    'concluido': 'concluido',
    'negado': 'negado',
    'cancelado': 'cancelado',
  };

  final Map<String, String> _statusDisplayMap = {
    'em_aprovacao': 'Em aprovação',
    'aprovado': 'Aprovado',
    'em_execucao': 'Em execução',
    'concluido': 'Concluído',
    'negado': 'Negado',
    'cancelado': 'Cancelado',
  };

  @override
  void initState() {
    super.initState();
    _inicializarRepository();
    _criarContratoComCache();
    _carregarContratos();
  }

  void _inicializarRepository() {
    try {
      final dio = Dio(BaseOptions(
        baseUrl: 'https://bepetfamily.onrender.com',
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
      final dio = Dio(BaseOptions(baseUrl: 'https://bepetfamily.onrender.com'));
      final contratoService = ContratoService(dio);
      _contratoRepository =
          ContratoRepositoryImpl(contratoService: contratoService);
    }
  }

  Future<void> _criarContratoComCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authService = AuthService();
      final idUsuario = await authService.getUserIdFromCache();

      if (idUsuario == null) {
        print('❌ Usuário não autenticado');
        return;
      }

      final contratoCriado = prefs.getBool('contrato_criado') ?? false;
      if (contratoCriado) {
        print('✅ Contrato já foi criado anteriormente');
        return;
      }

      final startDateMillis = prefs.getInt('selected_start_date');
      final endDateMillis = prefs.getInt('selected_end_date');
      final selectedPetIds = prefs.getStringList('selected_pets') ?? [];
      final selectedServiceIds = prefs.getStringList('selected_services') ?? [];

      if (startDateMillis == null || endDateMillis == null) {
        print('❌ Datas não encontradas no cache');
        return;
      }

      if (selectedPetIds.isEmpty) {
        print('❌ Nenhum pet selecionado no cache');
        return;
      }

      final startDate = DateTime.fromMillisecondsSinceEpoch(startDateMillis);
      final endDate = DateTime.fromMillisecondsSinceEpoch(endDateMillis);

      setState(() {
        _isCreating = true;
      });

      final dataInicio =
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
      final dataFim =
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';

      final petIds = selectedPetIds.map(int.parse).toList();
      final servicosFormatados = selectedServiceIds.map((id) {
        return {
          'idservico': int.parse(id),
          'quantidade': 1,
        };
      }).toList();

      print('🚀 Criando contrato automático com dados do cache:');
      print('👤 Usuário ID: $idUsuario');
      print('🐾 Pets: $petIds');
      print('📅 Data Início: $dataInicio');
      print('📅 Data Fim: $dataFim');
      print('🛎️ Serviços: $servicosFormatados');

      final contrato = await _contratoRepository.criarContrato(
        idHospedagem: 1,
        idUsuario: idUsuario,
        dataInicio: dataInicio,
        dataFim: dataFim,
        pets: petIds,
        servicos: servicosFormatados,
        status: 'em_aprovacao',
      );

      await prefs.setBool('contrato_criado', true);

      print('✅ Contrato criado com sucesso: ${contrato.idContrato}');

      setState(() {
        _isCreating = false;
      });

      await _carregarContratos();
    } catch (e) {
      print('❌ Erro ao criar contrato: $e');
      setState(() {
        _isCreating = false;
        _errorMessage = 'Erro ao criar agendamento: $e';
      });
    }
  }

  Future<void> _carregarContratos() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final authService = AuthService();
      final idUsuario = await authService.getUserIdFromCache();

      if (idUsuario == null) {
        throw Exception('Usuário não autenticado');
      }

      final contratos =
          await _contratoRepository.listarContratosPorUsuario(idUsuario);

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

  Future<void> _filtrarContratosPorStatus(String? statusDisplay) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        _optionSelected = statusDisplay;
      });

      final authService = AuthService();
      final idUsuario = await authService.getUserIdFromCache();

      if (idUsuario == null) {
        throw Exception('Usuário não autenticado');
      }

      print('🎯 Iniciando filtro por status: $statusDisplay');

      if (statusDisplay == null || statusDisplay == 'Todos') {
        // Carregar todos os contratos
        print('📋 Mostrando todos os contratos');
        await _carregarContratos();
      } else {
        // Converter status display para formato da API
        final statusApi = _statusMap[statusDisplay];

        if (statusApi == null) {
          throw Exception('Status inválido: $statusDisplay');
        }

        print('🔍 Status para API: $statusApi');

        // Usar o StatusService para filtrar
        final resultado = await _statusService.filtrarContratosUsuarioPorStatus(
          idUsuario: idUsuario,
          status: [statusApi],
        );

        print('📊 Resultado do filtro: ${resultado['success']}');

        if (resultado['success'] == true) {
          final contratosFiltrados =
              List<ContratoModel>.from(resultado['contratos'] ?? []);
          setState(() {
            _contratos = contratosFiltrados;
            _isLoading = false;
          });
          print(
              '✅ ${contratosFiltrados.length} contratos encontrados para "$statusDisplay"');
        } else {
          // Se a API falhar, fazer filtro local
          print('⚠️ API falhou, fazendo filtro local...');
          await _filtrarLocalmente(statusApi);
        }
      }
    } catch (e) {
      print('❌ Erro ao filtrar contratos: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao filtrar agendamentos: $e';
      });
    }
  }

  Future<void> _filtrarLocalmente(String statusApi) async {
    try {
      // Primeiro carrega todos os contratos
      await _carregarContratos();

      // Depois filtra localmente
      final contratosFiltrados = _contratos.where((contrato) {
        return contrato.status == statusApi;
      }).toList();

      setState(() {
        _contratos = contratosFiltrados;
        _isLoading = false;
      });

      print('✅ ${contratosFiltrados.length} contratos encontrados localmente');
    } catch (e) {
      print('❌ Erro no filtro local: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao filtrar localmente: $e';
      });
    }
  }

  Future<void> _atualizarContratoNaLista(
      ContratoModel contratoAtualizado) async {
    try {
      final contratoCompleto = await _contratoRepository.buscarContratoPorId(
        contratoAtualizado.idContrato!,
      );

      setState(() {
        final index = _contratos.indexWhere(
          (c) => c.idContrato == contratoCompleto.idContrato,
        );

        if (index != -1) {
          _contratos[index] = contratoCompleto;
          print(
              '✅ Contrato ${contratoCompleto.idContrato} atualizado na lista');
          print('📊 Novo status: ${contratoCompleto.status}');
        } else {
          _contratos.add(contratoCompleto);
        }
      });
    } catch (e) {
      print('❌ Erro ao atualizar contrato na lista: $e');
      setState(() {
        final index = _contratos.indexWhere(
          (c) => c.idContrato == contratoAtualizado.idContrato,
        );

        if (index != -1) {
          _contratos[index] = contratoAtualizado;
        }
      });
    }
  }

  Future<void> _cancelarContratoNoBackend(ContratoModel contrato) async {
    try {
      print('🚀 Cancelando contrato no backend: ${contrato.idContrato}');

      final contratoAtualizado =
          await _contratoRepository.atualizarStatusContrato(
        idContrato: contrato.idContrato!,
        status: 'cancelado',
        motivo: 'Cancelado pelo usuário',
      );

      _atualizarContratoNaLista(contratoAtualizado);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Agendamento cancelado com sucesso!",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      print('✅ Contrato cancelado com sucesso no backend');
    } catch (e) {
      print('❌ Erro ao cancelar contrato no backend: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erro ao cancelar: $e",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      await _carregarContratos();
    }
  }

  Future<void> _editarContrato(ContratoModel contrato) async {
    try {
      print('📝 Editando contrato: ${contrato.idContrato}');

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Editar Agendamento'),
          content: const Text('Funcionalidade de edição em desenvolvimento.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('❌ Erro ao editar contrato: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao editar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _excluirContrato(ContratoModel contrato) async {
    try {
      print('🗑️ Excluindo contrato: ${contrato.idContrato}');

      final confirmar = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const Text(
              'Tem certeza que deseja excluir este agendamento? Esta ação não pode ser desfeita.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmar != true) return;

      await _contratoRepository.excluirContrato(contrato.idContrato!);

      setState(() {
        _contratos.removeWhere((c) => c.idContrato == contrato.idContrato);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Agendamento excluído com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      print('✅ Contrato excluído com sucesso');
    } catch (e) {
      print('❌ Erro ao excluir contrato: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao excluir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _recarregarContratos() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        _optionSelected = null;
      });

      await _carregarContratos();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lista de agendamentos atualizada!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('❌ Erro ao recarregar contratos: $e');
      setState(() {
        _errorMessage = 'Erro ao recarregar: $e';
      });
    }
  }

  Widget _buildFiltroStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtrar por Status:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChipFiltro('Todos', null),
                ...listOptions
                    .map((status) => _buildChipFiltro(status, status)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipFiltro(String label, String? value) {
    final isSelected = _optionSelected == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _optionSelected = selected ? value : null;
          });
          _filtrarContratosPorStatus(_optionSelected);
        },
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue,
      ),
    );
  }

  String _formatarData(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _obterNomeStatus(String status) {
    return _statusDisplayMap[status] ?? status;
  }

  Color _obterCorStatus(String status) {
    switch (status) {
      case 'em_aprovacao':
        return Colors.orange;
      case 'aprovado':
        return Colors.green;
      case 'em_execucao':
        return Colors.blue;
      case 'concluido':
        return Colors.grey;
      case 'negado':
        return Colors.red;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            _optionSelected != null && _optionSelected != 'Todos'
                ? Icons.filter_alt_off
                : Icons.calendar_today,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            _optionSelected != null && _optionSelected != 'Todos'
                ? 'Nenhum agendamento "$_optionSelected" encontrado'
                : 'Nenhum agendamento encontrado',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _optionSelected != null && _optionSelected != 'Todos'
                ? 'Tente selecionar outro filtro'
                : 'Seus agendamentos aparecerão aqui',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _recarregarContratos,
            child: const Text('Recarregar'),
          ),
        ],
      ),
    );
  }

  Widget _buildContratosList() {
    final contratosOrdenados = List<ContratoModel>.from(_contratos)
      ..sort((a, b) => b.dataInicio.compareTo(a.dataInicio));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        ...contratosOrdenados.map((contrato) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: BookingTemplate(
              contrato: contrato,
              onTap: () {
                _mostrarDetalhesContrato(contrato);
              },
              onEditar: () {
                _editarContrato(contrato);
              },
              onCancelar: () {
                _cancelarContratoNoBackend(contrato);
              },
              onExcluir: () {
                _excluirContrato(contrato);
              },
              onContratoEditado: (contratoAtualizado) {
                _atualizarContratoNaLista(contratoAtualizado);
              },
            ),
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
        content: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('ID', contrato.idContrato?.toString() ?? 'N/A'),
              _buildDetailItem('Status', _obterNomeStatus(contrato.status)),
              _buildDetailItem('Check-in', _formatarData(contrato.dataInicio)),
              if (contrato.dataFim != null)
                _buildDetailItem('Check-out', _formatarData(contrato.dataFim!)),
              _buildDetailItem('Hospedagem', 'ID: ${contrato.idHospedagem}'),
              if (contrato.hospedagemNome != null)
                _buildDetailItem(
                    'Nome da Hospedagem', contrato.hospedagemNome!),
              if (contrato.dataCriacao != null)
                _buildDetailItem(
                    'Criado em', _formatarData(contrato.dataCriacao!)),
              if (contrato.pets != null && contrato.pets!.isNotEmpty)
                _buildDetailItem('Pets', '${contrato.pets!.length} pet(s)'),
              if (contrato.servicosGerais != null &&
                  contrato.servicosGerais!.isNotEmpty)
                _buildDetailItem('Serviços',
                    '${contrato.servicosGerais!.length} serviço(s)'),
              if (contrato.valorServicos != null)
                _buildDetailItem('Valor Total',
                    'R\$${contrato.valorServicos!.toStringAsFixed(2)}'),
            ],
          ),
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
        ));
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

              // Filtro de status
              _buildFiltroStatus(),
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

              // Loading principal
              if (_isLoading) ...[
                const Center(child: CircularProgressIndicator()),
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
                        onPressed: _recarregarContratos,
                        icon: const Icon(
                          Icons.refresh,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),

              // Lista vazia
              if (!_isLoading && _contratos.isEmpty && _errorMessage.isEmpty)
                _buildEmptyState()

              // Lista de contratos
              else if (!_isLoading && _contratos.isNotEmpty)
                _buildContratosList(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
