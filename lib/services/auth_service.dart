import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pet_family_app/models/user_model.dart';

class AuthService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      
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

      print('🔐 Login - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(utf8.decode(response.bodyBytes));
        
        if (responseData['success'] == true) {
          final usuario = UsuarioModel.fromJson(responseData['usuario']);
          
          // ✅ SALVAR ID DO USUÁRIO NO ARMAZENAMENTO
          await _saveUsuarioId(usuario.idUsuario ?? 0);
          
          // Salvar token se existir
          if (responseData['token'] != null) {
            await _secureStorage.write(key: 'auth_token', value: responseData['token']);
          }
          
          // Salvar dados completos do usuário
          await _secureStorage.write(
            key: 'usuario_data', 
            value: json.encode(usuario.toJson())
          );
          
          print('✅ Login realizado - ID Usuário: ${usuario.idUsuario}');
          
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
      print('❌ Erro no login: $error');
      return {
        'success': false,
        'message': 'Erro: ${error.toString()}',
      };
    }
  }

  // ✅ MÉTODO PARA SALVAR ID DO USUÁRIO
  Future<void> _saveUsuarioId(int idUsuario) async {
    try {
      await _secureStorage.write(key: 'usuario_id', value: idUsuario.toString());
      print('💾 ID Usuário salvo: $idUsuario');
    } catch (error) {
      print('❌ Erro ao salvar ID usuário: $error');
    }
  }

  // ✅ MÉTODO PARA OBTER ID DO USUÁRIO DO CACHE
  Future<int?> getUserIdFromCache() async {
    try {
      final idString = await _secureStorage.read(key: 'usuario_id');
      if (idString != null) {
        final id = int.tryParse(idString);
        print('📖 ID Usuário lido do cache: $id');
        return id;
      }
      return null;
    } catch (error) {
      print('❌ Erro ao ler ID usuário do cache: $error');
      return null;
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
    print('🚪 Logout usuário');
    await _secureStorage.delete(key: 'auth_token');
    await _secureStorage.delete(key: 'usuario_data');
    await _secureStorage.delete(key: 'usuario_id');
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: 'auth_token');
    final userData = await _secureStorage.read(key: 'usuario_data');
    final usuarioId = await getUserIdFromCache();
    
    print('🔍 Verificando login - Token: ${token != null}, Dados: ${userData != null}, ID: $usuarioId');
    return token != null && userData != null && usuarioId != null;
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