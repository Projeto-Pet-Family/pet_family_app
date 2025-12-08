// models/contrato_model.dart - VERSÃO COMPLETA COM TODOS OS GETTERS

import 'package:pet_family_app/models/service_model.dart';

class ContratoModel {
  final int? idContrato;
  final int idHospedagem;
  final int idUsuario;
  final String status;
  final DateTime dataInicio;
  final DateTime? dataFim;
  final DateTime? dataCriacao;
  final DateTime? dataAtualizacao;

  // Campos aninhados da nova API
  final Map<String, dynamic>? hospedagem;
  final Map<String, dynamic>? usuario;
  final Map<String, dynamic>? datas;
  final Map<String, dynamic>? calculos;
  final Map<String, dynamic>? statusInfo;
  final List<dynamic>? pets;
  final List<dynamic>? servicosGerais;
  final Map<String, dynamic>? formatado;

  // Campos opcionais extraídos
  final String? hospedagemNome;
  final double? valorDiaria;
  final double? valorTotal;
  final double? valorHospedagem;
  final double? valorServicos;

  ContratoModel({
    this.idContrato,
    required this.idHospedagem,
    required this.idUsuario,
    required this.status,
    required this.dataInicio,
    this.dataFim,
    this.dataCriacao,
    this.dataAtualizacao,
    this.hospedagem,
    this.usuario,
    this.datas,
    this.calculos,
    this.statusInfo,
    this.pets,
    this.servicosGerais,
    this.formatado,
    this.hospedagemNome,
    this.valorDiaria,
    this.valorTotal,
    this.valorHospedagem,
    this.valorServicos,
  });

  factory ContratoModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Convertendo JSON para ContratoModel (novo formato)...');
      
      // Funções auxiliares para conversão segura
      int safeParseInt(dynamic value, {int defaultValue = 0}) {
        if (value == null) return defaultValue;
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) {
          final parsed = int.tryParse(value);
          return parsed ?? defaultValue;
        }
        return defaultValue;
      }

      double safeParseDouble(dynamic value, {double defaultValue = 0.0}) {
        if (value == null) return defaultValue;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) {
          final parsed = double.tryParse(value);
          return parsed ?? defaultValue;
        }
        return defaultValue;
      }

      String safeParseString(dynamic value, {String defaultValue = ''}) {
        if (value == null) return defaultValue;
        return value.toString();
      }

      DateTime? safeParseDateTime(dynamic value) {
        if (value == null) return null;
        if (value is DateTime) return value;
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (e) {
            print('⚠️ Erro ao parse DateTime: $value');
            return null;
          }
        }
        return null;
      }

      // Extrair id do contrato (pode vir como 'id' ou 'idcontrato')
      final idContrato = json['id'] != null 
          ? safeParseInt(json['id'])
          : json['idcontrato'] != null
              ? safeParseInt(json['idcontrato'])
              : null;

      // Extrair id da hospedagem - pode estar aninhado ou direto
      int idHospedagem;
      if (json['hospedagem'] is Map && json['hospedagem']['id'] != null) {
        // Formato novo: hospedagem: {id: X, ...}
        idHospedagem = safeParseInt(json['hospedagem']['id']);
      } else if (json['idhospedagem'] != null) {
        // Formato antigo: idhospedagem: X
        idHospedagem = safeParseInt(json['idhospedagem']);
      } else {
        throw FormatException('Não foi possível encontrar id da hospedagem no JSON');
      }

      // Extrair id do usuário
      int idUsuario;
      if (json['usuario'] is Map && json['usuario']['id'] != null) {
        idUsuario = safeParseInt(json['usuario']['id']);
      } else if (json['idusuario'] != null) {
        idUsuario = safeParseInt(json['idusuario']);
      } else {
        throw FormatException('Não foi possível encontrar id do usuário no JSON');
      }

      // Extrair status - pode estar aninhado ou direto
      String status;
      if (json['status'] is Map && json['status']['contrato'] != null) {
        // Formato novo: status: {contrato: 'em_aprovacao', ...}
        status = safeParseString(json['status']['contrato'], defaultValue: 'em_aprovacao');
      } else if (json['status'] is String) {
        // Formato antigo: status: 'em_aprovacao'
        status = safeParseString(json['status'], defaultValue: 'em_aprovacao');
      } else {
        status = 'em_aprovacao';
      }

      // Extrair data início - pode estar aninhado ou direto
      DateTime dataInicio;
      if (json['datas'] is Map && json['datas']['inicio'] != null) {
        final inicioValue = json['datas']['inicio'];
        final parsedInicio = safeParseDateTime(inicioValue);
        if (parsedInicio == null) {
          throw FormatException('Data início inválida: $inicioValue');
        }
        dataInicio = parsedInicio;
      } else if (json['datainicio'] != null) {
        final parsedInicio = safeParseDateTime(json['datainicio']);
        if (parsedInicio == null) {
          throw FormatException('Data início inválida: ${json['datainicio']}');
        }
        dataInicio = parsedInicio;
      } else {
        throw FormatException('Campo datainicio é obrigatório');
      }

      // Extrair data fim
      DateTime? dataFim;
      if (json['datas'] is Map && json['datas']['fim'] != null) {
        dataFim = safeParseDateTime(json['datas']['fim']);
      } else if (json['datafim'] != null) {
        dataFim = safeParseDateTime(json['datafim']);
      }

      // Extrair data criação
      DateTime? dataCriacao;
      if (json['datas'] is Map && json['datas']['criacao'] != null) {
        dataCriacao = safeParseDateTime(json['datas']['criacao']);
      } else if (json['datacriacao'] != null) {
        dataCriacao = safeParseDateTime(json['datacriacao']);
      }

      // Extrair data atualização
      DateTime? dataAtualizacao;
      if (json['datas'] is Map && json['datas']['atualizacao'] != null) {
        dataAtualizacao = safeParseDateTime(json['datas']['atualizacao']);
      } else if (json['dataatualizacao'] != null) {
        dataAtualizacao = safeParseDateTime(json['dataatualizacao']);
      }

      // Extrair valores dos cálculos
      double? valorTotal;
      double? valorHospedagem;
      double? valorServicos;
      double? valorDiaria;
      
      if (json['calculos'] is Map) {
        valorTotal = safeParseDouble(json['calculos']['valorTotal']);
        valorHospedagem = safeParseDouble(json['calculos']['valorHospedagem']);
        valorServicos = safeParseDouble(json['calculos']['valorServicos']);
      } else if (json['calculoValores'] is Map) {
        valorTotal = safeParseDouble(json['calculoValores']['valorTotal']);
        valorHospedagem = safeParseDouble(json['calculoValores']['valorHospedagem']);
        valorServicos = safeParseDouble(json['calculoValores']['valorServicos']);
      }

      // Extrair valor da diária
      if (json['hospedagem'] is Map) {
        valorDiaria = safeParseDouble(json['hospedagem']['valorDiaria']);
      } else if (json['valor_diaria'] != null) {
        valorDiaria = safeParseDouble(json['valor_diaria']);
      }

      // Extrair nome da hospedagem
      String? hospedagemNome;
      if (json['hospedagem'] is Map) {
        hospedagemNome = safeParseString(json['hospedagem']['nome']);
      } else if (json['hospedagem_nome'] != null) {
        hospedagemNome = safeParseString(json['hospedagem_nome']);
      }

      // Converter listas de forma segura
      List<dynamic>? safeParseList(dynamic value) {
        if (value == null) return null;
        if (value is List) return value;
        return null;
      }

      // Converter mapas de forma segura
      Map<String, dynamic>? safeParseMap(dynamic value) {
        if (value == null) return null;
        if (value is Map<String, dynamic>) return value;
        if (value is Map) {
          try {
            return value.map((key, val) => MapEntry(key.toString(), val));
          } catch (e) {
            print('⚠️ Erro ao converter mapa: $e');
            return null;
          }
        }
        return null;
      }

      return ContratoModel(
        idContrato: idContrato,
        idHospedagem: idHospedagem,
        idUsuario: idUsuario,
        status: status,
        dataInicio: dataInicio,
        dataFim: dataFim,
        dataCriacao: dataCriacao,
        dataAtualizacao: dataAtualizacao,
        hospedagem: safeParseMap(json['hospedagem']),
        usuario: safeParseMap(json['usuario']),
        datas: safeParseMap(json['datas']),
        calculos: safeParseMap(json['calculos']),
        statusInfo: safeParseMap(json['status']),
        pets: safeParseList(json['pets']),
        servicosGerais: safeParseList(json['servicosGerais']),
        formatado: safeParseMap(json['formatado']),
        hospedagemNome: hospedagemNome,
        valorDiaria: valorDiaria,
        valorTotal: valorTotal,
        valorHospedagem: valorHospedagem,
        valorServicos: valorServicos,
      );
    } catch (e) {
      print('❌ Erro ao criar ContratoModel fromJson: $e');
      print('   JSON recebido: ${json.keys.toList()}');
      
      // Log mais detalhado para debug
      if (json.containsKey('hospedagem')) {
        print('   hospedagem tipo: ${json['hospedagem']?.runtimeType}');
        print('   hospedagem conteúdo: ${json['hospedagem']}');
      }
      if (json.containsKey('usuario')) {
        print('   usuario tipo: ${json['usuario']?.runtimeType}');
        print('   usuario conteúdo: ${json['usuario']}');
      }
      if (json.containsKey('datas')) {
        print('   datas tipo: ${json['datas']?.runtimeType}');
        print('   datas conteúdo: ${json['datas']}');
      }
      if (json.containsKey('status')) {
        print('   status tipo: ${json['status']?.runtimeType}');
        print('   status conteúdo: ${json['status']}');
      }
      
      throw FormatException('Erro ao converter JSON para ContratoModel: $e\nJSON keys: ${json.keys.toList()}');
    }
  }

  ContratoModel removeServicoGeral(int idServico) {
    final novosServicos = List<ServiceModel>.from(servicosGerais ?? [])
      .where((servico) => servico.idservico != idServico)
      .toList();
    
    return copyWith(servicosGerais: novosServicos);
  }

  ContratoModel removeServicoDoPet(int idPet, int idServico) {
    final novosPets = List<dynamic>.from(pets ?? [])
      .map((pet) {
        if (pet is Map<String, dynamic> && pet['idpet'] == idPet) {
          // Se o pet tem serviços, remove o específico
          if (pet['servicos'] != null && pet['servicos'] is List) {
            final servicos = List<dynamic>.from(pet['servicos'])
              .where((servico) => servico['idservico'] != idServico)
              .toList();
            
            return {
              ...pet,
              'servicos': servicos,
            };
          }
        }
        return pet;
      })
      .toList();
    
    return copyWith(pets: novosPets);
  }

  // MÉTODO: Converter para Map (para compatibilidade)
  Map<String, dynamic> toJson() {
    return {
      'id': idContrato ?? 0,
      'hospedagem': hospedagem ?? {'id': idHospedagem},
      'usuario': usuario ?? {'id': idUsuario},
      'status': statusInfo ?? {'contrato': status},
      'datas': datas ?? {
        'inicio': dataInicio.toIso8601String(),
        'fim': dataFim?.toIso8601String(),
        'criacao': dataCriacao?.toIso8601String(),
        'atualizacao': dataAtualizacao?.toIso8601String(),
      },
      'calculos': calculos ?? {
        'valorTotal': valorTotal,
        'valorHospedagem': valorHospedagem,
        'valorServicos': valorServicos,
      },
      'pets': pets ?? [],
      'servicosGerais': servicosGerais ?? [],
      'formatado': formatado ?? {},
    };
  }

  // MÉTODO: Criar uma cópia com alguns campos alterados
  ContratoModel copyWith({
    int? idContrato,
    int? idHospedagem,
    int? idUsuario,
    String? status,
    DateTime? dataInicio,
    DateTime? dataFim,
    DateTime? dataCriacao,
    DateTime? dataAtualizacao,
    Map<String, dynamic>? hospedagem,
    Map<String, dynamic>? usuario,
    Map<String, dynamic>? datas,
    Map<String, dynamic>? calculos,
    Map<String, dynamic>? statusInfo,
    List<dynamic>? pets,
    List<dynamic>? servicosGerais,
    Map<String, dynamic>? formatado,
    String? hospedagemNome,
    double? valorDiaria,
    double? valorTotal,
    double? valorHospedagem,
    double? valorServicos,
  }) {
    return ContratoModel(
      idContrato: idContrato ?? this.idContrato,
      idHospedagem: idHospedagem ?? this.idHospedagem,
      idUsuario: idUsuario ?? this.idUsuario,
      status: status ?? this.status,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataAtualizacao: dataAtualizacao ?? this.dataAtualizacao,
      hospedagem: hospedagem ?? this.hospedagem,
      usuario: usuario ?? this.usuario,
      datas: datas ?? this.datas,
      calculos: calculos ?? this.calculos,
      statusInfo: statusInfo ?? this.statusInfo,
      pets: pets ?? this.pets,
      servicosGerais: servicosGerais ?? this.servicosGerais,
      formatado: formatado ?? this.formatado,
      hospedagemNome: hospedagemNome ?? this.hospedagemNome,
      valorDiaria: valorDiaria ?? this.valorDiaria,
      valorTotal: valorTotal ?? this.valorTotal,
      valorHospedagem: valorHospedagem ?? this.valorHospedagem,
      valorServicos: valorServicos ?? this.valorServicos,
    );
  }

  // ========== GETTERS ÚTEIS ==========

  // GETTER: Nome da hospedagem (com fallback)
  String get hospedagemNomeComFallback {
    return hospedagemNome ?? 'Hospedagem';
  }

  // GETTER: Valor diária (com fallback)
  double get valorDiariaComFallback {
    return valorDiaria ?? 100.0;
  }

  // GETTER: Valor total (com fallback)
  double get valorTotalComFallback {
    return valorTotal ?? 0.0;
  }

  // GETTER: Valor formatado
  String get valorTotalFormatado {
    if (formatado != null && formatado!['valorTotal'] != null) {
      return formatado!['valorTotal'].toString();
    }
    return 'R\$${valorTotalComFallback.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // GETTER: Período formatado
  String get periodoFormatado {
    if (formatado != null && formatado!['periodo'] != null) {
      return formatado!['periodo'].toString();
    }
    final dias = dataFim != null 
        ? dataFim!.difference(dataInicio).inDays
        : 0;
    return '$dias dia${dias > 1 ? 's' : ''}';
  }

  // GETTER: Quantidade de pets
  int get quantidadePets {
    if (pets != null) return pets!.length;
    if (calculos != null && calculos!['quantidadePets'] != null) {
      return int.tryParse(calculos!['quantidadePets'].toString()) ?? 0;
    }
    return 0;
  }

  // GETTER: Status formatado para exibição
  String get statusFormatado {
    final statusMap = {
      'em_aprovacao': 'Em Aprovação',
      'aprovado': 'Aprovado',
      'em_execucao': 'Em Execução',
      'concluido': 'Concluído',
      'negado': 'Negado',
      'cancelado': 'Cancelado',
    };
    return statusMap[status] ?? 'Desconhecido';
  }

  // GETTER: Status pagamento
  String get statusPagamento {
    if (statusInfo != null && statusInfo!['pagamento'] != null) {
      return statusInfo!['pagamento'].toString();
    }
    return status;
  }

  // GETTER: Verificar se está ativo
  bool get estaAtivo {
    final statusAtivos = ['em_aprovacao', 'aprovado', 'em_execucao'];
    return statusAtivos.contains(status);
  }

  // GETTER: Verificar se pode cancelar
  bool get podeCancelar {
    return status == 'em_aprovacao' || status == 'aprovado';
  }

  // GETTER: Duração em dias
  int get duracaoDias {
    if (calculos != null && calculos!['quantidadeDias'] != null) {
      return int.tryParse(calculos!['quantidadeDias'].toString()) ?? 0;
    }
    if (dataFim != null) {
      return dataFim!.difference(dataInicio).inDays;
    }
    return 0;
  }

  // ========== NOVOS GETTERS ADICIONADOS ==========

  // GETTER: Verificar se pode editar
  bool get podeEditar {
    final statusEditaveis = ['em_aprovacao'];
    return statusEditaveis.contains(status);
  }

  // GETTER: Verificar se pode avaliar
  bool get podeAvaliar {
    return status == 'concluido';
  }

  // GETTER: Verificar se pode denunciar
  bool get podeDenunciar {
    return status == 'concluido';
  }

  // GETTER: Endereço da hospedagem (extraído do campo hospedagem)
  String? get hospedagemEndereco {
    if (hospedagem != null && hospedagem!['endereco'] is Map) {
      final enderecoMap = hospedagem!['endereco'] as Map;
      
      final parts = <String>[];
      
      if (enderecoMap['logradouro'] != null) {
        parts.add(enderecoMap['logradouro'].toString());
      }
      
      if (enderecoMap['numero'] != null) {
        parts.add(enderecoMap['numero'].toString());
      }
      
      if (enderecoMap['complemento'] != null && 
          enderecoMap['complemento'].toString().isNotEmpty) {
        parts.add(enderecoMap['complemento'].toString());
      }
      
      if (enderecoMap['bairro'] != null) {
        parts.add(enderecoMap['bairro'].toString());
      }
      
      if (enderecoMap['cidade'] != null) {
        parts.add(enderecoMap['cidade'].toString());
      }
      
      if (enderecoMap['sigla'] != null) {
        parts.add(enderecoMap['sigla'].toString());
      }
      
      if (enderecoMap['cep'] != null) {
        parts.add('CEP: ${enderecoMap['cep']}');
      }
      
      return parts.isNotEmpty ? parts.join(', ') : null;
    }
    
    return null;
  }

  // GETTER: Progresso do contrato (0.0 a 1.0)
  double get progresso {
    final agora = DateTime.now();

    if (agora.isBefore(dataInicio)) return 0.0;
    if (dataFim == null || agora.isAfter(dataFim!)) return 1.0;

    final total = dataFim!.difference(dataInicio).inDays;
    final decorrido = agora.difference(dataInicio).inDays;

    return decorrido / total;
  }

  // GETTER: Está próximo do check-in
  bool get estaProximoCheckIn {
    if (dataInicio.isBefore(DateTime.now())) return false;

    final diferenca = dataInicio.difference(DateTime.now());
    return diferenca.inDays <= 2;
  }

  // GETTER: Está próximo do check-out
  bool get estaProximoCheckOut {
    if (dataFim == null) return false;
    if (dataFim!.isBefore(DateTime.now())) return false;

    final diferenca = dataFim!.difference(DateTime.now());
    return diferenca.inDays <= 1;
  }

  // GETTER: Descrição detalhada do status
  String get statusDetalhado {
    final statusMap = {
      'em_aprovacao': 'Aguardando aprovação do anfitrião',
      'aprovado': 'Reserva confirmada - Aguardando check-in',
      'em_execucao': 'Em andamento - Hospedagem ativa',
      'concluido': 'Concluído - Hospedagem finalizada',
      'negado': 'Recusado pelo anfitrião',
      'cancelado': 'Cancelado pelo usuário',
    };
    return statusMap[status] ?? 'Status desconhecido';
  }

  // GETTER: Valor total da hospedagem (com fallback)
  double get valorTotalHospedagem {
    if (valorHospedagem != null) {
      return valorHospedagem!;
    }
    return valorDiariaComFallback * duracaoDias * quantidadePets;
  }

  // GETTER: Valor total dos serviços (com fallback)
  double get valorTotalServicos {
    if (valorServicos != null) {
      return valorServicos!;
    }
    return 0.0;
  }

  // GETTER: Valor total do contrato (com fallback)
  double get valorTotalContrato {
    if (valorTotal != null) {
      return valorTotal!;
    }
    return valorTotalHospedagem + valorTotalServicos;
  }

  // GETTER: Quantidade de dias da API
  int? get quantidadeDiasAPI {
    if (calculos != null && calculos!['quantidadeDias'] != null) {
      return int.tryParse(calculos!['quantidadeDias'].toString());
    }
    return duracaoDias;
  }

  // GETTER: Verifica se tem valores calculados da API
  bool get temValoresCalculadosAPI {
    return calculos != null && calculos!.isNotEmpty;
  }

  // GETTER: Valor formatado da API
  String? getValorFormatado(String campo) {
    if (formatado != null) {
      final valor = formatado![campo];
      if (valor != null && valor.toString().isNotEmpty) {
        return valor.toString();
      }
    }
    return null;
  }

  // GETTER: Período formatado da API
  String? get periodoFormatadoAPI {
    if (formatado != null && formatado!['periodo'] != null) {
      return formatado!['periodo'].toString();
    }
    return null;
  }

  // MÉTODO: Para debug - exibir resumo do contrato
  @override
  String toString() {
    return 'ContratoModel{'
        'id: $idContrato, '
        'Hospedagem: $hospedagemNomeComFallback, '
        'Status: $statusFormatado, '
        'Período: ${dataInicio.toIso8601String().substring(0, 10)} a ${dataFim?.toIso8601String().substring(0, 10)}, '
        'Duração: ${duracaoDias} dias, '
        'Pets: $quantidadePets, '
        'Valor Total: $valorTotalFormatado'
        '}';
  }
}