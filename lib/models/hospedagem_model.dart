class HospedagemModel {
  final int idHospedagem;
  final String nome;
  final int idEndereco;
  final String numero;
  final String complemento;
  final String cep;
  final String logradouro;
  final String bairro;
  final String cidade;
  final String estado;
  final String sigla;
  final double valorDiaria;

  HospedagemModel({
    required this.idHospedagem,
    required this.nome,
    required this.idEndereco,
    required this.numero,
    required this.complemento,
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.sigla,
    required this.valorDiaria,
  });

  factory HospedagemModel.fromJson(Map<String, dynamic> json) {
    // DEBUG DETALHADO
    print('🔍 JSON recebido no fromJson:');
    print(
        '   idhospedagem: ${json['idhospedagem']} (tipo: ${json['idhospedagem']?.runtimeType})');
    print(
        '   valor_diaria: ${json['valor_diaria']} (tipo: ${json['valor_diaria']?.runtimeType})');

    // ✅ CORREÇÃO: Garantir que o ID seja mapeado corretamente
    final dynamic idRaw = json['idhospedagem'];
    final int idHospedagem;

    if (idRaw is int) {
      idHospedagem = idRaw;
    } else if (idRaw is String) {
      idHospedagem = int.tryParse(idRaw) ?? 0;
    } else {
      idHospedagem = 0;
    }

    // ✅ CORREÇÃO: Garantir que o valor_diaria seja mapeado corretamente
    final dynamic valorDiariaRaw = json['valor_diaria'];
    final double valorDiaria;

    if (valorDiariaRaw is double) {
      valorDiaria = valorDiariaRaw;
    } else if (valorDiariaRaw is int) {
      valorDiaria = valorDiariaRaw.toDouble();
    } else if (valorDiariaRaw is String) {
      valorDiaria = double.tryParse(valorDiariaRaw) ?? 0.0;
    } else {
      valorDiaria = 0.0;
    }

    print('   ID mapeado: $idHospedagem');
    print('   Valor diária mapeado: $valorDiaria');

    return HospedagemModel(
      idHospedagem: idHospedagem,
      nome: json['nome'] ?? '',
      idEndereco: json['idendereco'] ?? 0,
      numero: json['numero']?.toString() ?? '',
      complemento: json['complemento'] ?? '',
      cep: json['CEP'] ?? '',
      logradouro: json['logradouro'] ?? '',
      bairro: json['bairro'] ?? '',
      cidade: json['cidade'] ?? '',
      estado: json['estado'] ?? '',
      sigla: json['sigla'] ?? '',
      valorDiaria: valorDiaria, // ✅ INCLUINDO VALOR DA DIÁRIA
    );
  }

  // ✅ MÉTODO toJson() ATUALIZADO
  Map<String, dynamic> toJson() {
    return {
      'idhospedagem': idHospedagem,
      'nome': nome,
      'idendereco': idEndereco,
      'numero': numero,
      'complemento': complemento,
      'CEP': cep,
      'logradouro': logradouro,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'sigla': sigla,
      'valor_diaria': valorDiaria, // ✅ INCLUINDO VALOR DA DIÁRIA
    };
  }

  // ✅ MÉTODO PARA CRIAR CÓPIA COM VALORES ALTERADOS (OPCIONAL)
  HospedagemModel copyWith({
    int? idHospedagem,
    String? nome,
    int? idEndereco,
    String? numero,
    String? complemento,
    String? cep,
    String? logradouro,
    String? bairro,
    String? cidade,
    String? estado,
    String? sigla,
    double? valorDiaria,
  }) {
    return HospedagemModel(
      idHospedagem: idHospedagem ?? this.idHospedagem,
      nome: nome ?? this.nome,
      idEndereco: idEndereco ?? this.idEndereco,
      numero: numero ?? this.numero,
      complemento: complemento ?? this.complemento,
      cep: cep ?? this.cep,
      logradouro: logradouro ?? this.logradouro,
      bairro: bairro ?? this.bairro,
      cidade: cidade ?? this.cidade,
      estado: estado ?? this.estado,
      sigla: sigla ?? this.sigla,
      valorDiaria: valorDiaria ?? this.valorDiaria,
    );
  }

  // ✅ MÉTODO PARA FORMATAR VALOR (OPCIONAL)
  String formatarValorDiaria() {
    return 'R\$${valorDiaria.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // ✅ MÉTODO PARA CALCULAR VALOR TOTAL (OPCIONAL)
  double calcularValorTotal(int dias) {
    return valorDiaria * dias;
  }

  String formatarValorTotal(int dias) {
    final total = calcularValorTotal(dias);
    return 'R\$${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}
