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
      hospedagemEndereco: json['hospedagem_endereco'] as String?,
      hospedagemTelefone: json['hospedagem_telefone'] as String?,
      usuarioNome: json['usuario_nome'] as String?,
      usuarioEmail: json['usuario_email'] as String?,
      usuarioTelefone: json['usuario_telefone'] as String?,
      statusDescricao: json['status_descricao'] as String?,
      pets: json['pets'] as List<dynamic>?,
      servicos: json['servicos'] as List<dynamic>?,
      totalServicos: (json['total_servicos'] as num?)?.toDouble(),
      duracaoDias: json['duracao_dias'] as int?,
    );
  }

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

  // Método para converter para Map (útil para atualizações)
  Map<String, dynamic> toJson() {
    return {
      'idcontrato': idContrato,
      'idhospedagem': idHospedagem,
      'idusuario': idUsuario,
      'status': status,
      'datainicio': dataInicio.toIso8601String(),
      'datafim': dataFim?.toIso8601String(),
      'datacriacao': dataCriacao?.toIso8601String(),
      'dataatualizacao': dataAtualizacao?.toIso8601String(),
      'hospedagem_nome': hospedagemNome,
      'hospedagem_endereco': hospedagemEndereco,
      'hospedagem_telefone': hospedagemTelefone,
      'usuario_nome': usuarioNome,
      'usuario_email': usuarioEmail,
      'usuario_telefone': usuarioTelefone,
      'status_descricao': statusDescricao,
      'pets': pets,
      'servicos': servicos,
      'total_servicos': totalServicos,
      'duracao_dias': duracaoDias,
    };
  }

  // Método para criar uma cópia com alguns campos alterados (útil para updates)
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
    );
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
    final statusCancelaveis = ['em_aprovacao', 'aprovado'];
    return statusCancelaveis.contains(status);
  }
}
