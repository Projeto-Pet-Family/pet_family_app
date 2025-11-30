// data/datasources/porte_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/models/pet/porte_model.dart';

class PorteService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';
  final http.Client client;

  PorteService({required this.client});

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
      };

  void _handleError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Dados inválidos');
      case 404:
        throw Exception('Porte não encontrado');
      case 409:
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Porte já existe');
      case 500:
        throw Exception('Erro interno do servidor');
      default:
        throw Exception('Falha na comunicação com o servidor');
    }
  }

  Future<List<PorteModel>> listarPortes() async {
    final response = await client.get(
      Uri.parse('$baseUrl/porte'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PorteModel.fromJson(json)).toList();
    } else {
      _handleError(response);
      throw Exception('Erro ao listar portes');
    }
  }

  Future<PorteModel> criarPorte(PorteModel porte) async {
    final response = await client.post(
      Uri.parse('$baseUrl/porte'),
      headers: headers,
      body: json.encode(porte.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return PorteModel.fromJson(data['data']);
    } else {
      _handleError(response);
      throw Exception('Erro ao criar porte');
    }
  }

  Future<PorteModel> atualizarPorte(int idPorte, PorteModel porte) async {
    final response = await client.put(
      Uri.parse('$baseUrl/porte/$idPorte'),
      headers: headers,
      body: json.encode(porte.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PorteModel.fromJson(data['data']);
    } else {
      _handleError(response);
      throw Exception('Erro ao atualizar porte');
    }
  }

  Future<void> excluirPorte(int idPorte) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/porte/$idPorte'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      _handleError(response);
      throw Exception('Erro ao excluir porte');
    }
  }
}
