class PetModel {
  final int? idpet;
  final int? idusuario;
  final int? idporte;
  final int? idespecie;
  final int? idraca;
  final String? nome;
  final String? sexo;
  final DateTime? nascimento;
  final String? observacoes;

  PetModel({
    this.idpet,
    this.idusuario,
    this.idporte,
    this.idespecie,
    this.idraca,
    this.nome,
    this.sexo,
    this.nascimento,
    this.observacoes,
  });

  // Método copyWith
  PetModel copyWith({
    int? id,
    int? idusuario,
    int? idporte,
    int? idespecie,
    int? idraca,
    String? nome,
    String? sexo,
    DateTime? nascimento,
    String? observacoes,
  }) {
    return PetModel(
      idpet: id ?? this.idpet,
      idusuario: idusuario ?? this.idusuario,
      idporte: idporte ?? this.idporte,
      idespecie: idespecie ?? this.idespecie,
      idraca: idraca ?? this.idraca,
      nome: nome ?? this.nome,
      sexo: sexo ?? this.sexo,
      nascimento: nascimento ?? this.nascimento,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  // Método toJson
  Map<String, dynamic> toJson() {
    return {
      'idusuario': idusuario,
      'idporte': idporte,
      'idespecie': idespecie,
      'idraca': idraca,
      'nome': nome,
      'sexo': sexo,
      'nascimento': nascimento?.toIso8601String(),
      'observacoes': observacoes,
    };
  }

  // Método fromJson (se necessário)
  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      idpet: json['idpet'],
      idusuario: json['idusuario'],
      idporte: json['idporte'],
      idespecie: json['idespecie'],
      idraca: json['idraca'],
      nome: json['nome'],
      sexo: json['sexo'],
      nascimento: json['nascimento'] != null
          ? DateTime.parse(json['nascimento'])
          : null,
      observacoes: json['observacoes'],
    );
  }
}
