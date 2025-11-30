// data/datasources/especie_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/models/pet/especie_model.dart';

class EspecieService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';
  final http.Client client;

  EspecieService({required this.client});

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
      };

  void _handleError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Dados inválidos');
      case 404:
        throw Exception('Espécie não encontrada');
      case 409:
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Espécie já existe');
      case 500:
        throw Exception('Erro interno do servidor');
      default:
        throw Exception('Falha na comunicação com o servidor');
    }
  }

  Future<List<EspecieModel>> listarEspecies() async {
    final response = await client.get(
      Uri.parse('$baseUrl/especie'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => EspecieModel.fromJson(json)).toList();
    } else {
      _handleError(response);
      throw Exception('Erro ao listar espécies');
    }
  }

  Future<EspecieModel> buscarEspeciePorId(int idEspecie) async {
    final response = await client.get(
      Uri.parse('$baseUrl/especie/$idEspecie'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return EspecieModel.fromJson(data);
    } else {
      _handleError(response);
      throw Exception('Erro ao buscar espécie');
    }
  }

  Future<EspecieModel> criarEspecie(EspecieModel especie) async {
    final response = await client.post(
      Uri.parse('$baseUrl/especie'),
      headers: headers,
      body: json.encode(especie.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return EspecieModel.fromJson(data['data']);
    } else {
      _handleError(response);
      throw Exception('Erro ao criar espécie');
    }
  }

  Future<EspecieModel> atualizarEspecie(
      int idEspecie, EspecieModel especie) async {
    final response = await client.put(
      Uri.parse('$baseUrl/especie/$idEspecie'),
      headers: headers,
      body: json.encode(especie.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return EspecieModel.fromJson(data['data']);
    } else {
      _handleError(response);
      throw Exception('Erro ao atualizar espécie');
    }
  }

  Future<void> excluirEspecie(int idEspecie) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/especie/$idEspecie'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      _handleError(response);
      throw Exception('Erro ao excluir espécie');
    }
  }
}
