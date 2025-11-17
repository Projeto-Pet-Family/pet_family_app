// lib/providers/mensagem_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pet_family_app/services/message_service.dart';
import '../models/message_model.dart';

class MensagemProvider with ChangeNotifier {
  final MensagemService _mensagemService;
  final int _currentUserId;

  List<MessageModel> _mensagens = [];
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;
  int? _currentConversationId;
  bool _isPolling = false;

  MensagemProvider({
    required MensagemService mensagemService,
    required int currentUserId,
  })  : _mensagemService = mensagemService,
        _currentUserId = currentUserId;

  List<MessageModel> get mensagens => _mensagens;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> carregarConversa(int idOutroUsuario) async {
    try {
      _isLoading = true;
      _error = null;
      _currentConversationId = idOutroUsuario;
      notifyListeners();

      print('🔄 Carregando conversa com usuário: $idOutroUsuario');

      final mensagensApi = await _mensagemService.buscarConversa(
        idusuario1: _currentUserId,
        idusuario2: idOutroUsuario,
      );

      _mensagens = mensagensApi;
      _ordenarMensagens();

      await _marcarMensagensComoLidas(mensagensApi);

      _iniciarPolling(idOutroUsuario);

      print('✅ Conversa carregada com ${_mensagens.length} mensagens');
    } catch (e) {
      _error = 'Erro ao carregar conversa: $e';
      print('❌ Erro ao carregar conversa: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> enviarMensagem({
    required int idDestinatario,
    required int idHospedagem,
    required String assunto,
    required String mensagemTexto,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      print('📝 Enviando mensagem para hospedagem: $idHospedagem');

      final request = EnviarMensagemRequest(
        idusuarioRemetente: _currentUserId,
        idusuarioDestinatario: idDestinatario,
        idHospedagem: idHospedagem,
        assunto: assunto,
        mensagem: mensagemTexto,
      );

      // Mensagem temporária para feedback imediato
      final mensagemTemporaria = request.toMessageModel();
      _mensagens.add(mensagemTemporaria);
      _ordenarMensagens();
      notifyListeners();

      print('🔄 Enviando mensagem para API...');
      final mensagemEnviada = await _mensagemService.enviarMensagem(request);

      // Substituir mensagem temporária pela real
      final index = _mensagens.indexWhere(
          (m) => m.idmensagem == null && m.mensagem == mensagemTexto);
      if (index != -1) {
        _mensagens[index] = mensagemEnviada;
        print(
            '✅ Mensagem temporária substituída pela real (ID: ${mensagemEnviada.idmensagem})');
      } else {
        _mensagens.add(mensagemEnviada);
        print('✅ Mensagem real adicionada (ID: ${mensagemEnviada.idmensagem})');
      }

      _ordenarMensagens();
      _error = null;

      print('🎉 Mensagem enviada com sucesso! Total: ${_mensagens.length}');
    } catch (e) {
      _error = 'Erro ao enviar mensagem: $e';

      // Remover mensagem temporária em caso de erro
      _mensagens.removeWhere(
          (m) => m.idmensagem == null && m.mensagem == mensagemTexto);

      print('❌ Erro ao enviar mensagem: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _iniciarPolling(int idOutroUsuario) {
    _pararPolling();

    print('🔄 Iniciando polling para conversa: $idOutroUsuario');

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_isPolling) return;

      _isPolling = true;
      try {
        final mensagensAtualizadas = await _mensagemService.buscarConversa(
          idusuario1: _currentUserId,
          idusuario2: idOutroUsuario,
        );

        if (_hasNewMessages(mensagensAtualizadas)) {
          print('🔄 Novas mensagens detectadas!');
          _mensagens = mensagensAtualizadas;
          _ordenarMensagens();
          notifyListeners();
        }

        await _marcarMensagensComoLidas(mensagensAtualizadas);
      } catch (e) {
        print('⚠️ Erro no polling: $e');
      } finally {
        _isPolling = false;
      }
    });
  }

  bool _hasNewMessages(List<MessageModel> novasMensagens) {
    if (novasMensagens.length != _mensagens.length) return true;

    for (int i = 0; i < novasMensagens.length; i++) {
      final nova = novasMensagens[i];
      final atual = _mensagens[i];

      if (nova.idmensagem != atual.idmensagem ||
          nova.lida != atual.lida ||
          nova.mensagem != atual.mensagem) {
        return true;
      }
    }

    return false;
  }

  void _pararPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
  }

  void _ordenarMensagens() {
    _mensagens.sort((a, b) {
      final aDate = a.dataEnvio ?? DateTime(0);
      final bDate = b.dataEnvio ?? DateTime(0);
      return aDate.compareTo(bDate);
    });
  }

  Future<void> _marcarMensagensComoLidas(
      List<MessageModel> mensagensApi) async {
    try {
      final mensagensNaoLidas = mensagensApi
          .where((m) =>
              m.idusuarioDestinatario == _currentUserId &&
              !m.lida &&
              m.idmensagem != null)
          .toList();

      for (final mensagem in mensagensNaoLidas) {
        await _mensagemService.marcarComoLida(mensagem.idmensagem!);

        final index =
            _mensagens.indexWhere((m) => m.idmensagem == mensagem.idmensagem);
        if (index != -1) {
          _mensagens[index] = _mensagens[index].copyWith(lida: true);
        }
      }
    } catch (e) {
      print('⚠️ Erro ao marcar mensagens como lidas: $e');
    }
  }

  Future<void> atualizarConversa() async {
    if (_currentConversationId != null) {
      print('🔄 Atualizando conversa manualmente');
      await carregarConversa(_currentConversationId!);
    }
  }

  @override
  void dispose() {
    _pararPolling();
    super.dispose();
  }

  void limparMensagens() {
    _mensagens.clear();
    _error = null;
    _pararPolling();
    _currentConversationId = null;
    notifyListeners();
  }

  void limparErro() {
    _error = null;
    notifyListeners();
  }
}
