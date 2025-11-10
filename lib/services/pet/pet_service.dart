import 'dart:convert';
import 'package:http/http.dart' as http;

class PetService {
  final http.Client client;

  PetService({required this.client});

  static const String baseUrl = 'https://bepetfamily.onrender.com';

  // Método principal para criar pet
  Future<Map<String, dynamic>> criarPet(Map<String, dynamic> petData) async {
    try {
      print('🔄 Tentando criar pet: $petData');

      // Remove campos nulos ou vazios
      final dadosLimpos = Map<String, dynamic>.from(petData);
      dadosLimpos.removeWhere((key, value) => value == null || value == '');

      print('📦 Dados limpos para envio: $dadosLimpos');

      final response = await client.post(
        Uri.parse('$baseUrl/pet'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dadosLimpos),
      );

      print('🔍 Criar Pet - Status: ${response.statusCode}');
      print('🔍 Criar Pet - Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Pet criado com sucesso!',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao criar pet',
        };
      }
    } catch (error) {
      print('❌ Erro ao criar pet: $error');
      return {
        'success': false,
        'message': 'Erro de conexão: $error',
      };
    }
  }

  // Alias para criarPet (mantido para compatibilidade)
  Future<Map<String, dynamic>> adicionarPet(
      Map<String, dynamic> petData) async {
    return await criarPet(petData);
  }

  // Método registerPet (alias para criarPet)
  Future<void> registerPet(Map<String, dynamic> petData) async {
    final result = await criarPet(petData);
    if (!result['success']) {
      throw Exception(result['message']);
    }
  }

  // Buscar pets por usuário
  Future<List<dynamic>> buscarPetsPorUsuario(String usuarioId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/usuario/$usuarioId/pets'),
      );

      print('🔍 Buscar Pets - Status: ${response.statusCode}');
      print('🔍 Buscar Pets - Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['pets'] ?? [];
        } else {
          throw Exception(data['message'] ?? 'Erro ao buscar pets');
        }
      } else {
        throw Exception('Erro ao carregar pets: ${response.statusCode}');
      }
    } catch (error) {
      print('❌ Erro ao buscar pets: $error');
      throw Exception('Erro de conexão: $error');
    }
  }

  // Atualizar pet
  Future<Map<String, dynamic>> atualizarPet(
      int petId, Map<String, dynamic> petData) async {
    try {
      print('🔄 Tentando atualizar pet $petId: $petData');

      final response = await client.put(
        Uri.parse('$baseUrl/pet/$petId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(petData),
      );

      print('🔍 Atualizar Pet - Status: ${response.statusCode}');
      print('🔍 Atualizar Pet - Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Pet atualizado com sucesso!',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao atualizar pet',
        };
      }
    } catch (error) {
      print('❌ Erro ao atualizar pet: $error');
      return {
        'success': false,
        'message': 'Erro de conexão: $error',
      };
    }
  }

  // Remover pet
  Future<Map<String, dynamic>> removerPet(int petId) async {
    try {
      print('🔄 Tentando remover pet $petId');

      final response = await client.delete(
        Uri.parse('$baseUrl/pet/$petId'),
      );

      print('🔍 Remover Pet - Status: ${response.statusCode}');
      print('🔍 Remover Pet - Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Pet removido com sucesso!',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao remover pet',
        };
      }
    } catch (error) {
      print('❌ Erro ao remover pet: $error');
      return {
        'success': false,
        'message': 'Erro de conexão: $error',
      };
    }
  }

  // Buscar pet por ID
  Future<Map<String, dynamic>> buscarPetPorId(int petId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/pet/$petId'),
      );

      print('🔍 Buscar Pet por ID - Status: ${response.statusCode}');
      print('🔍 Buscar Pet por ID - Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'success': true,
            'pet': data['pet'],
          };
        } else {
          throw Exception(data['message'] ?? 'Erro ao buscar pet');
        }
      } else {
        throw Exception('Erro ao buscar pet: ${response.statusCode}');
      }
    } catch (error) {
      print('❌ Erro ao buscar pet por ID: $error');
      throw Exception('Erro de conexão: $error');
    }
  }

  // Buscar raça por ID
  Future<Map<String, dynamic>?> buscarRacaPorId(int idRaca) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/raca/$idRaca'),
        headers: {'Content-Type': 'application/json'},
      );

      print('🔍 Buscar Raça - Status: ${response.statusCode}');
      print('🔍 Buscar Raça - Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['raca'] != null) {
          return data['raca'];
        } else {
          return null;
        }
      } else {
        throw Exception('Erro ao buscar raça: ${response.statusCode}');
      }
    } catch (error) {
      print('❌ Erro ao buscar raça: $error');
      return null;
    }
  }

  // Método específico para criar pet durante o cadastro do usuário
  Future<Map<String, dynamic>> criarPetDuranteCadastro(
      Map<String, dynamic> petData) async {
    return await criarPet(petData);
  }
}
