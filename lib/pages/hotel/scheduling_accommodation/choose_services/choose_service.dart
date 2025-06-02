import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/models/service_model.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_services/choose_service_template.dart';
import 'package:pet_family_app/repository/service_repository.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';

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
      } else {
        _selectedServices.add(serviceId);
      }
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

                  const SizedBox(height: 40),
                  if (_selectedServices.isNotEmpty)
                    AppButton(
                      onPressed: () {
                        context.go('/final-verification', extra: {
                          'selectedServices': _selectedServices.toList(),
                          'services': _services
                              .where((s) =>
                                  _selectedServices.contains(s.idServico))
                              .toList(),
                          'totalValue': totalValue,
                        });
                      },
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
