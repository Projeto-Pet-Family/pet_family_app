// domain/repositories/especie_repository.dart
import 'package:pet_family_app/models/pet/especie_model.dart';
import 'package:pet_family_app/services/pet/especie_service.dart';

abstract class EspecieRepository {
  Future<List<EspecieModel>> listarEspecies();
  Future<EspecieModel> buscarEspeciePorId(int idEspecie);
  Future<EspecieModel> criarEspecie(EspecieModel especie);
  Future<EspecieModel> atualizarEspecie(int idEspecie, EspecieModel especie);
  Future<void> excluirEspecie(int idEspecie);
}


class EspecieRepositoryImpl implements EspecieRepository {
  final EspecieService especieService;

  EspecieRepositoryImpl({required this.especieService});

  @override
  Future<List<EspecieModel>> listarEspecies() async {
    try {
      return await especieService.listarEspecies();
    } catch (e) {
      throw Exception('Erro no repositório ao listar espécies: ${e.toString()}');
    }
  }

  @override
  Future<EspecieModel> buscarEspeciePorId(int idEspecie) async {
    try {
      return await especieService.buscarEspeciePorId(idEspecie);
    } catch (e) {
      throw Exception('Erro ao buscar espécie: ${e.toString()}');
    }
  }

  @override
  Future<EspecieModel> criarEspecie(EspecieModel especie) async {
    try {
      return await especieService.criarEspecie(especie);
    } catch (e) {
      throw Exception('Erro ao criar espécie: ${e.toString()}');
    }
  }

  @override
  Future<EspecieModel> atualizarEspecie(int idEspecie, EspecieModel especie) async {
    try {
      return await especieService.atualizarEspecie(idEspecie, especie);
    } catch (e) {
      throw Exception('Erro ao atualizar espécie: ${e.toString()}');
    }
  }

  @override
  Future<void> excluirEspecie(int idEspecie) async {
    try {
      await especieService.excluirEspecie(idEspecie);
    } catch (e) {
      throw Exception('Erro ao excluir espécie: ${e.toString()}');
    }
  }
}