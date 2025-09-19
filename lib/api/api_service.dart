import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _vercelUrl = 'https://bepetfamily.vercel.app';
  final String _localUrl = 'http://192.168.0.107:3000';
  
  String _currentBaseUrl = '';
  
  ApiService() {
    _currentBaseUrl = _vercelUrl;
    _dio.options.baseUrl = _currentBaseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response;
    } on DioException catch (e) {
      if (_shouldTryLocalUrl(e)) {
        return _retryWithLocalUrl('GET', endpoint, queryParameters: queryParameters);
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

  bool _shouldTryLocalUrl(DioException e) {
    // Tenta a URL local se a Vercel estiver inacessível
    // e se ainda não estivermos usando a URL local
    return _currentBaseUrl == _vercelUrl && 
           (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError ||
            (e.response?.statusCode ?? 0) >= 500);
  }

  Future<Response> _retryWithLocalUrl(String method, String endpoint, {
    Map<String, dynamic>? queryParameters,
    dynamic data
  }) async {
    print('Falha na conexão com a Vercel. Tentando URL local...');
    
    // Muda para a URL local
    _currentBaseUrl = _localUrl;
    _dio.options.baseUrl = _localUrl;
    
    try {
      switch (method) {
        case 'GET':
          return await _dio.get(endpoint, queryParameters: queryParameters);
        case 'POST':
          return await _dio.post(endpoint, data: data);
        case 'PUT':
          return await _dio.put(endpoint, data: data);
        case 'DELETE':
          return await _dio.delete(endpoint);
        default:
          throw Exception('Método HTTP não suportado: $method');
      }
    } on DioException catch (e) {
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
  
  void resetToVercelUrl() {
    _currentBaseUrl = _vercelUrl;
    _dio.options.baseUrl = _vercelUrl;
  }
}