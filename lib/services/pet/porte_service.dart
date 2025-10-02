import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/pet/porte_model.dart';

class PorteService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';

  final http.Client client;

  PorteService({required this.client});

  Future<List<Porte>> getPortes() async {
    final response = await client.get(Uri.parse('$baseUrl/porte'));
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Porte.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar portes');
    }
  }
}