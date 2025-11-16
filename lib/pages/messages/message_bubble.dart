// lib/pages/messages/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:pet_family_app/models/message_model.dart';
import '../../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool showSenderName;

  const MessageBubble({
    super.key,
    required this.message,
    this.showSenderName = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!message.isMe &&
                    showSenderName &&
                    message.senderName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 8),
                    child: Text(
                      message.senderName!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? const Color(0xff8692DE)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: message.isMe
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                      bottomRight: message.isMe
                          ? const Radius.circular(4)
                          : const Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isMe ? Colors.white : Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.formattedTime,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      if (message.isMe) ...[
                        const SizedBox(width: 4),
                        _buildStatusIcon(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (message.isMe) const SizedBox(width: 8),
          if (message.isMe) _buildAvatar(isMe: true),
        ],
      ),
    );
  }

  Widget _buildAvatar({bool isMe = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isMe ? Colors.grey[300] : const Color(0xff8692DE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isMe ? Icons.person : Icons.person_outline,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (message.status) {
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = const Color(0xff8692DE);
        break;
      case MessageStatus.error:
        icon = Icons.error_outline;
        color = Colors.red;
        break;
    }

    return Icon(icon, size: 14, color: color);
  }
}
