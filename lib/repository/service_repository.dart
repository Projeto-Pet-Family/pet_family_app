import 'package:pet_family_app/services/api_service.dart';
import 'package:pet_family_app/models/service_model.dart';

class ServiceRepository {
  final ApiService _api = ApiService();

  Future<List<ServiceModel>> lerServico() async {
    try {
      final response = await _api.get('/hospedagens/1/servicos');

      // Log para debug
      print('Resposta bruta da API: ${response.data}');

      if (response.data is List) {
        final services = (response.data as List)
            .map((json) {
              try {
                print('Convertendo JSON: $json');
                final service = ServiceModel.fromJson(json);
                print(
                    'Serviço convertido: ${service.idServico} - ${service.descricao} - ${service.preco} (${service.preco.runtimeType})');
                return service;
              } catch (e, stack) {
                print('Erro ao converter serviço: $e');
                print('Stack trace: $stack');
                print('JSON problemático: $json');
                return null;
              }
            })
            .whereType<ServiceModel>()
            .toList();

        return services;
      } else {
        throw Exception('Formato de resposta inesperado');
      }
    } catch (e) {
      print('Erro no repositório: $e');
      throw Exception('Erro ao carregar serviços: $e');
    }
  }
}
