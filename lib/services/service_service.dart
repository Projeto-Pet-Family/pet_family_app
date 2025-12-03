// data/datasources/service_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/models/service_model.dart';

class ServiceService {
  static const String baseUrl = 'https://bepetfamily.onrender.com';
  final http.Client client;

  ServiceService({required this.client});

  Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };

  void _handleError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        throw Exception('Dados inválidos fornecidos');
      case 404:
        throw Exception('Recurso não encontrado');
      case 500:
        throw Exception('Erro interno do servidor');
      default:
        throw Exception('Falha na comunicação: ${response.statusCode}');
    }
  }

  Future<List<ServiceModel>> listarServicosPorHospedagem(int idHospedagem) async {
    try {
      print('🔄 ServiceService: Buscando serviços para hospedagem $idHospedagem');
      
      final response = await client.get(
        Uri.parse('$baseUrl/hospedagens/$idHospedagem/servicos'),
        headers: headers,
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<ServiceModel> servicos = data.map((json) {
          try {
            return ServiceModel.fromJson(json);
          } catch (e) {
            print('❌ Erro ao converter JSON: $json');
            print('❌ Erro detalhado: $e');
            return ServiceModel(
              idservico: json['idservico'] ?? 0,
              idhospedagem: idHospedagem,
              descricao: json['descricao']?.toString() ?? 'Serviço não identificado',
              preco: (json['preco'] is String)
                  ? double.tryParse(json['preco']) ?? 0.0
                  : (json['preco'] as num?)?.toDouble() ?? 0.0,
            );
          }
        }).toList();
        
        print('✅ ${servicos.length} serviços convertidos');
        return servicos;
      } else {
        _handleError(response);
        throw Exception('Erro ao listar serviços da hospedagem');
      }
    } catch (e) {
      print('❌ Erro no ServiceService: $e');
      rethrow;
    }
  }

  Future<ServiceModel> criarServico(int idHospedagem, ServiceModel servico) async {
    final response = await client.post(
      Uri.parse('$baseUrl/hospedagens/$idHospedagem/servicos'),
      headers: headers,
      body: json.encode({
        'descricao': servico.descricao,
        'preco': servico.preco,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return ServiceModel.fromJson(data['data']);
    } else {
      _handleError(response);
      throw Exception('Erro ao criar serviço');
    }
  }

  Future<ServiceModel> atualizarServico(ServiceModel servico) async {
    if (servico.idservico == null) {
      throw Exception('ID do serviço é obrigatório');
    }

    final Map<String, dynamic> body = {};
    if (servico.descricao.isNotEmpty) body['descricao'] = servico.descricao;
    if (servico.preco > 0) body['preco'] = servico.preco;

    final response = await client.put(
      Uri.parse('$baseUrl/servicos/${servico.idservico}'),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return ServiceModel.fromJson(data['data']);
    } else {
      _handleError(response);
      throw Exception('Erro ao atualizar serviço');
    }
  }

  Future<void> removerServico(int idServico) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/servicos/$idServico'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      _handleError(response);
      throw Exception('Erro ao remover serviço');
    }
  }
}