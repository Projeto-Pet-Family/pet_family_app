import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_services/choose_service_template.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class ChooseService extends StatefulWidget {
  const ChooseService({super.key});

  @override
  State<ChooseService> createState() => _ChooseServiceState();
}

class _ChooseServiceState extends State<ChooseService> {
  final Map<String, double> services = {
    'Passeio': 20.00,
    'Banho & Tosa': 50.00,
    'Spa': 150.00,
    'Massagem': 200.00,
    'Fisioterapia': 320.00,
  };

  final Set<String> selectedServices = {};

  double get totalValue {
    return selectedServices.fold(
        0.0, (sum, service) => sum + (services[service] ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBarReturn(route: '/core-navigation',),
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
                  Column(
                    children: services.keys.map((serviceName) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: ChooseServiceTemplate(
                          name:
                              '$serviceName - R\$${services[serviceName]!.toStringAsFixed(2)}',
                          isSelected: selectedServices.contains(serviceName),
                          onTap: () {
                            setState(() {
                              if (selectedServices.contains(serviceName)) {
                                selectedServices.remove(serviceName);
                              } else {
                                selectedServices.add(serviceName);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 40),
                  AppButton(
                    onPressed: () {
                      context.go('/final-verification');
                    },
                    label: 'Próximo',
                    fontSize: 17,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
