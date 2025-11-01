import 'dart:convert';
import 'package:http/http.dart' as http;

class PetService {
  final http.Client client;

  PetService({required this.client});

  static const String baseUrl = 'https://bepetfamily.onrender.com';

  // Adicionar novo pet
  Future<Map<String, dynamic>> adicionarPet(
      Map<String, dynamic> petData) async {
    try {
      print('🔄 Tentando adicionar pet: $petData');

      final response = await client.post(
        Uri.parse('$baseUrl/pet'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(petData),
      );

      print('🔍 Adicionar Pet - Status: ${response.statusCode}');
      print('🔍 Adicionar Pet - Body: ${response.body}');

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
          'message': data['message'] ?? 'Erro ao adicionar pet',
        };
      }
    } catch (error) {
      print('❌ Erro ao adicionar pet: $error');
      return {
        'success': false,
        'message': 'Erro de conexão: $error',
      };
    }
  }

  // Método registerPet (alias para adicionarPet)
  Future<void> registerPet(Map<String, dynamic> petData) async {
    final result = await adicionarPet(petData);
    if (!result['success']) {
      throw Exception(result['message']);
    }
  }

  // Buscar pets por usuário
  Future<List<dynamic>> buscarPetsPorUsuario(int usuarioId) async {
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
}
