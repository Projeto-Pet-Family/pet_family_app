import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // ✅ Use a URL do Render
  static const String baseUrl = 'https://bepetfamily.onrender.com';

  // Login do usuário
  static Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'senha': senha,
        }),
      );

      print('🔍 Status Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'usuario': data['usuario'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Erro desconhecido',
        };
      }
    } catch (error) {
      print('❌ Erro detalhado: $error');
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  // Solicitar recuperação de senha
  static Future<Map<String, dynamic>> solicitarRecuperacaoSenha({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/recuperar-senha'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      final data = jsonDecode(response.body);
      
      return {
        'success': data['success'] ?? false,
        'message': data['message'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  // Redefinir senha
  static Future<Map<String, dynamic>> redefinirSenha({
    required String token,
    required String novaSenha,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/redefinir-senha'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'token': token,
          'novaSenha': novaSenha,
        }),
      );

      final data = jsonDecode(response.body);
      
      return {
        'success': data['success'] ?? false,
        'message': data['message'],
      };
    } catch (error) {
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  // Testar conexão com o servidor
  static Future<bool> testarConexao() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Accept': 'application/json'},
      );
      
      print('🧪 Teste Conexão - Status: ${response.statusCode}');
      print('🧪 Teste Conexão - Body: ${response.body}');
      
      return response.statusCode == 200;
    } catch (error) {
      print('❌ Teste Conexão Falhou: $error');
      return false;
    }
  }
}