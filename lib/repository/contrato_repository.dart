// repository/contrato_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/services/api_service.dart';
import 'package:pet_family_app/providers/auth_provider.dart';

class ContratoRepository {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> criarContrato({
    required int idHospedagem,
    required String dataInicio,
    required String dataFim,
    required List<int> pets,
    required List<Map<String, dynamic>> servicos,
  }) async {
    try {
      final idUsuario = await AuthProvider.getUserIdFromCache();

      if (idUsuario == null) {
        throw Exception('Usuário não autenticado. Faça login novamente.');
      }

      print('📤 Enviando contrato para API...');
      print('🏨 ID Hospedagem: $idHospedagem');
      print('👤 ID Usuário: $idUsuario');
      print('📅 Data Início: $dataInicio');
      print('📅 Data Fim: $dataFim');
      print('🐾 Pets: $pets');
      print('🛎️ Serviços: $servicos');

      final Map<String, dynamic> contratoData = {
        'idHospedagem': idHospedagem,
        'idUsuario': idUsuario,
        'status': 'em_aprovacao',
        'dataInicio': dataInicio,
        'dataFim': dataFim,
        'pets': pets,
        'servicos': servicos,
      };

      print('📦 Dados do contrato: $contratoData');

      final response = await _api.post('/contrato', contratoData);

      print('✅ Contrato criado com sucesso: ${response.data}');

      return response.data;
    } catch (e) {
      print('❌ Erro ao criar contrato: $e');
      throw Exception('Erro ao criar contrato: $e');
    }
  }

  Future<List<ContratoModel>> buscarContratosPorUsuario(int idUsuario) async {
    try {
      final response = await _api.get('/contrato/usuario/$idUsuario');

      if (response.data is List) {
        final List<dynamic> jsonList = response.data as List;
        return jsonList.map((json) => ContratoModel.fromJson(json)).toList();
      } else {
        print('❌ Response.data não é uma lista: ${response.data}');
        return [];
      }
    } catch (e) {
      print('❌ Erro ao buscar contratos: $e');
      throw Exception('Erro ao buscar contratos: $e');
    }
  }

  Future<List<ContratoModel>> buscarContratosPorStatus(String status) async {
    try {
      final idUsuario = await AuthProvider.getUserIdFromCache();
      if (idUsuario == null) throw Exception('Usuário não autenticado');

      final response = await _api
          .get('/contrato/usuario?idUsuario=$idUsuario&status=$status');

      if (response.data is List) {
        final List<dynamic> jsonList = response.data as List;
        return jsonList.map((json) => ContratoModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Erro ao buscar contratos por status: $e');
      throw Exception('Erro ao buscar contratos por status: $e');
    }
  }

  Future<void> cancelarContrato(int idContrato) async {
    try {
      print('🚀 Iniciando cancelamento do contrato ID: $idContrato');

      // Tenta usar endpoint específico para cancelamento
      final response = await _api.put(
        '/contrato/$idContrato/cancelar',
        {},
      );

      print('✅ Contrato $idContrato cancelado com sucesso na API');
      print('📊 Resposta da API: ${response.data}');
    } catch (e) {
      print('❌ Erro no endpoint específico, tentando atualização geral: $e');

      // Se o endpoint específico não existir, tenta atualizar o status
      try {
        print('🔄 Tentando atualizar status via PUT...');
        await _atualizarStatusContrato(idContrato, 'cancelado');
      } catch (e2) {
        print('❌ Erro na segunda tentativa: $e2');
        throw Exception('Não foi possível cancelar o contrato: $e');
      }
    }
  }

  Future<void> _atualizarStatusContrato(int idContrato, String status) async {
    try {
      final response = await _api.put(
        '/contrato/$idContrato',
        {'status': status},
      );

      print('✅ Status do contrato $idContrato atualizado para: $status');
      print('📊 Resposta: ${response.data}');
    } catch (e) {
      print('❌ Erro ao atualizar status do contrato: $e');
      throw Exception('Erro ao atualizar status: $e');
    }
  }

  // repository/contrato_repository.dart - ADICIONE ESTE MÉTODO

  // repository/contrato_repository.dart
  Future<ContratoModel> atualizarContrato(ContratoModel contrato) async {
    try {
      print('🔄 Enviando atualização para API...');

      // DEBUG: Verifique os dados antes de enviar
      final dadosParaEnviar = contrato.toJson();
      print('📤 Dados sendo enviados:');
      dadosParaEnviar.forEach((key, value) {
        print('   $key: $value (${value.runtimeType})');
      });

      // Verifique se os campos obrigatórios estão presentes
      if (contrato.idContrato == null) {
        throw Exception('idContrato não pode ser nulo para atualização');
      }

      // ✅ USE O ApiService EM VEZ DE http.put DIRETO
      final response = await _api.put(
        '/contrato/${contrato.idContrato}',
        dadosParaEnviar, // Já é um Map<String, dynamic>
      );

      print('📥 Resposta da API: ${response.statusCode}');
      print('📄 Data: ${response.data}');

      // O ApiService já deve lidar com o status code, mas vamos verificar
      if (response.data != null) {
        return ContratoModel.fromJson(response.data);
      } else {
        throw Exception('Resposta vazia da API');
      }
    } catch (e) {
      print('❌ Erro no ContratoRepository.atualizarContrato: $e');

      // Mensagem mais amigável para o usuário
      if (e.toString().contains('404')) {
        throw Exception(
            'Serviço temporariamente indisponível. Tente novamente.');
      } else if (e.toString().contains('Network is unreachable')) {
        throw Exception('Sem conexão com a internet. Verifique sua conexão.');
      } else {
        throw Exception('Erro ao atualizar contrato: $e');
      }
    }
  }
}
