import 'package:flutter/material.dart';

class PetInformations extends StatelessWidget {
  final Map<String, dynamic>? cachedData;

  const PetInformations({super.key, this.cachedData});

  @override
  Widget build(BuildContext context) {
    final pets = cachedData?['selected_pets'] as Map<String, dynamic>?;
    final petNames = pets?['names'] as List<String>? ?? [];

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
            'Pets Selecionados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (petNames.isEmpty)
            const Text(
              'Nenhum pet selecionado',
              style: TextStyle(color: Colors.grey),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: petNames.map((name) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.pets, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(name),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
