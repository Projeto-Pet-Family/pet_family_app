import 'dart:convert';
import 'package:http/http.dart' as http;

class PetService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';

  // Buscar todos os pets de um usuário
  static Future<List<dynamic>> buscarPetsPorUsuario(int usuarioId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/pet/usuario/$usuarioId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['message']);
        }
      } else {
        throw Exception('Erro ao carregar pets: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Erro de conexão: $error');
    }
  }

  // Adicionar novo pet
  static Future<Map<String, dynamic>> adicionarPet(Map<String, dynamic> petData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/pet'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(petData),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'pet': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao adicionar pet',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Erro de conexão: $error',
      };
    }
  }

  // Atualizar pet
  static Future<Map<String, dynamic>> atualizarPet(int petId, Map<String, dynamic> petData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/pet/$petId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(petData),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'pet': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao atualizar pet',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Erro de conexão: $error',
      };
    }
  }

  // Remover pet
  static Future<Map<String, dynamic>> removerPet(int petId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/pet/$petId'),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro ao remover pet',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Erro de conexão: $error',
      };
    }
  }
}