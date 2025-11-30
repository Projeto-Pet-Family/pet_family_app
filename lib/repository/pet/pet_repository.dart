import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/services/pet/pet_service.dart';

abstract class PetRepository {
  Future<Map<String, dynamic>> criarPet(PetModel pet);
  Future<PetModel> buscarPetPorId(int idPet);
  Future<List<PetModel>> listarPets();
  Future<List<PetModel>> listarPetsPorUsuario(int idUsuario);
  Future<PetModel> atualizarPet(int idPet, PetModel pet);
  Future<void> excluirPet(int idPet);
}

class PetRepositoryImpl implements PetRepository {
  final PetService petService;

  PetRepositoryImpl({required this.petService});

  @override
  Future<Map<String, dynamic>> criarPet(PetModel pet) async {
    try {
      return await petService.criarPet(pet);
    } catch (e) {
      throw Exception('Erro no repositório ao criar pet: ${e.toString()}');
    }
  }

  @override
  Future<PetModel> buscarPetPorId(int idPet) async {
    try {
      return await petService.buscarPetPorId(idPet);
    } catch (e) {
      throw Exception('Erro ao buscar pet: ${e.toString()}');
    }
  }

  @override
  Future<List<PetModel>> listarPets() async {
    try {
      return await petService.listarPets();
    } catch (e) {
      throw Exception('Erro ao listar pets: ${e.toString()}');
    }
  }

  @override
  Future<List<PetModel>> listarPetsPorUsuario(int idUsuario) async {
    try {
      print('Repositório: Buscando pets para usuário $idUsuario');
      final pets = await petService.listarPetsPorUsuario(idUsuario);
      print('Repositório: ${pets.length} pets encontrados');

      // Debug: verificar cada pet
      for (var i = 0; i < pets.length; i++) {
        final pet = pets[i];
        print('Pet $i - Nome: "${pet.nome}", Sexo: "${pet.sexo}"');
      }

      return pets;
    } catch (e, stackTrace) {
      print('ERRO NO REPOSITÓRIO: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Erro ao listar pets do usuário: ${e.toString()}');
    }
  }

  @override
  Future<PetModel> atualizarPet(int idPet, PetModel pet) async {
    try {
      return await petService.atualizarPet(idPet, pet);
    } catch (e) {
      throw Exception('Erro ao atualizar pet: ${e.toString()}');
    }
  }

  @override
  Future<void> excluirPet(int idPet) async {
    try {
      await petService.excluirPet(idPet);
    } catch (e) {
      throw Exception('Erro ao excluir pet: ${e.toString()}');
    }
  }
}
