import 'dart:ui';

import 'package:flutter/material.dart';

class ServicesInformation extends StatelessWidget {
  final Map<String, dynamic>? cachedData;

  const ServicesInformation({super.key, this.cachedData});

  @override
  Widget build(BuildContext context) {
    final services = cachedData?['selected_services'] as Map<String, dynamic>?;
    final serviceNames = services?['names'] as List<String>? ?? [];
    final servicePrices = services?['prices'] as List<String>? ?? [];
    final totalValue = services?['total_value'] as double? ?? 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Serviços Adicionais',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (serviceNames.isEmpty)
            const Text(
              'Nenhum serviço selecionado',
              style: TextStyle(color: Colors.grey),
            )
          else
            Column(
              children: [
                ...List.generate(serviceNames.length, (index) {
                  return _buildServiceItem(
                    serviceNames[index],
                    servicePrices[index],
                  );
                }),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total dos Serviços:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$${totalValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String name, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Text(
            'R\$$price',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
