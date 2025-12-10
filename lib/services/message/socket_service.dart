import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  String? _socketId;
  
  // Callbacks
  final List<Function(Map<String, dynamic>)> _messageCallbacks = [];
  final List<Function(Map<String, dynamic>)> _notificationCallbacks = [];
  final List<Function(bool)> _connectionCallbacks = [];
  
  // Configurações
  static const String _socketUrl = 'https://bepetfamily.onrender.com';
  // Para produção: 'https://seu-servidor.com' ou use variável de ambiente

  // Conectar ao servidor - VERSÃO 3.1.3
  Future<void> connect({
    required String tipo, // 'usuario' ou 'hospedagem'
    required int id,
  }) async {
    try {
      if (_socket != null && _isConnected) {
        print('✅ Socket já está conectado');
        return;
      }

      // Configuração para socket_io_client 3.1.3
      _socket = IO.io(
        _socketUrl,
        IO.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .setQuery({'tipo': tipo, 'id': id.toString()})
          .build(),
      );

      _setupEventListeners();
      
      // Conectar manualmente (autoConnect pode não funcionar como esperado)
      _socket!.connect();
      
      print('🔄 Conectando ao servidor Socket.IO...');
      
    } catch (e) {
      print('❌ Erro ao conectar Socket.IO: $e');
      _isConnected = false;
      _notifyConnectionChange(false);
    }
  }

  // Método alternativo com configuração direta
  Future<void> connectSimple({
    required String tipo,
    required int id,
  }) async {
    try {
      if (_socket != null && _isConnected) {
        print('✅ Socket já está conectado');
        return;
      }

      // Configuração mais direta
      _socket = IO.io(
        _socketUrl,
        <String, dynamic>{
          'transports': ['websocket', 'polling'],
          'query': {'tipo': tipo, 'id': id.toString()},
          'autoConnect': true,
          'forceNew': true,
        },
      );

      _setupEventListeners();
      
      print('🔄 Conectando ao servidor Socket.IO...');
      
    } catch (e) {
      print('❌ Erro ao conectar Socket.IO: $e');
      _isConnected = false;
      _notifyConnectionChange(false);
    }
  }

  // Configurar listeners de eventos
  void _setupEventListeners() {
    if (_socket == null) return;

    // Conexão estabelecida
    _socket!.onConnect((_) {
      print('✅ Conectado ao servidor Socket.IO');
      _isConnected = true;
      _socketId = _socket!.id;
      _notifyConnectionChange(true);
      
      // Notificar servidor que estamos online
      if (_socket!.id != null) {
        emit('cliente-online', {'socketId': _socket!.id});
      }
    });

    // Desconexão
    _socket!.onDisconnect((_) {
      print('❌ Desconectado do servidor');
      _isConnected = false;
      _socketId = null;
      _notifyConnectionChange(false);
    });

    // Erro de conexão
    _socket!.onConnectError((data) {
      print('❌ Erro de conexão: $data');
      _isConnected = false;
      _notifyConnectionChange(false);
    });

    // Reconexão
    _socket!.onReconnect((data) {
      print('🔄 Reconectado ao servidor');
      _isConnected = true;
      _notifyConnectionChange(true);
    });

    // Tentativa de reconexão
    _socket!.onReconnectAttempt((data) {
      print('🔄 Tentando reconectar...');
    });

    // Tentativa de reconexão falhou
    _socket!.onReconnectFailed((data) {
      print('❌ Falha na reconexão');
    });

    // Erro
    _socket!.onError((data) {
      print('❌ Erro no socket: $data');
    });

    // Nova mensagem
    _socket!.on('nova-mensagem', (data) {
      print('📩 Nova mensagem recebida via socket: $data');
      if (data is Map<String, dynamic>) {
        _notifyMessageReceived(data);
      } else if (data is List) {
        // Se for uma lista, converter para Map
        final Map<String, dynamic> parsedData = {};
        for (var i = 0; i < data.length; i++) {
          parsedData['key$i'] = data[i];
        }
        _notifyMessageReceived(parsedData);
      }
    });

    // Notificação
    _socket!.on('notificacao-nova-mensagem', (data) {
      print('🔔 Nova notificação: $data');
      if (data is Map<String, dynamic>) {
        _notifyNotificationReceived(data);
      }
    });

    // Mensagem lida
    _socket!.on('mensagem-lida', (data) {
      print('✅ Mensagem marcada como lida: $data');
      // Aqui você pode atualizar o estado local das mensagens
    });

    // Status do usuário (online/offline)
    _socket!.on('status-usuario', (data) {
      print('👤 Status do usuário: $data');
      // Atualizar status de outros usuários
    });

    // Evento de ping/pong (keep-alive)
    _socket!.on('ping', (data) {
      print('🏓 Ping recebido');
    });

    _socket!.on('pong', (data) {
      print('🏓 Pong enviado');
    });
  }

  // Entrar em uma sala específica
  void entrarSala(String salaId) {
    if (_isConnected && _socket != null) {
      _socket!.emit('entrar-sala', salaId);
      print('🚪 Entrou na sala: $salaId');
    } else {
      print('⚠️ Socket não conectado para entrar na sala');
    }
  }

  // Sair de uma sala
  void sairSala(String salaId) {
    if (_isConnected && _socket != null) {
      _socket!.emit('sair-sala', salaId);
      print('🚪 Saiu da sala: $salaId');
    }
  }

  // Emitir um evento
  void emit(String eventName, dynamic data) {
    if (_isConnected && _socket != null) {
      _socket!.emit(eventName, data);
      print('📤 Evento emitido: $eventName');
    } else {
      print('⚠️ Socket não conectado, evento não enviado: $eventName');
    }
  }

  // Escutar um evento
  void on(String eventName, Function(dynamic) callback) {
    if (_socket != null) {
      _socket!.on(eventName, callback);
    }
  }

  // Remover listener de um evento
  void off(String eventName, [Function(dynamic)? callback]) {
    if (_socket != null) {
      _socket!.off(eventName, callback);
    }
  }

  // Desconectar
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.clearListeners();
      _socket = null;
      _isConnected = false;
      _socketId = null;
      print('🔌 Socket desconectado');
    }
  }

  // Criar ID da sala de conversa
  static String criarSalaId(int idHospedagem, int idUsuario) {
    return 'conversa_${idHospedagem}_${idUsuario}';
  }

  // Criar ID da sala da hospedagem
  static String criarSalaHospedagem(int idHospedagem) {
    return 'hospedagem_$idHospedagem';
  }

  // Criar ID da sala do usuário
  static String criarSalaUsuario(int idUsuario) {
    return 'usuario_$idUsuario';
  }

  // Notificar callbacks de mensagem
  void _notifyMessageReceived(Map<String, dynamic> message) {
    for (var callback in _messageCallbacks) {
      try {
        callback(message);
      } catch (e) {
        print('❌ Erro no callback de mensagem: $e');
      }
    }
  }

  // Notificar callbacks de notificação
  void _notifyNotificationReceived(Map<String, dynamic> notification) {
    for (var callback in _notificationCallbacks) {
      try {
        callback(notification);
      } catch (e) {
        print('❌ Erro no callback de notificação: $e');
      }
    }
  }

  // Notificar callbacks de conexão
  void _notifyConnectionChange(bool connected) {
    for (var callback in _connectionCallbacks) {
      try {
        callback(connected);
      } catch (e) {
        print('❌ Erro no callback de conexão: $e');
      }
    }
  }

  // Registrar callback para mensagens
  void addMessageListener(Function(Map<String, dynamic>) callback) {
    _messageCallbacks.add(callback);
  }

  // Remover callback de mensagens
  void removeMessageListener(Function(Map<String, dynamic>) callback) {
    _messageCallbacks.remove(callback);
  }

  // Registrar callback para notificações
  void addNotificationListener(Function(Map<String, dynamic>) callback) {
    _notificationCallbacks.add(callback);
  }

  // Remover callback de notificações
  void removeNotificationListener(Function(Map<String, dynamic>) callback) {
    _notificationCallbacks.remove(callback);
  }

  // Registrar callback para mudanças de conexão
  void addConnectionListener(Function(bool) callback) {
    _connectionCallbacks.add(callback);
  }

  // Remover callback de conexão
  void removeConnectionListener(Function(bool) callback) {
    _connectionCallbacks.remove(callback);
  }

  // Verificar status da conexão
  Map<String, dynamic> getStatus() {
    return {
      'connected': _isConnected,
      'socketId': _socketId,
      'url': _socketUrl,
    };
  }

  // Getters
  bool get isConnected => _isConnected;
  String? get socketId => _socketId;
  IO.Socket? get socket => _socket;
}