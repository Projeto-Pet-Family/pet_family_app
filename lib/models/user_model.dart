// data/models/usuario_model.dart
import 'package:pet_family_app/models/pet/pet_model.dart';

class UsuarioModel {
  final int? idUsuario;
  final String nome;
  final String cpf;
  final String email;
  final String telefone;
  final String senha;
  final bool? esqueceuSenha;
  final DateTime? dataCadastro;

  UsuarioModel({
    this.idUsuario,
    required this.nome,
    required this.cpf,
    required this.email,
    required this.telefone,
    required this.senha,
    this.esqueceuSenha = false,
    this.dataCadastro,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      idUsuario: json['idusuario'] ?? json['idUsuario'],
      nome: json['nome'],
      cpf: json['cpf'],
      email: json['email'],
      telefone: json['telefone'],
      senha: json['senha'] ?? '', // Não vem na resposta normalmente
      esqueceuSenha: json['esqueceusenha'] ?? json['esqueceuSenha'] ?? false,
      dataCadastro: json['datacadastro'] != null
          ? DateTime.parse(json['datacadastro'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'cpf': cpf,
      'email': email,
      'telefone': telefone,
      'senha': senha,
      'esqueceuSenha': esqueceuSenha ?? false,
      'dataCadastro': dataCadastro?.toIso8601String(),
    };
  }

  UsuarioModel copyWith({
    int? idUsuario,
    String? nome,
    String? cpf,
    String? email,
    String? telefone,
    String? senha,
    bool? esqueceuSenha,
    DateTime? dataCadastro,
    int? idCargo,
    PetModel? petCriado,
  }) {
    return UsuarioModel(
      idUsuario: idUsuario ?? this.idUsuario,
      nome: nome ?? this.nome,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      senha: senha ?? this.senha,
      esqueceuSenha: esqueceuSenha ?? this.esqueceuSenha,
      dataCadastro: dataCadastro ?? this.dataCadastro,
    );
  }
}
