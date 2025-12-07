// services/contrato_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/src/client.dart';
import 'package:pet_family_app/models/contrato_model.dart';

class ContratoService {
  final Dio _dio;

  ContratoService({required Dio dio, required Client client}) : _dio = dio;

  // Configuração base
  String get _baseUrl => 'https://bepetfamily.onrender.com';

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // Tratamento de erros
  void _handleError(DioException e) {
    print('❌ Erro na API: ${e.message}');
    print('📡 URL: ${e.requestOptions.uri}');
    print('📊 Status: ${e.response?.statusCode}');
    print('📦 Response: ${e.response?.data}');

    if (e.response?.statusCode == 404) {
      throw Exception('Recurso não encontrado');
    } else if (e.response?.statusCode == 400) {
      throw Exception('Dados inválidos: ${e.response?.data}');
    } else if (e.response?.statusCode == 500) {
      throw Exception('Erro interno do servidor');
    } else if (e.type == DioExceptionType.connectionTimeout) {
      throw Exception('Tempo de conexão esgotado');
    } else if (e.type == DioExceptionType.receiveTimeout) {
      throw Exception('Tempo de resposta esgotado');
    } else {
      throw Exception('Erro na comunicação: ${e.message}');
    }
  }

  // 1. Calcular valor do contrato (endpoint específico)
  Future<Map<String, dynamic>> calcularValorContrato({
    required int idHospedagem,
    required String dataInicio,
    required String dataFim,
    List<Map<String, dynamic>>? servicos,
  }) async {
    try {
      print('🧮 Calculando valor do contrato...');
      print('🏨 Hospedagem ID: $idHospedagem');
      print('📅 Data início: $dataInicio, Data fim: $dataFim');
      print('📦 Serviços: ${servicos?.length ?? 0}');

      // Construir o body da requisição
      final body = {
        'idHospedagem': idHospedagem,
        'dataInicio': dataInicio,
        'dataFim': dataFim,
        if (servicos != null && servicos.isNotEmpty) 'servicos': servicos,
      };

      print('📦 Request body: ${json.encode(body)}');

      final response = await _dio.post(
        '$_baseUrl/contrato/calcular',
        data: json.encode(body),
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        print('✅ Cálculo realizado com sucesso!');
        return response.data;
      } else {
        throw Exception('Erro no cálculo: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      print('❌ Erro ao calcular valor do contrato: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> criarContrato({
    required int idHospedagem,
    required int idUsuario,
    required String dataInicio,
    required String dataFim,
    required List<int> pets,
    List<Map<String, dynamic>>? servicos,
    String status = 'em_aprovacao',
  }) async {
    try {
      print('📝 === CRIANDO CONTRATO NA API ===');
      print('🏨 Hospedagem ID: $idHospedagem');
      print('👤 Usuário ID: $idUsuario');
      print('📅 Período: $dataInicio até $dataFim');
      print('🐕 Pets: $pets');
      print('🛎️ Serviços: ${servicos?.length ?? 0}');

      // CORREÇÃO: Construir o body INCLUINDO serviços quando existirem
      final Map<String, dynamic> body = {
        'idHospedagem': idHospedagem,
        'idUsuario': idUsuario,
        'dataInicio': dataInicio,
        'dataFim': dataFim,
        'pets': pets,
        'status': status,
      };

      // CORREÇÃO: Adicionar serviços se existirem
      if (servicos != null && servicos.isNotEmpty) {
        body['servicosPorPet'] = servicos; // ADICIONAR SERVIÇOS AQUI
        print('✅ Serviços incluídos na criação: $servicos');
      }

      print('📦 Request body: ${json.encode(body)}');

      final response = await _dio.post(
        '$_baseUrl/contrato',
        data: json.encode(body),
        options: Options(headers: _headers),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Contrato criado com sucesso na API!');
        return response.data;
      } else {
        throw Exception(
            'Erro ao criar contrato: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException ao criar contrato:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');

      _handleError(e);
      rethrow;
    } catch (e) {
      print('❌ Erro geral ao criar contrato: $e');
      rethrow;
    }
  }

  // 3. Buscar contrato por ID
  Future<ContratoModel> buscarContratoPorId(int idContrato) async {
    try {
      print('🔍 Buscando contrato ID: $idContrato');

      final response = await _dio.get(
        '$_baseUrl/contrato/$idContrato',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('✅ Contrato encontrado: ${data['idcontrato']}');
        return ContratoModel.fromJson(data);
      } else {
        throw Exception(
            'Contrato não encontrado: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      print('❌ Erro ao buscar contrato: $e');
      rethrow;
    }
  }

  // 4. Listar contratos do usuário
  // services/contrato_service.dart - MÉTODO listarContratosPorUsuario

  Future<List<ContratoModel>> listarContratosPorUsuario(int idUsuario) async {
    try {
      print('📋 Listando contratos do usuário: $idUsuario');

      final response = await _dio.get(
        '$_baseUrl/contrato/usuario/$idUsuario',
        options: Options(headers: _headers),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response data type: ${response.data.runtimeType}');
      print(
          '📡 Response data keys: ${response.data is Map ? (response.data as Map).keys.toList() : 'Not a Map'}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Verificar se a resposta tem a estrutura esperada {success, count, data}
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('success') &&
              responseData['success'] == true) {
            // Extrair a lista de contratos do campo 'data'
            final dynamic data = responseData['data'];

            if (data is List) {
              print('✅ ${data.length} contratos encontrados na estrutura data');
              return data.map((json) => ContratoModel.fromJson(json)).toList();
            } else {
              print('⚠️ Campo "data" não é uma lista: ${data.runtimeType}');
              throw Exception(
                  'Formato de resposta inválido: campo "data" não é uma lista');
            }
          } else {
            // Se não tem a estrutura esperada, verificar se é uma lista direta
            final List<dynamic> dataList;

            if (responseData is List) {
              dataList = responseData as List;
              print(
                  '✅ ${dataList.length} contratos encontrados (lista direta)');
            } else if (responseData.containsKey('contratos') &&
                responseData['contratos'] is List) {
              dataList = responseData['contratos'];
              print(
                  '✅ ${dataList.length} contratos encontrados no campo contratos');
            } else {
              print('❌ Formato de resposta desconhecido');
              throw Exception('Formato de resposta desconhecido do servidor');
            }

            return dataList
                .map((json) => ContratoModel.fromJson(json))
                .toList();
          }
        } else if (responseData is List) {
          // Resposta direta como lista
          print(
              '✅ ${responseData.length} contratos encontrados (resposta direta como lista)');
          return responseData
              .map((json) => ContratoModel.fromJson(json))
              .toList();
        } else {
          print('❌ Tipo de resposta inesperado: ${responseData.runtimeType}');
          throw Exception('Tipo de resposta inesperado do servidor');
        }
      } else {
        throw Exception(
            'Erro ao listar contratos: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException ao listar contratos:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');

      _handleError(e);
      rethrow;
    } catch (e) {
      print('❌ Erro ao listar contratos: $e');
      rethrow;
    }
  }

  // 5. Listar contratos por usuário e status
  Future<List<ContratoModel>> listarContratosPorUsuarioEStatus(
      int idUsuario, String status) async {
    try {
      print('📋 Listando contratos do usuário $idUsuario com status: $status');

      final response = await _dio.get(
        '$_baseUrl/contrato/usuario/$idUsuario/status',
        queryParameters: {'status': status},
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('✅ ${data.length} contratos encontrados');

        return data.map((json) => ContratoModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Erro ao listar contratos: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      print('❌ Erro ao listar contratos: $e');
      rethrow;
    }
  }

  // 6. Atualizar status do contrato
  Future<ContratoModel> atualizarStatusContrato({
    required int idContrato,
    required String status,
    String? motivo,
  }) async {
    try {
      print('🔄 Atualizando status do contrato $idContrato para: $status');

      final body = {
        'status': status,
        if (motivo != null && motivo.isNotEmpty) 'motivo': motivo,
      };

      final response = await _dio.put(
        '$_baseUrl/contrato/$idContrato/alterar-status',
        data: json.encode(body),
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        print('✅ Status atualizado com sucesso!');
        return ContratoModel.fromJson(data);
      } else {
        throw Exception(
            'Erro ao atualizar status: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      print('❌ Erro ao atualizar status: $e');
      rethrow;
    }
  }

  // 7. Obter transições de status permitidas
  Future<Map<String, dynamic>> obterTransicoesStatus(int idContrato) async {
    try {
      print('🔄 Obtendo transições de status para contrato: $idContrato');

      final response = await _dio.get(
        '$_baseUrl/contrato/$idContrato/transicoes-status',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        print('✅ Transições obtidas com sucesso!');
        return response.data;
      } else {
        throw Exception(
            'Erro ao obter transições: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      print('❌ Erro ao obter transições: $e');
      rethrow;
    }
  }

  // 8. Adicionar serviço ao contrato
  Future<Map<String, dynamic>> adicionarServicoContrato({
    required int idContrato,
    required List<Map<String, dynamic>> servicosPorPet,
  }) async {
    try {
      print('➕ === ADICIONANDO SERVIÇOS AO CONTRATO ===');
      print('📝 Contrato ID: $idContrato');
      print('📦 Serviços por pet: $servicosPorPet');

      // Validar formato
      for (var item in servicosPorPet) {
        if (!item.containsKey('idPet') || !item.containsKey('servicos')) {
          throw Exception(
              'Formato inválido. Use: [{idPet: X, servicos: [Y, Z]}]');
        }
      }

      final payload = {
        'servicosPorPet': servicosPorPet,
      };

      print('📤 Payload sendo enviado: $payload');
      print('📤 URL: POST /contrato/$idContrato/servico');

      final response = await _dio.post(
        'https://bepetfamily.onrender.com/contrato/$idContrato/servico',
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print('📡 Response completa:');
      print('  Status: ${response.statusCode}');
      print('  Data: ${response.data}');

      if (response.statusCode == 200) {
        print('✅ Serviço(s) adicionado(s) com sucesso!');
        final data = response.data;

        // A resposta deve conter o contrato atualizado em data.data
        if (data is Map && data.containsKey('data')) {
          return data['data'];
        } else {
          // Fallback: se não tiver data.data, tenta usar o objeto direto
          return data;
        }
      } else if (response.statusCode == 400) {
        // Erro de validação específico
        final errorData = response.data;
        print('❌ Erro 400 detalhado: $errorData');

        if (errorData is Map) {
          if (errorData.containsKey('servicosExistentes')) {
            throw Exception(
                'Alguns serviços já estão no contrato: ${errorData['servicosExistentes']}');
          } else if (errorData.containsKey('servicosInvalidos')) {
            throw Exception(
                'Serviços inválidos: ${errorData['servicosInvalidos']}');
          } else if (errorData.containsKey('petsInvalidos')) {
            throw Exception('Pets inválidos: ${errorData['petsInvalidos']}');
          } else if (errorData.containsKey('message')) {
            throw Exception(errorData['message']);
          }
        }

        throw Exception('Erro de validação: $errorData');
      } else {
        throw Exception('Erro ${response.statusCode}: ${response.data}');
      }
    } on DioException catch (e) {
      print('❌ DioException ao adicionar serviços:');
      print('  Type: ${e.type}');
      print('  Message: ${e.message}');
      print('  Response: ${e.response?.data}');

      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        if (errorData is Map && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        }
      }

      throw Exception('Erro ao adicionar serviços: ${e.message}');
    } catch (e) {
      print('❌ Erro inesperado ao adicionar serviços: $e');
      rethrow;
    }
  }

  // 9. Adicionar pet ao contrato
  Future<ContratoModel> adicionarPetContrato({
    required int idContrato,
    required List<int> pets,
  }) async {
    try {
      print('➕ Adicionando ${pets.length} pet(s) ao contrato $idContrato');

      final body = {'pets': pets};

      final response = await _dio.post(
        '$_baseUrl/contrato/$idContrato/pet',
        data: json.encode(body),
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        print('✅ Pet(s) adicionado(s) com sucesso!');
        return ContratoModel.fromJson(data);
      } else {
        throw Exception('Erro ao adicionar pet: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      print('❌ Erro ao adicionar pet: $e');
      rethrow;
    }
  }

  // 10. Atualizar datas do contrato
  Future<ContratoModel> atualizarDatasContrato({
    required int idContrato,
    String? dataInicio,
    String? dataFim,
  }) async {
    try {
      print('🚀🚀🚀 DEBUG DETALHADO - atualizarDatasContrato 🚀🚀🚀');
      print('📌 Contrato ID: $idContrato');

      // Criar um transformer customizado para as datas
      final Map<String, dynamic> body = {};

      // Processar dataInicio
      if (dataInicio != null) {
        // Remover qualquer informação de hora/minuto/segundo
        final dataInicioLimpa = _limparDataString(dataInicio);
        body['dataInicio'] = dataInicioLimpa;

        print('📝 Data Início:');
        print('   - Recebida: "$dataInicio"');
        print('   - Limpa: "$dataInicioLimpa"');
        print('   - Tipo: ${dataInicioLimpa.runtimeType}');
      }

      // Processar dataFim
      if (dataFim != null) {
        // Remover qualquer informação de hora/minuto/segundo
        final dataFimLimpa = _limparDataString(dataFim);
        body['dataFim'] = dataFimLimpa;

        print('📝 Data Fim:');
        print('   - Recebida: "$dataFim"');
        print('   - Limpa: "$dataFimLimpa"');
        print('   - Tipo: ${dataFimLimpa.runtimeType}');
      }

      print('📦 Body antes do envio:');
      print('   - Conteúdo: $body');
      print('   - Tipo: ${body.runtimeType}');

      // Teste: ver como o JSON serializa
      final jsonString = jsonEncode(body);
      print('📄 JSON serializado: $jsonString');

      // Adicionar interceptor para debug
      final dioDebug = Dio();

      // Interceptor para debug
      dioDebug.interceptors.add(InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          print('🌐 REQUEST DEBUG:');
          print('   - URL: ${options.baseUrl}${options.path}');
          print('   - Method: ${options.method}');
          print('   - Headers: ${options.headers}');
          print('   - Data: ${options.data}');
          print('   - Data tipo: ${options.data.runtimeType}');
          handler.next(options);
        },
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          print('📥 RESPONSE DEBUG:');
          print('   - Status: ${response.statusCode}');
          print('   - Data: ${response.data}');
          handler.next(response);
        },
        onError: (DioException e, ErrorInterceptorHandler handler) {
          print('❌ ERROR DEBUG:');
          print('   - Type: ${e.type}');
          print('   - Message: ${e.message}');
          print('   - Response: ${e.response?.data}');
          handler.next(e);
        },
      ));

      // Fazer a requisição
      final response = await dioDebug.put(
        'https://bepetfamily.onrender.com/contrato/$idContrato/data',
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            // Adicione outros headers necessários (auth, etc.)
            ..._headers,
          },
        ),
      );

      print('✅ Resposta da API: ${response.statusCode}');
      print('📦 Dados retornados: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return ContratoModel.fromJson(data);
      } else {
        throw Exception(
            'Erro ao atualizar datas: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException detalhada:');
      print('   - Error: $e');
      print('   - Response: ${e.response?.data}');
      print('   - Request: ${e.requestOptions.data}');
      rethrow;
    } catch (e) {
      print('❌ Erro geral: $e');
      rethrow;
    } finally {
      print('🏁 FIM DEBUG 🏁');
    }
  }

// Método auxiliar para limpar strings de data
  String _limparDataString(String dataString) {
    // Se a string contém espaço (tem hora), pegar apenas a parte da data
    if (dataString.contains(' ')) {
      return dataString.split(' ')[0];
    }

    // Se já está no formato YYYY-MM-DD, retornar como está
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (regex.hasMatch(dataString)) {
      return dataString;
    }

    // Tentar parsear e formatar
    try {
      final date = DateTime.parse(dataString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      // Se não conseguir parsear, retornar a string original
      return dataString;
    }
  }

  // 11. Remover serviço do contrato
  Future<Map<String, dynamic>> removerServicoContrato({
    required int idContrato,
    required int idServico,
  }) async {
    try {
      print('➖ Removendo serviço $idServico do contrato $idContrato');

      final response = await _dio.delete(
        '$_baseUrl/contrato/$idContrato/servico/$idServico',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        print('✅ Serviço removido com sucesso!');
        return response.data;
      } else {
        throw Exception(
            'Erro ao remover serviço: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      print('❌ Erro ao remover serviço: $e');
      rethrow;
    }
  }

  // 12. Remover pet do contrato
  Future<Map<String, dynamic>> removerPetContrato({
    required int idContrato,
    required int idPet,
  }) async {
    try {
      print('➖ Removendo pet $idPet do contrato $idContrato');

      final response = await _dio.delete(
        '$_baseUrl/contrato/$idContrato/pet/$idPet',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        print('✅ Pet removido com sucesso!');
        return response.data;
      } else {
        throw Exception('Erro ao remover pet: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      print('❌ Erro ao remover pet: $e');
      rethrow;
    }
  }

  // 13. Obter cálculo detalhado de um contrato existente
  Future<Map<String, dynamic>> obterCalculoDetalhadoContrato(
      int idContrato) async {
    try {
      print('🧮 Obtendo cálculo detalhado do contrato: $idContrato');

      final response = await _dio.get(
        '$_baseUrl/contrato/$idContrato/calcular',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        print('✅ Cálculo detalhado obtido!');
        return response.data;
      } else {
        throw Exception('Erro ao obter cálculo: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      print('❌ Erro ao obter cálculo: $e');
      rethrow;
    }
  }

  // 14. Excluir contrato
  Future<Map<String, dynamic>> excluirContrato(int idContrato) async {
    try {
      print('🗑️ Excluindo contrato: $idContrato');

      final response = await _dio.delete(
        '$_baseUrl/contrato/$idContrato',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        print('✅ Contrato excluído com sucesso!');
        return response.data;
      } else {
        throw Exception(
            'Erro ao excluir contrato: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      print('❌ Erro ao excluir contrato: $e');
      rethrow;
    }
  }

  // 15. Método auxiliar para calcular valor localmente (fallback)
  Map<String, dynamic> calcularValorLocalmente({
    required double valorDiaria,
    required int quantidadeDias,
    required int quantidadePets,
    required double totalServicos,
  }) {
    final valorHospedagem = valorDiaria * quantidadeDias * quantidadePets;
    final valorTotal = valorHospedagem + totalServicos;

    return {
      'valores': {
        'hospedagem': valorHospedagem,
        'servicos': totalServicos,
        'total': valorTotal,
        'valor_diaria': valorDiaria,
        'dias': quantidadeDias,
      },
      'resumo': {
        'valor_diaria': valorDiaria,
        'quantidade_dias': quantidadeDias,
        'quantidade_pets': quantidadePets,
        'servicos_selecionados': 0,
      },
      'formatado': {
        'valor_diaria':
            'R\$${valorDiaria.toStringAsFixed(2).replaceAll('.', ',')}',
        'valor_hospedagem':
            'R\$${valorHospedagem.toStringAsFixed(2).replaceAll('.', ',')}',
        'valor_servicos':
            'R\$${totalServicos.toStringAsFixed(2).replaceAll('.', ',')}',
        'valor_total':
            'R\$${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}',
        'periodo': '$quantidadeDias dia(s)',
        'pets': '$quantidadePets pet(s)',
      },
    };
  }

  Future<Map<String, dynamic>> lerPetsExistentesContrato(int idContrato) async {
    try {
      print('🐕 Carregando pets existentes do contrato ID: $idContrato');

      final response = await _dio.get(
        '$_baseUrl/contrato/$idContrato/pets',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('✅ Pets carregados com sucesso!');
        print('📊 Total de pets: ${data['data']['pets'].length}');

        return data;
      } else {
        throw Exception('Erro ao carregar pets: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      print('❌ Erro ao carregar pets existentes: $e');
      rethrow;
    }
  }
}
