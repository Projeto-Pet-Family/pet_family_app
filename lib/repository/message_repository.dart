import 'package:pet_family_app/models/message_model.dart';
import 'package:pet_family_app/services/message_service.dart';

class MensagemRepository {
  final MensagemService _mensagemService;

  MensagemRepository(this._mensagemService);

  // MÉTODOS MOBILE

  Future<Mensagem> enviarMensagemMobile({
    required int idusuario,
    required int idhospedagem,
    required String mensagem,
  }) async {
    try {
      final response = await _mensagemService.enviarMensagemMobile(
        idusuario: idusuario,
        idhospedagem: idhospedagem,
        mensagem: mensagem,
      );
      return Mensagem.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<ConversaMobile> buscarConversaMobile({
    required int idusuario,
    required int idhospedagem,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _mensagemService.buscarConversaMobile(
        idusuario: idusuario,
        idhospedagem: idhospedagem,
        limit: limit,
        offset: offset,
      );
      return ConversaMobile.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<RespostaConversasMobile> listarConversasMobile({
    required int idusuario,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _mensagemService.listarConversasMobile(
        idusuario: idusuario,
        limit: limit,
        offset: offset,
      );
      return RespostaConversasMobile.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> contarNaoLidasMobile(int idusuario) async {
    try {
      final response = await _mensagemService.contarNaoLidasMobile(idusuario);
      return RespostaContadorNaoLidas.fromJson(response).totalNaoLidas;
    } catch (e) {
      rethrow;
    }
  }
}
