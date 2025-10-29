import 'package:pet_family_app/models/service_model.dart';
import 'package:pet_family_app/services/api_service.dart';

class ServiceRepository {
  final ApiService _api = ApiService();

  Future<List<ServiceModel>> lerServico() async {
    try {
      final response = await _api.get('/hospedagens/1/servicos');

      print('Resposta bruta da API: ${response.data}');

      if (response.data is List) {
        final List<dynamic> jsonList = response.data as List;
        final List<ServiceModel> services = [];

        for (int i = 0; i < jsonList.length; i++) {
          try {
            final service = ServiceModel.fromJson(jsonList[i]);
            print(
                'Serviço $i: ID=${service.idServico}, Descrição=${service.descricao}');
            services.add(service);
          } catch (e) {
            print('❌ Erro ao converter serviço $i: $e');
          }
        }

        return services;
      } else {
        print('❌ Response.data não é uma lista: ${response.data}');
        return [];
      }
    } catch (e) {
      print('❌ Erro no ServiceRepository: $e');
      throw Exception('Erro ao carregar serviços: $e');
    }
  }
}
