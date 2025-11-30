// data/datasources/pet_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/models/pet/pet_model.dart';

class PetService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';
  final http.Client client;

  PetService({required this.client});

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
      };

  void _handleError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Dados inválidos');
      case 404:
        throw Exception('Pet não encontrado');
      case 500:
        throw Exception('Erro interno do servidor');
      default:
        throw Exception('Falha na comunicação com o servidor');
    }
  }

  // Criar pet
  Future<Map<String, dynamic>> criarPet(PetModel pet) async {
    final response = await client.post(
      Uri.parse('$baseUrl/pets'),
      headers: headers,
      body: json.encode(pet.toJson()),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      _handleError(response);
      throw Exception('Erro ao criar pet');
    }
  }

  // Buscar pet por ID
  Future<PetModel> buscarPetPorId(int idPet) async {
    final response = await client.get(
      Uri.parse('$baseUrl/pets/$idPet'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PetModel.fromJson(data);
    } else {
      _handleError(response);
      throw Exception('Erro ao buscar pet');
    }
  }

  // Listar todos os pets
  Future<List<PetModel>> listarPets() async {
    final response = await client.get(
      Uri.parse('$baseUrl/pets'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PetModel.fromJson(json)).toList();
    } else {
      _handleError(response);
      throw Exception('Erro ao listar pets');
    }
  }

  // Listar pets por usuário
  Future<List<PetModel>> listarPetsPorUsuario(int idUsuario) async {
    final response = await client.get(
      Uri.parse('$baseUrl/usuario/$idUsuario/pets'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> petsData = data['pets'];

      print('🔍 DEBUG - Resposta da API:');
      print('URL: $baseUrl/usuario/$idUsuario/pets');
      print('Status: ${response.statusCode}');
      print('Dados brutos: $data');

      // Debug detalhado de cada pet
      for (var i = 0; i < petsData.length; i++) {
        print('🐕 Pet $i da API:');
        print('   - idpet: ${petsData[i]['idpet']}');
        print('   - nome: ${petsData[i]['nome']}');
        print('   - sexo: ${petsData[i]['sexo']}');
        print('   - idespecie: ${petsData[i]['idespecie']}');
        print('   - idraca: ${petsData[i]['idraca']}');
        print('   - idporte: ${petsData[i]['idporte']}');
        print('   - descricaoespecie: ${petsData[i]['descricaoespecie']}');
        print('   - descricaoraca: ${petsData[i]['descricaoraca']}');
        print('   - descricaoporte: ${petsData[i]['descricaoporte']}');
      }

      return petsData.map((json) => PetModel.fromJson(json)).toList();
    } else {
      _handleError(response);
      throw Exception('Erro ao listar pets do usuário petservice');
    }
  }

  // Atualizar pet
  Future<PetModel> atualizarPet(int idPet, PetModel pet) async {
    final response = await client.put(
      Uri.parse('$baseUrl/pet/$idPet'),
      headers: headers,
      body: json.encode(pet.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PetModel.fromJson(data['data']);
    } else {
      _handleError(response);
      throw Exception('Erro ao atualizar pet');
    }
  }

  // Excluir pet
  Future<void> excluirPet(int idPet) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/pet/$idPet'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      _handleError(response);
      throw Exception('Erro ao excluir pet');
    }
  }
}
