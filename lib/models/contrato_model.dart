// models/contrato_model.dart
class ContratoModel {
  final int? idContrato;
  final int idHospedagem;
  final int idUsuario;
  final String status;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;

  // Campos opcionais da resposta
  final String? hospedagemNome;
  final String? hospedagemEndereco;
  final String? hospedagemTelefone;
  final String? usuarioNome;
  final String? usuarioEmail;
  final String? usuarioTelefone;
  final String? statusDescricao;
  final List<dynamic>? pets;
  final List<dynamic>? servicos;
  final double? totalServicos;
  final int? duracaoDias;

  // NOVOS CAMPOS PARA A API
  final double? valorDiaria;
  final Map<String, dynamic>? calculoValores;

  ContratoModel({
    this.idContrato,
    required this.idHospedagem,
    required this.idUsuario,
    required this.status,
    required this.dataInicio,
    this.dataFim,
    this.dataCriacao,
    this.dataAtualizacao,
    this.hospedagemNome,
    this.hospedagemEndereco,
    this.hospedagemTelefone,
    this.usuarioNome,
    this.usuarioEmail,
    this.usuarioTelefone,
    this.statusDescricao,
    this.pets,
    this.servicos,
    this.totalServicos,
    this.duracaoDias,
    this.valorDiaria, // NOVO: Valor da diária direto da API
    this.calculoValores, // NOVO: Estrutura completa de cálculo da API
  });

  factory ContratoModel.fromJson(Map<String, dynamic> json) {
    return ContratoModel(
      idContrato: json['idcontrato'] as int?,
      idHospedagem: json['idhospedagem'] as int,
      idUsuario: json['idusuario'] as int,
      status: json['status'] as String,
      dataInicio: DateTime.parse(json['datainicio'] as String),
      dataFim: json['datafim'] != null
          ? DateTime.parse(json['datafim'] as String)
          : null,
      dataCriacao: json['datacriacao'] != null
          ? DateTime.parse(json['datacriacao'] as String)
          : null,
      dataAtualizacao: json['dataatualizacao'] != null
          ? DateTime.parse(json['dataatualizacao'] as String)
          : null,
      hospedagemNome: json['hospedagem_nome'] as String?,
      hospedagemEndereco: _formatarEndereco(json),
      hospedagemTelefone: json['hospedagem_telefone'] as String?,
      usuarioNome: json['usuario_nome'] as String?,
      usuarioEmail: json['usuario_email'] as String?,
      usuarioTelefone: json['usuario_telefone'] as String?,
      statusDescricao: json['status_descricao'] as String?,
      pets: json['pets'] as List<dynamic>?,
      servicos: json['servicos'] as List<dynamic>?,
      totalServicos: (json['total_servicos'] as num?)?.toDouble(),
      duracaoDias: json['duracao_dias'] as int?,
      valorDiaria: _parseDouble(json['valor_diaria']),
      calculoValores: json['calculo_valores'] != null
          ? Map<String, dynamic>.from(json['calculo_valores'])
          : null,
    );
  }

  // MÉTODO AUXILIAR: Formatar endereço a partir do JSON
  static String? _formatarEndereco(Map<String, dynamic> json) {
    final parts = <String>[];

    if (json['logradouro_nome'] != null) parts.add(json['logradouro_nome']);
    if (json['endereco_numero'] != null)
      parts.add(json['endereco_numero'].toString());
    if (json['endereco_complemento'] != null)
      parts.add(json['endereco_complemento']);
    if (json['bairro_nome'] != null) parts.add(json['bairro_nome']);
    if (json['cidade_nome'] != null) parts.add(json['cidade_nome']);
    if (json['estado_sigla'] != null) parts.add(json['estado_sigla']);
    if (json['cep_codigo'] != null) parts.add('CEP: ${json['cep_codigo']}');

    return parts.isNotEmpty ? parts.join(', ') : null;
  }

  // MÉTODO AUXILIAR: Parse de double
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // MÉTODO AUXILIAR: Parse de int
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // MÉTODO: Converter para Map (útil para atualizações)
  Map<String, dynamic> toJson() {
    return {
      'idcontrato': idContrato ?? 0,
      'idhospedagem': idHospedagem,
      'idusuario': idUsuario,
      'status': status,
      'datainicio': dataInicio.toIso8601String(),
      'datafim': dataFim?.toIso8601String(),
      'datacriacao': dataCriacao?.toIso8601String(),
      'dataatualizacao': dataAtualizacao?.toIso8601String(),
      // Campos opcionais - só inclui se não forem null
      if (hospedagemNome != null) 'hospedagem_nome': hospedagemNome,
      if (hospedagemEndereco != null) 'hospedagem_endereco': hospedagemEndereco,
      if (hospedagemTelefone != null) 'hospedagem_telefone': hospedagemTelefone,
      if (usuarioNome != null) 'usuario_nome': usuarioNome,
      if (usuarioEmail != null) 'usuario_email': usuarioEmail,
      if (usuarioTelefone != null) 'usuario_telefone': usuarioTelefone,
      if (statusDescricao != null) 'status_descricao': statusDescricao,
      if (pets != null) 'pets': pets,
      if (servicos != null) 'servicos': servicos,
      if (totalServicos != null) 'total_servicos': totalServicos,
      if (duracaoDias != null) 'duracao_dias': duracaoDias,
      if (valorDiaria != null) 'valor_diaria': valorDiaria,
      if (calculoValores != null) 'calculo_valores': calculoValores,
    };
  }

  // MÉTODO: Criar uma cópia com alguns campos alterados (útil para updates)
  ContratoModel copyWith({
    int? idContrato,
    int? idHospedagem,
    int? idUsuario,
    String? status,
    DateTime? dataInicio,
    DateTime? dataFim,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
    String? hospedagemNome,
    String? hospedagemEndereco,
    String? hospedagemTelefone,
    String? usuarioNome,
    String? usuarioEmail,
    String? usuarioTelefone,
    String? statusDescricao,
    List<dynamic>? pets,
    List<dynamic>? servicos,
    double? totalServicos,
    int? duracaoDias,
    double? valorDiaria,
    Map<String, dynamic>? calculoValores,
  }) {
    return ContratoModel(
      idContrato: idContrato ?? this.idContrato,
      idHospedagem: idHospedagem ?? this.idHospedagem,
      idUsuario: idUsuario ?? this.idUsuario,
      status: status ?? this.status,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      hospedagemNome: hospedagemNome ?? this.hospedagemNome,
      hospedagemEndereco: hospedagemEndereco ?? this.hospedagemEndereco,
      hospedagemTelefone: hospedagemTelefone ?? this.hospedagemTelefone,
      usuarioNome: usuarioNome ?? this.usuarioNome,
      usuarioEmail: usuarioEmail ?? this.usuarioEmail,
      usuarioTelefone: usuarioTelefone ?? this.usuarioTelefone,
      statusDescricao: statusDescricao ?? this.statusDescricao,
      pets: pets ?? this.pets,
      servicos: servicos ?? this.servicos,
      totalServicos: totalServicos ?? this.totalServicos,
      duracaoDias: duracaoDias ?? this.duracaoDias,
      valorDiaria: valorDiaria ?? this.valorDiaria,
      calculoValores: calculoValores ?? this.calculoValores,
    );
  }

  // ========== NOVOS MÉTODOS PARA TRABALHAR COM A API ==========

  // GETTER: Verifica se tem dados calculados da API
  bool get temValoresCalculadosAPI {
    return calculoValores != null && calculoValores!.isNotEmpty;
  }

  // GETTER: Valor total do contrato vindo da API
  double? get valorTotalContrato {
    if (calculoValores?['valor_total_contrato'] != null) {
      return _parseDouble(calculoValores!['valor_total_contrato']);
    }
    return null;
  }

  // GETTER: Valor total da hospedagem vindo da API
  double? get valorTotalHospedagem {
    if (calculoValores?['valor_total_hospedagem'] != null) {
      return _parseDouble(calculoValores!['valor_total_hospedagem']);
    }
    return null;
  }

  // GETTER: Valor total dos serviços vindo da API
  double? get valorTotalServicos {
    if (calculoValores?['valor_total_servicos'] != null) {
      return _parseDouble(calculoValores!['valor_total_servicos']);
    }
    return totalServicos; // Fallback para o campo antigo
  }

  // GETTER: Quantidade de dias vindo da API
  int? get quantidadeDiasAPI {
    if (calculoValores?['quantidade_dias'] != null) {
      return _parseInt(calculoValores!['quantidade_dias']);
    }
    return duracaoDias; // Fallback para o campo antigo
  }

  // GETTER: Valor da diária vindo da API (com fallback)
  double get valorDiariaComFallback {
    if (calculoValores?['valor_diaria'] != null) {
      return _parseDouble(calculoValores!['valor_diaria']) ?? 0.0;
    }
    return valorDiaria ?? 89.90; // Fallback para valor padrão
  }

  // MÉTODO: Obter valor formatado da API
  String? getValorFormatado(String campo) {
    if (temValoresCalculadosAPI) {
      final valorFormatado = calculoValores!['${campo}_formatado'];
      if (valorFormatado is String) {
        return valorFormatado;
      }
    }
    return null;
  }

  // GETTER: Período formatado da API
  String? get periodoFormatadoAPI {
    if (temValoresCalculadosAPI) {
      final periodo = calculoValores!['periodo_dias'];
      if (periodo is String) {
        return periodo;
      }
    }
    return null;
  }

  // GETTER: Valor total formatado (com fallback)
  String get valorTotalFormatado {
    if (temValoresCalculadosAPI) {
      final valorFormatado = getValorFormatado('valor_total_contrato');
      if (valorFormatado != null) {
        return valorFormatado;
      }
    }

    // Fallback: calcular e formatar localmente
    final total = _calcularValorTotalLocal();
    return 'R\$${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // MÉTODO: Calcular valor total localmente (fallback)
  double _calcularValorTotalLocal() {
    final valorHospedagem =
        valorDiariaComFallback * (quantidadeDiasAPI ?? calcularDuracaoDias);
    final valorServicos = valorTotalServicos ?? 0.0;
    return valorHospedagem + valorServicos;
  }

  // MÉTODO: Obter descrição detalhada do status
  String get statusDetalhado {
    final statusMap = {
      'em_aprovacao': 'Aguardando aprovação do anfitrião',
      'aprovado': 'Reserva confirmada - Aguardando check-in',
      'em_execucao': 'Em andamento - Hospedagem ativa',
      'concluido': 'Concluído - Hospedagem finalizada',
      'negado': 'Recusado pelo anfitrião',
      'cancelado': 'Cancelado pelo usuário',
    };
    return statusMap[status] ?? 'Status desconhecido';
  }

  // MÉTODO: Verificar se pode solicitar alteração
  bool get podeSolicitarAlteracao {
    return status == 'em_aprovacao' || status == 'aprovado';
  }

  // MÉTODO: Verificar se está próximo do check-in
  bool get estaProximoCheckIn {
    if (dataInicio.isBefore(DateTime.now())) return false;

    final diferenca = dataInicio.difference(DateTime.now());
    return diferenca.inDays <= 2; // 2 dias ou menos
  }

  // MÉTODO: Verificar se está próximo do check-out
  bool get estaProximoCheckOut {
    if (dataFim == null) return false;
    if (dataFim!.isBefore(DateTime.now())) return false;

    final diferenca = dataFim!.difference(DateTime.now());
    return diferenca.inDays <= 1; // 1 dia ou menos
  }

  // MÉTODO: Obter progresso do contrato (0.0 a 1.0)
  double get progresso {
    final agora = DateTime.now();

    if (agora.isBefore(dataInicio)) return 0.0;
    if (dataFim == null || agora.isAfter(dataFim!)) return 1.0;

    final total = dataFim!.difference(dataInicio).inDays;
    final decorrido = agora.difference(dataInicio).inDays;

    return decorrido / total;
  }

  // ========== MÉTODOS EXISTENTES (MANTIDOS PARA COMPATIBILIDADE) ==========

  // Método auxiliar para obter ID do status (se necessário para compatibilidade)
  int get idStatus {
    final statusMap = {
      'em_aprovacao': 1,
      'aprovado': 2,
      'em_execucao': 3,
      'concluido': 4,
      'negado': 5,
      'cancelado': 6,
    };
    return statusMap[status] ?? 0;
  }

  // Método para calcular a duração em dias (fallback)
  int get calcularDuracaoDias {
    if (dataFim == null) return 0;
    final diff = dataFim!.difference(dataInicio);
    return diff.inDays;
  }

  // Método para verificar se o contrato está ativo
  bool get estaAtivo {
    final statusAtivos = ['em_aprovacao', 'aprovado', 'em_execucao'];
    return statusAtivos.contains(status);
  }

  // Método para verificar se o contrato pode ser editado
  bool get podeEditar {
    final statusEditaveis = ['em_aprovacao'];
    return statusEditaveis.contains(status);
  }

  // Método para verificar se o contrato pode ser cancelado
  bool get podeCancelar {
    return status == 'em_aprovacao' || status == 'aprovado';
  }

  // Avaliação apenas quando concluído
  bool get podeAvaliar {
    return status == 'concluido';
  }

  // Denúncia apenas quando concluído
  bool get podeDenunciar {
    return status == 'concluido';
  }

  // Status formatado para exibição
  String get statusFormatado {
    final statusMap = {
      'em_aprovacao': 'Em Aprovação',
      'aprovado': 'Aprovado',
      'em_execucao': 'Em Execução',
      'concluido': 'Concluído',
      'negado': 'Negado',
      'cancelado': 'Cancelado',
    };
    return statusMap[status] ?? 'Desconhecido';
  }

  // MÉTODO: Para debug - exibir resumo do contrato
  @override
  String toString() {
    return 'ContratoModel{'
        'id: $idContrato, '
        'Hospedagem: $hospedagemNome, '
        'Status: $statusFormatado, '
        'Período: ${dataInicio.toIso8601String().substring(0, 10)} a ${dataFim?.toIso8601String().substring(0, 10)}, '
        'Valor Total: $valorTotalFormatado, '
        'Tem API: $temValoresCalculadosAPI'
        '}';
  }
}
