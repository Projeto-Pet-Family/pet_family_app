// lib/pages/messages/models/message_model.dart
class MessageModel {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String? senderName;
  final MessageStatus status;

  MessageModel({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.senderName,
    this.status = MessageStatus.sent,
  });

  String get formattedTime {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      text: json['text'],
      isMe: json['isMe'],
      timestamp: DateTime.parse(json['timestamp']),
      senderName: json['senderName'],
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status']}',
        orElse: () => MessageStatus.sent,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isMe': isMe,
      'timestamp': timestamp.toIso8601String(),
      'senderName': senderName,
      'status': status.toString().split('.').last,
    };
  }
}

enum MessageStatus {
  sent,
  delivered,
  read,
  error,
}
