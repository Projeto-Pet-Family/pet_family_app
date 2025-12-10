// lib/services/status_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/models/contrato_model.dart';

class StatusService {
  // USANDO A URL CORRETA
  static const String baseUrl = 'https://bepetfamily.onrender.com';
  
  // MÉTODO: Filtrar contratos por usuário e status
  Future<Map<String, dynamic>> filtrarContratosUsuarioPorStatus({
    required int idUsuario,
    List<String>? status,
    String? dataInicio,
    String? dataFim,
    String orderBy = 'datacriacao',
    String orderDirection = 'DESC',
  }) async {
    try {
      print('🔄 [StatusService] Iniciando filtro...');
      print('👤 Usuário: $idUsuario');
      print('🎯 Status: ${status?.join(', ') ?? "todos"}');
      print('🌐 URL base: $baseUrl');
      
      // Construir URL com query parameters
      final uri = Uri.parse('$baseUrl/contrato/usuario/$idUsuario/filtrar');
      
      // Criar parâmetros da query
      final params = <String, String>{};
      
      // Adicionar status como múltiplos parâmetros se houver
      if (status != null && status.isNotEmpty) {
        // Para cada status, adicionar como parâmetro separado
        for (var s in status) {
          params['status'] = s;
        }
        print('📌 Status adicionados à query: $status');
      }
      
      // Adicionar parâmetros de ordenação
      params['orderBy'] = orderBy;
      params['orderDirection'] = orderDirection;
      
      // Construir URL final com parâmetros
      final urlWithParams = uri.replace(queryParameters: params);
      
      print('🔗 URL completa: ${urlWithParams.toString()}');
      
      // Fazer requisição GET com timeout
      final response = await http.get(
        urlWithParams,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30), onTimeout: () {
        throw Exception('Timeout ao conectar com o servidor (30 segundos)');
      });
      
      print('📡 Status da resposta: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('✅ Sucesso! Contratos encontrados: ${responseData['data']?.length ?? 0}');
        
        // Converter dados para lista de ContratoModel
        List<ContratoModel> contratos = [];
        
        if (responseData['data'] is List) {
          for (var item in responseData['data']) {
            try {
              final contrato = ContratoModel.fromJson(item);
              contratos.add(contrato);
            } catch (e) {
              print('⚠️ Erro ao converter contrato: $e');
            }
          }
        }
        
        return {
          'success': true,
          'contratos': contratos,
          'estatisticas': responseData['estatisticas'] ?? {},
          'filtros': responseData['filtros'] ?? {},
          'message': responseData['message'] ?? 'Contratos filtrados com sucesso',
          'total': contratos.length,
        };
      } else {
        // Erro na resposta
        print('❌ Erro HTTP: ${response.statusCode}');
        
        Map<String, dynamic> errorData = {};
        try {
          errorData = json.decode(response.body);
        } catch (e) {
          errorData = {'message': 'Erro ${response.statusCode}: ${response.body}'};
        }
        
        return {
          'success': false,
          'message': errorData['message'] ?? 'Erro ao filtrar contratos',
          'error': errorData,
          'statusCode': response.statusCode,
        };
      }
    } catch (error) {
      print('💥 Erro no StatusService: $error');
      
      return {
        'success': false,
        'message': 'Erro de conexão: $error',
        'error': error.toString(),
        'statusCode': 0,
      };
    }
  }
}