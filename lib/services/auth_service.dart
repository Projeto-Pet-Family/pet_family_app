import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/models/user_model.dart';

class AuthService {
  static const String baseUrl = 'http://seuservidor.com/api';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final url = Uri.parse('$baseUrl/autenticacao/login');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email.trim().toLowerCase(),
          'senha': senha,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
        
        if (responseData['success'] == true) {
          // Converter resposta para UsuarioModel
          final usuario = UsuarioModel.fromJson(responseData['usuario']);
          
          // Salvar token se existir
          if (responseData['token'] != null) {
            await _secureStorage.write(key: 'auth_token', value: responseData['token']);
          }
          
          // Salvar dados do usuário
          await _secureStorage.write(
            key: 'usuario_data', 
            value: json.encode(usuario.toJson())
          );
          
          return {
            'success': true,
            'message': responseData['message'],
            'usuario': usuario,
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Erro no login',
          };
        }
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erro na conexão',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Erro: ${error.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> alterarSenha(
    int idUsuario, 
    String senhaAtual, 
    String novaSenha
  ) async {
    try {
      final token = await _secureStorage.read(key: 'auth_token');
      final url = Uri.parse('$baseUrl/autenticacao/usuarios/$idUsuario/alterar-senha');
      
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'senhaAtual': senhaAtual,
          'novaSenha': novaSenha,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
        
        if (responseData['success'] == true) {
          // Atualizar dados do usuário se retornado
          if (responseData['usuario'] != null) {
            final usuario = UsuarioModel.fromJson(responseData['usuario']);
            await _secureStorage.write(
              key: 'usuario_data', 
              value: json.encode(usuario.toJson())
            );
          }
          
          return {
            'success': true,
            'message': responseData['message'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Erro ao alterar senha',
          };
        }
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erro na conexão',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Erro: ${error.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> solicitarRecuperacaoSenha(String email) async {
    try {
      final url = Uri.parse('$baseUrl/autenticacao/solicitar-recuperacao-senha');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email.trim().toLowerCase(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': responseData['success'] ?? false,
          'message': responseData['message'],
        };
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erro na conexão',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Erro: ${error.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> redefinirSenha(String email, String novaSenha) async {
    try {
      final url = Uri.parse('$baseUrl/autenticacao/redefinir-senha');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'email': email.trim().toLowerCase(),
          'novaSenha': novaSenha,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': responseData['success'] ?? false,
          'message': responseData['message'],
        };
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erro na conexão',
        };
      }
    } catch (error) {
      return {
        'success': false,
        'message': 'Erro: ${error.toString()}',
      };
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'usuario_data');
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'auth_token');
    final userData = await _secureStorage.read(key: 'usuario_data');
    return token != null && userData != null;
  }

  Future<UsuarioModel?> getCurrentUser() async {
    try {
      final userData = await _secureStorage.read(key: 'usuario_data');
      if (userData != null) {
        final Map<String, dynamic> userMap = json.decode(userData);
        return UsuarioModel.fromJson(userMap);
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }
}