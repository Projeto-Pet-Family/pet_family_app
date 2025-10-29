// models/contrato_model.dart
class ContratoModel {
  final int? idContrato;
  final int idHospedagem;
  final int idUsuario;
  final int idStatus;
  final DateTime dataInicio;
  final DateTime dataFim;
  final DateTime? dataCriacao;

  ContratoModel({
    this.idContrato,
    required this.idHospedagem,
    required this.idUsuario,
    required this.idStatus,
    required this.dataInicio,
    required this.dataFim,
    this.dataCriacao,
  });

  factory ContratoModel.fromJson(Map<String, dynamic> json) {
    return ContratoModel(
      idContrato: json['idcontrato'] as int?,
      idHospedagem: json['idhospedagem'] as int,
      idUsuario: json['idusuario'] as int,
      idStatus: json['idstatus'] as int,
      dataInicio: DateTime.parse(json['datainicio'] as String),
      dataFim: DateTime.parse(json['datafim'] as String),
      dataCriacao: json['datacriacao'] != null
          ? DateTime.parse(json['datacriacao'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idContrato != null) 'idcontrato': idContrato,
      'idhospedagem': idHospedagem,
      'idusuario': idUsuario,
      'idstatus': idStatus,
      'datainicio': dataInicio.toIso8601String(),
      'datafim': dataFim.toIso8601String(),
      if (dataCriacao != null) 'datacriacao': dataCriacao!.toIso8601String(),
    };
  }
}
