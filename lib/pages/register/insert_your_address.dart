import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';
import 'package:pet_family_app/widgets/app_drop_down.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InsertYourAddress extends StatefulWidget {
  const InsertYourAddress({super.key});

  @override
  State<InsertYourAddress> createState() => _InsertYourAddressState();
}

class _InsertYourAddressState extends State<InsertYourAddress> {
  TextEditingController cepController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController complementController = TextEditingController();
  TextEditingController neighborhoodController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  String? _selectedState;

  // Lista de estados brasileiros
  final List<String> statesList = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 
    'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 
    'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'
  ];

  // Chaves para o cache
  static const String _cepKey = 'user_cep';
  static const String _streetKey = 'user_street';
  static const String _numberKey = 'user_number';
  static const String _complementKey = 'user_complement';
  static const String _neighborhoodKey = 'user_neighborhood';
  static const String _cityKey = 'user_city';
  static const String _stateKey = 'user_state';

  @override
  void initState() {
    super.initState();
    _loadAddressData();
  }

  // Salvar dados no cache
  Future<void> _saveAddressData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_cepKey, cepController.text);
    await prefs.setString(_streetKey, streetController.text);
    await prefs.setString(_numberKey, numberController.text);
    await prefs.setString(_complementKey, complementController.text);
    await prefs.setString(_neighborhoodKey, neighborhoodController.text);
    await prefs.setString(_cityKey, cityController.text);
    
    // Só salva o estado se for um valor válido da lista
    if (_selectedState != null && statesList.contains(_selectedState)) {
      await prefs.setString(_stateKey, _selectedState!);
    } else {
      await prefs.remove(_stateKey); // Remove se for inválido
    }
  }

  // Carregar dados do cache
  Future<void> _loadAddressData() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      cepController.text = prefs.getString(_cepKey) ?? '';
      streetController.text = prefs.getString(_streetKey) ?? '';
      numberController.text = prefs.getString(_numberKey) ?? '';
      complementController.text = prefs.getString(_complementKey) ?? '';
      neighborhoodController.text = prefs.getString(_neighborhoodKey) ?? '';
      cityController.text = prefs.getString(_cityKey) ?? '';
      
      // Carrega o estado apenas se for um valor válido
      final savedState = prefs.getString(_stateKey);
      if (savedState != null && statesList.contains(savedState)) {
        _selectedState = savedState;
      } else {
        _selectedState = null;
        // Limpa o valor inválido do cache
        if (savedState != null) {
          prefs.remove(_stateKey);
        }
      }
    });
  }

  // Limpar dados do cache
  Future<void> _clearAddressData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_cepKey);
    await prefs.remove(_streetKey);
    await prefs.remove(_numberKey);
    await prefs.remove(_complementKey);
    await prefs.remove(_neighborhoodKey);
    await prefs.remove(_cityKey);
    await prefs.remove(_stateKey);
    
    setState(() {
      cepController.clear();
      streetController.clear();
      numberController.clear();
      complementController.clear();
      neighborhoodController.clear();
      cityController.clear();
      _selectedState = null;
    });
  }

  // Método para limpar apenas o estado (para resolver o problema atual)
  Future<void> _clearStateData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_stateKey);
    setState(() {
      _selectedState = null;
    });
  }

  bool get _isFormValid {
    return cepController.text.isNotEmpty &&
        streetController.text.isNotEmpty &&
        numberController.text.isNotEmpty &&
        neighborhoodController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        _selectedState != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PetFamilyAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Insira seu endereço',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                
                // Mapa placeholder
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, size: 50, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'Mapa (Google Maps)',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'Configure a API key para habilitar',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                AppTextField(
                  controller: cepController,
                  labelText: 'CEP',
                  hintText: 'Digite seu CEP',
                  onChanged: (value) {
                    _saveAddressData();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: streetController,
                  labelText: 'Rua',
                  hintText: 'Digite sua rua',
                  onChanged: (value) {
                    _saveAddressData();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: numberController,
                  labelText: 'Número',
                  hintText: 'Digite o número',
                  onChanged: (value) {
                    _saveAddressData();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: complementController,
                  labelText: 'Complemento (opcional)',
                  hintText: 'Digite o complemento',
                  onChanged: (value) {
                    _saveAddressData();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: neighborhoodController,
                  labelText: 'Bairro',
                  hintText: 'Digite o bairro',
                  onChanged: (value) {
                    _saveAddressData();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 15),
                AppTextField(
                  controller: cityController,
                  labelText: 'Cidade',
                  hintText: 'Digite a cidade',
                  onChanged: (value) {
                    _saveAddressData();
                    setState(() {});
                  },
                ),
                const SizedBox(height: 15),
                
                // Dropdown para Estado
                AppDropDown<String>(
                  value: _selectedState,
                  items: statesList,
                  label: 'Estado',
                  hint: 'Selecione o estado',
                  onChanged: (newValue) {
                    setState(() {
                      _selectedState = newValue;
                    });
                    _saveAddressData();
                  },
                  isRequired: true,
                  errorMessage: 'Por favor, selecione o estado',
                ),
                
                const SizedBox(height: 30),
                
                // Botão para limpar apenas o estado (solução temporária)
                if (_selectedState != null && !statesList.contains(_selectedState!))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OutlinedButton(
                      onPressed: _clearStateData,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        minimumSize: const Size(double.infinity, 40),
                      ),
                      child: const Text('Corrigir Estado (Valor Inválido)'),
                    ),
                  ),
                
                AppButton(
                  onPressed: _isFormValid
                      ? () async {
                          await _saveAddressData();
                          context.go('/confirm-your-datas');
                        }
                      : null,
                  label: 'Próximo',
                  fontSize: 20,
                ),
                
                const SizedBox(height: 20),
                
                // Botão para limpar cache
                OutlinedButton(
                  onPressed: _clearAddressData,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: const BorderSide(color: Colors.grey),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: const Text('Limpar Endereço'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    cepController.dispose();
    streetController.dispose();
    numberController.dispose();
    complementController.dispose();
    neighborhoodController.dispose();
    cityController.dispose();
    super.dispose();
  }
}