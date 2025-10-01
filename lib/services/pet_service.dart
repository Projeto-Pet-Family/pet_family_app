// services/pet_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PetService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';

  // ✅ Buscar pets do usuário
  static Future<Map<String, dynamic>> getPetsByUsuario(int idUsuario) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usuario/$idUsuario/pets'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('🔍 Buscar Pets - Status: ${response.statusCode}');
      print('🔍 Buscar Pets - Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'pets': data['pets'] ?? [],
          'message': data['message'] ?? 'Pets carregados com sucesso',
        };
      } else {
        return {
          'success': false,
          'pets': [],
          'message': data['message'] ?? 'Erro ao carregar pets',
        };
      }
    } catch (error) {
      print('❌ Erro ao buscar pets: $error');
      return {
        'success': false,
        'pets': [],
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  // ✅ Buscar pet por ID
  static Future<Map<String, dynamic>> getPetById(int idPet) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/pets/$idPet'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'pet': data['pet'],
          'message': data['message'] ?? 'Pet carregado com sucesso',
        };
      } else {
        return {
          'success': false,
          'pet': null,
          'message': data['message'] ?? 'Erro ao carregar pet',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'pet': null,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }
}