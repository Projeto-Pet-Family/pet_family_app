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
    // Função auxiliar para converter qualquer tipo para double
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
      }
      return 0.0;
    }

    return ServiceModel(
      idServico: json['idServico'] is int ? json['idServico'] : int.tryParse(json['idServico']?.toString() ?? '0') ?? 0,
      idHospedagem: json['idHospedagem'] is int ? json['idHospedagem'] : int.tryParse(json['idHospedagem']?.toString() ?? '0') ?? 0,
      descricao: json['descricao']?.toString() ?? '',
      preco: parseDouble(json['preco']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idServico': idServico,
      'idHospedagem': idHospedagem,
      'descricao': descricao,
      'preco': preco,
    };
  }
}