import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/models/denuncia_model.dart';

class DenunciaService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';

  // Buscar todas as denúncias
  static Future<List<DenunciaModel>> buscarDenuncias() async {
    try {
      print('🌐 Fazendo requisição para: $baseUrl/denuncia');

      final response = await http.get(
        Uri.parse('$baseUrl/denuncia'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Denúncias decodificadas: ${data.length} itens');
        return data.map((json) => DenunciaModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw DenunciaException(
          'Denúncias não encontradas',
          response.statusCode,
        );
      } else {
        throw DenunciaException(
          'Erro ao carregar denúncias: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw DenunciaException('Erro de conexão: ${e.message}', 0);
    } on TimeoutException catch (_) {
      throw DenunciaException('Tempo limite excedido ao buscar denúncias', 0);
    } on FormatException catch (e) {
      throw DenunciaException('Erro no formato dos dados: ${e.message}', 0);
    } catch (e) {
      throw DenunciaException('Erro inesperado: ${e.toString()}', 0);
    }
  }

  // Buscar denúncia por ID
  static Future<DenunciaModel> buscarDenunciaPorId(int idDenuncia) async {
    try {
      print('🌐 Fazendo requisição para: $baseUrl/denuncia/$idDenuncia');

      final response = await http.get(
        Uri.parse('$baseUrl/denuncia/$idDenuncia'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('✅ Denúncia decodificada: $data');
        return DenunciaModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw DenunciaException(
          'Denúncia não encontrada',
          response.statusCode,
        );
      } else {
        throw DenunciaException(
          'Erro ao carregar denúncia: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw DenunciaException('Erro de conexão: ${e.message}', 0);
    } on TimeoutException catch (_) {
      throw DenunciaException('Tempo limite excedido ao buscar denúncia', 0);
    } on FormatException catch (e) {
      throw DenunciaException('Erro no formato dos dados: ${e.message}', 0);
    } catch (e) {
      throw DenunciaException('Erro inesperado: ${e.toString()}', 0);
    }
  }

  // Buscar denúncias por usuário
  static Future<List<DenunciaModel>> buscarDenunciasPorUsuario(
      int idUsuario) async {
    try {
      print('🌐 Fazendo requisição para: $baseUrl/denuncia/usuario/$idUsuario');

      final response = await http.get(
        Uri.parse('$baseUrl/denuncia/usuario/$idUsuario'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Denúncias do usuário decodificadas: ${data.length} itens');
        return data.map((json) => DenunciaModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw DenunciaException(
          'Denúncias do usuário não encontradas',
          response.statusCode,
        );
      } else {
        throw DenunciaException(
          'Erro ao carregar denúncias do usuário: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw DenunciaException('Erro de conexão: ${e.message}', 0);
    } on TimeoutException catch (_) {
      throw DenunciaException(
          'Tempo limite excedido ao buscar denúncias do usuário', 0);
    } on FormatException catch (e) {
      throw DenunciaException('Erro no formato dos dados: ${e.message}', 0);
    } catch (e) {
      throw DenunciaException('Erro inesperado: ${e.toString()}', 0);
    }
  }

  // Buscar denúncias por hospedagem
  static Future<Map<String, dynamic>> buscarDenunciasPorHospedagem(
      int idHospedagem) async {
    try {
      print(
          '🌐 Fazendo requisição para: $baseUrl/denuncia/hospedagem/$idHospedagem');

      final response = await http.get(
        Uri.parse('$baseUrl/denuncia/hospedagem/$idHospedagem'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('✅ Denúncias da hospedagem decodificadas');

        final List<DenunciaModel> denuncias = (data['denuncias'] as List)
            .map((json) => DenunciaModel.fromJson(json))
            .toList();

        return {
          'denuncias': denuncias,
          'total_denuncias': data['total_denuncias'],
        };
      } else if (response.statusCode == 404) {
        throw DenunciaException(
          'Denúncias da hospedagem não encontradas',
          response.statusCode,
        );
      } else {
        throw DenunciaException(
          'Erro ao carregar denúncias da hospedagem: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw DenunciaException('Erro de conexão: ${e.message}', 0);
    } on TimeoutException catch (_) {
      throw DenunciaException(
          'Tempo limite excedido ao buscar denúncias da hospedagem', 0);
    } on FormatException catch (e) {
      throw DenunciaException('Erro no formato dos dados: ${e.message}', 0);
    } catch (e) {
      throw DenunciaException('Erro inesperado: ${e.toString()}', 0);
    }
  }

  // Criar denúncia
  static Future<DenunciaModel> criarDenuncia(DenunciaModel denuncia) async {
    try {
      print('🌐 Fazendo requisição POST para: $baseUrl/denuncia');
      print('📦 Dados enviados: ${denuncia.toJson()}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/denuncia'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(denuncia.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('✅ Denúncia criada com sucesso: $data');
        return DenunciaModel.fromJson(data['data']);
      } else {
        throw DenunciaException(
          'Erro ao criar denúncia: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw DenunciaException('Erro de conexão: ${e.message}', 0);
    } on TimeoutException catch (_) {
      throw DenunciaException('Tempo limite excedido ao criar denúncia', 0);
    } on FormatException catch (e) {
      throw DenunciaException('Erro no formato dos dados: ${e.message}', 0);
    } catch (e) {
      throw DenunciaException('Erro inesperado: ${e.toString()}', 0);
    }
  }

  // Atualizar denúncia
  static Future<DenunciaModel> atualizarDenuncia(
      int idDenuncia, DenunciaModel denuncia) async {
    try {
      print('🌐 Fazendo requisição PUT para: $baseUrl/denuncia/$idDenuncia');
      print('📦 Dados enviados: ${denuncia.toJson()}');

      final response = await http
          .put(
            Uri.parse('$baseUrl/denuncia/$idDenuncia'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(denuncia.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('✅ Denúncia atualizada com sucesso: $data');
        return DenunciaModel.fromJson(data['data']);
      } else {
        throw DenunciaException(
          'Erro ao atualizar denúncia: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw DenunciaException('Erro de conexão: ${e.message}', 0);
    } on TimeoutException catch (_) {
      throw DenunciaException('Tempo limite excedido ao atualizar denúncia', 0);
    } on FormatException catch (e) {
      throw DenunciaException('Erro no formato dos dados: ${e.message}', 0);
    } catch (e) {
      throw DenunciaException('Erro inesperado: ${e.toString()}', 0);
    }
  }

  // Excluir denúncia
  static Future<void> excluirDenuncia(int idDenuncia) async {
    try {
      print('🌐 Fazendo requisição DELETE para: $baseUrl/denuncia/$idDenuncia');

      final response = await http.delete(
        Uri.parse('$baseUrl/denuncia/$idDenuncia'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw DenunciaException(
          'Erro ao excluir denúncia: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      } else {
        print('✅ Denúncia excluída com sucesso');
      }
    } on http.ClientException catch (e) {
      throw DenunciaException('Erro de conexão: ${e.message}', 0);
    } on TimeoutException catch (_) {
      throw DenunciaException('Tempo limite excedido ao excluir denúncia', 0);
    } on FormatException catch (e) {
      throw DenunciaException('Erro no formato dos dados: ${e.message}', 0);
    } catch (e) {
      throw DenunciaException('Erro inesperado: ${e.toString()}', 0);
    }
  }
}

// Exceção customizada para erros de denúncia
class DenunciaException implements Exception {
  final String message;
  final int statusCode;

  const DenunciaException(this.message, this.statusCode);

  @override
  String toString() => message;
}
