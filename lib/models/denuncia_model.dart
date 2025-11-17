class DenunciaModel {
  final int? idDenuncia;
  final int idContrato;
  final int idHospedagem;
  final int idUsuario;
  final String comentario;
  final DateTime dataDenuncia;
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;
  final String? hospedagemNome;
  final String? usuarioNome;
  final DateTime? dataInicioContrato;
  final DateTime? dataFimContrato;

  const DenunciaModel({
    this.idDenuncia,
    required this.idContrato,
    required this.idHospedagem,
    required this.idUsuario,
    required this.comentario,
    required this.dataDenuncia,
    this.dataCriacao,
    this.dataAtualizacao,
    this.hospedagemNome,
    this.usuarioNome,
    this.dataInicioContrato,
    this.dataFimContrato,
  });

  factory DenunciaModel.fromJson(Map<String, dynamic> json) {
    return DenunciaModel(
      idDenuncia: json['iddenuncia'],
      idContrato: json['idcontrato'],
      idHospedagem: json['idhospedagem'],
      idUsuario: json['idusuario'],
      comentario: json['comentario'],
      dataDenuncia: DateTime.parse(json['data_denuncia']),
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
      'dataDenuncia': dataDenuncia.toIso8601String().split('T')[0],
      // ❌ NÃO enviar: idDenuncia, dataCriacao, dataAtualizacao
      // (são gerados automaticamente pelo backend)
    };
  }

  DenunciaModel copyWith({
    int? idDenuncia,
    int? idContrato,
    int? idHospedagem,
    int? idUsuario,
    String? comentario,
    DateTime? dataDenuncia,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
    String? hospedagemNome,
    String? usuarioNome,
    DateTime? dataInicioContrato,
    DateTime? dataFimContrato,
  }) {
    return DenunciaModel(
      idDenuncia: idDenuncia ?? this.idDenuncia,
      idContrato: idContrato ?? this.idContrato,
      idHospedagem: idHospedagem ?? this.idHospedagem,
      idUsuario: idUsuario ?? this.idUsuario,
      comentario: comentario ?? this.comentario,
      dataDenuncia: dataDenuncia ?? this.dataDenuncia,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      hospedagemNome: hospedagemNome ?? this.hospedagemNome,
      usuarioNome: usuarioNome ?? this.usuarioNome,
      dataInicioContrato: dataInicioContrato ?? this.dataInicioContrato,
      dataFimContrato: dataFimContrato ?? this.dataFimContrato,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DenunciaModel &&
        other.idDenuncia == idDenuncia &&
        other.idContrato == idContrato &&
        other.idHospedagem == idHospedagem &&
        other.idUsuario == idUsuario &&
        other.comentario == comentario &&
        other.dataDenuncia == dataDenuncia &&
        other.dataCriacao == dataCriacao &&
        other.dataAtualizacao == dataAtualizacao &&
        other.hospedagemNome == hospedagemNome &&
        other.usuarioNome == usuarioNome &&
        other.dataInicioContrato == dataInicioContrato &&
        other.dataFimContrato == dataFimContrato;
  }

  @override
  int get hashCode {
    return Object.hash(
      idDenuncia,
      idContrato,
      idHospedagem,
      idUsuario,
      comentario,
      dataDenuncia,
      dataCriacao,
      dataAtualizacao,
      hospedagemNome,
      usuarioNome,
      dataInicioContrato,
      dataFimContrato,
    );
  }

  @override
  String toString() {
    return 'DenunciaModel('
        'idDenuncia: $idDenuncia, '
        'idContrato: $idContrato, '
        'idHospedagem: $idHospedagem, '
        'idUsuario: $idUsuario, '
        'comentario: $comentario, '
        'dataDenuncia: $dataDenuncia, '
        'dataCriacao: $dataCriacao, '
        'dataAtualizacao: $dataAtualizacao, '
        'hospedagemNome: $hospedagemNome, '
        'usuarioNome: $usuarioNome, '
        'dataInicioContrato: $dataInicioContrato, '
        'dataFimContrato: $dataFimContrato'
        ')';
  }
}
