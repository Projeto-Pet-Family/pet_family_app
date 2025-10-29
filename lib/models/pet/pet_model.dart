class PetModel {
  final int? idpet;
  final String nome;
  final int? raca;
  final int? idusuario;
  final int? idespecie;
  final DateTime? nascimento;
  final double? peso;
  final String? observacoes;
  final String? sexo;
  final int? idporte;
  final int? idraca;

  PetModel({
    this.idpet,
    required this.nome,
    this.raca,
    this.idusuario,
    this.idespecie,
    this.nascimento,
    this.peso,
    this.observacoes,
    this.sexo,
    this.idporte,
    this.idraca,
  });

  // Método copyWith
  PetModel copyWith({
    int? idpet,
    String? nome,
    int? raca,
    int? idusuario,
    String? especie,
    DateTime? nascimento,
    double? peso,
    String? observacoes,
    String? sexo,
    int? idporte,
    int? idraca,
  }) {
    return PetModel(
      idpet: idpet ?? this.idpet,
      nome: nome ?? this.nome,
      raca: raca ?? this.raca,
      idusuario: idusuario ?? this.idusuario,
      idespecie: idespecie ?? idespecie,
      nascimento: nascimento ?? this.nascimento,
      peso: peso ?? this.peso,
      observacoes: observacoes ?? this.observacoes,
      sexo: sexo ?? this.sexo,
      idporte: idporte ?? this.idporte,
      idraca: idraca ?? this.idraca,
    );
  }

  factory PetModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Convertendo JSON para PetModel: $json');
      
      // Garantir que o campo 'nome' não seja nulo
      final nome = json['nome'] as String?;
      if (nome == null || nome.isEmpty) {
        throw Exception('Campo "nome" é obrigatório e não pode ser nulo');
      }

      return PetModel(
        idpet: _parseInt(json['idpet']),
        nome: nome,
        raca: json['raca'] as int?,
        idusuario: _parseInt(json['idUsuario']),
        idespecie: json['especie'] as int?,
        nascimento: json['nascimento'] != null 
            ? DateTime.tryParse(json['nascimento'].toString())
            : null,
        peso: _parseDouble(json['peso']),
        observacoes: json['observacoes'] as String?,
        sexo: json['sexo'] as String?,
        idporte: _parseInt(json['idporte']),
        idraca: _parseInt(json['idraca']),
      );
    } catch (e) {
      print('❌ Erro ao converter JSON para PetModel: $e');
      print('📦 JSON que causou o erro: $json');
      rethrow;
    }
  }

  // Métodos auxiliares para parsing seguro
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      if (idpet != null) 'idpet': idpet,
      'nome': nome,
      if (raca != null) 'raca': raca,
      if (idusuario != null) 'idUsuario': idusuario,
      if (idespecie != null) 'especie': idespecie,
      if (nascimento != null) 
        'nascimento': nascimento!.toIso8601String(),
      if (peso != null) 'peso': peso,
      if (observacoes != null) 'observacoes': observacoes,
      if (sexo != null) 'sexo': sexo,
      if (idporte != null) 'idporte': idporte,
      if (idraca != null) 'idraca': idraca,
    };
  }

  @override
  String toString() {
    return 'PetModel(idpet: $idpet, nome: $nome, idUsuario: $idusuario)';
  }
}