// data/models/porte_model.dart
class PorteModel {
  final int? idPorte;
  final String descricao;

  PorteModel({
    this.idPorte,
    required this.descricao,
  });

  factory PorteModel.fromJson(Map<String, dynamic> json) {
    return PorteModel(
      idPorte: json['idporte'] ?? json['idPorte'],
      descricao: json['descricao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idPorte != null) 'idPorte': idPorte,
      'descricao': descricao,
    };
  }

  PorteModel copyWith({
    int? idPorte,
    String? descricao,
  }) {
    return PorteModel(
      idPorte: idPorte ?? this.idPorte,
      descricao: descricao ?? this.descricao,
    );
  }

  @override
  String toString() => descricao;
}
