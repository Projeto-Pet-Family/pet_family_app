// presentation/providers/especie_provider.dart
import 'package:flutter/foundation.dart';
import 'package:pet_family_app/models/pet/especie_model.dart';
import 'package:pet_family_app/repository/pet/especie_repository.dart';

class EspecieProvider with ChangeNotifier {
  final EspecieRepository especieRepository;

  List<EspecieModel> _especies = [];
  EspecieModel? _especieSelecionada;
  bool _loading = false;
  String? _error;
  bool _success = false;

  EspecieProvider({required this.especieRepository});

  // Getters
  List<EspecieModel> get especies => _especies;
  EspecieModel? get especieSelecionada => _especieSelecionada;
  bool get loading => _loading;
  String? get error => _error;
  bool get success => _success;

  // Listar espécies
  Future<void> listarEspecies() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _especies = await especieRepository.listarEspecies();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _especies = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Buscar espécie por ID
  Future<void> buscarEspeciePorId(int idEspecie) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _especieSelecionada =
          await especieRepository.buscarEspeciePorId(idEspecie);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _especieSelecionada = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Criar espécie
  Future<void> criarEspecie(EspecieModel especie) async {
    _loading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      final especieCriada = await especieRepository.criarEspecie(especie);
      _especies.add(especieCriada);
      _success = true;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _success = false;
      notifyListeners();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Selecionar espécie
  void selecionarEspecie(EspecieModel especie) {
    _especieSelecionada = especie;
    notifyListeners();
  }

  // Limpar seleção
  void limparSelecao() {
    _especieSelecionada = null;
    notifyListeners();
  }

  // Limpar estados
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSuccess() {
    _success = false;
    notifyListeners();
  }
}
