class Porte {
  final int? idPorte;
  final String descricao;
  final String? tamanho; // Ex: 'P', 'M', 'G'
  final String? descricaoCompleta; // Ex: 'Pequeno', 'Médio', 'Grande'
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;

  Porte({
    this.idPorte,
    required this.descricao,
    this.tamanho,
    this.descricaoCompleta,
    this.dataCriacao,
    this.dataAtualizacao,
  });

  factory Porte.fromJson(Map<String, dynamic> json) {
    return Porte(
      idPorte: json['idporte'] ?? json['idPorte'],
      descricao: json['descricao'],
      tamanho: json['tamanho'],
      descricaoCompleta: json['descricao_completa'] ?? json['descricaoCompleta'],
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
      if (idPorte != null) 'idporte': idPorte,
      'descricao': descricao,
      if (tamanho != null) 'tamanho': tamanho,
      if (descricaoCompleta != null) 'descricao_completa': descricaoCompleta,
      if (dataCriacao != null) 'data_criacao': dataCriacao!.toIso8601String(),
      if (dataAtualizacao != null) 'data_atualizacao': dataAtualizacao!.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'descricao': descricao,
      if (tamanho != null) 'tamanho': tamanho,
      if (descricaoCompleta != null) 'descricao_completa': descricaoCompleta,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'descricao': descricao,
      if (tamanho != null) 'tamanho': tamanho,
      if (descricaoCompleta != null) 'descricao_completa': descricaoCompleta,
    };
  }

  Porte copyWith({
    int? idPorte,
    String? descricao,
    String? tamanho,
    String? descricaoCompleta,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
  }) {
    return Porte(
      idPorte: idPorte ?? this.idPorte,
      descricao: descricao ?? this.descricao,
      tamanho: tamanho ?? this.tamanho,
      descricaoCompleta: descricaoCompleta ?? this.descricaoCompleta,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
    );
  }

  // Método para exibição formatada
  String get displayText {
    if (descricaoCompleta != null && tamanho != null) {
      return '$descricaoCompleta ($tamanho)';
    } else if (descricaoCompleta != null) {
      return descricaoCompleta!;
    } else {
      return descricao;
    }
  }

  @override
  String toString() {
    return displayText;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Porte &&
      other.idPorte == idPorte &&
      other.descricao == descricao;
  }

  @override
  int get hashCode {
    return idPorte.hashCode ^ descricao.hashCode;
  }
}