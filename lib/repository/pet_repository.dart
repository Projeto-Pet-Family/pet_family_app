import 'package:pet_family_app/services/api_service.dart';
import 'package:pet_family_app/models/pet_model.dart';

class PetRepository {
  final ApiService _api = ApiService();

  Future<List<PetModel>> lerPet() async {
    try {
      final response = await _api.get('/pet'); 

      if (response.data is List) {
        return (response.data as List)
            .map((json) => PetModel.fromJson(json))
            .toList();
      } else {
        return [PetModel.fromJson(response.data)];
      }
    } catch (e) {
      print('Erro no repositório: $e');
      throw Exception('Erro ao carregar pets: $e');
    }
  }

  Future<PetModel> criarPet(PetModel pet) async {
    try {
      final response = await _api.post('/pet', pet.toJson());
      return PetModel.fromJson(response.data);
    } catch (e) {
      print('Erro ao criar pet: $e');
      throw Exception('Erro ao criar pet: $e');
    }
  }

  Future<void> atualizarPet(PetModel pet) async {
    try {
      await _api.put('/pet/${pet.idPet}', pet.toJson());
    } catch (e) {
      print('Erro ao atualizar pet: $e');
      throw Exception('Erro ao atualizar pet: $e');
    }
  }

  Future<void> deletarPet(int id) async {
    try {
      await _api.delete('/pet/$id');
    } catch (e) {
      print('Erro ao deletar pet: $e');
      throw Exception('Erro ao deletar pet: $e');
    }
  }
}