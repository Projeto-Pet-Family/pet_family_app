// providers/socket_provider.dart
import 'package:flutter/material.dart';
import 'package:pet_family_app/services/message/socket_manager.dart';

class SocketProvider extends ChangeNotifier {
  final SocketManager _socketManager = SocketManager();
  
  SocketProvider() {
    // Inicializar listeners
    _socketManager.addListener(() {
      notifyListeners();
    });
  }
  
  // Métodos para expor funcionalidades
  Future<void> connectAsUser(int idUsuario) async {
    await _socketManager.connectAsUser(idUsuario);
  }
  
  void entrarConversa(int idHospedagem, int idUsuario) {
    _socketManager.entrarConversa(idHospedagem, idUsuario);
  }
  
  void enviarMensagemViaSocket({
    required int idHospedagem,
    required int idUsuario,
    required String mensagem,
    Map<String, dynamic> dadosAdicionais = const {},
  }) {
    _socketManager.enviarMensagemViaSocket(
      idHospedagem: idHospedagem,
      idUsuario: idUsuario,
      mensagem: mensagem,
      dadosAdicionais: dadosAdicionais,
    );
  }
  
  bool get connected => _socketManager.connected;
  
  @override
  void dispose() {
    _socketManager.dispose();
    super.dispose();
  }
}