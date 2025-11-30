// domain/repositories/porte_repository.dart
import 'package:pet_family_app/models/pet/porte_model.dart';
import 'package:pet_family_app/services/pet/porte_service.dart';

abstract class PorteRepository {
  Future<List<PorteModel>> listarPortes();
  Future<PorteModel> criarPorte(PorteModel porte);
  Future<PorteModel> atualizarPorte(int idPorte, PorteModel porte);
  Future<void> excluirPorte(int idPorte);
}

class PorteRepositoryImpl implements PorteRepository {
  final PorteService porteService;

  PorteRepositoryImpl({required this.porteService});

  @override
  Future<List<PorteModel>> listarPortes() async {
    try {
      return await porteService.listarPortes();
    } catch (e) {
      throw Exception('Erro no repositório ao listar portes: ${e.toString()}');
    }
  }

  @override
  Future<PorteModel> criarPorte(PorteModel porte) async {
    try {
      return await porteService.criarPorte(porte);
    } catch (e) {
      throw Exception('Erro ao criar porte: ${e.toString()}');
    }
  }

  @override
  Future<PorteModel> atualizarPorte(int idPorte, PorteModel porte) async {
    try {
      return await porteService.atualizarPorte(idPorte, porte);
    } catch (e) {
      throw Exception('Erro ao atualizar porte: ${e.toString()}');
    }
  }

  @override
  Future<void> excluirPorte(int idPorte) async {
    try {
      await porteService.excluirPorte(idPorte);
    } catch (e) {
      throw Exception('Erro ao excluir porte: ${e.toString()}');
    }
  }
}