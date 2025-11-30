// presentation/providers/porte_provider.dart
import 'package:flutter/foundation.dart';
import 'package:pet_family_app/models/pet/porte_model.dart';
import 'package:pet_family_app/repository/pet/porte_repository.dart';

class PorteProvider with ChangeNotifier {
  final PorteRepository porteRepository;
  
  List<PorteModel> _portes = [];
  PorteModel? _porteSelecionado;
  bool _loading = false;
  String? _error;
  bool _success = false;

  PorteProvider({required this.porteRepository});

  // Getters
  List<PorteModel> get portes => _portes;
  PorteModel? get porteSelecionado => _porteSelecionado;
  bool get loading => _loading;
  String? get error => _error;
  bool get success => _success;

  // Listar portes
  Future<void> listarPortes() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _portes = await porteRepository.listarPortes();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _portes = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Criar porte
  Future<void> criarPorte(PorteModel porte) async {
    _loading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      final porteCriado = await porteRepository.criarPorte(porte);
      _portes.add(porteCriado);
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

  // Selecionar porte
  void selecionarPorte(PorteModel porte) {
    _porteSelecionado = porte;
    notifyListeners();
  }

  // Limpar seleção
  void limparSelecao() {
    _porteSelecionado = null;
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