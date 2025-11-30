import 'package:flutter/material.dart';
import 'package:pet_family_app/models/message_model.dart';
import 'package:pet_family_app/providers/message_provider.dart';
import 'package:provider/provider.dart';

class Message extends StatefulWidget {
  final int idusuario;
  final int idhospedagem;
  final String nomeHospedagem;

  const Message({
    super.key,
    required this.idusuario,
    required this.idhospedagem,
    required this.nomeHospedagem,
  });

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  TextEditingController messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
      _carregarConversa();
    });
  }

  Future<void> _carregarConversa() async {
    final provider = Provider.of<MensagemProvider>(context, listen: false);
    await provider.carregarConversaMobile(
      idusuario: widget.idusuario,
      idhospedagem: widget.idhospedagem,
    );

    // Rolar para o final após carregar as mensagens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  Future<void> _enviarMensagem() async {
    final texto = messageController.text.trim();
    if (texto.isEmpty) return;

    final provider = Provider.of<MensagemProvider>(context, listen: false);

    try {
      // Envia a mensagem
      await provider.enviarMensagemMobile(
        idusuario: widget.idusuario,
        idhospedagem: widget.idhospedagem,
        mensagem: texto,
      );

      messageController.clear();
      _focusNode.requestFocus();

      // Aguarda um pouco e rola para o final
      await Future.delayed(const Duration(milliseconds: 100));
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao enviar mensagem: $e')),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0, // Sempre rola para o início (que é o topo quando reverse=false)
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _onSubmitted(String value) {
    _enviarMensagem();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.nomeHospedagem,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Consumer<MensagemProvider>(
        builder: (context, provider, child) {
          final mensagens =
              provider.getConversaMobile(widget.idusuario, widget.idhospedagem);

          // VERIFIQUE A ORDEM DAS MENSAGENS NO CONSOLE
          print('📱 Total de mensagens: ${mensagens.length}');
          if (mensagens.isNotEmpty) {
            print(
                '📱 Primeira mensagem: ${mensagens.first.mensagem} - ${mensagens.first.dataEnvio}');
            print(
                '📱 Última mensagem: ${mensagens.last.mensagem} - ${mensagens.last.dataEnvio}');
          }

          return Column(
            children: [
              // Área de mensagens
              Expanded(
                child: provider.loading
                    ? const Center(child: CircularProgressIndicator())
                    : mensagens.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhuma mensagem ainda\nEnvie a primeira mensagem!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            reverse: false, // MUDOU PARA false
                            itemCount: mensagens.length,
                            itemBuilder: (context, index) {
                              // MANTÉM A ORDEM ORIGINAL - mais antigas primeiro
                              final mensagem = mensagens[index];
                              return _buildMessageBubble(mensagem);
                            },
                          ),
              ),

              // Campo de envio
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'Digite sua mensagem...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        onSubmitted: _onSubmitted,
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _enviarMensagem,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageBubble(Mensagem mensagem) {
    final isMinhaMensagem = mensagem.idRemetente == widget.idusuario;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isMinhaMensagem ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMinhaMensagem)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.business, size: 18, color: Colors.grey),
            ),
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMinhaMensagem
                    ? Theme.of(context).primaryColor
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mensagem.mensagem,
                    style: TextStyle(
                      color: isMinhaMensagem ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatarData(mensagem.dataEnvio),
                    style: TextStyle(
                      color:
                          isMinhaMensagem ? Colors.white70 : Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMinhaMensagem)
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 18, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
