import 'package:pet_family_app/services/api_service.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/providers/auth_provider.dart';

class PetRepository {
  final ApiService _api = ApiService();

  Future<List<PetModel>> lerPet() async {
    try {
      final idUsuario = await AuthProvider.getUserIdFromCache();

      print('🔍 PetRepository - ID do usuário do cache: $idUsuario');

      if (idUsuario == null) {
        throw Exception('Usuário não autenticado. Faça login novamente.');
      }

      // Faz a requisição para a API
      print('🔍 Buscando pets do usuário $idUsuario...');
      final response = await _api.get('/usuario/$idUsuario/pets');

      print('🔍 Response completa: $response');
      print('🔍 Response data type: ${response.data.runtimeType}');
      print('🔍 Response data: ${response.data}');

      // A API retorna um Map, não uma List
      if (response.data is Map<String, dynamic>) {
        final Map<String, dynamic> responseData = response.data;

        // Verifica se a requisição foi bem-sucedida
        if (responseData['success'] == true) {
          // Acessa a lista de pets dentro da chave 'pets'
          final List<dynamic> petsData = responseData['pets'];
          print('🔍 Número de pets retornados: ${petsData.length}');

          // Converter cada item com tratamento de erro individual
          final List<PetModel> pets = [];

          for (int i = 0; i < petsData.length; i++) {
            try {
              print('🔍 Convertendo pet $i: ${petsData[i]}');
              final pet = PetModel.fromJson(petsData[i]);
              pets.add(pet);
              print('✅ Pet adicionado: ${pet.nome} (ID: ${pet.idpet})');
            } catch (e) {
              print('❌ Erro ao converter pet $i: $e');
              print('📦 Dados problemáticos: ${petsData[i]}');
              // Continua com os próximos pets em vez de falhar completamente
            }
          }

          print('✅ Pets do usuário $idUsuario: ${pets.length} encontrados');
          return pets;
        } else {
          final errorMessage = responseData['message'] ?? 'Erro desconhecido';
          print('❌ API retornou erro: $errorMessage');
          throw Exception('Erro na API: $errorMessage');
        }
      } else {
        print('❌ Response.data não é um Map: ${response.data.runtimeType}');
        return [];
      }
    } catch (e) {
      print('❌ Erro no repositório: $e');
      throw Exception('Erro ao carregar pets: $e');
    }
  }

  Future<PetModel> criarPet(PetModel pet) async {
    try {
      // Obter o ID do usuário do cache
      final idUsuario = await AuthProvider.getUserIdFromCache();

      if (idUsuario == null) {
        throw Exception('Usuário não autenticado. Faça login novamente.');
      }

      // Adicionar o idUsuario ao pet antes de criar usando copyWith
      final petComUsuario = pet.copyWith(idusuario: idUsuario);

      final response = await _api.post('/pet', petComUsuario.toJson());
      return PetModel.fromJson(response.data);
    } catch (e) {
      print('Erro ao criar pet: $e');
      throw Exception('Erro ao criar pet: $e');
    }
  }

  Future<void> atualizarPet(PetModel pet) async {
    try {
      // Verificar se o pet pertence ao usuário logado
      final idUsuario = await AuthProvider.getUserIdFromCache();

      if (idUsuario == null) {
        throw Exception('Usuário não autenticado. Faça login novamente.');
      }

      // Garantir que o pet mantém o idUsuario correto usando copyWith
      final petAtualizado = pet.copyWith(idusuario: idUsuario);

      await _api.put('/pet/${pet.idpet}', petAtualizado.toJson());
    } catch (e) {
      print('Erro ao atualizar pet: $e');
      throw Exception('Erro ao atualizar pet: $e');
    }
  }

  Future<void> deletarPet(int id) async {
    try {
      // Verificar se o usuário está autenticado antes de deletar
      final idUsuario = await AuthProvider.getUserIdFromCache();

      if (idUsuario == null) {
        throw Exception('Usuário não autenticado. Faça login novamente.');
      }

      await _api.delete('/pet/$id');
    } catch (e) {
      print('Erro ao deletar pet: $e');
      throw Exception('Erro ao deletar pet: $e');
    }
  }

  // Método adicional para buscar um pet específico por ID
  Future<PetModel> lerPetPorId(int idPet) async {
    try {
      final idUsuario = await AuthProvider.getUserIdFromCache();

      if (idUsuario == null) {
        throw Exception('Usuário não autenticado. Faça login novamente.');
      }

      final response = await _api.get('/pet/$idPet');
      return PetModel.fromJson(response.data);
    } catch (e) {
      print('Erro ao carregar pet: $e');
      throw Exception('Erro ao carregar pet: $e');
    }
  }

  // Método para verificar se o usuário é dono do pet
  Future<bool> isDonoDoPet(int idPet) async {
    try {
      final pets = await lerPet();
      return pets.any((pet) => pet.idpet == idPet);
    } catch (e) {
      print('Erro ao verificar dono do pet: $e');
      return false;
    }
  }
}
