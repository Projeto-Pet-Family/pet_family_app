import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/models/service_model.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_services/choose_service_template.dart';
import 'package:pet_family_app/repository/service_repository.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChooseService extends StatefulWidget {
  const ChooseService({super.key});

  @override
  State<ChooseService> createState() => _ChooseServiceState();
}

class _ChooseServiceState extends State<ChooseService> {
  final ServiceRepository _serviceRepository = ServiceRepository();
  List<ServiceModel> _services = [];
  final Set<int> _selectedServices = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _carregarServicos();
    _carregarServicosSelecionadosDoCache();
  }

  Future<void> _carregarServicos() async {
    try {
      final servicos = await _serviceRepository.lerServico();

      // Filtra serviços com preço válido
      final servicosValidos = servicos.where((s) => s.preco > 0).toList();

      setState(() {
        _services = servicosValidos;
        _isLoading = false;
        _errorMessage =
            servicosValidos.isEmpty ? 'Nenhum serviço disponível' : '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar serviços. Tente novamente.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível carregar os serviços')),
      );
      print('Erro detalhado: $e');
    }
  }

  // Carrega os serviços selecionados do cache
  Future<void> _carregarServicosSelecionadosDoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedServicesString =
          prefs.getStringList('selected_services') ?? [];

      final selectedServices =
          selectedServicesString.map((id) => int.parse(id)).toSet();

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
      final selectedServicesString =
          _selectedServices.map((id) => id.toString()).toList();

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

      await prefs.setStringList(
          'selected_service_prices', selectedServicePrices);

      // Salva informações detalhadas de cada serviço
      for (final service in _services) {
        if (_selectedServices.contains(service.idServico)) {
          await prefs.setString(
              'service_${service.idServico}_desc', service.descricao);
          await prefs.setDouble(
              'service_${service.idServico}_price', service.preco);
        }
      }

      print(
          '💾 Detalhes dos serviços salvos no cache - Total: R\$${totalValue.toStringAsFixed(2)}');
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
          idServico: 0,
          idHospedagem: 0,
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

    context.go('/final-verification', extra: {
      'selectedServices': _selectedServices.toList(),
      'services': _services
          .where((s) => _selectedServices.contains(s.idServico))
          .toList(),
      'totalValue': totalValue,
    });
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
                      'Escolha o(s) serviço(s):',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w200,
                        color: Colors.black,
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
                    const Center(child: CircularProgressIndicator())
                  else if (_errorMessage.isNotEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(fontSize: 18),
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
                            name:
                                '${service.descricao} - R\$${service.preco.toStringAsFixed(2)}',
                            isSelected:
                                _selectedServices.contains(service.idServico),
                            onTap: () =>
                                _toggleServiceSelection(service.idServico),
                          ),
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 30),

                  // Botão para limpar seleção
                  if (_selectedServices.isNotEmpty)
                    OutlinedButton(
                      onPressed: _limparServicosSelecionados,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Limpar Serviços'),
                    ),

                  if (_selectedServices.isNotEmpty) const SizedBox(height: 16),

                  // Botão próximo
                  if (_selectedServices.isNotEmpty)
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
