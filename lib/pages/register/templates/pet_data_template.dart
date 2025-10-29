// widgets/pet_data_template.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PetDataTemplate extends StatefulWidget {
  const PetDataTemplate({super.key});

  @override
  State<PetDataTemplate> createState() => _PetDataTemplateState();
}

class _PetDataTemplateState extends State<PetDataTemplate> {
  Map<String, dynamic> _petData = {};

  @override
  void initState() {
    super.initState();
    _loadPetData();
  }

  Future<void> _loadPetData() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _petData = {
        'name': prefs.getString('pet_name') ?? 'Não informado',
        'species': prefs.getString('pet_species') ?? 'Não informado',
        'race': prefs.getString('pet_race') ?? 'Não informado',
        'sex': _getSexDisplay(prefs.getString('pet_sex')),
        'observation': prefs.getString('pet_observation') ?? 'Não informado',
      };
    });
  }

  String _getSexDisplay(String? sexValue) {
    if (sexValue == 'm') return 'Macho';
    if (sexValue == 'f') return 'Fêmea';
    return 'Não informado';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do Pet
          _buildDataRow('Nome', _petData['name']),
          const SizedBox(height: 12),
          
          // Espécie
          _buildDataRow('Espécie', _petData['species']),
          const SizedBox(height: 12),
          
          // Raça
          _buildDataRow('Raça', _petData['race']),
          const SizedBox(height: 12),
          
          // Sexo
          _buildDataRow('Sexo', _petData['sex']),
          const SizedBox(height: 12),
          
          // Observações (só mostra se tiver valor)
          if (_petData['observation'] != 'Não informado' && _petData['observation'].isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDataRow('Observações', _petData['observation']),
                const SizedBox(height: 12),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: value == 'Não informado' ? Colors.grey : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}