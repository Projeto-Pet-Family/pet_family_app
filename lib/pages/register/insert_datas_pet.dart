import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Import dos services
import 'package:pet_family_app/services/pet/especie_service.dart';
import 'package:pet_family_app/services/pet/raca_service.dart';
import 'package:pet_family_app/services/pet/porte_service.dart';

// Import dos widgets
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_drop_down.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';

// Import dos models
import 'package:pet_family_app/models/pet/especie_model.dart';
import 'package:pet_family_app/models/pet/raca_model.dart';
import 'package:pet_family_app/models/pet/porte_model.dart';

class InsertDatasPet extends StatefulWidget {
  const InsertDatasPet({super.key});

  @override
  State<InsertDatasPet> createState() => _InsertDatasPetState();
}

class _InsertDatasPetState extends State<InsertDatasPet> {
  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController observationAnimalController = TextEditingController();

  // Valores selecionados
  String? _speciesAnimalsType, _raceAnimalType, _porteAnimalType, _sexAnimalType, _sexAnimalValue;
  int? _idEspecie, _idRaca, _idPorte;

  // Listas
  List<String> speciesAnimalsList = [];
  List<String> raceAnimalList = [];
  List<String> porteAnimalList = [];
  List<String> sexAnimalList = ['Macho', 'Fêmea'];

  // Estados de loading e erro
  bool _isLoadingSpecies = false, _isLoadingRacas = false, _isLoadingPortes = false;
  String? _errorMessageSpecies, _errorMessageRacas, _errorMessagePortes;

  // Services
  late EspecieService _especieService;
  late RacaService _racaService;
  late PorteService _porteService;

  // Chaves para SharedPreferences
  static const String _namePetKey = 'pet_name';
  static const String _speciesKey = 'pet_species';
  static const String _raceKey = 'pet_race';
  static const String _porteKey = 'pet_porte';
  static const String _sexKey = 'pet_sex';
  static const String _observationKey = 'pet_observation';
  static const String _idEspecieKey = 'pet_id_especie';
  static const String _idRacaKey = 'pet_id_raca';
  static const String _idPorteKey = 'pet_id_porte';

  // Listas de modelos completos (para ter acesso aos IDs)
  List<EspecieModel> _especiesCompletas = [];
  List<RacaModel> _racasCompletas = [];
  List<PorteModel> _portesCompletos = [];

  @override
  void initState() {
    super.initState();
    
    print('🚀 [InsertDatasPet] initState iniciado');
    
    // Inicializa os services
    final client = http.Client();
    _especieService = EspecieService(client: client);
    _racaService = RacaService(client: client);
    _porteService = PorteService(client: client);
    
    print('✅ [InsertDatasPet] Services inicializados');
    
    // Carrega dados salvos e faz chamadas à API
    _loadPetData().then((_) {
      print('📁 [InsertDatasPet] Dados locais carregados:');
      print('   - Nome: ${nameController.text}');
      print('   - Espécie: $_speciesAnimalsType (ID: $_idEspecie)');
      print('   - Raça: $_raceAnimalType (ID: $_idRaca)');
      print('   - Porte: $_porteAnimalType (ID: $_idPorte)');
      print('   - Sexo: $_sexAnimalType (Valor: $_sexAnimalValue)');
      
      _loadSpeciesFromService();
      _loadRacasFromService();
      _loadPortesFromService();
    });
  }

  // ========== CARREGAMENTO DE DADOS DA API ==========

  Future<void> _loadSpeciesFromService() async {
    print('🔄 [InsertDatasPet] Iniciando carregamento de espécies da API...');
    
    setState(() {
      _isLoadingSpecies = true;
      _errorMessageSpecies = null;
    });

    try {
      print('🌐 [InsertDatasPet] Chamando API de espécies...');
      print('   URL: ${EspecieService.baseUrl}/especie');
      
      final startTime = DateTime.now();
      final especies = await _especieService.listarEspecies();
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      print('✅ [InsertDatasPet] Resposta de espécies recebida em ${duration.inMilliseconds}ms');
      print('   Total de espécies: ${especies.length}');

      setState(() {
        if (especies.isNotEmpty) {
          _especiesCompletas = especies;
          speciesAnimalsList = especies.map((e) => e.descricao).toList();
          _errorMessageSpecies = null;
          
          print('📋 [InsertDatasPet] Lista de espécies atualizada:');
          for (var especie in especies.take(5)) { // Mostra apenas as 5 primeiras
            print('   - ${especie.idEspecie}: ${especie.descricao}');
          }
          if (especies.length > 5) {
            print('   ... e mais ${especies.length - 5} espécies');
          }
          
          // Se já tinha uma espécie selecionada, mantém o ID correspondente
          if (_speciesAnimalsType != null) {
            _idEspecie = _getIdFromEspecieName(_speciesAnimalsType!);
            print('🎯 [InsertDatasPet] Espécie mantida: $_speciesAnimalsType (ID: $_idEspecie)');
          }
        } else {
          print('⚠️ [InsertDatasPet] API retornou lista vazia de espécies');
          _setFallbackSpecies('Nenhuma espécie encontrada.');
        }
      });
    } on http.ClientException catch (e) {
      print('❌ [InsertDatasPet] ClientException ao carregar espécies: ${e.message}');
      _setFallbackSpecies('Erro de conexão: ${e.message}');
    } on FormatException catch (e) {
      print('❌ [InsertDatasPet] FormatException ao carregar espécies: $e');
      _setFallbackSpecies('Erro no formato da resposta: $e');
    } catch (e) {
      print('❌ [InsertDatasPet] Erro genérico ao carregar espécies: $e');
      print('   Tipo de erro: ${e.runtimeType}');
      _setFallbackSpecies('Erro ao carregar espécies: $e');
    } finally {
      print('🏁 [InsertDatasPet] Carregamento de espécies finalizado');
      setState(() {
        _isLoadingSpecies = false;
      });
    }
  }

  Future<void> _loadRacasFromService() async {
    print('🔄 [InsertDatasPet] Iniciando carregamento de raças da API...');
    
    setState(() {
      _isLoadingRacas = true;
      _errorMessageRacas = null;
    });

    try {
      print('🌐 [InsertDatasPet] Chamando API de raças...');
      print('   URL: ${RacaService.baseUrl}/raca');
      
      final startTime = DateTime.now();
      final racas = await _racaService.listarRacas();
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      print('✅ [InsertDatasPet] Resposta de raças recebida em ${duration.inMilliseconds}ms');
      print('   Total de raças: ${racas.length}');

      setState(() {
        if (racas.isNotEmpty) {
          _racasCompletas = racas;
          raceAnimalList = racas.map((r) => r.descricao).toList();
          _errorMessageRacas = null;
          
          print('📋 [InsertDatasPet] Lista de raças atualizada:');
          for (var raca in racas.take(5)) { // Mostra apenas as 5 primeiras
            print('   - ${raca.idRaca}: ${raca.descricao}');
          }
          if (racas.length > 5) {
            print('   ... e mais ${racas.length - 5} raças');
          }
          
          // Se já tinha uma raça selecionada, mantém o ID correspondente
          if (_raceAnimalType != null) {
            _idRaca = _getIdFromRacaName(_raceAnimalType!);
            print('🎯 [InsertDatasPet] Raça mantida: $_raceAnimalType (ID: $_idRaca)');
          }
        } else {
          print('⚠️ [InsertDatasPet] API retornou lista vazia de raças');
          _setFallbackRacas('Nenhuma raça encontrada.');
        }
      });
    } on http.ClientException catch (e) {
      print('❌ [InsertDatasPet] ClientException ao carregar raças: ${e.message}');
      _setFallbackRacas('Erro de conexão: ${e.message}');
    } catch (e) {
      print('❌ [InsertDatasPet] Erro genérico ao carregar raças: $e');
      print('   Tipo de erro: ${e.runtimeType}');
      _setFallbackRacas('Erro ao carregar raças: $e');
    } finally {
      print('🏁 [InsertDatasPet] Carregamento de raças finalizado');
      setState(() {
        _isLoadingRacas = false;
      });
    }
  }

  Future<void> _loadPortesFromService() async {
    print('🔄 [InsertDatasPet] Iniciando carregamento de portes da API...');
    
    setState(() {
      _isLoadingPortes = true;
      _errorMessagePortes = null;
    });

    try {
      print('🌐 [InsertDatasPet] Chamando API de portes...');
      print('   URL: ${PorteService.baseUrl}/porte');
      
      final startTime = DateTime.now();
      final portes = await _porteService.listarPortes();
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      print('✅ [InsertDatasPet] Resposta de portes recebida em ${duration.inMilliseconds}ms');
      print('   Total de portes: ${portes.length}');

      setState(() {
        if (portes.isNotEmpty) {
          _portesCompletos = portes;
          porteAnimalList = portes.map((p) => p.descricao).toList();
          _errorMessagePortes = null;
          
          print('📋 [InsertDatasPet] Lista de portes atualizada:');
          for (var porte in portes) {
            print('   - ${porte.idPorte}: ${porte.descricao}');
          }
          
          // Se já tinha um porte selecionado, mantém o ID correspondente
          if (_porteAnimalType != null) {
            _idPorte = _getIdFromPorteName(_porteAnimalType!);
            print('🎯 [InsertDatasPet] Porte mantido: $_porteAnimalType (ID: $_idPorte)');
          }
        } else {
          print('⚠️ [InsertDatasPet] API retornou lista vazia de portes');
          _setFallbackPortes('Nenhum porte encontrado.');
        }
      });
    } on http.ClientException catch (e) {
      print('❌ [InsertDatasPet] ClientException ao carregar portes: ${e.message}');
      _setFallbackPortes('Erro de conexão: ${e.message}');
    } catch (e) {
      print('❌ [InsertDatasPet] Erro genérico ao carregar portes: $e');
      print('   Tipo de erro: ${e.runtimeType}');
      _setFallbackPortes('Erro ao carregar portes: $e');
    } finally {
      print('🏁 [InsertDatasPet] Carregamento de portes finalizado');
      setState(() {
        _isLoadingPortes = false;
      });
    }
  }

  // ========== FALLBACKS ==========

  void _setFallbackSpecies(String error) {
    print('🛡️ [InsertDatasPet] Ativando fallback para espécies');
    print('   Motivo: $error');
    
    setState(() {
      _errorMessageSpecies = '$error Usando lista padrão.';
      speciesAnimalsList = ['Cachorro', 'Gato', 'Pássaro', 'Peixe'];
      
      // IDs padrão para fallback
      final defaultSpecies = [
        EspecieModel(idEspecie: 1, descricao: 'Cachorro'),
        EspecieModel(idEspecie: 2, descricao: 'Gato'),
        EspecieModel(idEspecie: 3, descricao: 'Pássaro'),
        EspecieModel(idEspecie: 4, descricao: 'Peixe'),
      ];
      _especiesCompletas = defaultSpecies;
      
      print('📋 [InsertDatasPet] Lista padrão de espécies definida:');
      print('   ${speciesAnimalsList.join(', ')}');
      
      // Ajusta seleção se necessário
      if (_speciesAnimalsType != null && 
          !speciesAnimalsList.contains(_speciesAnimalsType)) {
        print('⚠️ [InsertDatasPet] Espécie anterior "$_speciesAnimalsType" não está na lista padrão');
        print('   Resetando seleção de espécie');
        _speciesAnimalsType = null;
        _idEspecie = null;
      } else if (_speciesAnimalsType != null) {
        print('✅ [InsertDatasPet] Espécie "$_speciesAnimalsType" mantida na lista padrão');
      }
    });
  }

  void _setFallbackRacas(String error) {
    print('🛡️ [InsertDatasPet] Ativando fallback para raças');
    print('   Motivo: $error');
    
    setState(() {
      _errorMessageRacas = '$error Usando lista padrão.';
      raceAnimalList = ['Sem raça definida', 'Vira-lata', 'SRD'];
      
      // IDs padrão para fallback
      final defaultRacas = [
        RacaModel(idRaca: 1, descricao: 'Sem raça definida'),
        RacaModel(idRaca: 2, descricao: 'Vira-lata'),
        RacaModel(idRaca: 3, descricao: 'SRD'),
      ];
      _racasCompletas = defaultRacas;
      
      print('📋 [InsertDatasPet] Lista padrão de raças definida:');
      print('   ${raceAnimalList.join(', ')}');
      
      // Ajusta seleção se necessário
      if (_raceAnimalType != null && 
          !raceAnimalList.contains(_raceAnimalType)) {
        print('⚠️ [InsertDatasPet] Raça anterior "$_raceAnimalType" não está na lista padrão');
        print('   Resetando seleção de raça');
        _raceAnimalType = null;
        _idRaca = null;
      } else if (_raceAnimalType != null) {
        print('✅ [InsertDatasPet] Raça "$_raceAnimalType" mantida na lista padrão');
      }
    });
  }

  void _setFallbackPortes(String error) {
    print('🛡️ [InsertDatasPet] Ativando fallback para portes');
    print('   Motivo: $error');
    
    setState(() {
      _errorMessagePortes = '$error Usando lista padrão.';
      porteAnimalList = ['Pequeno', 'Médio', 'Grande'];
      
      // IDs padrão para fallback
      final defaultPortes = [
        PorteModel(idPorte: 1, descricao: 'Pequeno'),
        PorteModel(idPorte: 2, descricao: 'Médio'),
        PorteModel(idPorte: 3, descricao: 'Grande'),
      ];
      _portesCompletos = defaultPortes;
      
      print('📋 [InsertDatasPet] Lista padrão de portes definida:');
      print('   ${porteAnimalList.join(', ')}');
      
      // Ajusta seleção se necessário
      if (_porteAnimalType != null && 
          !porteAnimalList.contains(_porteAnimalType)) {
        print('⚠️ [InsertDatasPet] Porte anterior "$_porteAnimalType" não está na lista padrão');
        print('   Resetando seleção de porte');
        _porteAnimalType = null;
        _idPorte = null;
      } else if (_porteAnimalType != null) {
        print('✅ [InsertDatasPet] Porte "$_porteAnimalType" mantida na lista padrão');
      }
    });
  }

  // ========== MÉTODOS AUXILIARES ==========

  int? _getIdFromEspecieName(String especieNome) {
    for (var especie in _especiesCompletas) {
      if (especie.descricao == especieNome) {
        print('🔍 [InsertDatasPet] Encontrado ID $especie.idEspecie para espécie "$especieNome"');
        return especie.idEspecie;
      }
    }
    print('❓ [InsertDatasPet] ID não encontrado para espécie "$especieNome"');
    return null;
  }

  int? _getIdFromRacaName(String racaNome) {
    for (var raca in _racasCompletas) {
      if (raca.descricao == racaNome) {
        print('🔍 [InsertDatasPet] Encontrado ID ${raca.idRaca} para raça "$racaNome"');
        return raca.idRaca;
      }
    }
    print('❓ [InsertDatasPet] ID não encontrado para raça "$racaNome"');
    return null;
  }

  int? _getIdFromPorteName(String porteNome) {
    for (var porte in _portesCompletos) {
      if (porte.descricao == porteNome) {
        print('🔍 [InsertDatasPet] Encontrado ID ${porte.idPorte} para porte "$porteNome"');
        return porte.idPorte;
      }
    }
    print('❓ [InsertDatasPet] ID não encontrado para porte "$porteNome"');
    return null;
  }

  String? _convertSexToValue(String? sexDisplay) {
    final value = sexDisplay == 'Macho'
        ? 'm'
        : sexDisplay == 'Fêmea'
            ? 'f'
            : null;
    
    print('⚧️ [InsertDatasPet] Convertendo sexo "$sexDisplay" para valor "$value"');
    return value;
  }

  // ========== SHARED PREFERENCES ==========

  Future<void> _savePetData() async {
    print('💾 [InsertDatasPet] Iniciando salvamento de dados do pet...');
    
    final prefs = await SharedPreferences.getInstance();
    
    // Salva os valores
    await prefs.setString(_namePetKey, nameController.text);
    await prefs.setString(_speciesKey, _speciesAnimalsType ?? '');
    await prefs.setString(_raceKey, _raceAnimalType ?? '');
    await prefs.setString(_porteKey, _porteAnimalType ?? '');
    await prefs.setString(_sexKey, _sexAnimalValue ?? '');
    await prefs.setString(_observationKey, observationAnimalController.text);
    
    // Salva os IDs se existirem
    if (_idEspecie != null) {
      await prefs.setInt(_idEspecieKey, _idEspecie!);
    }
    if (_idRaca != null) {
      await prefs.setInt(_idRacaKey, _idRaca!);
    }
    if (_idPorte != null) {
      await prefs.setInt(_idPorteKey, _idPorte!);
    }
    
    print('✅ [InsertDatasPet] Dados salvos com sucesso:');
    print('   - Nome: ${nameController.text}');
    print('   - Espécie: $_speciesAnimalsType (ID: $_idEspecie)');
    print('   - Raça: $_raceAnimalType (ID: $_idRaca)');
    print('   - Porte: $_porteAnimalType (ID: $_idPorte)');
    print('   - Sexo: $_sexAnimalType (Valor: $_sexAnimalValue)');
    print('   - Observação: ${observationAnimalController.text}');
  }

  Future<void> _loadPetData() async {
    print('📂 [InsertDatasPet] Carregando dados salvos...');
    
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      // Carrega valores básicos
      nameController.text = prefs.getString(_namePetKey) ?? '';
      _speciesAnimalsType = _getValidPref(prefs, _speciesKey);
      _raceAnimalType = _getValidPref(prefs, _raceKey);
      _porteAnimalType = _getValidPref(prefs, _porteKey);
      _sexAnimalValue = prefs.getString(_sexKey);
      observationAnimalController.text = prefs.getString(_observationKey) ?? '';
      
      // Converte valor do sexo para display
      _sexAnimalType = _sexAnimalValue == 'm'
          ? 'Macho'
          : _sexAnimalValue == 'f'
              ? 'Fêmea'
              : null;
      
      // Carrega IDs
      _idEspecie = _getValidId(prefs, _idEspecieKey);
      _idRaca = _getValidId(prefs, _idRacaKey);
      _idPorte = _getValidId(prefs, _idPorteKey);
    });
    
    print('✅ [InsertDatasPet] Dados locais carregados');
  }

  String? _getValidPref(SharedPreferences prefs, String key) {
    final value = prefs.getString(key);
    final isValid = (value != null && value.isNotEmpty);
    
    if (!isValid) {
      print('   - $key: Valor inválido ou vazio');
    }
    
    return isValid ? value : null;
  }

  int? _getValidId(SharedPreferences prefs, String key) {
    final id = prefs.getInt(key);
    final isValid = (id != null && id > 0);
    
    if (!isValid) {
      print('   - $key: ID inválido ou zero');
    }
    
    return isValid ? id : null;
  }

  // ========== REFRESH ==========

  Future<void> _refreshAllData() async {
    print('🔄 [InsertDatasPet] Usuário solicitou refresh dos dados');
    print('=========================================');
    
    await _loadSpeciesFromService();
    await _loadRacasFromService();
    await _loadPortesFromService();
    
    print('✅ [InsertDatasPet] Refresh completo');
    print('=========================================');
  }

  // ========== VALIDAÇÃO ==========

  bool get _isFormValid {
    final isValid = nameController.text.isNotEmpty &&
        _speciesAnimalsType != null &&
        _raceAnimalType != null &&
        _porteAnimalType != null &&
        _sexAnimalType != null;
    
    print('✓ [InsertDatasPet] Validação do formulário: ${isValid ? "VÁLIDO" : "INVÁLIDO"}');
    if (!isValid) {
      print('   Campos faltando:');
      if (nameController.text.isEmpty) print('   - Nome do pet');
      if (_speciesAnimalsType == null) print('   - Espécie');
      if (_raceAnimalType == null) print('   - Raça');
      if (_porteAnimalType == null) print('   - Porte');
      if (_sexAnimalType == null) print('   - Sexo');
    }
    
    return isValid;
  }

  // ========== BUILD ==========

  @override
  Widget build(BuildContext context) {
    print('🏗️ [InsertDatasPet] Widget rebuildado');
    print('   - Espécies carregando: $_isLoadingSpecies');
    print('   - Raças carregando: $_isLoadingRacas');
    print('   - Portes carregando: $_isLoadingPortes');
    
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
                
                // Exibe erros se houver
                if (_errorMessageSpecies != null || 
                    _errorMessageRacas != null || 
                    _errorMessagePortes != null) 
                  _buildErrorSection(),
                
                const SizedBox(height: 30),
                
                // Nome do pet
                AppTextField(
                  controller: nameController,
                  labelText: 'Nome do pet',
                  hintText: 'Digite o nome do pet',
                  onChanged: (value) {
                    print('✏️ [InsertDatasPet] Nome alterado: $value');
                    setState(() {});
                    _savePetData();
                  },
                ),
                
                // Espécie
                _buildDropdownSection(
                  'Espécie',
                  _speciesAnimalsType,
                  speciesAnimalsList,
                  _isLoadingSpecies,
                  _errorMessageSpecies,
                  (newValue) {
                    print('🎯 [InsertDatasPet] Espécie selecionada: $newValue');
                    setState(() {
                      _speciesAnimalsType = newValue;
                      _idEspecie = _getIdFromEspecieName(newValue!);
                    });
                    _savePetData();
                  },
                ),
                
                // Raça
                _buildDropdownSection(
                  'Raça',
                  _raceAnimalType,
                  raceAnimalList,
                  _isLoadingRacas,
                  _errorMessageRacas,
                  (newValue) {
                    print('🎯 [InsertDatasPet] Raça selecionada: $newValue');
                    setState(() {
                      _raceAnimalType = newValue;
                      _idRaca = _getIdFromRacaName(newValue!);
                    });
                    _savePetData();
                  },
                ),
                
                // Porte
                _buildDropdownSection(
                  'Porte',
                  _porteAnimalType,
                  porteAnimalList,
                  _isLoadingPortes,
                  _errorMessagePortes,
                  (newValue) {
                    print('🎯 [InsertDatasPet] Porte selecionado: $newValue');
                    setState(() {
                      _porteAnimalType = newValue;
                      _idPorte = _getIdFromPorteName(newValue!);
                    });
                    _savePetData();
                  },
                ),
                
                // Sexo
                AppDropDown<String>(
                  value: _sexAnimalType,
                  items: sexAnimalList,
                  label: 'Sexo',
                  hint: 'Selecione o sexo',
                  onChanged: (newValue) {
                    print('⚧️ [InsertDatasPet] Sexo selecionado: $newValue');
                    setState(() {
                      _sexAnimalType = newValue;
                      _sexAnimalValue = _convertSexToValue(newValue);
                    });
                    _savePetData();
                  },
                  isRequired: true,
                  errorMessage: 'Por favor, selecione o sexo do pet',
                ),
                
                // Observações
                AppTextField(
                  controller: observationAnimalController,
                  labelText: 'Observações (opcional)',
                  hintText: 'Digite mais sobre seu pet',
                  onChanged: (value) {
                    print('📝 [InsertDatasPet] Observação alterada: $value');
                    _savePetData();
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Botão Próximo
                AppButton(
                  onPressed: _isFormValid
                      ? () async {
                          print('🚀 [InsertDatasPet] Botão "Próximo" pressionado');
                          print('   Navegando para /insert-your-datas');
                          
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

  // ========== WIDGETS AUXILIARES ==========

  Widget _buildErrorSection() {
    final errors = [
      if (_errorMessageSpecies != null) _errorMessageSpecies!,
      if (_errorMessageRacas != null) _errorMessageRacas!,
      if (_errorMessagePortes != null) _errorMessagePortes!,
    ];
    
    if (errors.isEmpty) return const SizedBox();
    
    print('⚠️ [InsertDatasPet] Exibindo seção de erros:');
    for (var error in errors) {
      print('   - $error');
    }
    
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[800]),
                  const SizedBox(width: 10),
                  Text(
                    'Atenção',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...errors.map((error) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $error',
                  style: TextStyle(color: Colors.orange[800]),
                ),
              )).toList(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      print('🔄 [InsertDatasPet] Botão "Tentar novamente" pressionado');
                      _refreshAllData();
                    },
                    icon: Icon(Icons.refresh, size: 18),
                    label: Text('Tentar novamente'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange[800],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownSection(
    String label,
    String? value,
    List<String> items,
    bool isLoading,
    String? errorMessage,
    Function(String?) onChanged,
  ) {
    print('📊 [InsertDatasPet] Build dropdown $label:');
    print('   - Valor atual: $value');
    print('   - Itens disponíveis: ${items.length}');
    print('   - Carregando: $isLoading');
    print('   - Tem erro: ${errorMessage != null}');
    
    if (isLoading) {
      return _buildLoadingDropdown('Carregando ${label.toLowerCase()}...');
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppDropDown<String>(
          value: value,
          items: items,
          label: label,
          hint: 'Selecione $label',
          onChanged: onChanged,
          isRequired: true,
          errorMessage: 'Por favor, selecione $label do pet',
        ),
        if (errorMessage != null && errorMessage.contains('Usando lista padrão'))
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              'Lista padrão carregada',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[800],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
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
    print('♻️ [InsertDatasPet] Widget sendo destruído');
    print('   - Limpando controllers');
    
    nameController.dispose();
    observationAnimalController.dispose();
    
    super.dispose();
  }
}