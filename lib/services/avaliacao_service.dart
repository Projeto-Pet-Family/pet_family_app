import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/models/avaliacao_model.dart';

class AvaliacaoService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';

  // Buscar todas as avaliações
  static Future<List<AvaliacaoModel>> buscarAvaliacoes() async {
    try {
      print('🌐 Fazendo requisição para: $baseUrl/avaliacao');

      final response = await http.get(
        Uri.parse('$baseUrl/avaliacao'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Avaliações decodificadas: ${data.length} itens');
        return data.map((json) => AvaliacaoModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw AvaliacaoException(
          'Avaliações não encontradas',
          response.statusCode,
        );
      } else {
        throw AvaliacaoException(
          'Erro ao carregar avaliações: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw AvaliacaoException('Erro de conexão: ${e.message}', 0);
    } on TimeoutException catch (_) {
      throw AvaliacaoException('Tempo limite excedido ao buscar avaliações', 0);
    } on FormatException catch (e) {
      throw AvaliacaoException('Erro no formato dos dados: ${e.message}', 0);
    } catch (e) {
      throw AvaliacaoException('Erro inesperado: ${e.toString()}', 0);
    }
  }

  // Buscar avaliação por ID
  static Future<AvaliacaoModel> buscarAvaliacaoPorId(int idAvaliacao) async {
    try {
      print('🌐 Fazendo requisição para: $baseUrl/avaliacao/$idAvaliacao');

      final response = await http.get(
        Uri.parse('$baseUrl/avaliacao/$idAvaliacao'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('✅ Avaliação decodificada: $data');
        return AvaliacaoModel.fromJson(data);
      } else if (response.statusCode == 404) {
        throw AvaliacaoException(
          'Avaliação não encontrada',
          response.statusCode,
        );
      } else {
        throw AvaliacaoException(
          'Erro ao carregar avaliação: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw AvaliacaoException('Erro de conexão: ${e.message}', 0);
    } on TimeoutException catch (_) {
      throw AvaliacaoException('Tempo limite excedido ao buscar avaliação', 0);
    } on FormatException catch (e) {
      throw AvaliacaoException('Erro no formato dos dados: ${e.message}', 0);
    } catch (e) {
      throw AvaliacaoException('Erro inesperado: ${e.toString()}', 0);
    }
  }

  // Buscar avaliações por usuário
  static Future<List<AvaliacaoModel>> buscarAvaliacoesPorUsuario(
      int idUsuario) async {
    try {
      print(
          '🌐 Fazendo requisição para: $baseUrl/avaliacao/usuario/$idUsuario');

      final response = await http.get(
        Uri.parse('$baseUrl/avaliacao/usuario/$idUsuario'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Avaliações do usuário decodificadas: ${data.length} itens');
        return data.map((json) => AvaliacaoModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw AvaliacaoException(
          'Avaliações do usuário não encontradas',
          response.statusCode,
        );
      } else {
        throw AvaliacaoException(
          'Erro ao carregar avaliações do usuário: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw AvaliacaoException('Erro de conexão: ${e.message}', 0);
    } on TimeoutException catch (_) {
      throw AvaliacaoException(
          'Tempo limite excedido ao buscar avaliações do usuário', 0);
    } on FormatException catch (e) {
      throw AvaliacaoException('Erro no formato dos dados: ${e.message}', 0);
    } catch (e) {
      throw AvaliacaoException('Erro inesperado: ${e.toString()}', 0);
    }
  }

  // Buscar avaliações por hospedagem
  static Future<Map<String, dynamic>> buscarAvaliacoesPorHospedagem(
      int idHospedagem) async {
    try {
      print(
          '🌐 Fazendo requisição para: $baseUrl/avaliacao/hospedagem/$idHospedagem');

      final response = await http.get(
        Uri.parse('$baseUrl/avaliacao/hospedagem/$idHospedagem'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('✅ Avaliações da hospedagem decodificadas');

        final List<AvaliacaoModel> avaliacoes = (data['avaliacoes'] as List)
            .map((json) => AvaliacaoModel.fromJson(json))
            .toList();

        return {
          'avaliacoes': avaliacoes,
          'estatisticas': data['estatisticas'],
        };
      } else if (response.statusCode == 404) {
        throw AvaliacaoException(
          'Avaliações da hospedagem não encontradas',
          response.statusCode,
        );
      } else {
        throw AvaliacaoException(
          'Erro ao carregar avaliações da hospedagem: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw AvaliacaoException('Erro de conexão: ${e.message}', 0);
    } on TimeoutException catch (_) {
      throw AvaliacaoException(
          'Tempo limite excedido ao buscar avaliações da hospedagem', 0);
    } on FormatException catch (e) {
      throw AvaliacaoException('Erro no formato dos dados: ${e.message}', 0);
    } catch (e) {
      throw AvaliacaoException('Erro inesperado: ${e.toString()}', 0);
    }
  }

  // Criar avaliação
  static Future<AvaliacaoModel> criarAvaliacao(AvaliacaoModel avaliacao) async {
    try {
      print('🌐 Fazendo requisição POST para: $baseUrl/avaliacao');
      print('📦 Dados enviados: ${avaliacao.toJson()}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/avaliacao'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(avaliacao.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('✅ Avaliação criada com sucesso: $data');
        return AvaliacaoModel.fromJson(data['data']);
      } else {
        throw AvaliacaoException(
          'Erro ao criar avaliação: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw AvaliacaoException('Erro de conexão: ${e.message}', 0);
    } on TimeoutException catch (_) {
      throw AvaliacaoException('Tempo limite excedido ao criar avaliação', 0);
    } on FormatException catch (e) {
      throw AvaliacaoException('Erro no formato dos dados: ${e.message}', 0);
    } catch (e) {
      throw AvaliacaoException('Erro inesperado: ${e.toString()}', 0);
    }
  }

  // Atualizar avaliação
  static Future<AvaliacaoModel> atualizarAvaliacao(
      int idAvaliacao, AvaliacaoModel avaliacao) async {
    try {
      print('🌐 Fazendo requisição PUT para: $baseUrl/avaliacao/$idAvaliacao');
      print('📦 Dados enviados: ${avaliacao.toJson()}');

      final response = await http
          .put(
            Uri.parse('$baseUrl/avaliacao/$idAvaliacao'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(avaliacao.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('✅ Avaliação atualizada com sucesso: $data');
        return AvaliacaoModel.fromJson(data['data']);
      } else {
        throw AvaliacaoException(
          'Erro ao atualizar avaliação: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw AvaliacaoException('Erro de conexão: ${e.message}', 0);
    } on TimeoutException catch (_) {
      throw AvaliacaoException(
          'Tempo limite excedido ao atualizar avaliação', 0);
    } on FormatException catch (e) {
      throw AvaliacaoException('Erro no formato dos dados: ${e.message}', 0);
    } catch (e) {
      throw AvaliacaoException('Erro inesperado: ${e.toString()}', 0);
    }
  }

  // Excluir avaliação
  static Future<void> excluirAvaliacao(int idAvaliacao) async {
    try {
      print(
          '🌐 Fazendo requisição DELETE para: $baseUrl/avaliacao/$idAvaliacao');

      final response = await http.delete(
        Uri.parse('$baseUrl/avaliacao/$idAvaliacao'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Status Code: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw AvaliacaoException(
          'Erro ao excluir avaliação: ${response.statusCode} - ${response.body}',
          response.statusCode,
        );
      } else {
        print('✅ Avaliação excluída com sucesso');
      }
    } on http.ClientException catch (e) {
      throw AvaliacaoException('Erro de conexão: ${e.message}', 0);
    } on TimeoutException catch (_) {
      throw AvaliacaoException('Tempo limite excedido ao excluir avaliação', 0);
    } on FormatException catch (e) {
      throw AvaliacaoException('Erro no formato dos dados: ${e.message}', 0);
    } catch (e) {
      throw AvaliacaoException('Erro inesperado: ${e.toString()}', 0);
    }
  }
}

// Exceção customizada para erros de avaliação
class AvaliacaoException implements Exception {
  final String message;
  final int statusCode;

  const AvaliacaoException(this.message, this.statusCode);

  @override
  String toString() => message;
}
