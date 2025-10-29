import 'package:flutter/material.dart';

class TaxasInformations extends StatelessWidget {
  final Map<String, dynamic>? cachedData;

  const TaxasInformations({super.key, this.cachedData});

  @override
  Widget build(BuildContext context) {
    // Você pode adicionar cálculos de taxas baseados nos dados do cache
    final services = cachedData?['selected_services'] as Map<String, dynamic>?;
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
            'Resumo Financeiro',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildTaxaItem('Serviços Adicionais', totalValue),
          _buildTaxaItem('Taxa de Hospedagem', 0.0), // Adicione seus cálculos
          _buildTaxaItem(
              'Taxas Administrativas', 0.0), // Adicione seus cálculos
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Valor Total:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'R\$${(totalValue + 0.0).toStringAsFixed(2)}', // Ajuste com seus cálculos
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxaItem(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            'R\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              color: value > 0 ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
