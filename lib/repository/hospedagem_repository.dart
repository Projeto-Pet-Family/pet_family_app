import 'package:pet_family_app/services/api_service.dart';
import 'package:pet_family_app/models/hospedagem_model.dart';

class HospedagemRepository {
  final ApiService _api = ApiService();

  Future<List<HospedagemModel>> lerHospedagem() async {
    try {
      final response = await _api.get('/hospedagens');

      // DEBUG para ver a estrutura dos dados
      print('📦 Dados brutos da API: ${response.data}');

      if (response.data is List) {
        final List<HospedagemModel> hospedagens = (response.data as List)
            .map((json) => HospedagemModel.fromJson(json))
            .toList();

        // Debug final
        print('✅ Hospedagens mapeadas:');
        for (var h in hospedagens) {
          print('   - ${h.nome} (ID: ${h.idHospedagem})');
        }

        return hospedagens;
      } else {
        // Se não for lista, cria uma lista com um único item
        return [HospedagemModel.fromJson(response.data)];
      }
    } catch (e) {
      print('❌ Erro no repositório: $e');
      throw Exception('Erro ao carregar hospedagens: $e');
    }
  }

  Future<HospedagemModel> criarHospedagem(HospedagemModel hospedagem) async {
    try {
      final response = await _api.post('/hospedagens', hospedagem.toJson());
      return HospedagemModel.fromJson(response.data);
    } catch (e) {
      print('❌ Erro ao criar hospedagem: $e');
      throw Exception('Erro ao criar hospedagem: $e');
    }
  }

  Future<void> atualizarHospedagem(HospedagemModel hospedagem) async {
    try {
      // ✅ CORREÇÃO: URL corrigida (hospedagem no singular)
      await _api.put(
          '/hospedagem/${hospedagem.idHospedagem}', hospedagem.toJson());
    } catch (e) {
      print('❌ Erro ao atualizar hospedagem: $e');
      throw Exception('Erro ao atualizar hospedagem: $e');
    }
  }

  Future<void> deletarHospedagem(int id) async {
    try {
      // ✅ CORREÇÃO: URL corrigida (hospedagem no singular)
      await _api.delete('/hospedagem/$id');
    } catch (e) {
      print('❌ Erro ao deletar hospedagem: $e');
      throw Exception('Erro ao deletar hospedagem: $e');
    }
  }
}
