import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/providers/pet/especie_provider.dart';
import 'package:pet_family_app/providers/pet/porte_provider.dart';
import 'package:pet_family_app/providers/pet/raca_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_drop_down.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';

class InsertDatasPet extends StatefulWidget {
  const InsertDatasPet({super.key});

  @override
  State<InsertDatasPet> createState() => _InsertDatasPetState();
}

class _InsertDatasPetState extends State<InsertDatasPet> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController observationAnimalController =
      TextEditingController();

  String? _speciesAnimalsType,
      _raceAnimalType,
      _porteAnimalType,
      _sexAnimalType,
      _sexAnimalValue;
  int? _idEspecie, _idRaca, _idPorte;

  List<String> speciesAnimalsList = [],
      raceAnimalList = [],
      porteAnimalList = [];
  List<String> sexAnimalList = ['Macho', 'Fêmea'];

  bool _isLoadingSpecies = false,
      _isLoadingRacas = false,
      _isLoadingPortes = false;
  String? _errorMessage;

  static const String _namePetKey = 'pet_name',
      _speciesKey = 'pet_species',
      _raceKey = 'pet_race';
  static const String _porteKey = 'pet_porte',
      _sexKey = 'pet_sex',
      _observationKey = 'pet_observation';
  static const String _idEspecieKey = 'pet_id_especie',
      _idRacaKey = 'pet_id_raca',
      _idPorteKey = 'pet_id_porte';

  @override
  void initState() {
    super.initState();
    _loadPetData();
    _loadSpeciesFromProvider();
    _loadRacasFromProvider();
    _loadPortesFromProvider();
  }

  Future<void> _loadSpeciesFromProvider() async {
    setState(() {
      _isLoadingSpecies = true;
      _errorMessage = null;
    });

    try {
      final especieProvider =
          Provider.of<EspecieProvider>(context, listen: false);
      await especieProvider.listarEspecies();

      if (especieProvider.error == null) {
        setState(() {
          speciesAnimalsList =
              especieProvider.especies.map((e) => e.descricao).toList();
        });
      } else {
        setState(() {
          _errorMessage = 'Erro ao carregar espécies: ${especieProvider.error}';
          speciesAnimalsList = ['Cachorro', 'Gato', 'Pássaro', 'Peixe'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar espécies: $e';
        speciesAnimalsList = ['Cachorro', 'Gato', 'Pássaro', 'Peixe'];
      });
    } finally {
      setState(() {
        _isLoadingSpecies = false;
      });
    }
  }

  Future<void> _loadRacasFromProvider() async {
    setState(() {
      _isLoadingRacas = true;
    });

    try {
      final racaProvider = Provider.of<RacaProvider>(context, listen: false);
      await racaProvider.listarRacas();

      if (racaProvider.error == null) {
        setState(() {
          raceAnimalList = racaProvider.racas.map((r) => r.descricao).toList();
        });
      } else {
        setState(() {
          raceAnimalList = ['Sem raça definida'];
        });
      }
    } catch (e) {
      setState(() {
        raceAnimalList = ['Sem raça definida'];
      });
    } finally {
      setState(() {
        _isLoadingRacas = false;
      });
    }
  }

  Future<void> _loadPortesFromProvider() async {
    setState(() {
      _isLoadingPortes = true;
    });

    try {
      final porteProvider = Provider.of<PorteProvider>(context, listen: false);
      await porteProvider.listarPortes();

      if (porteProvider.error == null) {
        setState(() {
          porteAnimalList =
              porteProvider.portes.map((p) => p.descricao).toList();
        });
      } else {
        setState(() {
          porteAnimalList = ['Pequeno', 'Médio', 'Grande'];
        });
      }
    } catch (e) {
      setState(() {
        porteAnimalList = ['Pequeno', 'Médio', 'Grande'];
      });
    } finally {
      setState(() {
        _isLoadingPortes = false;
      });
    }
  }

  int? _getIdEspecie(String? especieNome) {
    if (especieNome == null) return null;

    final especieProvider =
        Provider.of<EspecieProvider>(context, listen: false);
    for (final especie in especieProvider.especies) {
      if (especie.descricao == especieNome && especie.idEspecie != null) {
        return especie.idEspecie;
      }
    }
    return null;
  }

  int? _getIdRaca(String? racaNome) {
    if (racaNome == null) return null;

    final racaProvider = Provider.of<RacaProvider>(context, listen: false);
    for (final raca in racaProvider.racas) {
      if (raca.descricao == racaNome && raca.idRaca != null) {
        return raca.idRaca;
      }
    }
    return null;
  }

  int? _getIdPorte(String? porteNome) {
    if (porteNome == null) return null;

    final porteProvider = Provider.of<PorteProvider>(context, listen: false);
    for (final porte in porteProvider.portes) {
      if (porte.descricao == porteNome && porte.idPorte != null) {
        return porte.idPorte;
      }
    }
    return null;
  }

  String? _convertSexToValue(String? sexDisplay) => sexDisplay == 'Macho'
      ? 'm'
      : sexDisplay == 'Fêmea'
          ? 'f'
          : null;

  Future<void> _savePetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_namePetKey, nameController.text);
    await prefs.setString(_speciesKey, _speciesAnimalsType ?? '');
    await prefs.setString(_raceKey, _raceAnimalType ?? '');
    await prefs.setString(_porteKey, _porteAnimalType ?? '');
    await prefs.setString(_sexKey, _sexAnimalValue ?? '');
    await prefs.setString(_observationKey, observationAnimalController.text);

    if (_idEspecie != null) await prefs.setInt(_idEspecieKey, _idEspecie!);
    if (_idRaca != null) await prefs.setInt(_idRacaKey, _idRaca!);
    if (_idPorte != null) await prefs.setInt(_idPorteKey, _idPorte!);
  }

  Future<void> _loadPetData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString(_namePetKey) ?? '';
      _speciesAnimalsType = _getValidPref(prefs, _speciesKey);
      _raceAnimalType = _getValidPref(prefs, _raceKey);
      _porteAnimalType = _getValidPref(prefs, _porteKey);
      _sexAnimalValue = prefs.getString(_sexKey);
      _sexAnimalType = _sexAnimalValue == 'm'
          ? 'Macho'
          : _sexAnimalValue == 'f'
              ? 'Fêmea'
              : null;
      observationAnimalController.text = prefs.getString(_observationKey) ?? '';
      _idEspecie = _getValidId(prefs, _idEspecieKey);
      _idRaca = _getValidId(prefs, _idRacaKey);
      _idPorte = _getValidId(prefs, _idPorteKey);
    });
  }

  String? _getValidPref(SharedPreferences prefs, String key) {
    final value = prefs.getString(key);
    return (value != null && value.isNotEmpty) ? value : null;
  }

  int? _getValidId(SharedPreferences prefs, String key) {
    final id = prefs.getInt(key);
    return (id != null && id > 0) ? id : null;
  }

  Future<void> _refreshData() async {
    await _loadSpeciesFromProvider();
    await _loadRacasFromProvider();
    await _loadPortesFromProvider();
  }

  bool get _isFormValid =>
      nameController.text.isNotEmpty &&
      _speciesAnimalsType != null &&
      _raceAnimalType != null &&
      _porteAnimalType != null &&
      _sexAnimalType != null;

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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Insira os dados do pet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ),
                ),
                if (_errorMessage != null) _buildErrorSection(),
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
                _buildDropdownSection('Espécie', _speciesAnimalsType,
                    speciesAnimalsList, _isLoadingSpecies, (newValue) {
                  setState(() {
                    _speciesAnimalsType = newValue;
                    _idEspecie = _getIdEspecie(newValue);
                  });
                  _savePetData();
                }),
                _buildDropdownSection(
                    'Raça', _raceAnimalType, raceAnimalList, _isLoadingRacas,
                    (newValue) {
                  setState(() {
                    _raceAnimalType = newValue;
                    _idRaca = _getIdRaca(newValue);
                  });
                  _savePetData();
                }),
                _buildDropdownSection('Porte', _porteAnimalType,
                    porteAnimalList, _isLoadingPortes, (newValue) {
                  setState(() {
                    _porteAnimalType = newValue;
                    _idPorte = _getIdPorte(newValue);
                  });
                  _savePetData();
                }),
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
                AppTextField(
                  controller: observationAnimalController,
                  labelText: 'Observações (opcional)',
                  hintText: 'Digite mais sobre seu pet',
                  onChanged: (value) => _savePetData(),
                ),
                const SizedBox(height: 30),
                AppButton(
                  onPressed: _isFormValid
                      ? () async {
                          await _savePetData();
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

  Widget _buildErrorSection() => Column(
        children: [
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
                IconButton(icon: Icon(Icons.refresh), onPressed: _refreshData)
              ],
            ),
          ),
        ],
      );

  Widget _buildDropdownSection(String label, String? value, List<String> items,
      bool isLoading, Function(String?) onChanged) {
    return isLoading
        ? _buildLoadingDropdown('Carregando ${label.toLowerCase()}...')
        : AppDropDown<String>(
            value: value,
            items: items,
            label: label,
            hint: 'Selecione $label',
            onChanged: onChanged,
            isRequired: true,
            errorMessage: 'Por favor, selecione $label do pet');
  }

  Widget _buildLoadingDropdown(String text) => Column(
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
                Text('Carregando...', style: TextStyle(color: Colors.grey[600]))
              ],
            ),
          ),
          const SizedBox(height: 20)
        ],
      );

  @override
  void dispose() {
    nameController.dispose();
    observationAnimalController.dispose();
    super.dispose();
  }
}
