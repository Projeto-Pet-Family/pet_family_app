// domain/repositories/raca_repository.dart
import 'package:pet_family_app/models/pet/raca_model.dart';
import 'package:pet_family_app/services/pet/raca_service.dart';

abstract class RacaRepository {
  Future<List<RacaModel>> listarRacas();
  Future<List<RacaModel>> listarRacasPorEspecie(int idEspecie);
  Future<RacaModel> criarRaca(RacaModel raca);
  Future<RacaModel> atualizarRaca(int idRaca, RacaModel raca);
  Future<void> excluirRaca(int idRaca);
}

class RacaRepositoryImpl implements RacaRepository {
  final RacaService racaService;

  RacaRepositoryImpl({required this.racaService});

  @override
  Future<List<RacaModel>> listarRacas() async {
    try {
      return await racaService.listarRacas();
    } catch (e) {
      throw Exception('Erro no repositório ao listar raças: ${e.toString()}');
    }
  }

  @override
  Future<List<RacaModel>> listarRacasPorEspecie(int idEspecie) async {
    try {
      return await racaService.listarRacasPorEspecie(idEspecie);
    } catch (e) {
      throw Exception('Erro ao listar raças por espécie: ${e.toString()}');
    }
  }

  @override
  Future<RacaModel> criarRaca(RacaModel raca) async {
    try {
      return await racaService.criarRaca(raca);
    } catch (e) {
      throw Exception('Erro ao criar raça: ${e.toString()}');
    }
  }

  @override
  Future<RacaModel> atualizarRaca(int idRaca, RacaModel raca) async {
    try {
      return await racaService.atualizarRaca(idRaca, raca);
    } catch (e) {
      throw Exception('Erro ao atualizar raça: ${e.toString()}');
    }
  }

  @override
  Future<void> excluirRaca(int idRaca) async {
    try {
      await racaService.excluirRaca(idRaca);
    } catch (e) {
      throw Exception('Erro ao excluir raça: ${e.toString()}');
    }
  }
}