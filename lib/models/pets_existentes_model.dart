// models/pet_existente_model.dart

import 'package:flutter/material.dart';

class PetExistenteModel {
  final int idContrato;
  final HospedagemExistente hospedagem;
  final UsuarioExistente usuario;
  final List<PetInfo> pets;
  final Map<String, dynamic> estatisticas;

  PetExistenteModel({
    required this.idContrato,
    required this.hospedagem,
    required this.usuario,
    required this.pets,
    required this.estatisticas,
  });

  factory PetExistenteModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    
    return PetExistenteModel(
      idContrato: data['contrato']['id'],
      hospedagem: HospedagemExistente.fromJson(data['hospedagem']),
      usuario: UsuarioExistente.fromJson(data['usuario']),
      pets: (data['pets'] as List)
          .map((petJson) => PetInfo.fromJson(petJson))
          .toList(),
      estatisticas: data['estatisticas'] ?? {},
    );
  }
}

class HospedagemExistente {
  final int id;
  final String nome;
  final String endereco;
  final String telefone;

  HospedagemExistente({
    required this.id,
    required this.nome,
    required this.endereco,
    required this.telefone,
  });

  factory HospedagemExistente.fromJson(Map<String, dynamic> json) {
    return HospedagemExistente(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? 'Não informado',
      endereco: json['endereco'] ?? 'Não informado',
      telefone: json['telefone'] ?? 'Não informado',
    );
  }
}

class UsuarioExistente {
  final int id;
  final String nome;
  final String email;

  UsuarioExistente({
    required this.id,
    required this.nome,
    required this.email,
  });

  factory UsuarioExistente.fromJson(Map<String, dynamic> json) {
    return UsuarioExistente(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? 'Não informado',
      email: json['email'] ?? 'Não informado',
    );
  }
}

class PetInfo {
  final int idPet;
  final String nome;
  final String sexo;
  final bool estaNoContrato;

  PetInfo({
    required this.idPet,
    required this.nome,
    required this.sexo,
    required this.estaNoContrato,
  });

  factory PetInfo.fromJson(Map<String, dynamic> json) {
    return PetInfo(
      idPet: json['idPet'] ?? 0,
      nome: json['nome'] ?? 'Não informado',
      sexo: json['sexo'] ?? 'Não informado',
      estaNoContrato: json['estaNoContrato'] ?? false,
    );
  }

  // Para facilitar a exibição
  String get statusNoContrato {
    return estaNoContrato ? '✓ No contrato' : '✗ Fora do contrato';
  }

  Color get statusColor {
    return estaNoContrato ? Colors.green : Colors.orange;
  }
}