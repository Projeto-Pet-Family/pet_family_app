import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/hospedagem_model.dart';

class HospedagemService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<Map<String, String>> getHeaders() async {
    final token = await _secureStorage.read(key: 'auth_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET - Listar todas as hospedagens
  Future<List<HospedagemModel>> getHospedagens() async {
    try {
      final headers = await getHeaders();
      final url = Uri.parse('$baseUrl/hospedagens');
      
      final response = await http.get(url, headers: headers);

      print('🔍 GET Hospedagens - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ ${data.length} hospedagens carregadas');
        
        return data.map((json) {
          print('🔍 Processando hospedagem: ${json['nome']}');
          return HospedagemModel.fromJson(json);
        }).toList();
      } else {
        throw Exception('Falha ao carregar hospedagens: ${response.statusCode}');
      }
    } catch (error) {
      print('❌ Erro no getHospedagens: $error');
      throw Exception('Erro: ${error.toString()}');
    }
  }

  // GET - Buscar hospedagem por ID
  Future<HospedagemModel> getHospedagemById(int idHospedagem) async {
    try {
      final headers = await getHeaders();
      final url = Uri.parse('$baseUrl/hospedagem/hospedagens/$idHospedagem');
      
      final response = await http.get(url, headers: headers);

      print('🔍 GET Hospedagem por ID - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Hospedagem encontrada: ${data['nome']}');
        return HospedagemModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Hospedagem não encontrada');
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['message'] ?? 'Erro ao buscar hospedagem');
      }
    } catch (error) {
      print('❌ Erro no getHospedagemById: $error');
      throw Exception('Erro: ${error.toString()}');
    }
  }

  // POST - Criar nova hospedagem
  Future<Map<String, dynamic>> createHospedagem(HospedagemModel hospedagem) async {
    try {
      final headers = await getHeaders();
      final url = Uri.parse('$baseUrl/hospedagem/hospedagens');
      
      final dadosParaEnviar = {
        'nome': hospedagem.nome,
        'idendereco': hospedagem.idEndereco,
        'valor_diaria': hospedagem.valorDiaria,
        'email': '',
        'senha': '',
        'telefone': '',
        'cnpj': '',
      };
      
      print('📤 POST Criar Hospedagem - Dados: $dadosParaEnviar');
      
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(dadosParaEnviar),
      );

      print('📥 POST Criar Hospedagem - Status: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Hospedagem criada com sucesso');
        
        // ✅ SALVAR ID DA HOSPEDAGEM NO ARMAZENAMENTO
        final hospedagemCriada = HospedagemModel.fromJson(data['data'] ?? data);
        await _saveHospedagemId(hospedagemCriada.idHospedagem);
        
        return {
          'success': true,
          'message': data['message'],
          'hospedagem': hospedagemCriada,
        };
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        print('❌ Erro ao criar hospedagem: ${errorData['message']}');
        
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erro ao criar hospedagem',
        };
      }
    } catch (error) {
      print('❌ Erro no createHospedagem: $error');
      return {
        'success': false,
        'message': 'Erro: ${error.toString()}',
      };
    }
  }

  // PUT - Atualizar hospedagem
  Future<Map<String, dynamic>> updateHospedagem(int idHospedagem, HospedagemModel hospedagem) async {
    try {
      final headers = await getHeaders();
      final url = Uri.parse('$baseUrl/hospedagem/hospedagens/$idHospedagem');
      
      final dadosParaEnviar = {
        if (hospedagem.nome.isNotEmpty) 'nome': hospedagem.nome,
        if (hospedagem.valorDiaria > 0) 'valor_diaria': hospedagem.valorDiaria,
        'idEndereco': hospedagem.idEndereco,
      };
      
      print('📤 PUT Atualizar Hospedagem - Dados: $dadosParaEnviar');
      
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(dadosParaEnviar),
      );

      print('📥 PUT Atualizar Hospedagem - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Hospedagem atualizada com sucesso');
        
        // ✅ ATUALIZAR ID DA HOSPEDAGEM NO ARMAZENAMENTO
        await _saveHospedagemId(idHospedagem);
        
        return {
          'success': true,
          'message': data['message'],
          'hospedagem': HospedagemModel.fromJson(data['data'] ?? data),
        };
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        print('❌ Erro ao atualizar hospedagem: ${errorData['message']}');
        
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erro ao atualizar hospedagem',
        };
      }
    } catch (error) {
      print('❌ Erro no updateHospedagem: $error');
      return {
        'success': false,
        'message': 'Erro: ${error.toString()}',
      };
    }
  }

  // DELETE - Excluir hospedagem
  Future<Map<String, dynamic>> deleteHospedagem(int idHospedagem) async {
    try {
      final headers = await getHeaders();
      final url = Uri.parse('$baseUrl/hospedagem/hospedagens/$idHospedagem');
      
      print('🗑️ DELETE Hospedagem - ID: $idHospedagem');
      
      final response = await http.delete(url, headers: headers);

      print('📥 DELETE Hospedagem - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Hospedagem excluída com sucesso');
        
        // ✅ REMOVER ID DA HOSPEDAGEM DO ARMAZENAMENTO SE FOR A MESMA
        final currentId = await getHospedagemIdFromCache();
        if (currentId == idHospedagem) {
          await _removeHospedagemId();
        }
        
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        print('❌ Erro ao excluir hospedagem: ${errorData['message']}');
        
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erro ao excluir hospedagem',
        };
      }
    } catch (error) {
      print('❌ Erro no deleteHospedagem: $error');
      return {
        'success': false,
        'message': 'Erro: ${error.toString()}',
      };
    }
  }

  // POST - Login de hospedagem
  Future<Map<String, dynamic>> loginHospedagem(String email, String senha) async {
    try {
      final url = Uri.parse('$baseUrl/hospedagem/hospedagens/login');
      
      print('🔐 Login Hospedagem - Email: $email');
      
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

      print('📥 Login Hospedagem - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        
        if (data['message'] == 'Login realizado com sucesso' || data['success'] == true) {
          final hospedagem = HospedagemModel.fromJson(data['data'] ?? data);
          
          // ✅ SALVAR ID DA HOSPEDAGEM NO ARMAZENAMENTO
          await _saveHospedagemId(hospedagem.idHospedagem);
          
          await _secureStorage.write(
            key: 'hospedagem_data', 
            value: json.encode(hospedagem.toJson())
          );
          
          print('✅ Login realizado com sucesso - ID Hospedagem: ${hospedagem.idHospedagem}');
          
          return {
            'success': true,
            'message': data['message'],
            'hospedagem': hospedagem,
          };
        } else {
          print('❌ Login falhou: ${data['message']}');
          return {
            'success': false,
            'message': data['message'],
          };
        }
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        print('❌ Erro no login: ${errorData['message']}');
        
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erro no login',
        };
      }
    } catch (error) {
      print('❌ Erro no loginHospedagem: $error');
      return {
        'success': false,
        'message': 'Erro: ${error.toString()}',
      };
    }
  }

  // PUT - Alterar senha da hospedagem
  Future<Map<String, dynamic>> alterarSenhaHospedagem(
    int idHospedagem, 
    String senhaAtual, 
    String novaSenha
  ) async {
    try {
      final headers = await getHeaders();
      final url = Uri.parse('$baseUrl/hospedagem/hospedagens/$idHospedagem/senha');
      
      print('🔐 Alterar Senha - ID Hospedagem: $idHospedagem');
      
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode({
          'senhaAtual': senhaAtual,
          'novaSenha': novaSenha,
        }),
      );

      print('📥 Alterar Senha - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        print('✅ Senha alterada com sucesso');
        
        return {
          'success': true,
          'message': data['message'],
        };
      } else {
        final errorData = json.decode(utf8.decode(response.bodyBytes));
        print('❌ Erro ao alterar senha: ${errorData['message']}');
        
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erro ao alterar senha',
        };
      }
    } catch (error) {
      print('❌ Erro no alterarSenhaHospedagem: $error');
      return {
        'success': false,
        'message': 'Erro: ${error.toString()}',
      };
    }
  }

  // ✅ MÉTODO PARA SALVAR ID DA HOSPEDAGEM
  Future<void> _saveHospedagemId(int idHospedagem) async {
    try {
      await _secureStorage.write(key: 'hospedagem_id', value: idHospedagem.toString());
      print('💾 ID Hospedagem salvo: $idHospedagem');
    } catch (error) {
      print('❌ Erro ao salvar ID hospedagem: $error');
    }
  }

  // ✅ MÉTODO PARA REMOVER ID DA HOSPEDAGEM
  Future<void> _removeHospedagemId() async {
    try {
      await _secureStorage.delete(key: 'hospedagem_id');
      print('🗑️ ID Hospedagem removido');
    } catch (error) {
      print('❌ Erro ao remover ID hospedagem: $error');
    }
  }

  // ✅ MÉTODO PARA OBTER ID DA HOSPEDAGEM DO CACHE
  Future<int?> getHospedagemIdFromCache() async {
    try {
      final idString = await _secureStorage.read(key: 'hospedagem_id');
      if (idString != null) {
        final id = int.tryParse(idString);
        print('📖 ID Hospedagem lido do cache: $id');
        return id;
      }
      return null;
    } catch (error) {
      print('❌ Erro ao ler ID hospedagem do cache: $error');
      return null;
    }
  }

  Future<HospedagemModel?> getCurrentHospedagem() async {
    try {
      final hospedagemData = await _secureStorage.read(key: 'hospedagem_data');
      if (hospedagemData != null) {
        final Map<String, dynamic> hospedagemMap = json.decode(hospedagemData);
        print('📖 Hospedagem atual carregada do storage');
        return HospedagemModel.fromJson(hospedagemMap);
      }
      return null;
    } catch (error) {
      print('❌ Erro ao carregar hospedagem atual: $error');
      return null;
    }
  }

  Future<bool> isHospedagemLoggedIn() async {
    try {
      final hospedagemData = await _secureStorage.read(key: 'hospedagem_data');
      final hospedagemId = await getHospedagemIdFromCache();
      
      final temDados = hospedagemData != null && hospedagemId != null;
      print('🔍 Verificando login hospedagem - Dados: ${hospedagemData != null}, ID: $hospedagemId');
      return temDados;
    } catch (error) {
      return false;
    }
  }

  Future<void> logoutHospedagem() async {
    print('🚪 Logout hospedagem');
    await _secureStorage.delete(key: 'hospedagem_data');
    await _secureStorage.delete(key: 'hospedagem_token');
    await _removeHospedagemId();
  }

  Future<String?> getHospedagemToken() async {
    return await _secureStorage.read(key: 'hospedagem_token');
  }
}