// data/models/pet_model.dart
class PetModel {
  final int? idPet;
  final int? idUsuario;
  final int? idPorte;
  final int? idEspecie;
  final int? idRaca;
  final String? nome;
  final String? sexo;
  final DateTime? nascimento;
  final String? observacoes;
  final List<dynamic>? servicos; // ADICIONADO: Campo para serviços do pet

  // Campos opcionais para joins
  final String? nomeUsuario;
  final String? descricaoPorte;
  final String? descricaoEspecie;
  final String? descricaoRaca;

  PetModel({
    this.idPet,
    this.idUsuario,
    this.idPorte,
    this.idEspecie,
    this.idRaca,
    this.nome,
    this.sexo,
    this.nascimento,
    this.observacoes,
    this.servicos, // ADICIONADO
    this.nomeUsuario,
    this.descricaoPorte,
    this.descricaoEspecie,
    this.descricaoRaca,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      idPet: json['idpet'] ?? json['idPet'],
      idUsuario: json['idusuario'] ?? json['idUsuario'],
      idPorte: json['idporte'] ?? json['idPorte'],
      idEspecie: json['idespecie'] ?? json['idEspecie'],
      idRaca: json['idraca'] ?? json['idRaca'],
      nome: json['nome'],
      sexo: json['sexo'],
      nascimento: json['nascimento'] != null
          ? DateTime.parse(json['nascimento'])
          : null,
      observacoes: json['observacoes'],
      servicos: json['servicos'], // ADICIONADO: Parse serviços
      nomeUsuario: json['nomeusuario'] ?? json['nomeUsuario'],
      descricaoPorte: json['descricaoporte'] ?? json['descricaoPorte'],
      descricaoEspecie: json['descricaoespecie'] ?? json['descricaoEspecie'],
      descricaoRaca: json['descricaoraca'] ?? json['descricaoRaca'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idUsuario != null) 'idusuario': idUsuario,
      if (idPorte != null) 'idporte': idPorte,
      if (idEspecie != null) 'idespecie': idEspecie,
      if (idRaca != null) 'idraca': idRaca,
      'nome': nome,
      'sexo': sexo,
      if (nascimento != null) 'nascimento': nascimento!.toIso8601String(),
      if (observacoes != null) 'observacoes': observacoes,
      if (servicos != null) 'servicos': servicos, // ADICIONADO
    };
  }

  PetModel copyWith({
    int? idPet,
    int? idUsuario,
    int? idPorte,
    int? idEspecie,
    int? idRaca,
    String? nome,
    String? sexo,
    DateTime? nascimento,
    String? observacoes,
    List<dynamic>? servicos, // ADICIONADO
    String? nomeUsuario,
    String? descricaoPorte,
    String? descricaoEspecie,
    String? descricaoRaca,
  }) {
    return PetModel(
      idPet: idPet ?? this.idPet,
      idUsuario: idUsuario ?? this.idUsuario,
      idPorte: idPorte ?? this.idPorte,
      idEspecie: idEspecie ?? this.idEspecie,
      idRaca: idRaca ?? this.idRaca,
      nome: nome ?? this.nome,
      sexo: sexo ?? this.sexo,
      nascimento: nascimento ?? this.nascimento,
      observacoes: observacoes ?? this.observacoes,
      servicos: servicos ?? this.servicos, // ADICIONADO
      nomeUsuario: nomeUsuario ?? this.nomeUsuario,
      descricaoPorte: descricaoPorte ?? this.descricaoPorte,
      descricaoEspecie: descricaoEspecie ?? this.descricaoEspecie,
      descricaoRaca: descricaoRaca ?? this.descricaoRaca,
    );
  }

  static PetModel fromMap(Map<String, dynamic> map) {
    return PetModel(
      idPet: map['idPet'],
      nome: map['nome'],
      descricaoEspecie: map['descricaoEspecie'],
      idEspecie: map['idEspecie'],
      descricaoRaca: map['descricaoRaca'],
      idRaca: map['idRaca'],
      nascimento: map['nascimento'] is DateTime
          ? map['nascimento']
          : map['nascimento'] != null
              ? DateTime.parse(map['nascimento'])
              : null,
      sexo: map['sexo'],
      descricaoPorte: map['descricaoPorte'],
      idPorte: map['idPorte'],
      servicos: map['servicos'], // ADICIONADO
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idPet': idPet,
      'nome': nome,
      'descricaoEspecie': descricaoEspecie,
      'idEspecie': idEspecie,
      'descricaoRaca': descricaoRaca,
      'idRaca': idRaca,
      'nascimento': nascimento?.toIso8601String(),
      'sexo': sexo,
      'descricaoPorte': descricaoPorte,
      'idPorte': idPorte,
      'servicos': servicos, // ADICIONADO
    };
  }
}