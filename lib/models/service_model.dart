class ServiceModel {
  final int idServico;
  final int idHospedagem;
  final String descricao;
  final double preco;

  ServiceModel({
    required this.idServico,
    required this.idHospedagem,
    required this.descricao,
    required this.preco,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Convertendo JSON: $json');

    // Verifica as chaves exatas que a API está retornando
    final idServico = json['idservico'] as int? ?? 0;
    final descricao = json['descricao'] as String? ?? '';
    final preco = (json['preco'] is String)
        ? double.tryParse(json['preco']) ?? 0.0
        : (json['preco'] as num?)?.toDouble() ?? 0.0;

    print('✅ Serviço convertido: $idServico - $descricao - $preco');

    return ServiceModel(
      idServico: idServico,
      idHospedagem:
          json['idhospedagem'] as int? ?? 1, // Valor padrão se não vier
      descricao: descricao,
      preco: preco,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idservico': idServico,
      'idhospedagem': idHospedagem,
      'descricao': descricao,
      'preco': preco,
    };
  }
}
