import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';

  static Future<Map<String, dynamic>> verificarEmail({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/solicitar-recuperacao-senhaawsd'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      print('🔍 Verificar Email - Status: ${response.statusCode}');
      print('🔍 Verificar Email - Body: ${response.body}');

      final data = jsonDecode(response.body);

      return {
        'success': data['success'] ?? false,
        'message': data['message'],
      };
    } catch (error) {
      print('❌ Erro ao verificar email: $error');
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

  // ✅ REDEFINIR SENHA (usando redefinir-senha)
  static Future<Map<String, dynamic>> redefinirSenhaComEmail({
    required String email,
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
          'email': email,
          'novaSenha': novaSenha,
        }),
      );

      print('🔍 Redefinir Senha - Status: ${response.statusCode}');
      print('🔍 Redefinir Senha - Body: ${response.body}');

      final data = jsonDecode(response.body);

      return {
        'success': data['success'] ?? false,
        'message': data['message'],
      };
    } catch (error) {
      print('❌ Erro ao redefinir senha: $error');
      return {
        'success': false,
        'message': 'Erro de conexão com o servidor',
      };
    }
  }

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

  // Outros métodos mantidos para compatibilidade
  static Future<Map<String, dynamic>> solicitarRecuperacaoSenha({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/solicitar-recuperacao-senha'),
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
}