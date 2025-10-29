// repository/contrato_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/services/api_service.dart';
import 'package:pet_family_app/providers/auth_provider.dart';

class ContratoRepository {
  final ApiService _api = ApiService();

  // Método ÚNICO para criar contrato - use este
  Future<Map<String, dynamic>> criarContrato({
    required int idHospedagem,
    required String dataInicio,
    required String dataFim,
    required List<int> pets,
    required List<Map<String, dynamic>> servicos,
  }) async {
    try {
      // Obter o ID do usuário do cache
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

  // Buscar contratos por usuário - ATUALIZADO para nova estrutura
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

  // Buscar contratos por status - ATUALIZADO para nova estrutura
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
}
