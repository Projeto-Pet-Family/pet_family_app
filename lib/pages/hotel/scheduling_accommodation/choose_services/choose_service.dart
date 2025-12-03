import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/models/service_model.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_services/choose_service_template.dart';
import 'package:pet_family_app/repository/service_repository.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/services/service_service.dart';

class ChooseService extends StatefulWidget {
  const ChooseService({super.key});

  @override
  State<ChooseService> createState() => _ChooseServiceState();
}

class _ChooseServiceState extends State<ChooseService> {
  late ServiceRepository _serviceRepository;
  List<ServiceModel> _services = [];
  final Set<int> _selectedServices = {};
  bool _isLoading = true;
  String _errorMessage = '';
  int? _idHospedagem;

  @override
  void initState() {
    super.initState();
    _serviceRepository = ServiceRepositoryImpl(serviceService: ServiceService(client: http.Client())); // Inicialização correta
    _carregarIdHospedagemEServicos();
  }

  Future<void> _carregarIdHospedagemEServicos() async {
    try {
      // Primeiro carrega o ID da hospedagem
      final prefs = await SharedPreferences.getInstance();
      final idHospedagem = prefs.getInt('id_hospedagem_selecionada');
      
      if (idHospedagem == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Nenhuma hospedagem selecionada';
        });
        return;
      }
      
      setState(() {
        _idHospedagem = idHospedagem;
      });
      
      // Carrega os serviços selecionados do cache
      await _carregarServicosSelecionadosDoCache();
      
      // Depois carrega os serviços da hospedagem
      await _carregarServicos(idHospedagem);
      
    } catch (e) {
      print('❌ Erro ao carregar dados: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar dados. Tente novamente.';
      });
    }
  }

  Future<void> _carregarServicos(int idHospedagem) async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final servicos = await _serviceRepository.listarServicosPorHospedagem(idHospedagem);
      
      // Filtra serviços com preço válido
      final servicosValidos = servicos.where((s) => s.preco > 0).toList();

      setState(() {
        _services = servicosValidos;
        _isLoading = false;
        _errorMessage = servicosValidos.isEmpty ? 'Nenhum serviço disponível' : '';
      });
    } catch (e) {
      print('❌ Erro ao carregar serviços: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar serviços. Tente novamente.';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível carregar os serviços')),
        );
      }
    }
  }

  // Carrega os serviços selecionados do cache
  Future<void> _carregarServicosSelecionadosDoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedServicesString = prefs.getStringList('selected_services') ?? [];

      final selectedServices = selectedServicesString
          .where((id) => id.isNotEmpty)
          .map((id) => int.tryParse(id))
          .where((id) => id != null)
          .map((id) => id!)
          .toSet();

      setState(() {
        _selectedServices.addAll(selectedServices);
      });

      print('✅ Serviços selecionados carregados do cache: $_selectedServices');
    } catch (e) {
      print('❌ Erro ao carregar serviços do cache: $e');
    }
  }

  // Salva os serviços selecionados no cache
  Future<void> _salvarServicosSelecionadosNoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedServicesString = _selectedServices.map((id) => id.toString()).toList();

      await prefs.setStringList('selected_services', selectedServicesString);

      print('💾 Serviços selecionados salvos no cache: $_selectedServices');
    } catch (e) {
      print('❌ Erro ao salvar serviços no cache: $e');
    }
  }

  // Salva detalhes dos serviços selecionados
  Future<void> _salvarDetalhesServicosNoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Salva o valor total
      await prefs.setDouble('selected_services_total', totalValue);

      // Salva os nomes/descrições dos serviços selecionados
      final selectedServiceNames = _services
          .where((service) => _selectedServices.contains(service.idServico))
          .map((service) => service.descricao)
          .toList();

      await prefs.setStringList('selected_service_names', selectedServiceNames);

      // Salva os preços individuais
      final selectedServicePrices = _services
          .where((service) => _selectedServices.contains(service.idServico))
          .map((service) => service.preco.toString())
          .toList();

      await prefs.setStringList('selected_service_prices', selectedServicePrices);

      print('💾 Detalhes dos serviços salvos no cache - Total: R\$${totalValue.toStringAsFixed(2)}');
    } catch (e) {
      print('❌ Erro ao salvar detalhes dos serviços: $e');
    }
  }

  // Limpa os serviços selecionados do cache
  Future<void> _limparServicosSelecionados() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove('selected_services');
      await prefs.remove('selected_services_total');
      await prefs.remove('selected_service_names');
      await prefs.remove('selected_service_prices');

      // Limpa informações individuais dos serviços
      for (final service in _services) {
        await prefs.remove('service_${service.idServico}_desc');
        await prefs.remove('service_${service.idServico}_price');
      }

      setState(() {
        _selectedServices.clear();
      });

      print('🗑️ Serviços selecionados limpos do cache');
    } catch (e) {
      print('❌ Erro ao limpar serviços do cache: $e');
    }
  }

  double get totalValue {
    return _selectedServices.fold(0.0, (sum, id) {
      final service = _services.firstWhere(
        (s) => s.idServico == id,
        orElse: () => ServiceModel(
          idservico: 0,
          idhospedagem: 0,
          descricao: '',
          preco: 0,
        ),
      );
      return sum + service.preco;
    });
  }

  void _toggleServiceSelection(int serviceId) {
    setState(() {
      if (_selectedServices.contains(serviceId)) {
        _selectedServices.remove(serviceId);
        print('➖ Serviço $serviceId removido da seleção');
      } else {
        _selectedServices.add(serviceId);
        print('➕ Serviço $serviceId adicionado à seleção');
      }
    });

    // Salva automaticamente no cache quando a seleção muda
    _salvarServicosSelecionadosNoCache();
  }

  void _navigateToNext() {
    // Salva detalhes antes de navegar
    _salvarDetalhesServicosNoCache();

    if (!mounted) return;
    
    context.go('/final-verification', extra: {
      'selectedServices': _selectedServices.toList(),
      'services': _services.where((s) => _selectedServices.contains(s.idServico)).toList(),
      'totalValue': totalValue,
    });
  }

  void _tryAgain() {
    if (_idHospedagem != null) {
      _carregarServicos(_idHospedagem!);
    } else {
      _carregarIdHospedagemEServicos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBarReturn(route: '/choose-data'),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Escolha o(s) serviço(s)',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w200,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Opcional',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w200,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),

                  // Mostra resumo dos serviços selecionados
                  if (_selectedServices.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Serviços selecionados:',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_selectedServices.length} serviço(s)',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: _limparServicosSelecionados,
                            icon: const Icon(Icons.clear, color: Colors.blue),
                            tooltip: 'Limpar serviços',
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Valor total:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          'R\$${totalValue.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Exibe loading, erro ou lista de serviços
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            _errorMessage,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          AppButton(
                            onPressed: _tryAgain,
                            label: 'Tentar Novamente',
                            fontSize: 16,
                          ),
                        ],
                      ),
                    )
                  else if (_services.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'Nenhum serviço disponível',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: _services.map((service) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15),
                          child: ChooseServiceTemplate(
                            key: ValueKey(service.idServico),
                            name: '${service.descricao} - R\$${service.preco.toStringAsFixed(2)}',
                            isSelected: _selectedServices.contains(service.idServico),
                            onTap: () => _toggleServiceSelection(service.idServico),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 30),

                  // Botão para limpar serviços (só aparece se houver serviços selecionados)
                  if (_selectedServices.isNotEmpty)
                    Column(
                      children: [
                        AppButton(
                          onPressed: _limparServicosSelecionados,
                          label: 'Limpar serviços',
                          fontSize: 17,
                          buttonColor: Colors.redAccent,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                  // Botão próximo (sempre visível)
                  AppButton(
                    onPressed: _navigateToNext,
                    label: 'Próximo',
                    fontSize: 17,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}