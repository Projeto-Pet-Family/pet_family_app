import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/pet/raca_model.dart';

class RacaService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';

  final http.Client client;

  RacaService({required this.client});

  Future<List<Raca>> getRacas() async {
    final response = await client.get(Uri.parse('$baseUrl/raca'));

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Raca.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar raças');
    }
  }

}
