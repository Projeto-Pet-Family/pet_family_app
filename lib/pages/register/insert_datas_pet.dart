import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_drop_down.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importe os serviços
import '../../services/pet/especie_service.dart';
import '../../services/pet/raca_service.dart';
import '../../services/pet/porte_service.dart';

class InsertDatasPet extends StatefulWidget {
  const InsertDatasPet({super.key});

  @override
  State<InsertDatasPet> createState() => _InsertDatasPetState();
}

class _InsertDatasPetState extends State<InsertDatasPet> {
  TextEditingController nameController = TextEditingController();
  String? _speciesAnimalsType;
  String? _raceAnimalType;
  String? _porteAnimalType;
  String? _sexAnimalType; // Vai armazenar 'Macho' ou 'Fêmea'
  String? _sexAnimalValue; // Vai armazenar 'm' ou 'f'
  TextEditingController observationAnimalController = TextEditingController();

  // Para armazenar os IDs
  int? _idEspecie;
  int? _idRaca;
  int? _idPorte;

  List<String> speciesAnimalsList = [];
  List<String> raceAnimalList = [];
  List<String> porteAnimalList = [];
  List<String> sexAnimalList = ['Macho', 'Fêmea'];

  // Listas completas com objetos (para obter IDs)
  List<dynamic> especiesCompletas = [];
  List<dynamic> racasCompletas = [];
  List<dynamic> portesCompletos = [];

  bool _isLoadingSpecies = false;
  bool _isLoadingRacas = false;
  bool _isLoadingPortes = false;
  String? _errorMessage;

  // Chaves para o cache dos dados do formulário
  static const String _nameKey = 'pet_name';
  static const String _speciesKey = 'pet_species';
  static const String _raceKey = 'pet_race';
  static const String _porteKey = 'pet_porte';
  static const String _sexKey = 'pet_sex';
  static const String _observationKey = 'pet_observation';
  
  // Chaves para os IDs
  static const String _idEspecieKey = 'pet_id_especie';
  static const String _idRacaKey = 'pet_id_raca';
  static const String _idPorteKey = 'pet_id_porte';

  @override
  void initState() {
    super.initState();
    _loadPetData(); // Carrega dados do formulário
    _loadSpeciesFromAPI(); // Carrega espécies da API
    _loadRacasFromAPI(); // Carrega todas as raças da API
    _loadPortesFromAPI(); // Carrega todos os portes da API
  }

  // Carregar espécies da API
  Future<void> _loadSpeciesFromAPI() async {
    setState(() {
      _isLoadingSpecies = true;
      _errorMessage = null;
    });

    try {
      final especieService = EspecieService(client: http.Client());
      final especies = await especieService.getEspecies();

      setState(() {
        especiesCompletas = especies;
        speciesAnimalsList = especies.map((e) => e.descricao).toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar espécies: $e';
        // Lista fallback caso a API falhe
        speciesAnimalsList = ['Cachorro', 'Gato', 'Pássaro', 'Peixe'];
      });
    } finally {
      setState(() {
        _isLoadingSpecies = false;
      });
    }
  }

  // Carregar raças da API
  Future<void> _loadRacasFromAPI() async {
    setState(() {
      _isLoadingRacas = true;
    });

    try {
      final racaService = RacaService(client: http.Client());
      final racas = await racaService.getRacas();

      setState(() {
        racasCompletas = racas;
        raceAnimalList = racas.isNotEmpty 
          ? racas.map((r) => r.descricao).toList() 
          : ['Sem raça definida'];
      });
    } catch (e) {
      setState(() {
        raceAnimalList = ['Sem raça definida']; // Fallback
      });
    } finally {
      setState(() {
        _isLoadingRacas = false;
      });
    }
  }

  // Carregar portes da API
  Future<void> _loadPortesFromAPI() async {
    setState(() {
      _isLoadingPortes = true;
    });

    try {
      final porteService = PorteService(client: http.Client());
      final portes = await porteService.getPortes();

      setState(() {
        portesCompletos = portes;
        porteAnimalList = portes.isNotEmpty 
          ? portes.map((p) => p.descricao).toList() 
          : ['Pequeno', 'Médio', 'Grande'];
      });
    } catch (e) {
      setState(() {
        porteAnimalList = ['Pequeno', 'Médio', 'Grande']; // Fallback
      });
    } finally {
      setState(() {
        _isLoadingPortes = false;
      });
    }
  }

  // Obter ID da espécie selecionada
  int? _getIdEspecie(String? especieNome) {
    if (especieNome == null) return null;
    final especie = especiesCompletas.firstWhere(
      (e) => e.descricao == especieNome,
      orElse: () => null,
    );
    return especie?.id;
  }

  // Obter ID da raça selecionada
  int? _getIdRaca(String? racaNome) {
    if (racaNome == null) return null;
    final raca = racasCompletas.firstWhere(
      (r) => r.nome == racaNome,
      orElse: () => null,
    );
    return raca?.id;
  }

  // Obter ID do porte selecionado
  int? _getIdPorte(String? porteNome) {
    if (porteNome == null) return null;
    final porte = portesCompletos.firstWhere(
      (p) => p.descricao == porteNome,
      orElse: () => null,
    );
    return porte?.id;
  }

  // Converter sexo para 'm' ou 'f'
  String? _convertSexToValue(String? sexDisplay) {
    if (sexDisplay == 'Macho') return 'm';
    if (sexDisplay == 'Fêmea') return 'f';
    return null;
  }

  // Salvar dados do formulário no cache
  Future<void> _savePetData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_nameKey, nameController.text);
    await prefs.setString(_speciesKey, _speciesAnimalsType ?? '');
    await prefs.setString(_raceKey, _raceAnimalType ?? '');
    await prefs.setString(_porteKey, _porteAnimalType ?? '');
    await prefs.setString(_sexKey, _sexAnimalValue ?? ''); // Salva 'm' ou 'f'
    await prefs.setString(_observationKey, observationAnimalController.text);
    
    // Salvar os IDs
    await prefs.setInt(_idEspecieKey, _idEspecie ?? 0);
    await prefs.setInt(_idRacaKey, _idRaca ?? 0);
    await prefs.setInt(_idPorteKey, _idPorte ?? 0);
  }

  // Carregar dados do formulário do cache
  Future<void> _loadPetData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nameController.text = prefs.getString(_nameKey) ?? '';
      _speciesAnimalsType = prefs.getString(_speciesKey);
      if (_speciesAnimalsType != null && _speciesAnimalsType!.isEmpty) {
        _speciesAnimalsType = null;
      }
      _raceAnimalType = prefs.getString(_raceKey);
      if (_raceAnimalType != null && _raceAnimalType!.isEmpty) {
        _raceAnimalType = null;
      }
      _porteAnimalType = prefs.getString(_porteKey);
      if (_porteAnimalType != null && _porteAnimalType!.isEmpty) {
        _porteAnimalType = null;
      }

      // Carrega o valor salvo do sexo
      final savedSexValue = prefs.getString(_sexKey);
      _sexAnimalValue = savedSexValue;
      _sexAnimalType = savedSexValue == 'm' ? 'Macho' : 
                      savedSexValue == 'f' ? 'Fêmea' : null;

      observationAnimalController.text = prefs.getString(_observationKey) ?? '';
      
      // Carregar os IDs
      _idEspecie = prefs.getInt(_idEspecieKey);
      _idRaca = prefs.getInt(_idRacaKey);
      _idPorte = prefs.getInt(_idPorteKey);
    });
  }

  // Recarregar dados da API
  Future<void> _refreshData() async {
    await _loadSpeciesFromAPI();
    await _loadRacasFromAPI();
    await _loadPortesFromAPI();
  }

  bool get _isFormValid {
    return nameController.text.isNotEmpty &&
        _speciesAnimalsType != null &&
        _raceAnimalType != null &&
        _porteAnimalType != null &&
        _sexAnimalType != null;
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
                    'Insira os dados do pet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),

                // Mensagem de erro
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: _refreshData,
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                AppTextField(
                  controller: nameController,
                  labelText: 'Nome do pet',
                  hintText: 'Digite o nome do pet',
                  onChanged: (value) {
                    setState(() {});
                    _savePetData();
                  },
                ),

                // Dropdown de Espécie
                _isLoadingSpecies
                    ? _buildLoadingDropdown('Carregando espécies...')
                    : AppDropDown<String>(
                        value: _speciesAnimalsType,
                        items: speciesAnimalsList,
                        label: 'Espécie',
                        hint: 'Selecione a espécie',
                        onChanged: (newValue) {
                          setState(() {
                            _speciesAnimalsType = newValue;
                            _idEspecie = _getIdEspecie(newValue);
                          });
                          _savePetData();
                        },
                        isRequired: true,
                        errorMessage: 'Por favor, selecione a espécie do pet',
                      ),

                // Dropdown de Raça
                _isLoadingRacas
                    ? _buildLoadingDropdown('Carregando raças...')
                    : AppDropDown<String>(
                        value: _raceAnimalType,
                        items: raceAnimalList,
                        label: 'Raça',
                        hint: 'Selecione a raça',
                        onChanged: (newValue) {
                          setState(() {
                            _raceAnimalType = newValue;
                            _idRaca = _getIdRaca(newValue);
                          });
                          _savePetData();
                        },
                        isRequired: true,
                        errorMessage: 'Por favor, selecione a raça do pet',
                      ),

                // Dropdown de Porte
                _isLoadingPortes
                    ? _buildLoadingDropdown('Carregando portes...')
                    : AppDropDown<String>(
                        value: _porteAnimalType,
                        items: porteAnimalList,
                        label: 'Porte',
                        hint: 'Selecione o porte',
                        onChanged: (newValue) {
                          setState(() {
                            _porteAnimalType = newValue;
                            _idPorte = _getIdPorte(newValue);
                          });
                          _savePetData();
                        },
                        isRequired: true,
                        errorMessage: 'Por favor, selecione o porte do pet',
                      ),

                // Dropdown de Sexo
                AppDropDown<String>(
                  value: _sexAnimalType,
                  items: sexAnimalList,
                  label: 'Sexo',
                  hint: 'Selecione o sexo',
                  onChanged: (newValue) {
                    setState(() {
                      _sexAnimalType = newValue;
                      _sexAnimalValue = _convertSexToValue(newValue);
                    });
                    _savePetData();
                  },
                  isRequired: true,
                  errorMessage: 'Por favor, selecione o sexo do pet',
                ),

                // Display dos IDs salvos (opcional - para debug)
                // if (_idEspecie != null && _idRaca != null && _idPorte != null)
                //   Column(
                //     children: [
                //       Text('ID Espécie: $_idEspecie'),
                //       Text('ID Raça: $_idRaca'),
                //       Text('ID Porte: $_idPorte'),
                //     ],
                //   ),

                AppTextField(
                  controller: observationAnimalController,
                  labelText: 'Observações (opcional)',
                  hintText: 'Digite mais sobre seu pet',
                  onChanged: (value) {
                    _savePetData();
                  },
                ),

                const SizedBox(height: 30),

                AppButton(
                  onPressed: _isFormValid
                      ? () async {
                          // Antes de navegar, garantir que tudo está salvo
                          await _savePetData();

                          // Debug: mostrar os dados que serão salvos
                          print('Nome: ${nameController.text}');
                          print('Espécie: $_speciesAnimalsType (ID: $_idEspecie)');
                          print('Raça: $_raceAnimalType (ID: $_idRaca)');
                          print('Porte: $_porteAnimalType (ID: $_idPorte)');
                          print('Sexo (valor): $_sexAnimalValue');
                          print('Observações: ${observationAnimalController.text}');

                          context.go('/insert-your-datas');
                        }
                      : null,
                  label: 'Próximo',
                  fontSize: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingDropdown(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Text('Carregando...', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    observationAnimalController.dispose();
    super.dispose();
  }
}