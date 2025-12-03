// domain/repositories/service_repository.dart
import 'package:pet_family_app/models/service_model.dart';
import 'package:pet_family_app/services/service_service.dart';

abstract class ServiceRepository {
  Future<List<ServiceModel>> listarServicosPorHospedagem(int idHospedagem);
  Future<ServiceModel> criarServico(int idHospedagem, ServiceModel servico);
  Future<ServiceModel> atualizarServico(ServiceModel servico);
  Future<void> removerServico(int idServico);
}

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceService serviceService;

  ServiceRepositoryImpl({required this.serviceService});

  @override
  Future<List<ServiceModel>> listarServicosPorHospedagem(int idHospedagem) async {
    try {
      return await serviceService.listarServicosPorHospedagem(idHospedagem);
    } catch (e) {
      throw Exception('Erro ao listar serviços: ${e.toString()}');
    }
  }

  @override
  Future<ServiceModel> criarServico(int idHospedagem, ServiceModel servico) async {
    try {
      return await serviceService.criarServico(idHospedagem, servico);
    } catch (e) {
      throw Exception('Erro ao criar serviço: ${e.toString()}');
    }
  }

  @override
  Future<ServiceModel> atualizarServico(ServiceModel servico) async {
    try {
      return await serviceService.atualizarServico(servico);
    } catch (e) {
      throw Exception('Erro ao atualizar serviço: ${e.toString()}');
    }
  }

  @override
  Future<void> removerServico(int idServico) async {
    try {
      await serviceService.removerServico(idServico);
    } catch (e) {
      throw Exception('Erro ao remover serviço: ${e.toString()}');
    }
  }
}