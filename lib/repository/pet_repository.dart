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

      // Primeiro, vamos testar o endpoint /pets para ver todos os pets
      print('🔍 Testando endpoint /pets...');
      final response = await _api.get('/pet');

      print('🔍 Response completa: $response');
      print('🔍 Response data type: ${response.data.runtimeType}');
      print('🔍 Response data: ${response.data}');

      if (response.data is List) {
        final List<dynamic> jsonList = response.data as List;
        print('🔍 Número de pets retornados: ${jsonList.length}');

        // Converter cada item com tratamento de erro individual
        final List<PetModel> pets = [];

        for (int i = 0; i < jsonList.length; i++) {
          try {
            print('🔍 Convertendo pet $i: ${jsonList[i]}');
            final pet = PetModel.fromJson(jsonList[i]);

            // Filtrar pelo usuário logado
            if (pet.idusuario == idUsuario) {
              pets.add(pet);
              print('✅ Pet adicionado: ${pet.nome}');
            } else {
              print(
                  '❌ Pet ignorado (idUsuario diferente): ${pet.nome} (${pet.idusuario} vs $idUsuario)');
            }
          } catch (e) {
            print('❌ Erro ao converter pet $i: $e');
            print('📦 Dados problemáticos: ${jsonList[i]}');
            // Continua com os próximos pets em vez de falhar completamente
          }
        }

        print('✅ Pets do usuário $idUsuario: ${pets.length} encontrados');
        return pets;
      } else {
        print('❌ Response.data não é uma lista: ${response.data}');
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
