import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HotelService {
  static const String baseUrl = 'https://sua-api.com'; // Substitua pela URL real

  // Buscar serviços do hotel
  static Future<List<dynamic>> fetchServicos(int hotelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/servicos/$hotelId'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is List ? data : [];
      } else {
        throw HotelException(
          'Erro ao carregar serviços: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw HotelException('Erro de conexão: ${e.message}', 0);
    } on TimeoutException catch (_) {
      throw HotelException('Tempo limite excedido', 0);
    } catch (e) {
      throw HotelException('Erro inesperado: ${e.toString()}', 0);
    }
  }

  // Buscar funcionários do hotel (se necessário)
  static Future<List<dynamic>> fetchFuncionarios(int hotelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/funcionarios/$hotelId'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data is List ? data : [];
      } else {
        throw HotelException(
          'Erro ao carregar funcionários: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw HotelException('Erro ao carregar funcionários: ${e.toString()}', 0);
    }
  }

  // Buscar detalhes adicionais do hotel (se necessário)
  static Future<Map<String, dynamic>> fetchHotelDetalhes(int hotelId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/hoteis/$hotelId/detalhes'),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw HotelException(
          'Erro ao carregar detalhes do hotel: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      throw HotelException('Erro ao carregar detalhes: ${e.toString()}', 0);
    }
  }
}

// Exceção customizada para erros do hotel
class HotelException implements Exception {
  final String message;
  final int statusCode;

  const HotelException(this.message, this.statusCode);

  @override
  String toString() => message;
}