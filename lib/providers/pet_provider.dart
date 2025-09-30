import 'package:flutter/foundation.dart';
import '../services/pet_service.dart';

class PetProvider with ChangeNotifier {
  List<dynamic> _pets = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<dynamic> get pets => _pets;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Buscar pets por usuário
  Future<void> buscarPetsPorUsuario(int usuarioId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final petsData = await PetService.buscarPetsPorUsuario(usuarioId);
      _pets = petsData;
      _errorMessage = '';
    } catch (error) {
      _errorMessage = error.toString();
      _pets = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Adicionar pet
  Future<bool> adicionarPet(Map<String, dynamic> petData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await PetService.adicionarPet(petData);
      
      _isLoading = false;
      
      if (result['success'] == true) {
        // Recarrega a lista de pets
        await buscarPetsPorUsuario(petData['idUsuario']);
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  // Atualizar pet
  Future<bool> atualizarPet(int petId, Map<String, dynamic> petData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await PetService.atualizarPet(petId, petData);
      
      _isLoading = false;
      
      if (result['success'] == true) {
        // Recarrega a lista de pets
        final usuarioId = petData['idUsuario'];
        if (usuarioId != null) {
          await buscarPetsPorUsuario(usuarioId);
        }
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  // Remover pet
  Future<bool> removerPet(int petId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await PetService.removerPet(petId);
      
      _isLoading = false;
      
      if (result['success'] == true) {
        // Remove o pet da lista local
        _pets.removeWhere((pet) => pet['idPet'] == petId);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (error) {
      _isLoading = false;
      _errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}