// lib/pages/messages/widgets/chat_header.dart
import 'package:flutter/material.dart';

class ChatHeader extends StatelessWidget {
  final String hospedagemNome;
  final String? contratoId;
  final VoidCallback? onInfoPressed;

  const ChatHeader({
    super.key,
    required this.hospedagemNome,
    this.contratoId,
    this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xff8692DE),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.pets,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hospedagemNome,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  'About info, action and...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                if (contratoId != null)
                  Text(
                    'Contrato: $contratoId',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xff8692DE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xff8692DE)),
            ),
            child: const Text(
              'ATIVO',
              style: TextStyle(
                color: Color(0xff8692DE),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (onInfoPressed != null) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: onInfoPressed,
            ),
          ],
        ],
      ),
    );
  }
}
