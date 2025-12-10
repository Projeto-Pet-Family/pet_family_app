import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pet_family_app/services/message/socket_service.dart';

class SocketManager with ChangeNotifier {
  final SocketService _socketService = SocketService();
  bool _connected = false;
  String? _socketId;
  
  // Dados da sessão atual
  String? _tipo; // 'usuario' ou 'hospedagem'
  int? _id;
  Timer? _reconnectTimer;
  
  // Construtor
  SocketManager() {
    // Inicializar listeners
    _socketService.addConnectionListener(_onConnectionChanged);
    _socketService.addMessageListener(_onMessageReceived);
    _socketService.addNotificationListener(_onNotificationReceived);
  }
  
  // Conectar com dados do usuário/hospedagem
  Future<void> connect({required String tipo, required int id}) async {
    _tipo = tipo;
    _id = id;
    
    await _socketService.connect(tipo: tipo, id: id);
    _startReconnectTimer();
  }
  
  // Conectar como usuário específico
  Future<void> connectAsUser(int idUsuario) async {
    await connect(tipo: 'usuario', id: idUsuario);
  }
  
  // Conectar como hospedagem específica
  Future<void> connectAsHospedagem(int idHospedagem) async {
    await connect(tipo: 'hospedagem', id: idHospedagem);
  }
  
  // Timer para tentar reconectar automaticamente
  void _startReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_connected && _tipo != null && _id != null) {
        print('🔄 Tentando reconectar automaticamente...');
        _socketService.connect(tipo: _tipo!, id: _id!);
      }
    });
  }
  
  // Entrar na sala de uma conversa
  void entrarConversa(int idHospedagem, int idUsuario) {
    final salaId = SocketService.criarSalaId(idHospedagem, idUsuario);
    _socketService.entrarSala(salaId);
    
    // Também entrar na sala pessoal para notificações
    if (_tipo == 'hospedagem') {
      final salaHospedagem = SocketService.criarSalaHospedagem(_id!);
      _socketService.entrarSala(salaHospedagem);
    } else if (_tipo == 'usuario') {
      final salaUsuario = SocketService.criarSalaUsuario(_id!);
      _socketService.entrarSala(salaUsuario);
    }
  }
  
  // Sair da sala de uma conversa
  void sairConversa(int idHospedagem, int idUsuario) {
    final salaId = SocketService.criarSalaId(idHospedagem, idUsuario);
    _socketService.sairSala(salaId);
  }
  
  // Enviar mensagem via socket
  void enviarMensagemViaSocket({
    required int idHospedagem,
    required int idUsuario,
    required String mensagem,
    Map<String, dynamic> dadosAdicionais = const {},
  }) {
    final salaId = SocketService.criarSalaId(idHospedagem, idUsuario);
    
    _socketService.emit('enviar-mensagem', {
      'sala': salaId,
      'mensagem': mensagem,
      'idRemetente': _id,
      'tipoRemetente': _tipo,
      'idHospedagem': idHospedagem,
      'idUsuario': idUsuario,
      'timestamp': DateTime.now().toIso8601String(),
      ...dadosAdicionais,
    });
  }
  
  // Marcar mensagem como lida via socket
  void marcarMensagemLida({
    required String idMensagem,
    required int idHospedagem,
    required int idUsuario,
  }) {
    final salaId = SocketService.criarSalaId(idHospedagem, idUsuario);
    
    _socketService.emit('marcar-lida', {
      'idMensagem': idMensagem,
      'sala': salaId,
      'idHospedagem': idHospedagem,
      'idUsuario': idUsuario,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  // Notificar que está digitando
  void notificarDigitando({
    required int idHospedagem,
    required int idUsuario,
    required bool digitando,
  }) {
    final salaId = SocketService.criarSalaId(idHospedagem, idUsuario);
    
    _socketService.emit('digitando', {
      'sala': salaId,
      'digitando': digitando,
      'idRemetente': _id,
      'tipoRemetente': _tipo,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  // Callback quando conexão muda
  void _onConnectionChanged(bool connected) {
    _connected = connected;
    _socketId = _socketService.socketId;
    print('🔄 Status da conexão: ${connected ? "✅ Conectado" : "❌ Desconectado"}');
    notifyListeners();
  }
  
  // Callback quando recebe mensagem
  void _onMessageReceived(Map<String, dynamic> message) {
    print('📩 Mensagem recebida via socket: ${message.toString()}');
    
    // Processar mensagem
    final processedMessage = _processarMensagem(message);
    
    // Notificar ouvintes
    notifyListeners();
  }
  
  // Processar mensagem recebida
  Map<String, dynamic> _processarMensagem(Map<String, dynamic> rawMessage) {
    return {
      'id': rawMessage['idmensagem'] ?? rawMessage['id'],
      'id_remetente': rawMessage['id_remetente'] ?? rawMessage['remetenteId'],
      'id_destinatario': rawMessage['id_destinatario'] ?? rawMessage['destinatarioId'],
      'mensagem': rawMessage['mensagem'] ?? rawMessage['texto'],
      'data_envio': rawMessage['data_envio'] ?? rawMessage['timestamp'],
      'lida': rawMessage['lida'] ?? false,
      'nome_remetente': rawMessage['nome_remetente'] ?? rawMessage['remetente'],
      'nome_destinatario': rawMessage['nome_destinatario'] ?? rawMessage['destinatario'],
    };
  }
  
  // Callback quando recebe notificação
  void _onNotificationReceived(Map<String, dynamic> notification) {
    print('🔔 Notificação recebida: ${notification.toString()}');
    
    // Mostrar notificação local
    _mostrarNotificacaoLocal(notification);
    notifyListeners();
  }
  
  // Mostrar notificação local
  void _mostrarNotificacaoLocal(Map<String, dynamic> notification) {
    final remetente = notification['remetente'] ?? 'Alguém';
    final mensagem = notification['mensagem'] ?? 'Nova mensagem';
    final conversa = notification['conversa'] ?? '';
    
    print('🔔 Nova mensagem de $remetente: $mensagem (Conversa: $conversa)');
  }
  
  // Verificar se está conectado
  bool get isConnected => _connected;
  
  // Obter status da conexão
  Map<String, dynamic> getConnectionStatus() {
    return _socketService.getStatus();
  }
  
  // Desconectar
  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    
    _socketService.disconnect();
    _connected = false;
    _socketId = null;
    _tipo = null;
    _id = null;
    notifyListeners();
  }
  
  // Limpar todos os listeners
  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _socketService.removeConnectionListener(_onConnectionChanged);
    _socketService.removeMessageListener(_onMessageReceived);
    _socketService.removeNotificationListener(_onNotificationReceived);
    _socketService.disconnect();
    super.dispose();
  }
  
  // Getters
  bool get connected => _connected;
  String? get socketId => _socketId;
  String? get tipo => _tipo;
  int? get id => _id;
  SocketService get socketService => _socketService;
}