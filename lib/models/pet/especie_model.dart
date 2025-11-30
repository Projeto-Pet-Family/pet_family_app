// data/models/especie_model.dart
class EspecieModel {
  final int? idEspecie;
  final String descricao;

  EspecieModel({
    this.idEspecie,
    required this.descricao,
  });

  factory EspecieModel.fromJson(Map<String, dynamic> json) {
    return EspecieModel(
      idEspecie: json['idespecie'] ?? json['idEspecie'],
      descricao: json['descricao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idEspecie != null) 'idEspecie': idEspecie,
      'descricao': descricao,
    };
  }

  EspecieModel copyWith({
    int? idEspecie,
    String? descricao,
  }) {
    return EspecieModel(
      idEspecie: idEspecie ?? this.idEspecie,
      descricao: descricao ?? this.descricao,
    );
  }

  @override
  String toString() => descricao;
}
