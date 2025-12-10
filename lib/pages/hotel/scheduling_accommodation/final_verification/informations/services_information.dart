import 'package:flutter/material.dart';

class ServicesInformation extends StatelessWidget {
  final Map<String, dynamic> cachedData;

  const ServicesInformation({
    super.key,
    required this.cachedData,
  });

  @override
  Widget build(BuildContext context) {
    final selectedServices = cachedData['selected_services'] as Map<String, dynamic>?;
    
    // VERIFICAÇÃO SEGURA DE NULL
    final servicesDetailed = selectedServices?['services_detailed'] as List? ?? [];
    final hasServices = selectedServices?['has_services'] as bool? ?? false;
    final totalValue = selectedServices?['total_value'] as double? ?? 0.0;

    // Verifica se servicesDetailed é realmente uma lista de Map
    final validServices = servicesDetailed
        .where((item) => item is Map<String, dynamic>)
        .cast<Map<String, dynamic>>()
        .toList();

    if (!hasServices || validServices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.emoji_objects_outlined,
              size: 40,
              color: Colors.grey,
            ),
            SizedBox(height: 8),
            Text(
              'Nenhum serviço adicional selecionado',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.spa, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                'Serviços Adicionais',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  'R\$${totalValue.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${validServices.length} pet${validServices.length > 1 ? 's' : ''} com serviços selecionados',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          ...validServices.map((petData) => _buildPetServices(petData)).toList(),
        ],
      ),
    );
  }

  Widget _buildPetServices(Map<String, dynamic> petData) {
    // VERIFICAÇÃO SEGURA DOS DADOS
    final petName = (petData['pet_name'] as String?) ?? 'Pet';
    final servicesRaw = petData['services'];
    final petTotal = (petData['total'] as num?)?.toDouble() ?? 0.0;
    
    // Converte serviços para lista segura
    final List<Map<String, dynamic>> services = [];
    if (servicesRaw is List) {
      for (var item in servicesRaw) {
        if (item is Map<String, dynamic>) {
          services.add(item);
        }
      }
    }
    
    if (services.isEmpty) {
      return const SizedBox(); // Retorna widget vazio se não houver serviços
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pets, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                petName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
              const Spacer(),
              Text(
                'R\$${petTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...services.map((service) => Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: _buildServiceItem(
              (service['name'] as String?) ?? 'Serviço',
              (service['price'] as num?)?.toDouble() ?? 0.0,
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String name, double price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            'R\$${price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }
}