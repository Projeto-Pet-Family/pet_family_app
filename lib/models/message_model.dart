// models/mensagem_model.dart
class MensagemModel {
  final int idmensagem;
  final int idusuarioRemetente;
  final int idusuarioDestinatario;
  final String mensagem;
  final DateTime dataEnvio;
  final bool lida;
  final String? nomeRemetente;
  final String? nomeDestinatario;

  MensagemModel({
    required this.idmensagem,
    required this.idusuarioRemetente,
    required this.idusuarioDestinatario,
    required this.mensagem,
    required this.dataEnvio,
    required this.lida,
    this.nomeRemetente,
    this.nomeDestinatario,
  });

  factory MensagemModel.fromJson(Map<String, dynamic> json) {
    return MensagemModel(
      idmensagem: json['idmensagem'] as int,
      idusuarioRemetente: json['idusuario_remetente'] as int,
      idusuarioDestinatario: json['idusuario_destinatario'] as int,
      mensagem: json['mensagem'] as String,
      dataEnvio: DateTime.parse(json['data_envio'] as String),
      lida: json['lida'] as bool,
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

  MensagemModel copyWith({
    int? idmensagem,
    int? idusuarioRemetente,
    int? idusuarioDestinatario,
    String? mensagem,
    DateTime? dataEnvio,
    bool? lida,
    String? nomeRemetente,
    String? nomeDestinatario,
  }) {
    return MensagemModel(
      idmensagem: idmensagem ?? this.idmensagem,
      idusuarioRemetente: idusuarioRemetente ?? this.idusuarioRemetente,
      idusuarioDestinatario:
          idusuarioDestinatario ?? this.idusuarioDestinatario,
      mensagem: mensagem ?? this.mensagem,
      dataEnvio: dataEnvio ?? this.dataEnvio,
      lida: lida ?? this.lida,
      nomeRemetente: nomeRemetente ?? this.nomeRemetente,
      nomeDestinatario: nomeDestinatario ?? this.nomeDestinatario,
    );
  }

  bool isEnviadaPorMim(int currentUserId) {
    return idusuarioRemetente == currentUserId;
  }

  String getNomeContato(int currentUserId) {
    if (idusuarioRemetente == currentUserId) {
      return nomeDestinatario ?? 'Usuário $idusuarioDestinatario';
    } else {
      return nomeRemetente ?? 'Usuário $idusuarioRemetente';
    }
  }

  String formatarData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(dataEnvio.year, dataEnvio.month, dataEnvio.day);

    if (messageDate == today) {
      return '${dataEnvio.hour.toString().padLeft(2, '0')}:${dataEnvio.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Ontem';
    } else {
      return '${dataEnvio.day.toString().padLeft(2, '0')}/${dataEnvio.month.toString().padLeft(2, '0')}';
    }
  }

  String formatarTimestamp() {
    final now = DateTime.now();
    final difference = now.difference(dataEnvio);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }
}
