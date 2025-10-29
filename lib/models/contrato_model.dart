// models/contrato_model.dart
class ContratoModel {
  final int? idContrato;
  final int idHospedagem;
  final int idUsuario;
  final String status; // Agora é String
  final DateTime dataInicio;
  final DateTime? dataFim;
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;

  // Campos opcionais da resposta
  final String? hospedagemNome;
  final String? statusDescricao;
  final List<dynamic>? pets;
  final List<dynamic>? servicos;
  final double? totalServicos;

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
    this.statusDescricao,
    this.pets,
    this.servicos,
    this.totalServicos,
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
      statusDescricao: json['status_descricao'] as String?,
      pets: json['pets'] as List<dynamic>?,
      servicos: json['servicos'] as List<dynamic>?,
      totalServicos: (json['total_servicos'] as num?)?.toDouble(),
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
}
