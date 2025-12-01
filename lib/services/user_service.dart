// data/datasources/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/models/user_model.dart';

class UserService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';
  final http.Client client;

  UserService({required this.client});

  // Headers comuns
  Map<String, String> get headers => {
        'Content-Type': 'application/json',
      };

  // Tratamento de erros
  void _handleError(http.Response response) {
    switch (response.statusCode) {
      case 409:
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'CPF ou email já cadastrado');
      case 404:
        throw Exception('Usuário não encontrado');
      case 500:
        throw Exception('Erro interno do servidor');
      default:
        throw Exception('Falha na comunicação com o servidor');
    }
  }

  // Criar usuário
  Future<Map<String, dynamic>> criarUsuario(UsuarioModel usuario) async {
    final response = await client.post(
      Uri.parse('$baseUrl/usuarios'),
      headers: headers,
      body: json.encode(usuario.toJson()),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      _handleError(response);
      throw Exception('Erro ao criar usuário');
    }
  }

  // Buscar usuário por ID
  Future<UsuarioModel> buscarUsuarioPorId(int idUsuario) async {
    final response = await client.get(
      Uri.parse('$baseUrl/usuarios/$idUsuario'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UsuarioModel.fromJson(data);
    } else {
      _handleError(response);
      throw Exception('Erro ao buscar usuário');
    }
  }

  // Listar todos os usuários
  Future<List<UsuarioModel>> listarUsuarios() async {
    final response = await client.get(
      Uri.parse('$baseUrl/usuarios'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => UsuarioModel.fromJson(json)).toList();
    } else {
      _handleError(response);
      throw Exception('Erro ao listar usuários');
    }
  }

  // Atualizar usuário
  Future<UsuarioModel> atualizarUsuario(
      int idUsuario, UsuarioModel usuario) async {
    final response = await client.put(
      Uri.parse('$baseUrl/usuarios/$idUsuario'),
      headers: headers,
      body: json.encode(usuario.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UsuarioModel.fromJson(data['data']);
    } else {
      _handleError(response);
      throw Exception('Erro ao atualizar usuário');
    }
  }

  // Excluir usuário
  Future<void> excluirUsuario(int idUsuario) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/usuarios/$idUsuario'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      _handleError(response);
      throw Exception('Erro ao excluir usuário');
    }
  }

  Future<Map<String, dynamic>> criarUsuarioComPet(
      UsuarioModel usuario, PetModel? petData) async {
    final payload = {
      ...usuario.toJson(),
      if (petData != null) 'petData': petData.toJson(),
    };

    final response = await client.post(
      Uri.parse('$baseUrl/usuarios'),
      headers: headers,
      body: json.encode(payload),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      _handleError(response);
      throw Exception('Erro ao criar usuário com pet');
    }
  }
}
