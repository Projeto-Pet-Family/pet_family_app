// services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class UserService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';

  final http.Client client;

  UserService({required this.client});

  /// Registra um novo usuário no sistema
  Future<void> registerUser(UserModel user) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/usuarios'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(user.toJson()),
      );

      if (response.statusCode == 201) {
        // Cadastro realizado com sucesso
        return;
      } else {
        // Tratamento de erros específicos
        final errorResponse = json.decode(response.body);
        final errorMessage = errorResponse['message'] ?? 'Erro desconhecido';
        
        switch (response.statusCode) {
          case 400:
            throw Exception('Dados inválidos: $errorMessage');
          case 409:
            throw Exception('Usuário já cadastrado: $errorMessage');
          case 500:
            throw Exception('Erro interno do servidor: $errorMessage');
          default:
            throw Exception('Erro ${response.statusCode}: $errorMessage');
        }
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Erro de conexão: $e');
    }
  }

  /// Busca um usuário por ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/usuario/$userId'),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        // Você precisaria criar um factory fromJson no UserModel para isso
        // return UserModel.fromJson(userData);
        return null; // Implemente conforme sua necessidade
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Erro ao buscar usuário: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}