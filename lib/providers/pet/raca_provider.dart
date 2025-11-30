// presentation/providers/raca_provider.dart
import 'package:flutter/foundation.dart';
import 'package:pet_family_app/models/pet/raca_model.dart';
import 'package:pet_family_app/repository/pet/raca_repository.dart';

class RacaProvider with ChangeNotifier {
  final RacaRepository racaRepository;
  
  List<RacaModel> _racas = [];
  List<RacaModel> _racasPorEspecie = [];
  RacaModel? _racaSelecionada;
  bool _loading = false;
  String? _error;
  bool _success = false;

  RacaProvider({required this.racaRepository});

  // Getters
  List<RacaModel> get racas => _racas;
  List<RacaModel> get racasPorEspecie => _racasPorEspecie;
  RacaModel? get racaSelecionada => _racaSelecionada;
  bool get loading => _loading;
  String? get error => _error;
  bool get success => _success;

  // Listar todas as raças
  Future<void> listarRacas() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _racas = await racaRepository.listarRacas();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _racas = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Listar raças por espécie
  Future<void> listarRacasPorEspecie(int idEspecie) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _racasPorEspecie = await racaRepository.listarRacasPorEspecie(idEspecie);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _racasPorEspecie = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Criar raça
  Future<void> criarRaca(RacaModel raca) async {
    _loading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      final racaCriada = await racaRepository.criarRaca(raca);
      _racas.add(racaCriada);
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

  // Selecionar raça
  void selecionarRaca(RacaModel raca) {
    _racaSelecionada = raca;
    notifyListeners();
  }

  // Limpar seleção
  void limparSelecao() {
    _racaSelecionada = null;
    notifyListeners();
  }

  // Limpar raças por espécie
  void limparRacasPorEspecie() {
    _racasPorEspecie = [];
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