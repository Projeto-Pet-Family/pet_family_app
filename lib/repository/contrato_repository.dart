// repository/contrato_repository.dart
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/services/api_service.dart';
import 'package:pet_family_app/providers/auth_provider.dart';

class ContratoRepository {
  final ApiService _api = ApiService();

  // Criar novo contrato
  Future<ContratoModel> criarContrato(ContratoModel contrato) async {
    try {
      final response = await _api.post('/contrato', contrato.toJson());
      return ContratoModel.fromJson(response.data);
    } catch (e) {
      print('❌ Erro ao criar contrato: $e');
      throw Exception('Erro ao criar contrato: $e');
    }
  }

  // Buscar contratos por usuário
  Future<List<ContratoModel>> buscarContratosPorUsuario(int idUsuario) async {
    try {
      final response = await _api.get('/usuario/$idUsuario/contratos');

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

  // Buscar contratos por status
  Future<List<ContratoModel>> buscarContratosPorStatus(int idStatus) async {
    try {
      final idUsuario = await AuthProvider.getUserIdFromCache();
      if (idUsuario == null) throw Exception('Usuário não autenticado');

      final response =
          await _api.get('/contrato?idusuario=$idUsuario&idstatus=$idStatus');

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
