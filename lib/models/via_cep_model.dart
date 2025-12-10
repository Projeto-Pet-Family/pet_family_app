// models/via_cep_model.dart
class ViaCepModel {
  final String cep;
  final String logradouro;
  final String complemento;
  final String bairro;
  final String localidade;
  final String uf;
  final String? erro;

  ViaCepModel({
    required this.cep,
    required this.logradouro,
    required this.complemento,
    required this.bairro,
    required this.localidade,
    required this.uf,
    this.erro,
  });

  factory ViaCepModel.fromJson(Map<String, dynamic> json) {
    return ViaCepModel(
      cep: json['cep'] ?? '',
      logradouro: json['street'] ?? json['logradouro'] ?? '', // BrasilAPI usa 'street'
      complemento: json['complemento'] ?? '',
      bairro: json['neighborhood'] ?? json['bairro'] ?? '', // BrasilAPI usa 'neighborhood'
      localidade: json['city'] ?? json['localidade'] ?? '', // BrasilAPI usa 'city'
      uf: json['state'] ?? json['uf'] ?? '', // BrasilAPI usa 'state'
      erro: json['erro'],
    );
  }

  bool get isValid => erro == null;
}