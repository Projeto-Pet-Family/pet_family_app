import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../services/pet/pet_service.dart';

class PetProvider with ChangeNotifier {
  List<dynamic> _pets = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Crie uma instância do PetService
  final PetService _petService = PetService(client: http.Client());

  List<dynamic> get pets => _pets;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Buscar pets por usuário
  Future<void> buscarPetsPorUsuario(int usuarioId) async {
    if (_isLoading) return; // Evita múltiplas chamadas simultâneas

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Use a instância _petService em vez do acesso estático
      final petsData = await _petService.buscarPetsPorUsuario(usuarioId);
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
      // Use a instância _petService
      final result = await _petService.adicionarPet(petData);

      if (result['success'] == true) {
        await Future.delayed(const Duration(milliseconds: 500));
        await buscarPetsPorUsuario(petData['idusuario']);
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
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
      // Use a instância _petService
      final result = await _petService.atualizarPet(petId, petData);

      if (result['success'] == true) {
        await Future.delayed(const Duration(milliseconds: 500));
        final usuarioId = petData['idusuario'];
        if (usuarioId != null) {
          await buscarPetsPorUsuario(usuarioId);
        }
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
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
      // Use a instância _petService
      final result = await _petService.removerPet(petId);

      if (result['success'] == true) {
        _pets.removeWhere((pet) => pet['idpet'] == petId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (error) {
      _errorMessage = error.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
