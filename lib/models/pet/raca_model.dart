class Raca {
  final int? idRaca;
  final String descricao;
  final int idEspecie;
  final String? especieDescricao; // Para exibir na UI
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;

  Raca({
    this.idRaca,
    required this.descricao,
    required this.idEspecie,
    this.especieDescricao,
    this.dataCriacao,
    this.dataAtualizacao,
  });

  factory Raca.fromJson(Map<String, dynamic> json) {
    return Raca(
      idRaca: json['idraca'] ?? json['idRaca'],
      descricao: json['descricao'],
      idEspecie: json['idespecie'] ?? json['idEspecie'],
      especieDescricao: json['especie_descricao'] ?? json['especieDescricao'],
      dataCriacao: json['data_criacao'] != null 
          ? DateTime.parse(json['data_criacao'])
          : null,
      dataAtualizacao: json['data_atualizacao'] != null
          ? DateTime.parse(json['data_atualizacao'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idRaca != null) 'idraca': idRaca,
      'descricao': descricao,
      'idespecie': idEspecie,
      if (especieDescricao != null) 'especie_descricao': especieDescricao,
      if (dataCriacao != null) 'data_criacao': dataCriacao!.toIso8601String(),
      if (dataAtualizacao != null) 'data_atualizacao': dataAtualizacao!.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'descricao': descricao,
      'idespecie': idEspecie,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'descricao': descricao,
      'idespecie': idEspecie,
    };
  }

  Raca copyWith({
    int? idRaca,
    String? descricao,
    int? idEspecie,
    String? especieDescricao,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return Raca(
      idRaca: idRaca ?? this.idRaca,
      descricao: descricao ?? this.descricao,
      idEspecie: idEspecie ?? this.idEspecie,
      especieDescricao: especieDescricao ?? this.especieDescricao,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }

  @override
  String toString() {
    return '$descricao${especieDescricao != null ? ' ($especieDescricao)' : ''}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Raca &&
      other.idRaca == idRaca &&
      other.descricao == descricao &&
      other.idEspecie == idEspecie;
  }

  @override
  int get hashCode {
    return idRaca.hashCode ^ descricao.hashCode ^ idEspecie.hashCode;
  }
}