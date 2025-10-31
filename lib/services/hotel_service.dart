import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HotelService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';

  // Buscar serviços do hotel - URL CORRIGIDA
  static Future<List<dynamic>> fetchServicos(int hotelId) async {
    try {
      print(
          '🌐 Fazendo requisição para: $baseUrl/hospedagens/$hotelId/servicos');

      final response = await http.get(
        Uri.parse('$baseUrl/hospedagens/$hotelId/servicos'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Serviços decodificados: $data');
        return data is List ? data : [];
      } else if (response.statusCode == 404) {
        throw HotelException(
          'Serviços não encontrados para este hotel',
          response.statusCode,
        );
      } else {
        throw HotelException(
          'Erro ao carregar serviços: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw HotelException('Erro de conexão: ${e.message}', 0);
    } on TimeoutException catch (_) {
      throw HotelException('Tempo limite excedido ao buscar serviços', 0);
    } on FormatException catch (e) {
      throw HotelException('Erro no formato dos dados: ${e.message}', 0);
    } catch (e) {
      throw HotelException('Erro inesperado: ${e.toString()}', 0);
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
