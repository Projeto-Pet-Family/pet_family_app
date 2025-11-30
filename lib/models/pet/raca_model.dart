// data/models/raca_model.dart
class RacaModel {
  final int? idRaca;
  final String descricao;
  final int? idEspecie;
  final String? descricaoEspecie;

  RacaModel({
    this.idRaca,
    required this.descricao,
    this.idEspecie,
    this.descricaoEspecie,
  });

  factory RacaModel.fromJson(Map<String, dynamic> json) {
    return RacaModel(
      idRaca: json['idraca'] ?? json['idRaca'],
      descricao: json['descricao'],
      idEspecie: json['idespecie'] ?? json['idEspecie'],
      descricaoEspecie: json['descricaoespecie'] ?? json['descricaoEspecie'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idRaca != null) 'idRaca': idRaca,
      'descricao': descricao,
      if (idEspecie != null) 'idEspecie': idEspecie,
    };
  }

  RacaModel copyWith({
    int? idRaca,
    String? descricao,
    int? idEspecie,
    String? descricaoEspecie,
  }) {
    return RacaModel(
      idRaca: idRaca ?? this.idRaca,
      descricao: descricao ?? this.descricao,
      idEspecie: idEspecie ?? this.idEspecie,
      descricaoEspecie: descricaoEspecie ?? this.descricaoEspecie,
    );
  }

  @override
  String toString() => descricao;
}
