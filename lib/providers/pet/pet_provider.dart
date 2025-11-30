// presentation/providers/pet_provider.dart
import 'package:flutter/foundation.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/repository/pet/pet_repository.dart';

class PetProvider with ChangeNotifier {
  final PetRepository petRepository;

  List<PetModel> _pets = [];
  PetModel? _petSelecionado;
  bool _loading = false;
  String? _error;
  bool _success = false;

  PetProvider({required this.petRepository});

  // Getters
  List<PetModel> get pets => _pets;
  PetModel? get petSelecionado => _petSelecionado;
  bool get loading => _loading;
  String? get error => _error;
  bool get success => _success;

  // Criar pet
  Future<void> criarPet(PetModel pet) async {
    _loading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      final response = await petRepository.criarPet(pet);
      final petCriado = PetModel.fromJson(response['data']);

      _pets.add(petCriado);
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

  // Buscar pet por ID
  Future<void> buscarPetPorId(int idPet) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _petSelecionado = await petRepository.buscarPetPorId(idPet);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _petSelecionado = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Listar todos os pets
  Future<void> listarPets() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _pets = await petRepository.listarPets();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _pets = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Listar pets por usuário
  Future<void> listarPetsPorUsuario(int idUsuario) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _pets = await petRepository.listarPetsPorUsuario(idUsuario);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _pets = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Atualizar pet
  Future<void> atualizarPet(int idPet, PetModel pet) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final petAtualizado = await petRepository.atualizarPet(idPet, pet);

      // Atualiza na lista local
      final index = _pets.indexWhere((p) => p.idPet == idPet);
      if (index != -1) {
        _pets[index] = petAtualizado;
      }

      // Atualiza pet selecionado se for o mesmo
      if (_petSelecionado?.idPet == idPet) {
        _petSelecionado = petAtualizado;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Excluir pet
  Future<void> excluirPet(int idPet) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await petRepository.excluirPet(idPet);

      // Remove da lista local
      _pets.removeWhere((p) => p.idPet == idPet);

      // Limpa pet selecionado se for o mesmo
      if (_petSelecionado?.idPet == idPet) {
        _petSelecionado = null;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Selecionar pet
  void selecionarPet(PetModel pet) {
    _petSelecionado = pet;
    notifyListeners();
  }

  // Limpar seleção
  void limparSelecao() {
    _petSelecionado = null;
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
