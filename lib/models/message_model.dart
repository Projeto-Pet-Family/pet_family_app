class Mensagem {
  final int idmensagem;
  final int idRemetente;
  final int idDestinatario;
  final String mensagem;
  final DateTime dataEnvio;
  bool lida;
  DateTime? dataLeitura;
  final String? nomeRemetente;
  final String? nomeDestinatario;

  Mensagem({
    required this.idmensagem,
    required this.idRemetente,
    required this.idDestinatario,
    required this.mensagem,
    required this.dataEnvio,
    required this.lida,
    this.dataLeitura,
    this.nomeRemetente,
    this.nomeDestinatario,
  });

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      idmensagem: json['idmensagem'] ?? json['id'] ?? 0,
      idRemetente: json['id_remetente'] ?? json['remetenteId'] ?? 0,
      idDestinatario: json['id_destinatario'] ?? json['destinatarioId'] ?? 0,
      mensagem: json['mensagem'] ?? json['texto'] ?? '',
      dataEnvio: DateTime.parse(
          json['data_envio'] ?? json['timestamp'] ?? DateTime.now().toIso8601String()),
      lida: json['lida'] ?? false,
      dataLeitura: json['data_leitura'] != null 
          ? DateTime.parse(json['data_leitura']) 
          : null,
      nomeRemetente: json['nome_remetente'] ?? json['remetenteNome'],
      nomeDestinatario: json['nome_destinatario'] ?? json['destinatarioNome'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idmensagem': idmensagem,
      'id_remetente': idRemetente,
      'id_destinatario': idDestinatario,
      'mensagem': mensagem,
      'data_envio': dataEnvio.toIso8601String(),
      'lida': lida,
      'data_leitura': dataLeitura?.toIso8601String(),
      'nome_remetente': nomeRemetente,
      'nome_destinatario': nomeDestinatario,
    };
  }

  // Método para clonar com novas propriedades
  Mensagem copyWith({
    int? idmensagem,
    int? idRemetente,
    int? idDestinatario,
    String? mensagem,
    DateTime? dataEnvio,
    bool? lida,
    DateTime? dataLeitura,
    String? nomeRemetente,
    String? nomeDestinatario,
  }) {
    return Mensagem(
      idmensagem: idmensagem ?? this.idmensagem,
      idRemetente: idRemetente ?? this.idRemetente,
      idDestinatario: idDestinatario ?? this.idDestinatario,
      mensagem: mensagem ?? this.mensagem,
      dataEnvio: dataEnvio ?? this.dataEnvio,
      lida: lida ?? this.lida,
      dataLeitura: dataLeitura ?? this.dataLeitura,
      nomeRemetente: nomeRemetente ?? this.nomeRemetente,
      nomeDestinatario: nomeDestinatario ?? this.nomeDestinatario,
    );
  }

  // Método para marcar como lida
  Mensagem marcarComoLida() {
    return copyWith(
      lida: true,
      dataLeitura: DateTime.now(),
    );
  }

  // Verificar se é mensagem do usuário
  bool isMinhaMensagem(int meuId) {
    return idRemetente == meuId;
  }

  // Verificar se é mensagem da hospedagem
  bool isMensagemHospedagem(int idHospedagem) {
    return idRemetente == idHospedagem;
  }

  // Getter para compatibilidade com código existente
  int get id => idmensagem;
}

// Model para dados do socket
class SocketMensagem {
  final String evento;
  final Map<String, dynamic> dados;
  final String sala;
  final DateTime timestamp;

  SocketMensagem({
    required this.evento,
    required this.dados,
    required this.sala,
    required this.timestamp,
  });

  factory SocketMensagem.fromJson(Map<String, dynamic> json) {
    return SocketMensagem(
      evento: json['evento'] ?? '',
      dados: Map<String, dynamic>.from(json['dados'] ?? {}),
      sala: json['sala'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evento': evento,
      'dados': dados,
      'sala': sala,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// Model para status de digitação
class DigitandoStatus {
  final bool digitando;
  final int idRemetente;
  final String tipoRemetente;
  final int idHospedagem;
  final int idUsuario;
  final DateTime timestamp;

  DigitandoStatus({
    required this.digitando,
    required this.idRemetente,
    required this.tipoRemetente,
    required this.idHospedagem,
    required this.idUsuario,
    required this.timestamp,
  });

  factory DigitandoStatus.fromJson(Map<String, dynamic> json) {
    return DigitandoStatus(
      digitando: json['digitando'] ?? false,
      idRemetente: json['idRemetente'] ?? 0,
      tipoRemetente: json['tipoRemetente'] ?? '',
      idHospedagem: json['idHospedagem'] ?? 0,
      idUsuario: json['idUsuario'] ?? 0,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

// Classes auxiliares existentes (mantenha exatamente como estão)
class MensagemEnvio {
  final int idRemetente;
  final int idDestinatario;
  final String mensagem;

  MensagemEnvio({
    required this.idRemetente,
    required this.idDestinatario,
    required this.mensagem,
  });

  Map<String, dynamic> toJson() {
    return {
      'id_remetente': idRemetente,
      'id_destinatario': idDestinatario,
      'mensagem': mensagem,
    };
  }
}

class MensagemMobileEnvio {
  final int idusuario;
  final int idhospedagem;
  final String mensagem;

  MensagemMobileEnvio({
    required this.idusuario,
    required this.idhospedagem,
    required this.mensagem,
  });

  Map<String, dynamic> toJson() {
    return {
      'idusuario': idusuario,
      'idhospedagem': idhospedagem,
      'mensagem': mensagem,
    };
  }
}

class ConversaMobile {
  final List<Mensagem> conversa;
  final Map<String, dynamic> participantes;
  final Paginacao paginacao;

  ConversaMobile({
    required this.conversa,
    required this.participantes,
    required this.paginacao,
  });

  factory ConversaMobile.fromJson(Map<String, dynamic> json) {
    return ConversaMobile(
      conversa:
          (json['conversa'] as List).map((e) => Mensagem.fromJson(e)).toList(),
      participantes: json['participantes'],
      paginacao: Paginacao.fromJson(json['paginacao']),
    );
  }
}

class ConversaResumidaMobile {
  final int idcontato;
  final String nomeContato;
  final String tipoContato;
  final String ultimaMensagem;
  final DateTime ultimaData;
  final bool lida;
  final int naoLidas;

  ConversaResumidaMobile({
    required this.idcontato,
    required this.nomeContato,
    required this.tipoContato,
    required this.ultimaMensagem,
    required this.ultimaData,
    required this.lida,
    required this.naoLidas,
  });

  factory ConversaResumidaMobile.fromJson(Map<String, dynamic> json) {
    return ConversaResumidaMobile(
      idcontato: json['idcontato'],
      nomeContato: json['nome_contato'],
      tipoContato: json['tipo_contato'],
      ultimaMensagem: json['ultima_mensagem'],
      ultimaData: DateTime.parse(json['ultima_data']),
      lida: json['lida'],
      naoLidas: json['nao_lidas'],
    );
  }
}

class RespostaConversasMobile {
  final List<ConversaResumidaMobile> conversas;
  final Paginacao paginacao;

  RespostaConversasMobile({
    required this.conversas,
    required this.paginacao,
  });

  factory RespostaConversasMobile.fromJson(Map<String, dynamic> json) {
    return RespostaConversasMobile(
      conversas: (json['conversas'] as List)
          .map((e) => ConversaResumidaMobile.fromJson(e))
          .toList(),
      paginacao: Paginacao.fromJson(json['paginacao']),
    );
  }
}

class Paginacao {
  final int limit;
  final int offset;
  final int total;

  Paginacao({
    required this.limit,
    required this.offset,
    required this.total,
  });

  factory Paginacao.fromJson(Map<String, dynamic> json) {
    return Paginacao(
      limit: json['limit'],
      offset: json['offset'],
      total: json['total'],
    );
  }
}

class RespostaContadorNaoLidas {
  final int totalNaoLidas;

  RespostaContadorNaoLidas({
    required this.totalNaoLidas,
  });

  factory RespostaContadorNaoLidas.fromJson(Map<String, dynamic> json) {
    return RespostaContadorNaoLidas(
      totalNaoLidas: json['total_nao_lidas'],
    );
  }
}