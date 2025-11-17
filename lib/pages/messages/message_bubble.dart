// lib/pages/messages/widgets/message_bubble.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../models/message_model.dart';

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
    final authProvider = Provider.of<AuthProvider>(context);
    final usuarioLogado = authProvider.usuarioLogado;

    // ✅ CORREÇÃO: Acessando o Map corretamente
    final currentUserId =
        usuarioLogado?['idusuario'] ?? usuarioLogado?['idUsuario'];

    if (currentUserId == null) {
      return Container(); // Ou algum widget de fallback
    }

    // Converter para int se necessário
    final userId = currentUserId is int
        ? currentUserId
        : int.tryParse(currentUserId.toString());

    if (userId == null) {
      return Container();
    }

    // ✅ CORREÇÃO: Usando métodos em vez de getters
    final isMe = message.isMeForUser(userId);
    final displaySenderName = message.displaySenderNameForUser(userId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) _buildAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe && showSenderName && displaySenderName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 8),
                    child: Text(
                      displaySenderName,
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
                    color: isMe ? const Color(0xff8692DE) : Colors.grey[100],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isMe
                          ? const Radius.circular(20)
                          : const Radius.circular(4),
                      bottomRight: isMe
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
                    message.mensagem,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black87,
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
                        message.formattedTime, // ✅ Usando o getter correto
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        _buildStatusIcon(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) const SizedBox(width: 8),
          if (isMe) _buildAvatar(isMe: true),
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
    // ✅ CORREÇÃO: Mensagens temporárias não têm ID
    if (message.idmensagem == null) {
      return const Icon(
        Icons.access_time,
        size: 14,
        color: Colors.grey,
      );
    } else if (message.lida) {
      return const Icon(
        Icons.done_all,
        size: 14,
        color: Color(0xff8692DE),
      );
    } else {
      return const Icon(
        Icons.done,
        size: 14,
        color: Colors.grey,
      );
    }
  }
}
