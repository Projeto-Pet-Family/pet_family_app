class PetModel {
  final int idPet;
  final String nome;
  final String sexo;
  final String nascimento;
  final String usuario;
  final String porte;
  final String especie;
  final String raca;

  PetModel({
    required this.idPet,
    required this.nome,
    required this.sexo,
    required this.nascimento,
    required this.usuario,
    required this.porte,
    required this.especie,
    required this.raca,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      idPet: json['IdPet'] ?? 0,
      nome: json['nome'] ?? '',
      sexo: json['sexo'] ?? '',
      nascimento: json['nascimento'] ?? '',
      usuario: json['usuario'] ?? '',
      porte: json['porte'] ?? '',
      especie: json['especie'] ?? '',
      raca: json['raca'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdPet': idPet,
      'nome': nome,
      'sexo': sexo,
      'nascimento': nascimento,
      'usuario': usuario,
      'porte': porte,
      'especie': especie,
      'raca': raca,
    };
  }
}