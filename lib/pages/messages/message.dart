// lib/pages/messages/message_screen.dart
import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/messages/chat_header.dart';
import 'package:pet_family_app/pages/messages/message_bubble.dart';
import 'package:pet_family_app/pages/messages/message_input.dart';
import 'package:pet_family_app/services/cache_service.dart';
import 'package:pet_family_app/providers/message_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class Message extends StatefulWidget {
  final int? idHospedagem;
  final int? idUsuario;
  final String? hospedagemNome;
  final String? contratoId;

  const Message({
    super.key,
    this.idHospedagem,
    this.idUsuario,
    this.hospedagemNome,
    this.contratoId,
  });

  @override
  State<Message> createState() => _MessageState();
}

class _MessageState extends State<Message> {
  late MensagemProvider _mensagemProvider;
  late AuthProvider _authProvider;
  final ScrollController _scrollController = ScrollController();

  late int _idHospedagem;
  late int _idUsuario;
  String? _hospedagemNome;
  String? _contratoId;
  bool _carregandoDados = true;

  @override
  void initState() {
    super.initState();
    print('🚀 Iniciando tela de mensagens');
    _carregarDadosConversa();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _mensagemProvider = Provider.of<MensagemProvider>(context, listen: false);
  }

  Future<void> _carregarDadosConversa() async {
    try {
      _carregandoDados = true;
      if (mounted) setState(() {});

      // Tenta carregar do cache se os parâmetros não foram fornecidos
      if (widget.idHospedagem == null || widget.idUsuario == null) {
        print('🔄 Carregando dados do cache...');
        final dadosCache = await CacheService.carregarDadosConversa();

        if (dadosCache != null) {
          _idHospedagem = dadosCache['idHospedagem'];
          _idUsuario = dadosCache['idUsuario'];
          _hospedagemNome = dadosCache['hospedagemNome'];
          _contratoId = dadosCache['contratoId'];
          print('✅ Dados carregados do cache');
        } else {
          print('❌ Nenhum dado encontrado no cache');
          _mostrarErroInicial(
              'Nenhuma conversa encontrada. Volte e selecione uma hospedagem.');
          return;
        }
      } else {
        // Usa os dados dos parâmetros
        _idHospedagem = widget.idHospedagem!;
        _idUsuario = widget.idUsuario!;
        _hospedagemNome = widget.hospedagemNome ?? 'Hospedagem';
        _contratoId = widget.contratoId;

        // Salva no cache para uso futuro
        await CacheService.salvarDadosConversa(
          idHospedagem: _idHospedagem,
          idUsuario: _idUsuario,
          hospedagemNome: _hospedagemNome!,
          contratoId: _contratoId,
        );
        print('✅ Dados salvos no cache');
      }

      print('🎯 Conversa configurada:');
      print('🎯 Hospedagem: $_idHospedagem');
      print('🎯 Usuário: $_idUsuario');
      print('🎯 Nome: $_hospedagemNome');

      _carregarConversa();
    } catch (e) {
      print('❌ Erro ao carregar dados: $e');
      _mostrarErroInicial('Erro ao carregar conversa: $e');
    } finally {
      _carregandoDados = false;
      if (mounted) setState(() {});
    }
  }

  void _carregarConversa() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 Carregando conversa com usuário: $_idUsuario');
      _mensagemProvider.carregarConversa(_idUsuario);
    });
  }

  void _enviarMensagem(String texto) async {
    print('📨 Enviando mensagem: "$texto"');

    try {
      await _mensagemProvider.enviarMensagem(
        idDestinatario: _idUsuario,
        idHospedagem: _idHospedagem,
        assunto: 'Hospedagem: $_hospedagemNome',
        mensagemTexto: texto,
      );
      print('✅ Mensagem enviada com sucesso!');
      _scrollToBottom();
    } catch (e) {
      print('❌ Erro ao enviar mensagem: $e');
      _mostrarErro('Erro ao enviar mensagem. Tente novamente.');
    }
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

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _mostrarErroInicial(String mensagem) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Erro'),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      );
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
            Text("Hospedagem: $_hospedagemNome"),
            Text("ID Hospedagem: $_idHospedagem"),
            Text("ID Usuário: $_idUsuario"),
            if (_contratoId != null) Text("Contrato: $_contratoId"),
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

  void _limparCacheESair() async {
    await CacheService.limparDadosConversa();
    Navigator.pop(context);
  }

  void _atualizarConversa() {
    print('🔄 Atualizando conversa manualmente...');
    _mensagemProvider.atualizarConversa();
  }

  @override
  Widget build(BuildContext context) {
    _authProvider = Provider.of<AuthProvider>(context);
    _mensagemProvider = Provider.of<MensagemProvider>(context);

    if (_carregandoDados) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mensagens'),
          backgroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando conversa...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_hospedagemNome!),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _mensagemProvider.isLoading ? null : _atualizarConversa,
            tooltip: 'Atualizar conversa',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _limparCacheESair,
            tooltip: 'Limpar cache e sair',
          ),
        ],
      ),
      body: Consumer<MensagemProvider>(
        builder: (context, mensagemProvider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });

          return Column(
            children: [
              ChatHeader(
                hospedagemNome: _hospedagemNome!,
                contratoId: _contratoId,
                onInfoPressed: _showInfoDialog,
              ),
              if (mensagemProvider.error != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red[50],
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mensagemProvider.error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: mensagemProvider.limparErro,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _buildMessageList(mensagemProvider),
              ),
              MessageInput(
                onSendMessage: _enviarMensagem,
                isLoading: mensagemProvider.isLoading,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessageList(MensagemProvider mensagemProvider) {
    if (mensagemProvider.isLoading && mensagemProvider.mensagens.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando conversa...'),
          ],
        ),
      );
    }

    if (mensagemProvider.mensagens.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhuma mensagem ainda'),
            SizedBox(height: 8),
            Text('Envie a primeira mensagem!'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _atualizarConversa();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: mensagemProvider.mensagens.length,
        itemBuilder: (context, index) {
          final message = mensagemProvider.mensagens[index];
          return MessageBubble(
            message: message,
            showSenderName: true,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
