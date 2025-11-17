// lib/services/mensagem_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';

class MensagemService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';
  static const Duration timeoutDuration = Duration(seconds: 30);

  final http.Client client;

  MensagemService({required this.client});

  Future<List<MessageModel>> buscarConversa({
    required int idusuario1,
    required int idusuario2,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      print('🔍 Buscando conversa: $idusuario1 <-> $idusuario2');

      final response = await client
          .get(
            Uri.parse('$baseUrl/mensagem/$idusuario1/$idusuario2'),
          )
          .timeout(timeoutDuration);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        final mensagens =
            jsonData.map((json) => MessageModel.fromJson(json)).toList();
        print('✅ ${mensagens.length} mensagens carregadas');
        return mensagens;
      } else {
        throw Exception(
            'Falha ao carregar conversa: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Erro ao buscar conversa: $e');
      throw Exception('Erro ao buscar conversa: $e');
    }
  }

  Future<MessageModel> enviarMensagem(EnviarMensagemRequest request) async {
    try {
      print('📤 Enviando mensagem: ${request.toJson()}');

      final response = await client
          .post(
            Uri.parse('$baseUrl/mensagem'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(request.toJson()),
          )
          .timeout(timeoutDuration);

      print('📨 Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('data')) {
          return MessageModel.fromJson(responseData['data']);
        } else if (responseData.containsKey('mensagem')) {
          return MessageModel.fromJson(responseData);
        } else {
          return MessageModel.fromJson(responseData);
        }
      } else {
        throw Exception(
            'Falha ao enviar mensagem: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Erro ao enviar mensagem: $e');
      throw Exception('Erro ao enviar mensagem: $e');
    }
  }

  Future<MessageModel> marcarComoLida(int idmensagem) async {
    try {
      final response = await client
          .put(
            Uri.parse('$baseUrl/mensagem/$idmensagem/ler'),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data')) {
          return MessageModel.fromJson(responseData['data']);
        } else {
          return MessageModel.fromJson(responseData);
        }
      } else {
        throw Exception('Falha ao marcar como lida: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao marcar mensagem como lida: $e');
    }
  }
}
