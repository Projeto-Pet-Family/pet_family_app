import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';

  static Future<Map<String, dynamic>> verificarEmail({
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

  static Future<Map<String, dynamic>> atualizarPerfil({
    required int idUsuario,
    required Map<String, dynamic> dadosAtualizados,
  }) async {
    try {
      print('🌐 Enviando atualização para API...');
      print('🌐 URL: $baseUrl/usuarios/$idUsuario');
      print('🌐 Dados: $dadosAtualizados');

      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/$idUsuario'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(dadosAtualizados),
      );

      print('🌐 Status Code: ${response.statusCode}');
      print('🌐 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'usuario': data, // A API deve retornar os dados atualizados
          'message': 'Perfil atualizado com sucesso!',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Usuário não encontrado',
        };
      } else {
        return {
          'success': false,
          'message': 'Erro ao atualizar perfil: ${response.statusCode}',
        };
      }
    } catch (error) {
      print('❌ Erro na chamada API: $error');
      return {
        'success': false,
        'message': 'Erro de conexão: $error',
      };
    }
  }
}
