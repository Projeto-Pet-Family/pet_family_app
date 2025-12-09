// data/datasources/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/models/user_model.dart';
import 'package:pet_family_app/services/secure_storage.dart';

class UserService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';
  final http.Client client;

  UserService({required this.client});

  // Headers comuns
  Map<String, String> get headers => {
        'Content-Type': 'application/json',
      };

  // Headers com autenticação
  Future<Map<String, String>> get headersComAuth async {
    final secureStorage = SecureStorage();
    final token = await secureStorage.getToken();
    print('🔑 Token obtido: ${token != null ? "SIM" : "NÃO"}');
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Tratamento de erros
  Map<String, dynamic> _handleError(http.Response response) {
    print('❌ Erro HTTP ${response.statusCode}');
    print('📦 Corpo do erro: ${response.body}');
    
    try {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Erro desconhecido';
      
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': errorMessage,
        'data': errorData,
      };
    } catch (e) {
      return {
        'success': false,
        'statusCode': response.statusCode,
        'message': 'Erro na comunicação com o servidor',
      };
    }
  }

  // ========== MÉTODOS DE USUÁRIO ==========

  // Criar usuário
  Future<Map<String, dynamic>> criarUsuario(UsuarioModel usuario) async {
    try {
      print('👤 Criando novo usuário: ${usuario.nome}');
      
      final response = await client.post(
        Uri.parse('$baseUrl/usuarios'),
        headers: headers,
        body: json.encode(usuario.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Usuário criado com sucesso');
        return {
          'success': true,
          'message': 'Usuário criado com sucesso',
          'data': data,
        };
      } else {
        return _handleError(response);
      }
    } catch (e) {
      print('❌ Exceção ao criar usuário: $e');
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Buscar usuário por ID
  Future<Map<String, dynamic>> buscarUsuarioPorId(int idUsuario) async {
    try {
      print('🔍 Buscando usuário ID: $idUsuario');
      
      final response = await client.get(
        Uri.parse('$baseUrl/usuarios/$idUsuario'),
        headers: await headersComAuth,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Usuário encontrado');
        
        return {
          'success': true,
          'data': data,
          'usuario': UsuarioModel.fromJson(data),
        };
      } else {
        return _handleError(response);
      }
    } catch (e) {
      print('❌ Exceção ao buscar usuário: $e');
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Atualizar perfil do usuário
  Future<Map<String, dynamic>> atualizarPerfil(int idUsuario, Map<String, dynamic> dados) async {
    try {
      print('🔄 Atualizando perfil do usuário ID: $idUsuario');
      print('📤 Dados para atualização: $dados');
      
      final authHeaders = await headersComAuth;
      print('📋 Headers de autenticação: $authHeaders');
      
      final response = await client.put(
        Uri.parse('$baseUrl/usuarios/$idUsuario'),
        headers: authHeaders,
        body: json.encode(dados),
      );

      print('📥 Resposta da API: ${response.statusCode}');
      print('📦 Corpo da resposta: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('✅ Perfil atualizado com sucesso!');
        
        // Processar diferentes formatos de resposta
        UsuarioModel? usuarioAtualizado;
        
        if (responseData.containsKey('data')) {
          // Formato: {"success": true, "message": "...", "data": {...}}
          final userData = responseData['data'];
          if (userData != null) {
            usuarioAtualizado = UsuarioModel.fromJson(userData);
          }
        } else if (responseData.containsKey('nome')) {
          // Formato direto do usuário
          usuarioAtualizado = UsuarioModel.fromJson(responseData);
        }
        
        return {
          'success': true,
          'message': responseData['message'] ?? 'Perfil atualizado com sucesso',
          'data': responseData,
          'usuario': usuarioAtualizado,
        };
      } else {
        return _handleError(response);
      }
    } catch (e) {
      print('❌ Exceção ao atualizar perfil: $e');
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Atualizar usuário completo
  Future<Map<String, dynamic>> atualizarUsuario(int idUsuario, UsuarioModel usuario) async {
    try {
      print('🔄 Atualizando usuário completo ID: $idUsuario');
      
      final authHeaders = await headersComAuth;
      
      final response = await client.put(
        Uri.parse('$baseUrl/usuarios/$idUsuario'),
        headers: authHeaders,
        body: json.encode(usuario.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Usuário atualizado com sucesso');
        
        return {
          'success': true,
          'message': 'Usuário atualizado com sucesso',
          'data': data,
          'usuario': UsuarioModel.fromJson(data['data'] ?? data),
        };
      } else {
        return _handleError(response);
      }
    } catch (e) {
      print('❌ Exceção ao atualizar usuário: $e');
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Buscar usuário atual
  Future<Map<String, dynamic>> buscarUsuarioAtual() async {
    try {
      print('🔍 Buscando dados do usuário atual');
      
      final authHeaders = await headersComAuth;
      
      // Tente diferentes endpoints possíveis
      final endpoints = [
        '$baseUrl/usuario/atual',
        '$baseUrl/usuarios/me',
        '$baseUrl/auth/me',
      ];
      
      http.Response? response;
      String? usedEndpoint;
      
      for (final endpoint in endpoints) {
        try {
          print('🔗 Tentando endpoint: $endpoint');
          response = await client.get(
            Uri.parse(endpoint),
            headers: authHeaders,
          );
          
          if (response.statusCode == 200) {
            usedEndpoint = endpoint;
            break;
          }
        } catch (e) {
          print('⚠️ Endpoint $endpoint falhou: $e');
          continue;
        }
      }
      
      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Dados do usuário atual carregados do endpoint: $usedEndpoint');
        
        return {
          'success': true,
          'data': data,
          'usuario': UsuarioModel.fromJson(data['data'] ?? data),
        };
      } else if (response != null) {
        return _handleError(response);
      } else {
        return {
          'success': false,
          'message': 'Nenhum endpoint funcionou',
        };
      }
    } catch (e) {
      print('❌ Exceção ao buscar usuário atual: $e');
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Listar todos os usuários
  Future<Map<String, dynamic>> listarUsuarios() async {
    try {
      print('📋 Listando todos os usuários');
      
      final response = await client.get(
        Uri.parse('$baseUrl/usuarios'),
        headers: await headersComAuth,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ ${data.length} usuários encontrados');
        
        return {
          'success': true,
          'data': data,
          'usuarios': data.map((json) => UsuarioModel.fromJson(json)).toList(),
        };
      } else {
        return _handleError(response);
      }
    } catch (e) {
      print('❌ Exceção ao listar usuários: $e');
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Excluir usuário
  Future<Map<String, dynamic>> excluirUsuario(int idUsuario) async {
    try {
      print('🗑️ Excluindo usuário ID: $idUsuario');
      
      final authHeaders = await headersComAuth;
      
      final response = await client.delete(
        Uri.parse('$baseUrl/usuarios/$idUsuario'),
        headers: authHeaders,
      );

      if (response.statusCode == 200) {
        print('✅ Usuário excluído com sucesso');
        return {
          'success': true,
          'message': 'Usuário excluído com sucesso',
        };
      } else {
        return _handleError(response);
      }
    } catch (e) {
      print('❌ Exceção ao excluir usuário: $e');
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Criar usuário com pet
  Future<Map<String, dynamic>> criarUsuarioComPet(
      UsuarioModel usuario, PetModel? petData) async {
    try {
      print('👤➕🐕 Criando usuário com pet');
      
      final payload = {
        ...usuario.toJson(),
        if (petData != null) 'petData': petData.toJson(),
      };

      final response = await client.post(
        Uri.parse('$baseUrl/usuarios'),
        headers: headers,
        body: json.encode(payload),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Usuário com pet criado com sucesso');
        
        return {
          'success': true,
          'message': 'Usuário criado com sucesso',
          'data': data,
        };
      } else {
        return _handleError(response);
      }
    } catch (e) {
      print('❌ Exceção ao criar usuário com pet: $e');
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }

  // Verificar se email existe
  Future<Map<String, dynamic>> verificarEmail(String email) async {
    try {
      print('📧 Verificando email: $email');
      
      final response = await client.post(
        Uri.parse('$baseUrl/usuarios/verificar-email'),
        headers: headers,
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final emailDisponivel = data['disponivel'] ?? true;
        
        return {
          'success': true,
          'disponivel': emailDisponivel,
          'message': emailDisponivel ? 'Email disponível' : 'Email já cadastrado',
        };
      } else {
        return _handleError(response);
      }
    } catch (e) {
      print('❌ Exceção ao verificar email: $e');
      return {
        'success': false,
        'disponivel': false,
        'message': 'Erro ao verificar email',
      };
    }
  }

  // Alterar senha
  Future<Map<String, dynamic>> alterarSenha(int idUsuario, String senhaAtual, String novaSenha) async {
    try {
      print('🔐 Alterando senha do usuário ID: $idUsuario');
      
      final authHeaders = await headersComAuth;
      
      final response = await client.put(
        Uri.parse('$baseUrl/usuarios/$idUsuario/senha'),
        headers: authHeaders,
        body: json.encode({
          'senhaAtual': senhaAtual,
          'novaSenha': novaSenha,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Senha alterada com sucesso');
        
        return {
          'success': true,
          'message': data['message'] ?? 'Senha alterada com sucesso',
          'data': data,
        };
      } else {
        return _handleError(response);
      }
    } catch (e) {
      print('❌ Exceção ao alterar senha: $e');
      return {
        'success': false,
        'message': 'Erro de conexão: $e',
      };
    }
  }
}