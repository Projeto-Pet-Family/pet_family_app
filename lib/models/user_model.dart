// models/user_model.dart
class UserModel {
  final String nome;
  final String cpf;
  final String email;
  final String telefone;
  final String senha; // Senha em texto puro
  final bool ativado;
  final bool desativado;
  final bool esqueceuSenha;
  final DateTime dataCadastro;
  final AddressModel endereco;

  UserModel({
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
    required this.senha,
    this.ativado = false,
    this.desativado = false,
    this.esqueceuSenha = false,
    required this.dataCadastro,
    required this.endereco,
  });

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cpf': cpf,
      'email': email,
      'telefone': telefone,
      'senha': senha,
      'ativado': ativado,
      'desativado': desativado,
      'esqueceuSenha': esqueceuSenha,
      'dataCadastro': dataCadastro.toIso8601String(),
      'endereco': endereco.toJson(),
    };
  }

  // Método factory para criar a partir do cache
  factory UserModel.fromCache({
    required String nome,
    required String cpf,
    required String email,
    required String telefone,
    required String senha,
    required AddressModel endereco,
  }) {
    return UserModel(
      nome: nome,
      cpf: cpf,
      email: email,
      telefone: telefone,
      senha: senha,
      ativado: false,
      desativado: false,
      esqueceuSenha: false,
      dataCadastro: DateTime.now(), // Data atual do cadastro
      endereco: endereco,
    );
  }
}

class AddressModel {
  final String cep;
  final String rua;
  final String numero;
  final String? complemento;
  final String bairro;
  final String cidade;
  final String estado;

  AddressModel({
    required this.cep,
    required this.rua,
    required this.numero,
    this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
  });

  Map<String, dynamic> toJson() {
    return {
      'cep': cep,
      'rua': rua,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
    };
  }
}