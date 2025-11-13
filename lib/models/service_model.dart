class ServiceModel {
  final int? idservico;
  final int? idhospedagem;
  final String descricao;
  final double preco;

  ServiceModel({
    this.idservico,
    this.idhospedagem,
    required this.descricao,
    required this.preco,
  });

  // Getter para compatibilidade com código existente
  int get idServico => idservico ?? 0;
  int get idHospedagem => idhospedagem ?? 0;

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Convertendo JSON: $json');

    // Verifica as chaves exatas que a API está retornando
    final idservico = json['idservico'] as int? ?? 0;
    final descricao = json['descricao'] as String? ?? '';
    final preco = (json['preco'] is String)
        ? double.tryParse(json['preco']) ?? 0.0
        : (json['preco'] as num?)?.toDouble() ?? 0.0;

    print('✅ Serviço convertido: $idservico - $descricao - $preco');

    return ServiceModel(
      idservico: idservico,
      idhospedagem: json['idhospedagem'] as int? ?? 1,
      descricao: descricao,
      preco: preco,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idservico': idservico,
      'idhospedagem': idhospedagem,
      'descricao': descricao,
      'preco': preco,
    };
  }

  // Método copyWith para atualizações
  ServiceModel copyWith({
    int? idservico,
    int? idhospedagem,
    String? descricao,
    double? preco,
  }) {
    return ServiceModel(
      idservico: idservico ?? this.idservico,
      idhospedagem: idhospedagem ?? this.idhospedagem,
      descricao: descricao ?? this.descricao,
      preco: preco ?? this.preco,
    );
  }
}
