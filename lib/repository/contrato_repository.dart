// repository/contrato_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/services/api_service.dart';
import 'package:pet_family_app/providers/auth_provider.dart';

class ContratoRepository {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> criarContrato({
    required int idHospedagem,
    required String dataInicio,
    required String dataFim,
    required List<int> pets,
    List<Map<String, dynamic>>? servicos,
  }) async {
    try {
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
      print('🛎️ Serviços: ${servicos ?? "Nenhum serviço selecionado"}');

      // Calcular valores antes de criar o contrato
      final calculo = await calcularValorContrato(
        idHospedagem: idHospedagem,
        dataInicio: dataInicio,
        dataFim: dataFim,
        servicos: servicos,
      );

      final Map<String, dynamic> contratoData = {
        'idHospedagem': idHospedagem,
        'idUsuario': idUsuario,
        'status': 'em_aprovacao',
        'dataInicio': dataInicio,
        'dataFim': dataFim,
        'pets': pets,
        'servicos': servicos ?? [],
        'valor_calculado': calculo,
      };

      print('📦 Dados do contrato: $contratoData');

      final response = await _api.post('/contrato', contratoData);

      print('✅ Contrato criado com sucesso: ${response.data}');

      return {
        'contrato': response.data,
        'calculo': calculo,
      };
    } catch (e) {
      print('❌ Erro ao criar contrato: $e');
      throw Exception('Erro ao criar contrato: $e');
    }
  }

  /// Busca todos os contratos
  Future<List<ContratoModel>> lerContratos() async {
    try {
      final response = await _api.get('/contrato');

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

  /// Busca contrato por ID
  Future<ContratoModel> buscarContratoPorId(int idContrato) async {
    try {
      final response = await _api.get('/contrato/$idContrato');

      return ContratoModel.fromJson(response.data);
    } catch (e) {
      print('❌ Erro ao buscar contrato por ID: $e');
      throw Exception('Erro ao buscar contrato: $e');
    }
  }

  /// Busca contratos por usuário
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
      print('❌ Erro ao buscar contratos do usuário: $e');
      throw Exception('Erro ao buscar contratos do usuário: $e');
    }
  }

  /// Busca contratos por usuário e status
  Future<List<ContratoModel>> buscarContratosPorUsuarioEStatus({
    required int idUsuario,
    required String status,
  }) async {
    try {
      final response =
          await _api.get('/contrato/usuario/$idUsuario?status=$status');

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

  /// Busca contratos por status
  Future<List<ContratoModel>> buscarContratosPorStatus(String status) async {
    try {
      final idUsuario = await AuthProvider.getUserIdFromCache();
      if (idUsuario == null) throw Exception('Usuário não autenticado');

      final response = await _api.get('/contrato?status=$status');

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

  // ========== MÉTODOS DE ATUALIZAÇÃO ==========

  /// Atualiza um contrato existente
  Future<ContratoModel> atualizarContrato(ContratoModel contrato) async {
    try {
      if (contrato.idContrato == null) {
        throw Exception('idContrato não pode ser nulo para atualização');
      }

      print('🔄 Enviando atualização para API...');

      final dadosParaEnviar = contrato.toJson();
      print('📤 Dados sendo enviados:');
      dadosParaEnviar.forEach((key, value) {
        print('   $key: $value (${value.runtimeType})');
      });

      final response = await _api.put(
        '/contrato/${contrato.idContrato}',
        dadosParaEnviar,
      );

      print('📥 Resposta da API: ${response.statusCode}');
      print('📄 Data: ${response.data}');

      if (response.data != null) {
        return ContratoModel.fromJson(response.data);
      } else {
        throw Exception('Resposta vazia da API');
      }
    } catch (e) {
      print('❌ Erro ao atualizar contrato: $e');

      if (e.toString().contains('404')) {
        throw Exception(
            'Serviço temporariamente indisponível. Tente novamente.');
      } else if (e.toString().contains('Network is unreachable')) {
        throw Exception('Sem conexão com a internet. Verifique sua conexão.');
      } else {
        throw Exception('Erro ao atualizar contrato: $e');
      }
    }
  }

  /// Atualiza apenas o status do contrato
  Future<ContratoModel> atualizarStatusContrato({
    required int idContrato,
    required String status,
    String? motivo,
  }) async {
    try {
      print('🔄 Atualizando status do contrato $idContrato para: $status');

      final dados = {'status': status};
      if (motivo != null && motivo.isNotEmpty) {
        dados['motivo'] = motivo;
      }

      final response = await _api.put(
        '/contrato/$idContrato/status',
        dados,
      );

      print('✅ Status atualizado com sucesso: ${response.data}');

      return ContratoModel.fromJson(response.data);
    } catch (e) {
      print('❌ Erro ao atualizar status do contrato: $e');

      // Fallback: tenta atualizar via endpoint geral
      try {
        print('🔄 Tentando atualização via endpoint geral...');
        return await _atualizarStatusViaEndpointGeral(idContrato, status);
      } catch (e2) {
        throw Exception('Erro ao atualizar status: $e');
      }
    }
  }

  /// Atualiza apenas as datas do contrato
  Future<ContratoModel> atualizarDatasContrato({
    required int idContrato,
    required String dataInicio,
    required String dataFim,
  }) async {
    try {
      print('🔄 Atualizando datas do contrato $idContrato');

      final response = await _api.put(
        '/contrato/$idContrato/datas',
        {
          'dataInicio': dataInicio,
          'dataFim': dataFim,
        },
      );

      print('✅ Datas atualizadas com sucesso: ${response.data}');

      return ContratoModel.fromJson(response.data);
    } catch (e) {
      print('❌ Erro ao atualizar datas do contrato: $e');
      throw Exception('Erro ao atualizar datas: $e');
    }
  }

  // ========== MÉTODOS DE EXCLUSÃO ==========

  /// Exclui um contrato
  Future<void> excluirContrato(int idContrato) async {
    try {
      print('🗑️ Excluindo contrato ID: $idContrato');

      await _api.delete('/contrato/$idContrato');

      print('✅ Contrato excluído com sucesso');
    } catch (e) {
      print('❌ Erro ao excluir contrato: $e');

      if (e.toString().contains('23503')) {
        throw Exception(
            'Não é possível excluir o contrato pois está vinculado a outros registros');
      } else {
        throw Exception('Erro ao excluir contrato: $e');
      }
    }
  }

  /// Remove um serviço do contrato
  Future<void> excluirServicoContrato({
    required int idContrato,
    required int idServico,
  }) async {
    try {
      print('🗑️ Removendo serviço $idServico do contrato $idContrato');

      await _api.delete('/contrato/$idContrato/servico/$idServico');

      print('✅ Serviço removido do contrato com sucesso');
    } catch (e) {
      print('❌ Erro ao remover serviço do contrato: $e');
      throw Exception('Erro ao remover serviço: $e');
    }
  }

  /// Remove um pet do contrato
  Future<void> excluirPetContrato({
    required int idContrato,
    required int idPet,
  }) async {
    try {
      print('🗑️ Removendo pet $idPet do contrato $idContrato');

      await _api.delete('/contrato/$idContrato/pet/$idPet');

      print('✅ Pet removido do contrato com sucesso');
    } catch (e) {
      print('❌ Erro ao remover pet do contrato: $e');
      throw Exception('Erro ao remover pet: $e');
    }
  }

  // ========== MÉTODOS DE CÁLCULO E VALIDAÇÃO ==========

  /// Calcula o valor total do contrato
  Future<Map<String, dynamic>> calcularValorContrato({
    required int idHospedagem,
    required String dataInicio,
    required String dataFim,
    List<Map<String, dynamic>>? servicos,
  }) async {
    try {
      print('🧮 Calculando valor do contrato...');

      // Buscar informações da hospedagem
      final hospedagemInfo = await buscarInformacoesHospedagem(idHospedagem);

      if (hospedagemInfo['valor_diaria'] == null) {
        throw Exception('Hospedagem não possui valor de diária configurado');
      }

      final valorDiaria =
          double.parse(hospedagemInfo['valor_diaria'].toString());

      // Calcular quantidade de dias
      final inicio = DateTime.parse(dataInicio);
      final fim = DateTime.parse(dataFim);
      final diff = fim.difference(inicio);
      final quantidadeDias = diff.inDays;

      if (quantidadeDias <= 0) {
        throw Exception('Data fim deve ser posterior à data início');
      }

      // Calcular valor da hospedagem
      final valorHospedagem = valorDiaria * quantidadeDias;

      // Calcular valor dos serviços
      double valorServicos = 0.0;
      List<Map<String, dynamic>> servicosDetalhados = [];

      if (servicos != null && servicos.isNotEmpty) {
        for (final servico in servicos) {
          final servicoInfo = await _buscarPrecoServico(servico['idservico']);
          final quantidade = servico['quantidade'] ?? 1;
          final subtotal = servicoInfo['preco'] * quantidade;

          valorServicos += subtotal;

          servicosDetalhados.add({
            'id': servico['idservico'],
            'descricao': servicoInfo['descricao'],
            'preco_unitario': servicoInfo['preco'],
            'quantidade': quantidade,
            'subtotal': subtotal,
          });
        }
      }

      // Calcular valor total
      final valorTotal = valorHospedagem + valorServicos;

      final resultado = {
        'hospedagem': {
          'id': idHospedagem,
          'nome': hospedagemInfo['nome'],
          'valor_diaria': valorDiaria,
        },
        'periodo': {
          'data_inicio': dataInicio,
          'data_fim': dataFim,
          'quantidade_dias': quantidadeDias,
        },
        'servicos': servicosDetalhados,
        'valores': {
          'hospedagem': valorHospedagem,
          'servicos': valorServicos,
          'total': valorTotal,
        },
        'calculos': {
          'diaria': valorDiaria,
          'dias': quantidadeDias,
          'subtotal_hospedagem': valorHospedagem,
          'subtotal_servicos': valorServicos,
          'total_geral': valorTotal,
        }
      };

      print('💰 Resultado do cálculo: $resultado');

      return resultado;
    } catch (e) {
      print('❌ Erro ao calcular valor do contrato c: $e');
      throw Exception('Erro ao calcular valor do contrato: $e');
    }
  }

  /// Busca informações da hospedagem
  Future<Map<String, dynamic>> buscarInformacoesHospedagem(
      int idHospedagem) async {
    try {
      final response = await _api.get('/hospedagens/$idHospedagem');

      print('🏨 Informações da hospedagem: ${response.data}');

      return response.data;
    } catch (e) {
      print('❌ Erro ao buscar informações da hospedagem: $e');
      throw Exception('Erro ao buscar informações da hospedagem: $e');
    }
  }

  /// Obtém transições de status permitidas para um contrato
  Future<Map<String, dynamic>> obterTransicoesStatus(int idContrato) async {
    try {
      final response =
          await _api.get('/contrato/$idContrato/transicoes-status');

      return response.data;
    } catch (e) {
      print('❌ Erro ao obter transições de status: $e');

      // Fallback: retorna transições padrão
      return {
        'statusAtual': 'em_aprovacao',
        'transicoesPermitidas': ['aprovado', 'negado', 'cancelado'],
        'todasOpcoes': [
          {
            'status': 'em_aprovacao',
            'descricao': 'Em aprovação',
            'permitido': false
          },
          {'status': 'aprovado', 'descricao': 'Aprovado', 'permitido': true},
          {'status': 'negado', 'descricao': 'Negado', 'permitido': true},
          {'status': 'cancelado', 'descricao': 'Cancelado', 'permitido': true},
        ]
      };
    }
  }

  /// Valida se as datas são válidas para um contrato
  Future<Map<String, dynamic>> validarDatasContrato({
    required int idHospedagem,
    required String dataInicio,
    required String dataFim,
    int? idContrato, // Para validação em atualização
  }) async {
    try {
      final response = await _api.post('/contrato/validar-datas', {
        'idHospedagem': idHospedagem,
        'dataInicio': dataInicio,
        'dataFim': dataFim,
        'idContrato': idContrato,
      });

      return response.data;
    } catch (e) {
      print('❌ Erro ao validar datas: $e');

      // Validação básica local
      final inicio = DateTime.parse(dataInicio);
      final fim = DateTime.parse(dataFim);

      if (fim.isBefore(inicio)) {
        throw Exception('Data fim não pode ser anterior à data início');
      }

      if (inicio.isBefore(DateTime.now())) {
        throw Exception('Data início não pode ser anterior à data atual');
      }

      return {'valido': true, 'mensagem': 'Datas válidas'};
    }
  }

  // ========== MÉTODOS AUXILIARES PRIVADOS ==========

  /// Método auxiliar para buscar preço do serviço
  Future<Map<String, dynamic>> _buscarPrecoServico(int idServico) async {
    try {
      final response = await _api.get('/servico/$idServico');
      return {
        'id': idServico,
        'descricao': response.data['descricao'],
        'preco': double.parse(response.data['preco'].toString()),
      };
    } catch (e) {
      print('❌ Erro ao buscar preço do serviço: $e');
      throw Exception('Erro ao buscar preço do serviço: $e');
    }
  }

  /// Fallback para atualização de status via endpoint geral
  Future<ContratoModel> _atualizarStatusViaEndpointGeral(
    int idContrato,
    String status,
  ) async {
    final response = await _api.put(
      '/contrato/$idContrato',
      {'status': status},
    );

    return ContratoModel.fromJson(response.data);
  }

  // ========== MÉTODOS DE RELATÓRIO E ESTATÍSTICAS ==========

  /// Busca estatísticas de contratos do usuário
  Future<Map<String, dynamic>> buscarEstatisticasUsuario() async {
    try {
      final idUsuario = await AuthProvider.getUserIdFromCache();
      if (idUsuario == null) throw Exception('Usuário não autenticado');

      final response =
          await _api.get('/contrato/estatisticas/usuario/$idUsuario');

      return response.data;
    } catch (e) {
      print('❌ Erro ao buscar estatísticas: $e');
      return {
        'total_contratos': 0,
        'em_aprovacao': 0,
        'aprovados': 0,
        'em_execucao': 0,
        'concluidos': 0,
        'cancelados': 0,
      };
    }
  }

  /// Busca histórico de alterações do contrato
  Future<List<dynamic>> buscarHistoricoContrato(int idContrato) async {
    try {
      final response = await _api.get('/contrato/$idContrato/historico');

      if (response.data is List) {
        return response.data as List;
      } else {
        return [];
      }
    } catch (e) {
      print('❌ Erro ao buscar histórico do contrato: $e');
      return [];
    }
  }

  // ========== MÉTODOS DE CANCELAMENTO ESPECÍFICOS ==========

  /// Cancela um contrato
  Future<void> cancelarContrato(int idContrato, {String? motivo}) async {
    try {
      print('🚀 Iniciando cancelamento do contrato ID: $idContrato');

      final dados = {};
      if (motivo != null && motivo.isNotEmpty) {
        dados['motivo'] = motivo;
      }

      final response = await _api.put(
        '/contrato/$idContrato/cancelar',
        dados,
      );

      print('✅ Contrato $idContrato cancelado com sucesso na API');
      print('📊 Resposta da API: ${response.data}');
    } catch (e) {
      print('❌ Erro no endpoint específico de cancelamento: $e');

      // Fallback: tenta atualizar status para cancelado
      try {
        print('🔄 Tentando cancelar via atualização de status...');
        await atualizarStatusContrato(
          idContrato: idContrato,
          status: 'cancelado',
          motivo: motivo,
        );
      } catch (e2) {
        print('❌ Erro na segunda tentativa: $e2');
        throw Exception('Não foi possível cancelar o contrato: $e');
      }
    }
  }

  /// Solicita aprovação de contrato
  Future<void> solicitarAprovacaoContrato(int idContrato) async {
    try {
      print('📝 Solicitando aprovação do contrato: $idContrato');

      await _api.put(
        '/contrato/$idContrato/solicitar-aprovacao',
        {},
      );

      print('✅ Solicitação de aprovação enviada com sucesso');
    } catch (e) {
      print('❌ Erro ao solicitar aprovação: $e');
      throw Exception('Erro ao solicitar aprovação: $e');
    }
  }

  // ========== MÉTODOS DE NOTIFICAÇÃO ==========

  /// Envia notificação sobre alteração no contrato
  Future<void> enviarNotificacaoContrato({
    required int idContrato,
    required String tipo,
    required String mensagem,
  }) async {
    try {
      await _api.post('/contrato/$idContrato/notificacao', {
        'tipo': tipo,
        'mensagem': mensagem,
      });

      print('📢 Notificação enviada para contrato $idContrato');
    } catch (e) {
      print('❌ Erro ao enviar notificação: $e');
      // Não lança exceção para não quebrar o fluxo principal
    }
  }

  
}
