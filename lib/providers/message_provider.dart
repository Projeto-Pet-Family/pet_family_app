import 'package:flutter/foundation.dart';
import 'package:pet_family_app/models/message_model.dart';
import 'package:pet_family_app/repository/message_repository.dart';

class MensagemProvider with ChangeNotifier {
  final MensagemRepository _mensagemRepository;

  MensagemProvider(this._mensagemRepository);

  // Estado
  List<Mensagem> _mensagens = [];
  List<ConversaResumidaMobile> _conversasMobile = [];
  Map<String, List<Mensagem>> _conversasDetalhadasMobile = {};
  bool _loading = false;
  String? _error;
  int _totalNaoLidasMobile = 0;

  // Getters
  List<Mensagem> get mensagens => _mensagens;
  List<ConversaResumidaMobile> get conversasMobile => _conversasMobile;
  bool get loading => _loading;
  String? get error => _error;
  int get totalNaoLidasMobile => _totalNaoLidasMobile;

  List<Mensagem> getConversaMobile(int idusuario, int idhospedagem) {
    final key = '${idusuario}_$idhospedagem';
    final conversa = _conversasDetalhadasMobile[key] ?? [];
    conversa.sort((a, b) => a.dataEnvio.compareTo(b.dataEnvio));
    return conversa;
  }

  Future<void> carregarConversasMobile({
    required int idusuario,
    int limit = 20,
    int offset = 0,
  }) async {
    _setLoading(true);
    try {
      final resposta = await _mensagemRepository.listarConversasMobile(
        idusuario: idusuario,
        limit: limit,
        offset: offset,
      );
      _conversasMobile = resposta.conversas;
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar conversas: $e';
      _conversasMobile = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> carregarConversaMobile({
    required int idusuario,
    required int idhospedagem,
    int limit = 100,
    int offset = 0,
  }) async {
    _setLoading(true);
    try {
      final resposta = await _mensagemRepository.buscarConversaMobile(
        idusuario: idusuario,
        idhospedagem: idhospedagem,
        limit: limit,
        offset: offset,
      );

      final key = '${idusuario}_$idhospedagem';
      _conversasDetalhadasMobile[key] = resposta.conversa;
      _error = null;
    } catch (e) {
      _error = 'Erro ao carregar conversa: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<Mensagem> enviarMensagemMobile({
    required int idusuario,
    required int idhospedagem,
    required String mensagem,
  }) async {
    try {
      final mensagemEnviada = await _mensagemRepository.enviarMensagemMobile(
        idusuario: idusuario,
        idhospedagem: idhospedagem,
        mensagem: mensagem,
      );

      // Adiciona à lista local
      _mensagens.insert(0, mensagemEnviada);

      // Atualiza a conversa detalhada
      final key = '${idusuario}_$idhospedagem';
      if (_conversasDetalhadasMobile.containsKey(key)) {
        _conversasDetalhadasMobile[key]!.insert(0, mensagemEnviada);
      }

      // Atualiza contador de não lidas
      await _atualizarContadorNaoLidasMobile(idusuario);

      notifyListeners();
      return mensagemEnviada;
    } catch (e) {
      _error = 'Erro ao enviar mensagem: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _atualizarContadorNaoLidasMobile(int idusuario) async {
    try {
      _totalNaoLidasMobile =
          await _mensagemRepository.contarNaoLidasMobile(idusuario);
      notifyListeners();
    } catch (e) {
      print('Erro ao atualizar contador: $e');
    }
  }

  Future<void> atualizarContadorNaoLidasMobile(int idusuario) async {
    await _atualizarContadorNaoLidasMobile(idusuario);
  }

  void limparErro() {
    _error = null;
    notifyListeners();
  }

  void limparDados() {
    _mensagens.clear();
    _conversasMobile.clear();
    _conversasDetalhadasMobile.clear();
    _totalNaoLidasMobile = 0;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
