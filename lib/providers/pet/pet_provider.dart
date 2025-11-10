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

  // Buscar pets por usuário - ajustado para String
  Future<void> buscarPetsPorUsuario(String usuarioId) async {
    if (_isLoading) return; // Evita múltiplas chamadas simultâneas

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final petsData = await _petService.buscarPetsPorUsuario(usuarioId);
      _pets = petsData;
      _errorMessage = '';
    } catch (error) {
      _errorMessage = error.toString();
      _pets = [];
      print('❌ Erro ao buscar pets: $error');
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
      final result = await _petService.adicionarPet(petData);

      if (result['success'] == true) {
        // Recarrega a lista de pets após adicionar
        final usuarioId = petData['idusuario'];
        if (usuarioId != null) {
          await buscarPetsPorUsuario(usuarioId.toString());
        }
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Erro ao adicionar pet';
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
      final result = await _petService.atualizarPet(petId, petData);

      if (result['success'] == true) {
        // Recarrega a lista de pets após atualizar
        final usuarioId = petData['idusuario'];
        if (usuarioId != null) {
          await buscarPetsPorUsuario(usuarioId.toString());
        }
        return true;
      } else {
        _errorMessage = result['message'] ?? 'Erro ao atualizar pet';
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
  Future<bool> removerPet(int petId, String usuarioId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _petService.removerPet(petId);

      if (result['success'] == true) {
        // Remove localmente e recarrega a lista
        _pets.removeWhere((pet) => pet['idpet'] == petId);

        // Recarrega a lista completa para garantir sincronização
        await buscarPetsPorUsuario(usuarioId);

        return true;
      } else {
        _errorMessage = result['message'] ?? 'Erro ao remover pet';
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

  // Buscar pet por ID
  Future<Map<String, dynamic>?> buscarPetPorId(int petId) async {
    try {
      final result = await _petService.buscarPetPorId(petId);

      if (result['success'] == true) {
        return result['pet'];
      } else {
        _errorMessage = 'Pet não encontrado';
        return null;
      }
    } catch (error) {
      _errorMessage = error.toString();
      return null;
    }
  }

  // Buscar raça por ID
  Future<Map<String, dynamic>?> buscarRacaPorId(int idRaca) async {
    try {
      return await _petService.buscarRacaPorId(idRaca);
    } catch (error) {
      _errorMessage = error.toString();
      return null;
    }
  }

  // Limpar erro
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Limpar lista de pets
  void clearPets() {
    _pets = [];
    notifyListeners();
  }

  // Buscar pet localmente por ID
  Map<String, dynamic>? getPetPorId(int petId) {
    try {
      return _pets.firstWhere(
        (pet) => pet['idpet'] == petId,
        orElse: () => null,
      );
    } catch (e) {
      return null;
    }
  }

  // Atualizar pet localmente (para otimização)
  void atualizarPetLocalmente(int petId, Map<String, dynamic> novosDados) {
    final index = _pets.indexWhere((pet) => pet['idpet'] == petId);
    if (index != -1) {
      _pets[index] = {..._pets[index], ...novosDados};
      notifyListeners();
    }
  }
}
