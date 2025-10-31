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
  });

  factory HospedagemModel.fromJson(Map<String, dynamic> json) {
    // DEBUG DETALHADO
    print('🔍 JSON recebido no fromJson:');
    print(
        '   idhospedagem: ${json['idhospedagem']} (tipo: ${json['idhospedagem']?.runtimeType})');

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

    print('   ID mapeado: $idHospedagem');

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
    );
  }

  // ✅ ADICIONE ESTE MÉTODO toJson()
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
    };
  }
}
