class Mensagem {
  final int idmensagem;
  final int idusuarioRemetente;
  final int idusuarioDestinatario;
  final String mensagem;
  final DateTime dataEnvio;
  final bool lida;
  final String? nomeRemetente;
  final String? nomeDestinatario;

  Mensagem({
    required this.idmensagem,
    required this.idusuarioRemetente,
    required this.idusuarioDestinatario,
    required this.mensagem,
    required this.dataEnvio,
    required this.lida,
    this.nomeRemetente,
    this.nomeDestinatario,
  });

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      idmensagem: json['idmensagem'],
      idusuarioRemetente: json['idusuario_remetente'],
      idusuarioDestinatario: json['idusuario_destinatario'],
      mensagem: json['mensagem'],
      dataEnvio: DateTime.parse(json['data_envio']),
      lida: json['lida'],
      nomeRemetente: json['nome_remetente'],
      nomeDestinatario: json['nome_destinatario'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idmensagem': idmensagem,
      'idusuario_remetente': idusuarioRemetente,
      'idusuario_destinatario': idusuarioDestinatario,
      'mensagem': mensagem,
      'data_envio': dataEnvio.toIso8601String(),
      'lida': lida,
      'nome_remetente': nomeRemetente,
      'nome_destinatario': nomeDestinatario,
    };
  }
}

class MensagemEnvio {
  final int idusuarioRemetente;
  final int idusuarioDestinatario;
  final String mensagem;

  MensagemEnvio({
    required this.idusuarioRemetente,
    required this.idusuarioDestinatario,
    required this.mensagem,
  });

  Map<String, dynamic> toJson() {
    return {
      'idusuario_remetente': idusuarioRemetente,
      'idusuario_destinatario': idusuarioDestinatario,
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
