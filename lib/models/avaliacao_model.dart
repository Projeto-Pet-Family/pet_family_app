class AvaliacaoModel {
  final int? idAvaliacao;
  final int idContrato;
  final int idHospedagem;
  final int idUsuario;
  final String? comentario;
  final int estrelas;
  final DateTime dataAvaliacao;
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;
  final String? hospedagemNome;
  final String? usuarioNome;
  final DateTime? dataInicioContrato;
  final DateTime? dataFimContrato;

  AvaliacaoModel({
    this.idAvaliacao,
    required this.idContrato,
    required this.idHospedagem,
    required this.idUsuario,
    this.comentario,
    required this.estrelas,
    required this.dataAvaliacao,
    this.dataCriacao,
    this.dataAtualizacao,
    this.hospedagemNome,
    this.usuarioNome,
    this.dataInicioContrato,
    this.dataFimContrato,
  });

  factory AvaliacaoModel.fromJson(Map<String, dynamic> json) {
    return AvaliacaoModel(
      idAvaliacao: json['idavaliacao'],
      idContrato: json['idcontrato'],
      idHospedagem: json['idhospedagem'],
      idUsuario: json['idusuario'],
      comentario: json['comentario'],
      estrelas: json['estrelas'],
      dataAvaliacao: DateTime.parse(json['data_avaliacao']),
      dataCriacao: json['datacriacao'] != null
          ? DateTime.parse(json['datacriacao'])
          : null,
      dataAtualizacao: json['dataatualizacao'] != null
          ? DateTime.parse(json['dataatualizacao'])
          : null,
      hospedagemNome: json['hospedagem_nome'],
      usuarioNome: json['usuario_nome'],
      dataInicioContrato: json['datainicio'] != null
          ? DateTime.parse(json['datainicio'])
          : null,
      dataFimContrato:
          json['datafim'] != null ? DateTime.parse(json['datafim']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // ✅ APENAS campos necessários para criação
      'idContrato': idContrato,
      'idHospedagem': idHospedagem,
      'idUsuario': idUsuario,
      'comentario': comentario,
      'estrelas': estrelas,
      'dataAvaliacao': dataAvaliacao.toIso8601String().split('T')[0],
      // ❌ NÃO enviar: idAvaliacao, dataCriacao, dataAtualizacao
      // (são gerados automaticamente pelo backend)
    };
  }

  AvaliacaoModel copyWith({
    int? idAvaliacao,
    int? idContrato,
    int? idHospedagem,
    int? idUsuario,
    String? comentario,
    int? estrelas,
    DateTime? dataAvaliacao,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
    String? hospedagemNome,
    String? usuarioNome,
    DateTime? dataInicioContrato,
    DateTime? dataFimContrato,
  }) {
    return AvaliacaoModel(
      idAvaliacao: idAvaliacao ?? this.idAvaliacao,
      idContrato: idContrato ?? this.idContrato,
      idHospedagem: idHospedagem ?? this.idHospedagem,
      idUsuario: idUsuario ?? this.idUsuario,
      comentario: comentario ?? this.comentario,
      estrelas: estrelas ?? this.estrelas,
      dataAvaliacao: dataAvaliacao ?? this.dataAvaliacao,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      hospedagemNome: hospedagemNome ?? this.hospedagemNome,
      usuarioNome: usuarioNome ?? this.usuarioNome,
      dataInicioContrato: dataInicioContrato ?? this.dataInicioContrato,
      dataFimContrato: dataFimContrato ?? this.dataFimContrato,
    );
  }
}
