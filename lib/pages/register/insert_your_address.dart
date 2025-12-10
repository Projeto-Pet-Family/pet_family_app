import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/services/via_cep_service.dart';
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_drop_down.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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

  // Variáveis para controle da busca de CEP
  bool _isLoadingCep = false;
  String? _cepError;
  Timer? _debounceTimer;
  final int _cepDebounceMs = 800;

  // Lista de estados brasileiros
  final List<String> statesList = [
    'AC',
    'AL',
    'AP',
    'AM',
    'BA',
    'CE',
    'DF',
    'ES',
    'GO',
    'MA',
    'MT',
    'MS',
    'MG',
    'PA',
    'PB',
    'PR',
    'PE',
    'PI',
    'RJ',
    'RN',
    'RS',
    'RO',
    'RR',
    'SC',
    'SP',
    'SE',
    'TO'
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
      _cepError = null;
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

  // Método para limpar campos de endereço (exceto CEP)
  void _clearAddressFields() {
    setState(() {
      streetController.clear();
      numberController.clear();
      complementController.clear();
      neighborhoodController.clear();
      cityController.clear();
      _selectedState = null;
      _cepError = null;
    });
  }

  // Método para consultar CEP automaticamente
  Future<void> _fetchAddressFromCep(String cep) async {
    // Remove formatação
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Verifica se tem 8 dígitos
    if (cleanCep.length != 8) {
      setState(() {
        _cepError = cleanCep.isNotEmpty ? 'CEP incompleto' : null;
      });
      return;
    }

    setState(() {
      _isLoadingCep = true;
      _cepError = null;
    });

    try {
      final address = await ViaCepService.fetchAddress(cep);
      
      if (address != null && address.isValid) {
        setState(() {
          // Preenche os campos automaticamente
          streetController.text = address.logradouro;
          complementController.text = address.complemento;
          neighborhoodController.text = address.bairro;
          cityController.text = address.localidade;
          _selectedState = address.uf;
          
          // Remove foco do campo CEP para evitar teclado
          FocusScope.of(context).requestFocus(FocusNode());
        });
        
        // Salva os dados automaticamente
        await _saveAddressData();
      } else if (address != null && !address.isValid) {
        setState(() {
          _cepError = 'CEP não encontrado';
        });
      } else {
        setState(() {
          _cepError = 'Erro ao buscar endereço';
        });
      }
    } catch (e) {
      setState(() {
        _cepError = 'Erro ao buscar CEP. Tente novamente.';
      });
    } finally {
      setState(() {
        _isLoadingCep = false;
      });
    }
  }

  // Método para lidar com digitação no campo CEP
  void _onCepChanged(String value) {
    // Cancela o timer anterior
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    
    // Limpa mensagens de erro
    if (_cepError != null) {
      setState(() {
        _cepError = null;
      });
    }
    
    // Configura novo timer para debounce
    _debounceTimer = Timer(Duration(milliseconds: _cepDebounceMs), () {
      final cleanCep = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanCep.length == 8) {
        _fetchAddressFromCep(value);
      } else if (cleanCep.isNotEmpty) {
        setState(() {
          _cepError = 'CEP incompleto';
        });
      }
    });
    
    // Salva dados imediatamente
    _saveAddressData();
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

                // Campo CEP com busca automática
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: cepController,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CepInputFormatter()
                      ],
                      labelText: 'CEP',
                      hintText: 'Digite seu CEP',
                      onChanged: _onCepChanged,
                    ),
                    if (_isLoadingCep)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                        child: Text(
                          'Buscando endereço...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                  ],
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
                if (_selectedState != null &&
                    !statesList.contains(_selectedState!))
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    cepController.dispose();
    streetController.dispose();
    numberController.dispose();
    complementController.dispose();
    neighborhoodController.dispose();
    cityController.dispose();
    super.dispose();
  }
}