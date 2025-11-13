import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _renderUrl = 'https://bepetfamily.onrender.com';
  final String _localUrl = 'http://localhost:3000';

  String _currentBaseUrl = '';

  ApiService() {
    _currentBaseUrl = _renderUrl;
    _dio.options.baseUrl = _currentBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);

    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
    ));
  }

  // Métodos HTTP básicos
  Future<Response> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response =
          await _dio.get(endpoint, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      if (_shouldTryLocalUrl(e)) {
        return _retryWithLocalUrl('GET', endpoint,
            queryParameters: queryParameters);
      }
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> post(String endpoint, dynamic data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      if (_shouldTryLocalUrl(e)) {
        return _retryWithLocalUrl('POST', endpoint, data: data);
      }
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> put(String endpoint, dynamic data) async {
    try {
      final response = await _dio.put(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      if (_shouldTryLocalUrl(e)) {
        return _retryWithLocalUrl('PUT', endpoint, data: data);
      }
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> patch(String endpoint, dynamic data) async {
    try {
      final response = await _dio.patch(endpoint, data: data);
      return response;
    } on DioException catch (e) {
      if (_shouldTryLocalUrl(e)) {
        return _retryWithLocalUrl('PATCH', endpoint, data: data);
      }
      _handleError(e);
      rethrow;
    }
  }

  Future<Response> delete(String endpoint) async {
    try {
      final response = await _dio.delete(endpoint);
      return response;
    } on DioException catch (e) {
      if (_shouldTryLocalUrl(e)) {
        return _retryWithLocalUrl('DELETE', endpoint);
      }
      _handleError(e);
      rethrow;
    }
  }

  // Métodos específicos para contratos
  Future<bool> removerServicoContrato({
    required int idContrato,
    required int idServico,
  }) async {
    try {
      final response = await _dio.delete(
        '/contrato/$idContrato/servico/$idServico',
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ Erro ao remover serviço do contrato: $e');
      throw e;
    }
  }

  Future<bool> removerPetContrato({
    required int idContrato,
    required int idPet,
  }) async {
    try {
      final response = await _dio.delete(
        '/contrato/$idContrato/pet/$idPet',
      );

      if (response.statusCode == 200) {
        print('✅ Pet removido com sucesso do contrato');
        return true;
      } else {
        print('❌ Erro ao remover pet: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erro ao remover pet do contrato: $e');
      throw e;
    }
  }

  Future<bool> atualizarDatasContrato({
    required int idContrato,
    required String? dataInicio,
    required String? dataFim,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (dataInicio != null) {
        data['dataInicio'] = dataInicio;
      }
      if (dataFim != null) {
        data['dataFim'] = dataFim;
      }

      final response = await _dio.patch(
        '/contrato/$idContrato/atualizar-datas',
        data: data,
      );

      if (response.statusCode == 200) {
        print('✅ Datas do contrato atualizadas com sucesso');
        return true;
      } else {
        print('❌ Erro ao atualizar datas: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Erro ao atualizar datas do contrato: $e');
      throw e;
    }
  }

  // Métodos auxiliares
  bool _shouldTryLocalUrl(DioException e) {
    return _currentBaseUrl == _renderUrl &&
        (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError ||
            (e.response?.statusCode ?? 0) >= 500);
  }

  Future<Response> _retryWithLocalUrl(String method, String endpoint,
      {Map<String, dynamic>? queryParameters, dynamic data}) async {
    print('Falha na conexão com o Render. Tentando URL local...');

    final originalBaseUrl = _currentBaseUrl;

    try {
      _currentBaseUrl = _localUrl;
      _dio.options.baseUrl = _localUrl;

      switch (method) {
        case 'GET':
          return await _dio.get(endpoint, queryParameters: queryParameters);
        case 'POST':
          return await _dio.post(endpoint, data: data);
        case 'PUT':
          return await _dio.put(endpoint, data: data);
        case 'PATCH':
          return await _dio.patch(endpoint, data: data);
        case 'DELETE':
          return await _dio.delete(endpoint);
        default:
          throw Exception('Método HTTP não suportado: $method');
      }
    } on DioException catch (e) {
      _currentBaseUrl = originalBaseUrl;
      _dio.options.baseUrl = originalBaseUrl;
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(DioException e) {
    if (e.response != null) {
      print('Erro na resposta: ${e.response?.statusCode}');
      print('URL: ${e.requestOptions.uri}');
      print('Dados: ${e.response?.data}');
    } else {
      print('Erro na requisição: ${e.message}');
      print('URL: ${e.requestOptions.uri}');
    }
  }

  String get currentBaseUrl => _currentBaseUrl;

  void resetToRenderUrl() {
    _currentBaseUrl = _renderUrl;
    _dio.options.baseUrl = _renderUrl;
  }
}
