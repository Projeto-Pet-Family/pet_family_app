import 'dart:convert';
import 'package:http/http.dart' as http;

class MensagemService {
  final String baseUrl = 'https://bepetfamily.onrender.com';
  final String? token;

  MensagemService({this.token});

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> enviarMensagemMobile({
    required int idusuario,
    required int idhospedagem,
    required String mensagem,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/mensagem/mobile');
      final body = json.encode({
        'idusuario': idusuario,
        'idhospedagem': idhospedagem,
        'mensagem': mensagem,
      });

      print('📱 Enviando mensagem mobile para: $url');
      print('📱 Dados: $body');

      final response = await http.post(
        url,
        headers: _headers,
        body: body,
      );

      print('📱 Status code: ${response.statusCode}');
      print('📱 Response: ${response.body}');

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Falha ao enviar mensagem mobile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Erro no enviarMensagemMobile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> buscarConversaMobile({
    required int idusuario,
    required int idhospedagem,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final url = Uri.parse(
          '$baseUrl/mensagem/mobile/conversa/$idusuario/$idhospedagem?limit=$limit&offset=$offset');

      print('📱 Buscando conversa mobile: $url');

      final response = await http.get(
        url,
        headers: _headers,
      );

      print('📱 Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Falha ao buscar conversa mobile: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro no buscarConversaMobile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> listarConversasMobile({
    required int idusuario,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final url = Uri.parse(
          '$baseUrl/mensagem/mobile/conversas/$idusuario?limit=$limit&offset=$offset');

      print('📱 Listando conversas mobile: $url');

      final response = await http.get(
        url,
        headers: _headers,
      );

      print('📱 Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Falha ao listar conversas mobile: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro no listarConversasMobile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> contarNaoLidasMobile(int idusuario) async {
    try {
      final url = Uri.parse('$baseUrl/mensagem/mobile/nao-lidas/$idusuario');

      print('📱 Contando não lidas mobile: $url');

      final response = await http.get(
        url,
        headers: _headers,
      );

      print('📱 Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Falha ao contar mensagens não lidas mobile: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro no contarNaoLidasMobile: $e');
      rethrow;
    }
  }
}
