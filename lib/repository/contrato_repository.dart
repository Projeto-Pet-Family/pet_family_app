// repository/contrato_repository.dart

import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/services/contrato_service.dart';

abstract class ContratoRepository {
  Future<Map<String, dynamic>> calcularValorContrato({
    required int idHospedagem,
    required String dataInicio,
    required String dataFim,
    List<Map<String, dynamic>>? servicos,
  });
  
  Future<ContratoModel> criarContrato({
    required int idHospedagem,
    required int idUsuario,
    required String dataInicio,
    required String dataFim,
    required List<int> pets,
    List<Map<String, dynamic>>? servicos,
    String status = 'em_aprovacao',
  });
  
  Future<ContratoModel> buscarContratoPorId(int idContrato);
  
  Future<List<ContratoModel>> listarContratosPorUsuario(int idUsuario);
  
  Future<List<ContratoModel>> listarContratosPorUsuarioEStatus(
    int idUsuario, 
    String status
  );
  
  Future<ContratoModel> atualizarStatusContrato({
    required int idContrato,
    required String status,
    String? motivo,
  });
  
  Future<Map<String, dynamic>> obterTransicoesStatus(int idContrato);
  
  Future<ContratoModel> adicionarServicoContrato({
    required int idContrato,
    required List<Map<String, dynamic>> servicos,
  });
  
  Future<ContratoModel> adicionarPetContrato({
    required int idContrato,
    required List<int> pets,
  });
  
  Future<ContratoModel> atualizarDatasContrato({
    required int idContrato,
    String? dataInicio,
    String? dataFim,
  });
  
  Future<Map<String, dynamic>> removerServicoContrato({
    required int idContrato,
    required int idServico,
  });
  
  Future<Map<String, dynamic>> removerPetContrato({
    required int idContrato,
    required int idPet,
  });
  
  Future<Map<String, dynamic>> obterCalculoDetalhadoContrato(int idContrato);
  
  Future<Map<String, dynamic>> excluirContrato(int idContrato);
}

class ContratoRepositoryImpl implements ContratoRepository {
  final ContratoService contratoService;

  ContratoRepositoryImpl({required this.contratoService});

  @override
  Future<Map<String, dynamic>> calcularValorContrato({
    required int idHospedagem,
    required String dataInicio,
    required String dataFim,
    List<Map<String, dynamic>>? servicos,
  }) async {
    try {
      print('📊 Repository: Calculando valor do contrato');
      return await contratoService.calcularValorContrato(
        idHospedagem: idHospedagem,
        dataInicio: dataInicio,
        dataFim: dataFim,
        servicos: servicos,
      );
    } catch (e) {
      print('❌ Repository: Erro ao calcular valor: $e');
      rethrow;
    }
  }

  @override
  Future<ContratoModel> criarContrato({
    required int idHospedagem,
    required int idUsuario,
    required String dataInicio,
    required String dataFim,
    required List<int> pets,
    List<Map<String, dynamic>>? servicos,
    String status = 'em_aprovacao',
  }) async {
    try {
      print('📝 Repository: Criando contrato');
      final response = await contratoService.criarContrato(
        idHospedagem: idHospedagem,
        idUsuario: idUsuario,
        dataInicio: dataInicio,
        dataFim: dataFim,
        pets: pets,
        servicos: servicos,
        status: status,
      );
      
      return ContratoModel.fromJson(response['data']);
    } catch (e) {
      print('❌ Repository: Erro ao criar contrato: $e');
      rethrow;
    }
  }

  @override
  Future<ContratoModel> buscarContratoPorId(int idContrato) async {
    try {
      print('🔍 Repository: Buscando contrato ID: $idContrato');
      return await contratoService.buscarContratoPorId(idContrato);
    } catch (e) {
      print('❌ Repository: Erro ao buscar contrato: $e');
      rethrow;
    }
  }

  @override
  Future<List<ContratoModel>> listarContratosPorUsuario(int idUsuario) async {
    try {
      print('📋 Repository: Listando contratos do usuário: $idUsuario');
      return await contratoService.listarContratosPorUsuario(idUsuario);
    } catch (e) {
      print('❌ Repository: Erro ao listar contratos: $e');
      rethrow;
    }
  }

  @override
  Future<List<ContratoModel>> listarContratosPorUsuarioEStatus(
    int idUsuario, 
    String status
  ) async {
    try {
      print('📋 Repository: Listando contratos do usuário $idUsuario com status: $status');
      return await contratoService.listarContratosPorUsuarioEStatus(idUsuario, status);
    } catch (e) {
      print('❌ Repository: Erro ao listar contratos por status: $e');
      rethrow;
    }
  }

  @override
  Future<ContratoModel> atualizarStatusContrato({
    required int idContrato,
    required String status,
    String? motivo,
  }) async {
    try {
      print('🔄 Repository: Atualizando status do contrato');
      return await contratoService.atualizarStatusContrato(
        idContrato: idContrato,
        status: status,
        motivo: motivo,
      );
    } catch (e) {
      print('❌ Repository: Erro ao atualizar status: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> obterTransicoesStatus(int idContrato) async {
    try {
      print('🔄 Repository: Obtendo transições de status');
      return await contratoService.obterTransicoesStatus(idContrato);
    } catch (e) {
      print('❌ Repository: Erro ao obter transições: $e');
      rethrow;
    }
  }

  @override
  Future<ContratoModel> adicionarServicoContrato({
    required int idContrato,
    required List<Map<String, dynamic>> servicos,
  }) async {
    try {
      print('➕ Repository: Adicionando serviço ao contrato');
      return await contratoService.adicionarServicoContrato(
        idContrato: idContrato,
        servicos: servicos,
      );
    } catch (e) {
      print('❌ Repository: Erro ao adicionar serviço: $e');
      rethrow;
    }
  }

  @override
  Future<ContratoModel> adicionarPetContrato({
    required int idContrato,
    required List<int> pets,
  }) async {
    try {
      print('➕ Repository: Adicionando pet ao contrato');
      return await contratoService.adicionarPetContrato(
        idContrato: idContrato,
        pets: pets,
      );
    } catch (e) {
      print('❌ Repository: Erro ao adicionar pet: $e');
      rethrow;
    }
  }

  @override
  Future<ContratoModel> atualizarDatasContrato({
    required int idContrato,
    String? dataInicio,
    String? dataFim,
  }) async {
    try {
      print('📅 Repository: Atualizando datas do contrato');
      return await contratoService.atualizarDatasContrato(
        idContrato: idContrato,
        dataInicio: dataInicio,
        dataFim: dataFim,
      );
    } catch (e) {
      print('❌ Repository: Erro ao atualizar datas: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> removerServicoContrato({
    required int idContrato,
    required int idServico,
  }) async {
    try {
      print('➖ Repository: Removendo serviço do contrato');
      return await contratoService.removerServicoContrato(
        idContrato: idContrato,
        idServico: idServico,
      );
    } catch (e) {
      print('❌ Repository: Erro ao remover serviço: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> removerPetContrato({
    required int idContrato,
    required int idPet,
  }) async {
    try {
      print('➖ Repository: Removendo pet do contrato');
      return await contratoService.removerPetContrato(
        idContrato: idContrato,
        idPet: idPet,
      );
    } catch (e) {
      print('❌ Repository: Erro ao remover pet: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> obterCalculoDetalhadoContrato(int idContrato) async {
    try {
      print('🧮 Repository: Obtendo cálculo detalhado');
      return await contratoService.obterCalculoDetalhadoContrato(idContrato);
    } catch (e) {
      print('❌ Repository: Erro ao obter cálculo: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> excluirContrato(int idContrato) async {
    try {
      print('🗑️ Repository: Excluindo contrato');
      return await contratoService.excluirContrato(idContrato);
    } catch (e) {
      print('❌ Repository: Erro ao excluir contrato: $e');
      rethrow;
    }
  }

  // Método auxiliar para fallback - calcular localmente
  Map<String, dynamic> calcularValorLocalmenteFallback({
    required double valorDiaria,
    required int quantidadeDias,
    required int quantidadePets,
    required double totalServicos,
  }) {
    return contratoService.calcularValorLocalmente(
      valorDiaria: valorDiaria,
      quantidadeDias: quantidadeDias,
      quantidadePets: quantidadePets,
      totalServicos: totalServicos,
    );
  }
}