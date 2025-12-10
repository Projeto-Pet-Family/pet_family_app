import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pet_family_app/models/message_model.dart';
import 'package:pet_family_app/providers/message_provider.dart';
import 'package:pet_family_app/services/message/socket_service.dart';
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
  late SocketService _socketService;
  bool _socketConnected = false;
  bool _isTyping = false;
  bool _otherIsTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    
    // Inicializar o serviço de socket
    _socketService = SocketService();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
      _carregarConversa();
      _inicializarSocket();
    });
  }

  // Inicializar conexão Socket.IO
  void _inicializarSocket() {
    print('🔌 Inicializando Socket.IO...');
    
    // Conectar como usuário
    _socketService.connect(
      tipo: 'usuario',
      id: widget.idusuario,
    );

    // Configurar listeners
    _socketService.addConnectionListener(_onSocketConnectionChanged);
    _socketService.addMessageListener(_onNovaMensagemSocket);
    _socketService.addNotificationListener(_onNotificacaoSocket);

    // Entrar na sala da conversa
    final salaId = SocketService.criarSalaId(widget.idhospedagem, widget.idusuario);
    _socketService.entrarSala(salaId);

    // Configurar listener para evento de "digitando"
    _socketService.on('digitando', (data) {
      _onDigitandoEvento(data);
    });

    // Configurar listener para evento de mensagem lida
    _socketService.on('mensagem-lida', (data) {
      _onMensagemLidaEvento(data);
    });

    print('🎯 Socket configurado para conversa: ${widget.idusuario}-${widget.idhospedagem}');
  }

  // Callback quando a conexão do socket muda
  void _onSocketConnectionChanged(bool connected) {
    setState(() {
      _socketConnected = connected;
    });
    
    if (connected) {
      print('✅ Socket conectado com sucesso');
      
      // Quando reconectar, marcar mensagens como lidas
      _marcarMensagensComoLidas();
    } else {
      print('❌ Socket desconectado');
    }
  }

  // Callback quando recebe nova mensagem via socket
  void _onNovaMensagemSocket(Map<String, dynamic> mensagemData) {
    print('📩 Nova mensagem via socket: $mensagemData');
    
    // Verificar se a mensagem é para esta conversa
    final idRemetente = mensagemData['id_remetente'] ?? mensagemData['remetenteId'];
    final idDestinatario = mensagemData['id_destinatario'] ?? mensagemData['destinatarioId'];
    
    if ((idRemetente == widget.idhospedagem && idDestinatario == widget.idusuario) ||
        (idRemetente == widget.idusuario && idDestinatario == widget.idhospedagem)) {
      
      // Processar a mensagem
      final novaMensagem = _processarMensagemSocket(mensagemData);
      
      // Adicionar ao provider
      final provider = Provider.of<MensagemProvider>(context, listen: false);
      _adicionarMensagemAoProvider(provider, novaMensagem);
      
      // Marcar como lida (se for a hospedagem que enviou)
      if (idRemetente == widget.idhospedagem) {
        _enviarConfirmacaoLeitura(novaMensagem);
      }
      
      // Rolar para o final
      _scrollToBottom();
      
      // Mostrar notificação (se o app não estiver em foco)
      _mostrarNotificacao(novaMensagem);
    }
  }

  // Processar dados da mensagem recebida via socket
  Mensagem _processarMensagemSocket(Map<String, dynamic> dados) {
    return Mensagem(
      idmensagem: dados['idmensagem'] ?? 0,
      idRemetente: dados['id_remetente'] ?? dados['remetenteId'] ?? 0,
      idDestinatario: dados['id_destinatario'] ?? dados['destinatarioId'] ?? 0,
      mensagem: dados['mensagem'] ?? dados['texto'] ?? '',
      dataEnvio: DateTime.parse(dados['data_envio'] ?? 
                                dados['timestamp'] ?? 
                                DateTime.now().toIso8601String()),
      lida: dados['lida'] ?? false,
      nomeRemetente: dados['nome_remetente'] ?? dados['remetenteNome'],
    );
  }

  // Adicionar mensagem ao provider
  void _adicionarMensagemAoProvider(MensagemProvider provider, Mensagem mensagem) {
    // Verificar se a mensagem já existe para evitar duplicatas
    final conversa = provider.getConversaMobile(widget.idusuario, widget.idhospedagem);
    final mensagemExiste = conversa.any((m) => 
      m.idmensagem == mensagem.idmensagem || 
      (m.mensagem == mensagem.mensagem && m.dataEnvio.difference(mensagem.dataEnvio).inSeconds.abs() < 5)
    );
    
    if (!mensagemExiste) {
      // Você precisará adicionar este método ao seu provider
      provider.adicionarMensagemViaSocket(
        idusuario: widget.idusuario,
        idhospedagem: widget.idhospedagem,
        mensagem: mensagem,
      );
    }
  }

  // Callback quando recebe notificação via socket
  void _onNotificacaoSocket(Map<String, dynamic> notificacao) {
    print('🔔 Notificação via socket: $notificacao');
    
    // Mostrar snackbar se não for a conversa atual
    final conversaNotificacao = notificacao['conversa'] ?? '';
    final conversaAtual = '${widget.idhospedagem}_${widget.idusuario}';
    
    if (conversaNotificacao != conversaAtual) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📩 ${notificacao['remetente'] ?? "Nova mensagem"}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Evento de "digitando"
  void _onDigitandoEvento(dynamic data) {
    if (data is Map<String, dynamic>) {
      final idRemetente = data['idRemetente'];
      final digitando = data['digitando'] ?? false;
      
      // Se não for o usuário atual que está digitando
      if (idRemetente != widget.idusuario) {
        setState(() {
          _otherIsTyping = digitando;
        });
      }
    }
  }

  // Evento de mensagem lida
  void _onMensagemLidaEvento(dynamic data) {
    if (data is Map<String, dynamic>) {
      final idMensagem = data['idMensagem'];
      final idRemetente = data['idRemetente'];
      
      // Se foi a hospedagem que leu as mensagens do usuário
      if (idRemetente == widget.idhospedagem) {
        final provider = Provider.of<MensagemProvider>(context, listen: false);
        provider.marcarMensagensComoLidas(
          idusuario: widget.idusuario,
          idhospedagem: widget.idhospedagem,
        );
      }
    }
  }

  // Enviar evento de "digitando"
  void _enviarEventoDigitando(bool digitando) {
    if (!_socketConnected) return;
    
    final salaId = SocketService.criarSalaId(widget.idhospedagem, widget.idusuario);
    
    _socketService.emit('digitando', {
      'sala': salaId,
      'digitando': digitando,
      'idRemetente': widget.idusuario,
      'tipoRemetente': 'usuario',
      'idHospedagem': widget.idhospedagem,
      'idUsuario': widget.idusuario,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Enviar confirmação de leitura
  void _enviarConfirmacaoLeitura(Mensagem mensagem) {
    if (!_socketConnected) return;
    
    final salaId = SocketService.criarSalaId(widget.idhospedagem, widget.idusuario);
    
    _socketService.emit('mensagem-lida', {
      'sala': salaId,
      'idMensagem': mensagem.idmensagem.toString(),
      'idRemetente': widget.idusuario,
      'idDestinatario': widget.idhospedagem,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Marcar mensagens como lidas
  void _marcarMensagensComoLidas() {
    final provider = Provider.of<MensagemProvider>(context, listen: false);
    
    // Marcar mensagens não lidas como lidas localmente
    provider.marcarMensagensComoLidas(
      idusuario: widget.idusuario,
      idhospedagem: widget.idhospedagem,
    );
    
    // Enviar confirmação via socket
    _enviarConfirmacaoLeituraViaSocket();
  }

  // Enviar confirmação de leitura via socket
  void _enviarConfirmacaoLeituraViaSocket() {
    if (!_socketConnected) return;
    
    final salaId = SocketService.criarSalaId(widget.idhospedagem, widget.idusuario);
    
    _socketService.emit('marcar-conversa-lida', {
      'sala': salaId,
      'idHospedagem': widget.idhospedagem,
      'idUsuario': widget.idusuario,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Mostrar notificação local
  void _mostrarNotificacao(Mensagem mensagem) {
    // Aqui você pode integrar com flutter_local_notifications se quiser
    print('📢 Nova mensagem: ${mensagem.mensagem}');
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

    // Marcar mensagens como lidas
    _marcarMensagensComoLidas();
  }

  Future<void> _enviarMensagem() async {
    final texto = messageController.text.trim();
    if (texto.isEmpty) return;

    final provider = Provider.of<MensagemProvider>(context, listen: false);

    try {
      // Parar de enviar evento "digitando"
      _enviarEventoDigitando(false);
      _typingTimer?.cancel();
      
      // Envia a mensagem via API REST
      await provider.enviarMensagemMobile(
        idusuario: widget.idusuario,
        idhospedagem: widget.idhospedagem,
        mensagem: texto,
      );

      // Envia também via socket (para atualização em tempo real)
      if (_socketConnected) {
        final salaId = SocketService.criarSalaId(widget.idhospedagem, widget.idusuario);
        
        _socketService.emit('enviar-mensagem', {
          'sala': salaId,
          'mensagem': texto,
          'idRemetente': widget.idusuario,
          'idDestinatario': widget.idhospedagem,
          'tipoRemetente': 'usuario',
          'timestamp': DateTime.now().toIso8601String(),
          'nomeRemetente': 'Você',
          'nomeDestinatario': widget.nomeHospedagem,
        });
      }

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

  // Handler para quando o usuário está digitando
  void _onTextChanged(String text) {
    if (!_socketConnected) return;
    
    // Cancelar timer anterior
    _typingTimer?.cancel();
    
    // Se o usuário está digitando
    if (text.isNotEmpty && !_isTyping) {
      _isTyping = true;
      _enviarEventoDigitando(true);
    }
    
    // Se parou de digitar por 1 segundo, enviar evento de parada
    _typingTimer = Timer(const Duration(seconds: 1), () {
      if (_isTyping) {
        _isTyping = false;
        _enviarEventoDigitando(false);
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.nomeHospedagem,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_otherIsTyping)
              const Text(
                'Digitando...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // Indicador de status do socket
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Icon(
              _socketConnected ? Icons.wifi : Icons.wifi_off,
              color: _socketConnected ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
        ],
      ),
      body: Consumer<MensagemProvider>(
        builder: (context, provider, child) {
          final mensagens =
              provider.getConversaMobile(widget.idusuario, widget.idhospedagem);

          // DEBUG: Verificar ordem das mensagens
          if (mensagens.isNotEmpty) {
            print('📱 Total de mensagens: ${mensagens.length}');
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
                            reverse: false,
                            itemCount: mensagens.length,
                            itemBuilder: (context, index) {
                              final mensagem = mensagens[index];
                              return _buildMessageBubble(mensagem);
                            },
                          ),
              ),

              // Indicador de digitação
              if (_otherIsTyping)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey,
                        child: Icon(
                          Icons.business,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$widget.nomeHospedagem está digitando...',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
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
                    // Indicador de conexão
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: Icon(
                        _socketConnected ? Icons.cloud_done : Icons.cloud_off,
                        color: _socketConnected ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ),
                    
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
                        onChanged: _onTextChanged,
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
                        icon: Icon(
                          Icons.send,
                          color: _socketConnected ? Colors.white : Colors.grey[300],
                        ),
                        onPressed: _socketConnected ? _enviarMensagem : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      // Botão para tentar reconectar se desconectado
    
    );
  }

  Widget _buildMessageBubble(Mensagem mensagem) {
    final isMinhaMensagem = mensagem.idRemetente == widget.idusuario;
    final foiLida = mensagem.lida;

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatarData(mensagem.dataEnvio),
                        style: TextStyle(
                          color: isMinhaMensagem ? Colors.white70 : Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                      if (isMinhaMensagem)
                        Icon(
                          foiLida ? Icons.done_all : Icons.done,
                          size: 12,
                          color: foiLida ? Colors.blue : Colors.grey,
                        ),
                    ],
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(data.year, data.month, data.day);
    
    if (messageDate == today) {
      return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Ontem ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    } else {
      return '${data.day}/${data.month} ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    // Limpar timers
    _typingTimer?.cancel();
    
    // Parar de enviar evento "digitando"
    if (_isTyping) {
      _enviarEventoDigitando(false);
    }
    
    // Sair da sala e desconectar
    final salaId = SocketService.criarSalaId(widget.idhospedagem, widget.idusuario);
    _socketService.sairSala(salaId);
    _socketService.disconnect();
    
    // Limpar listeners
    _socketService.removeConnectionListener(_onSocketConnectionChanged);
    _socketService.removeMessageListener(_onNovaMensagemSocket);
    _socketService.removeNotificationListener(_onNotificacaoSocket);
    
    // Limpar controladores
    messageController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    
    super.dispose();
  }
}