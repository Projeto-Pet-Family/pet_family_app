// providers/pet_provider.dart
import 'package:flutter/foundation.dart';
import '../services/pet_service.dart';

class PetProvider with ChangeNotifier {
  List<dynamic> _pets = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<dynamic> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ✅ Carregar pets do usuário
  Future<bool> loadPetsByUsuario(int idUsuario) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await PetService.getPetsByUsuario(idUsuario);

      _isLoading = false;

      if (result['success'] == true) {
        _pets = result['pets'] ?? [];
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _pets = [];
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (error) {
      _isLoading = false;
      _pets = [];
      _errorMessage = 'Erro ao carregar pets: $error';
      notifyListeners();
      return false;
    }
  }

  // ✅ Limpar dados
  void clearPets() {
    _pets = [];
    _errorMessage = null;
    notifyListeners();
  }

  // ✅ Limpar erros
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}