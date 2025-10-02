class Especie {
  final int? idEspecie;
  final String descricao;
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;

  Especie({
    this.idEspecie,
    required this.descricao,
    this.dataCriacao,
    this.dataAtualizacao,
  });

  factory Especie.fromJson(Map<String, dynamic> json) {
    return Especie(
      idEspecie: json['idespecie'] ?? json['idEspecie'],
      descricao: json['descricao'],
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
      if (idEspecie != null) 'idespecie': idEspecie,
      'descricao': descricao,
      if (dataCriacao != null) 'data_criacao': dataCriacao!.toIso8601String(),
      if (dataAtualizacao != null) 'data_atualizacao': dataAtualizacao!.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'descricao': descricao,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'descricao': descricao,
    };
  }

  Especie copyWith({
    int? idEspecie,
    String? descricao,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return Especie(
      idEspecie: idEspecie ?? this.idEspecie,
      descricao: descricao ?? this.descricao,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }

  @override
  String toString() {
    return descricao;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Especie &&
      other.idEspecie == idEspecie &&
      other.descricao == descricao;
  }

  @override
  int get hashCode {
    return idEspecie.hashCode ^ descricao.hashCode;
  }
}