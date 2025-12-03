// services/contrato_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pet_family_app/models/contrato_model.dart';

class ContratoService {
  final Dio _dio;

  ContratoService({required Dio dio}) : _dio = dio;

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

  // 2. Criar contrato
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
      print('📝 Criando contrato...');
      print('🏨 Hospedagem ID: $idHospedagem');
      print('👤 Usuário ID: $idUsuario');
      print('📅 Período: $dataInicio até $dataFim');
      print('🐕 Pets: ${pets.length}');
      print('🛎️ Serviços: ${servicos?.length ?? 0}');

      final body = {
        'idHospedagem': idHospedagem,
        'idUsuario': idUsuario,
        'dataInicio': dataInicio,
        'dataFim': dataFim,
        'pets': pets,
        if (servicos != null && servicos.isNotEmpty) 'servicos': servicos,
        'status': status,
      };

      print('📦 Request body: ${json.encode(body)}');

      final response = await _dio.post(
        '$_baseUrl/contrato',
        data: json.encode(body),
        options: Options(headers: _headers),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Contrato criado com sucesso!');
        return response.data;
      } else {
        throw Exception('Erro ao criar contrato: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      print('❌ Erro ao criar contrato: $e');
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
        throw Exception('Contrato não encontrado: Status ${response.statusCode}');
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
  Future<List<ContratoModel>> listarContratosPorUsuario(int idUsuario) async {
    try {
      print('📋 Listando contratos do usuário: $idUsuario');

      final response = await _dio.get(
        '$_baseUrl/contrato/usuario/$idUsuario',
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['contratos'] ?? response.data;
        print('✅ ${data.length} contratos encontrados');
        
        return data.map((json) => ContratoModel.fromJson(json)).toList();
      } else {
        throw Exception('Erro ao listar contratos: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      print('❌ Erro ao listar contratos: $e');
      rethrow;
    }
  }

  // 5. Listar contratos por usuário e status
  Future<List<ContratoModel>> listarContratosPorUsuarioEStatus(
    int idUsuario, 
    String status
  ) async {
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
        throw Exception('Erro ao listar contratos: Status ${response.statusCode}');
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
        throw Exception('Erro ao atualizar status: Status ${response.statusCode}');
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
        throw Exception('Erro ao obter transições: Status ${response.statusCode}');
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
  Future<ContratoModel> adicionarServicoContrato({
    required int idContrato,
    required List<Map<String, dynamic>> servicos,
  }) async {
    try {
      print('➕ Adicionando ${servicos.length} serviço(s) ao contrato $idContrato');

      final body = {'servicos': servicos};

      final response = await _dio.post(
        '$_baseUrl/contrato/$idContrato/servico',
        data: json.encode(body),
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        print('✅ Serviço(s) adicionado(s) com sucesso!');
        return ContratoModel.fromJson(data);
      } else {
        throw Exception('Erro ao adicionar serviço: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      print('❌ Erro ao adicionar serviço: $e');
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
      print('📅 Atualizando datas do contrato $idContrato');

      final body = {
        if (dataInicio != null) 'dataInicio': dataInicio,
        if (dataFim != null) 'dataFim': dataFim,
      };

      final response = await _dio.put(
        '$_baseUrl/contrato/$idContrato/data',
        data: json.encode(body),
        options: Options(headers: _headers),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        print('✅ Datas atualizadas com sucesso!');
        return ContratoModel.fromJson(data);
      } else {
        throw Exception('Erro ao atualizar datas: Status ${response.statusCode}');
      }
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      print('❌ Erro ao atualizar datas: $e');
      rethrow;
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
        throw Exception('Erro ao remover serviço: Status ${response.statusCode}');
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
  Future<Map<String, dynamic>> obterCalculoDetalhadoContrato(int idContrato) async {
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
        throw Exception('Erro ao excluir contrato: Status ${response.statusCode}');
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
        'valor_diaria': 'R\$${valorDiaria.toStringAsFixed(2).replaceAll('.', ',')}',
        'valor_hospedagem': 'R\$${valorHospedagem.toStringAsFixed(2).replaceAll('.', ',')}',
        'valor_servicos': 'R\$${totalServicos.toStringAsFixed(2).replaceAll('.', ',')}',
        'valor_total': 'R\$${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}',
        'periodo': '$quantidadeDias dia(s)',
        'pets': '$quantidadePets pet(s)',
      },
    };
  }
}