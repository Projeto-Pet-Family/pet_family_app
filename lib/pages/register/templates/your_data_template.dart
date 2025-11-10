import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YourDataTemplate extends StatefulWidget {
  const YourDataTemplate({super.key});

  @override
  State<YourDataTemplate> createState() => _YourDataTemplateState();
}

class _YourDataTemplateState extends State<YourDataTemplate> {
  Map<String, dynamic> _userData = {};
  Map<String, dynamic> _addressData = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAddressData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _userData = {
        'name': prefs.getString('user_name') ?? 'Não informado',
        'cpf': prefs.getString('user_cpf') ?? 'Não informado',
        'phone': prefs.getString('user_phone') ?? 'Não informado',
        'email': prefs.getString('user_email') ?? 'Não informado',
      };
    });
  }

  Future<void> _loadAddressData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _addressData = {
        'cep': prefs.getString('user_cep') ?? 'Não informado',
        'street': prefs.getString('user_street') ?? 'Não informado',
        'number': prefs.getString('user_number') ?? 'Não informado',
        'complement': prefs.getString('user_complement'),
        'neighborhood': prefs.getString('user_neighborhood') ?? 'Não informado',
        'city': prefs.getString('user_city') ?? 'Não informado',
        'state': prefs.getString('user_state') ?? 'Não informado',
      };
    });
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
          // Dados Pessoais
          const Text(
            'Dados Pessoais',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          _buildDataRow('Nome completo', _userData['name']),
          const SizedBox(height: 12),
          _buildDataRow('CPF', _userData['cpf']),
          const SizedBox(height: 12),
          _buildDataRow('Telefone', _userData['phone']),
          const SizedBox(height: 12),
          _buildDataRow('E-mail', _userData['email']),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // Endereço
          const Text(
            'Endereço',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          _buildDataRow('CEP', _addressData['cep']),
          const SizedBox(height: 12),
          _buildDataRow('Rua', _addressData['street']),
          const SizedBox(height: 12),
          _buildDataRow('Número', _addressData['number']),
          const SizedBox(height: 12),

          // Complemento (só mostra se tiver valor)
          if (_addressData['complement'] != null &&
              _addressData['complement'].isNotEmpty)
            Column(
              children: [
                _buildDataRow('Complemento', _addressData['complement']!),
                const SizedBox(height: 12),
              ],
            ),

          _buildDataRow('Bairro', _addressData['neighborhood']),
          const SizedBox(height: 12),
          _buildDataRow('Cidade', _addressData['city']),
          const SizedBox(height: 12),
          _buildDataRow('Estado', _addressData['state']),
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
