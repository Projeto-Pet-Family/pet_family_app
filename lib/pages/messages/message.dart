// lib/pages/messages/message_screen.dart
import 'package:flutter/material.dart';
import 'package:pet_family_app/models/message_model.dart';
import 'package:pet_family_app/pages/messages/chat_header.dart';
import 'package:pet_family_app/pages/messages/message_bubble.dart';
import 'package:pet_family_app/pages/messages/message_input.dart';

class Message extends StatefulWidget {
  final String? contratoId;
  final String? hospedagemNome;

  const Message({
    super.key,
    this.contratoId,
    this.hospedagemNome,
  });

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  final List<MessageModel> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Não carrega mensagens iniciais - começa vazio
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final newMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    setState(() {
      _messages.add(newMessage);
      _isLoading = false; // Não simula loading para envio local
    });

    _scrollToBottom();

    // REMOVIDA a resposta automática do anfitrião
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Informações da Hospedagem"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.hospedagemNome != null)
              Text("Hospedagem: ${widget.hospedagemNome}"),
            if (widget.contratoId != null)
              Text("Contrato: ${widget.contratoId}"),
            const SizedBox(height: 16),
            const Text(
              "Status: Ativo",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.hospedagemNome ?? 'Mensagens'),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          ChatHeader(
            hospedagemNome: widget.hospedagemNome ?? 'Hospedagem',
            contratoId: widget.contratoId,
            onInfoPressed: _showInfoDialog,
          ),
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma mensagem ainda',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Envie a primeira mensagem!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return MessageBubble(message: message);
                    },
                  ),
          ),
          MessageInput(
            onSendMessage: _sendMessage,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
