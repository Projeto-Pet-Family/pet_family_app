import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/pet/especie_model.dart';

class EspecieService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';

  final http.Client client;

  EspecieService({required this.client});

  Future<List<Especie>> getEspecies() async {
    final response = await client.get(Uri.parse('$baseUrl/especie'));
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Especie.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar espécies');
    }
  }

}