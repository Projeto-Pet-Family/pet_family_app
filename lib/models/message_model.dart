// lib/models/message_model.dart
class MessageModel {
  final int? idmensagem;
  final int idusuarioRemetente;
  final int idusuarioDestinatario;
  final int idHospedagem;
  final String assunto;
  final String mensagem;
  final DateTime? dataEnvio;
  final bool lida;
  final bool arquivada;
  final String? nomeRemetente;
  final String? nomeDestinatario;

  MessageModel({
    this.idmensagem,
    required this.idusuarioRemetente,
    required this.idusuarioDestinatario,
    required this.idHospedagem,
    required this.assunto,
    required this.mensagem,
    this.dataEnvio,
    this.lida = false,
    this.arquivada = false,
    this.nomeRemetente,
    this.nomeDestinatario,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      idmensagem: json['idmensagem'],
      idusuarioRemetente: json['idusuario_remetente'],
      idusuarioDestinatario: json['idusuario_destinatario'],
      idHospedagem: json['id_hospedagem'] ?? 0,
      assunto: json['assunto'],
      mensagem: json['mensagem'],
      dataEnvio: json['data_envio'] != null
          ? DateTime.parse(json['data_envio'])
          : null,
      lida: json['lida'] ?? false,
      arquivada: json['arquivada'] ?? false,
      nomeRemetente: json['nome_remetente'],
      nomeDestinatario: json['nome_destinatario'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idmensagem != null) 'idmensagem': idmensagem,
      'idusuario_remetente': idusuarioRemetente,
      'idusuario_destinatario': idusuarioDestinatario,
      'id_hospedagem': idHospedagem,
      'assunto': assunto,
      'mensagem': mensagem,
      'data_envio': dataEnvio?.toIso8601String(),
      'lida': lida,
      'arquivada': arquivada,
      if (nomeRemetente != null) 'nome_remetente': nomeRemetente,
      if (nomeDestinatario != null) 'nome_destinatario': nomeDestinatario,
    };
  }

  String get formattedTime {
    if (dataEnvio == null) return 'Agora';
    final now = DateTime.now();
    final difference = now.difference(dataEnvio!);

    if (difference.inMinutes < 1) return 'Agora';
    if (difference.inHours < 1) return '${difference.inMinutes}m';
    if (difference.inDays < 1) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';

    return '${dataEnvio!.day}/${dataEnvio!.month}/${dataEnvio!.year}';
  }

  bool isMeForUser(int currentUserId) {
    return idusuarioRemetente == currentUserId;
  }

  String? displaySenderNameForUser(int currentUserId) {
    return isMeForUser(currentUserId) ? null : (nomeRemetente ?? 'Usuário');
  }

  MessageModel copyWith({
    int? idmensagem,
    int? idusuarioRemetente,
    int? idusuarioDestinatario,
    int? idHospedagem,
    String? assunto,
    String? mensagem,
    DateTime? dataEnvio,
    bool? lida,
    bool? arquivada,
    String? nomeRemetente,
    String? nomeDestinatario,
  }) {
    return MessageModel(
      idmensagem: idmensagem ?? this.idmensagem,
      idusuarioRemetente: idusuarioRemetente ?? this.idusuarioRemetente,
      idusuarioDestinatario:
          idusuarioDestinatario ?? this.idusuarioDestinatario,
      idHospedagem: idHospedagem ?? this.idHospedagem,
      assunto: assunto ?? this.assunto,
      mensagem: mensagem ?? this.mensagem,
      dataEnvio: dataEnvio ?? this.dataEnvio,
      lida: lida ?? this.lida,
      arquivada: arquivada ?? this.arquivada,
      nomeRemetente: nomeRemetente ?? this.nomeRemetente,
      nomeDestinatario: nomeDestinatario ?? this.nomeDestinatario,
    );
  }
}

class EnviarMensagemRequest {
  final int idusuarioRemetente;
  final int idusuarioDestinatario;
  final int idHospedagem;
  final String assunto;
  final String mensagem;

  EnviarMensagemRequest({
    required this.idusuarioRemetente,
    required this.idusuarioDestinatario,
    required this.idHospedagem,
    required this.assunto,
    required this.mensagem,
  });

  Map<String, dynamic> toJson() {
    return {
      'idusuario_remetente': idusuarioRemetente,
      'idusuario_destinatario': idusuarioDestinatario,
      'id_hospedagem': idHospedagem,
      'assunto': assunto,
      'mensagem': mensagem,
    };
  }

  MessageModel toMessageModel() {
    return MessageModel(
      idusuarioRemetente: idusuarioRemetente,
      idusuarioDestinatario: idusuarioDestinatario,
      idHospedagem: idHospedagem,
      assunto: assunto,
      mensagem: mensagem,
      dataEnvio: DateTime.now(),
      lida: false,
      arquivada: false,
    );
  }
}
