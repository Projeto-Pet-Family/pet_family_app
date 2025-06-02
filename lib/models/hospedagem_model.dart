class HospedagemModel {
  final int idHospedagem;
  final String nome;
  final int idEndereco;
  final int numero;
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
    return HospedagemModel(
      idHospedagem: json['IdHospedagem'] ?? 0,
      nome: json['nome'] ?? '',
      idEndereco: json['IdEndereco'] ?? 0,
      numero: json['numero'] ?? 0,
      complemento: json['complemento'] ?? '',
      cep: json['CEP'] ?? '',
      logradouro: json['logradouro'] ?? '',
      bairro: json['bairro'] ?? '',
      cidade: json['cidade'] ?? '',
      estado: json['estado'] ?? '',
      sigla: json['sigla'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdHospedagem': idHospedagem,
      'nome': nome,
      'IdEndereco': idEndereco,
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