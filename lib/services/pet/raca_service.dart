// data/datasources/raca_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/models/pet/raca_model.dart';

class RacaService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';
  final http.Client client;

  RacaService({required this.client});

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
      };

  void _handleError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Dados inválidos');
      case 404:
        throw Exception('Raça não encontrada');
      case 409:
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Raça já existe');
      case 500:
        throw Exception('Erro interno do servidor');
      default:
        throw Exception('Falha na comunicação com o servidor');
    }
  }

  Future<List<RacaModel>> listarRacas() async {
    final response = await client.get(
      Uri.parse('$baseUrl/raca'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => RacaModel.fromJson(json)).toList();
    } else {
      _handleError(response);
      throw Exception('Erro ao listar raças');
    }
  }

  Future<List<RacaModel>> listarRacasPorEspecie(int idEspecie) async {
    final response = await client.get(
      Uri.parse('$baseUrl/raca/especie/$idEspecie'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => RacaModel.fromJson(json)).toList();
    } else {
      _handleError(response);
      throw Exception('Erro ao listar raças por espécie');
    }
  }

  Future<RacaModel> criarRaca(RacaModel raca) async {
    final response = await client.post(
      Uri.parse('$baseUrl/raca'),
      headers: headers,
      body: json.encode(raca.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return RacaModel.fromJson(data['data']);
    } else {
      _handleError(response);
      throw Exception('Erro ao criar raça');
    }
  }

  Future<RacaModel> atualizarRaca(int idRaca, RacaModel raca) async {
    final response = await client.put(
      Uri.parse('$baseUrl/raca/$idRaca'),
      headers: headers,
      body: json.encode(raca.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return RacaModel.fromJson(data['data']);
    } else {
      _handleError(response);
      throw Exception('Erro ao atualizar raça');
    }
  }

  Future<void> excluirRaca(int idRaca) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/raca/$idRaca'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      _handleError(response);
      throw Exception('Erro ao excluir raça');
    }
  }
}
