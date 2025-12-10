import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/models/message_model.dart';
import 'package:pet_family_app/repository/message_repository.dart';

class MensagemProvider with ChangeNotifier {
  // Map para armazenar conversas: chave = "idusuario_idhospedagem"
  Map<String, List<Mensagem>> _conversasMobile = {};
  bool _loading = false;
  String? _error;
  
  // Status de digitação por conversa
  final Map<String, bool> _digitandoStatus = {};
  
  // Mensagens temporárias (para feedback UI)
  final Map<String, List<Mensagem>> _mensagensTemporarias = {};

  // URL da API - SUBSTITUA PELA SUA URL
  static const String _baseUrl = 'https://bepetfamily.onrender.com';

  MensagemProvider(MensagemRepository mensagemRepository); // ou sua URL

  // Getters
  Map<String, List<Mensagem>> get conversasMobile => _conversasMobile;
  bool get loading => _loading;
  String? get error => _error;
  
  // Verificar se alguém está digitando em uma conversa
  bool estaDigitando(int idusuario, int idhospedagem) {
    final key = '${idusuario}_$idhospedagem';
    return _digitandoStatus[key] ?? false;
  }

  // ==================== MÉTODOS EXISTENTES (API) ====================
  
  // Carregar conversa específica
  Future<void> carregarConversaMobile({
    required int idusuario,
    required int idhospedagem,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      // USANDO SUA URL DIRETAMENTE
      final url = Uri.parse('$_baseUrl/mensagem/mobile/conversa/$idusuario/$idhospedagem');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> mensagensData = data['conversa'] ?? [];
          final List<Mensagem> mensagens = mensagensData.map((msg) {
            return Mensagem.fromJson(msg);
          }).toList();

          // Ordenar por data (mais antiga primeiro)
          mensagens.sort((a, b) => a.dataEnvio.compareTo(b.dataEnvio));

          final key = '${idusuario}_$idhospedagem';
          _conversasMobile[key] = mensagens;
          
          // Remover mensagens temporárias após carregar as reais
          _removerMensagensTemporarias(key);
        } else {
          _error = data['message'] ?? 'Erro ao carregar conversa';
        }
      } else {
        _error = 'Erro ${response.statusCode}: ${response.reasonPhrase}';
      }
    } catch (e) {
      _error = 'Erro: $e';
      print('❌ Erro ao carregar conversa: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Enviar mensagem
  Future<Mensagem?> enviarMensagemMobile({
    required int idusuario,
    required int idhospedagem,
    required String mensagem,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      // Adicionar mensagem temporária para feedback imediato
      _adicionarMensagemTemporaria(
        idusuario: idusuario,
        idhospedagem: idhospedagem,
        texto: mensagem,
        isMinhaMensagem: true,
      );

      // USANDO SUA URL DIRETAMENTE
      final url = Uri.parse('$_baseUrl/mensagem/mobile');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'idusuario': idusuario,
          'idhospedagem': idhospedagem,
          'mensagem': mensagem,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final mensagemData = data['data'];
          final novaMensagem = Mensagem.fromJson(mensagemData);

          // Remover a temporária e adicionar a real
          final key = '${idusuario}_$idhospedagem';
          _removerUltimaMensagemTemporaria(key, mensagem);
          _adicionarMensagemReal(key, novaMensagem);
          
          return novaMensagem;
        } else {
          _error = data['message'] ?? 'Erro ao enviar mensagem';
          _removerUltimaMensagemTemporaria('${idusuario}_$idhospedagem', mensagem);
        }
      } else {
        _error = 'Erro ${response.statusCode}: ${response.reasonPhrase}';
        _removerUltimaMensagemTemporaria('${idusuario}_$idhospedagem', mensagem);
      }
    } catch (e) {
      _error = 'Erro: $e';
      print('❌ Erro ao enviar mensagem: $e');
      _removerUltimaMensagemTemporaria('${idusuario}_$idhospedagem', mensagem);
    } finally {
      _loading = false;
      notifyListeners();
    }
    return null;
  }

  // Obter conversa específica
  List<Mensagem> getConversaMobile(int idusuario, int idhospedagem) {
    final key = '${idusuario}_$idhospedagem';
    final mensagensReais = _conversasMobile[key] ?? [];
    final mensagensTemp = _mensagensTemporarias[key] ?? [];
    
    // Combinar mensagens reais e temporárias, ordenar por data
    final todasMensagens = [...mensagensReais, ...mensagensTemp];
    todasMensagens.sort((a, b) => a.dataEnvio.compareTo(b.dataEnvio));
    
    return todasMensagens;
  }

  // ==================== MÉTODOS PARA SOCKET.IO ====================

  // 1. Adicionar mensagem recebida via Socket.IO
  void adicionarMensagemViaSocket({
    required int idusuario,
    required int idhospedagem,
    required Mensagem mensagem,
  }) {
    final key = '${idusuario}_$idhospedagem';
    
    print('📥 Socket: Adicionando mensagem: ${mensagem.mensagem}');
    
    if (_conversasMobile.containsKey(key)) {
      final conversa = _conversasMobile[key]!;
      
      // Verificar se a mensagem já existe para evitar duplicatas
      final mensagemExiste = conversa.any((m) => 
        m.idmensagem == mensagem.idmensagem || 
        (m.mensagem == mensagem.mensagem && 
         m.dataEnvio.difference(mensagem.dataEnvio).inSeconds.abs() < 2)
      );
      
      if (!mensagemExiste) {
        // Adicionar mensagem
        conversa.add(mensagem);
        
        // Ordenar por data (mais antiga primeiro)
        conversa.sort((a, b) => a.dataEnvio.compareTo(b.dataEnvio));
        
        print('✅ Socket: Mensagem adicionada. Total: ${conversa.length}');
        notifyListeners();
      } else {
        print('⚠️ Socket: Mensagem duplicada ignorada');
      }
    } else {
      // Criar nova conversa
      _conversasMobile[key] = [mensagem];
      print('✅ Socket: Nova conversa criada');
      notifyListeners();
    }
  }

  // 2. Atualizar status de digitação
  void atualizarStatusDigitando({
    required int idusuario,
    required int idhospedagem,
    required bool digitando,
    required int idRemetente,
    required String tipoRemetente,
  }) {
    // Só atualizar se não for o próprio usuário
    if (tipoRemetente == 'hospedagem' || idRemetente != idusuario) {
      final key = '${idusuario}_$idhospedagem';
      _digitandoStatus[key] = digitando;
      
      if (digitando) {
        print('⌨️ Socket: $idRemetente está digitando...');
      }
      
      notifyListeners();
      
      // Auto-remover status após 3 segundos
      if (digitando) {
        Future.delayed(const Duration(seconds: 3), () {
          if (_digitandoStatus[key] == true) {
            _digitandoStatus[key] = false;
            notifyListeners();
          }
        });
      }
    }
  }

  // 3. Marcar mensagem como lida via socket
  void marcarMensagemComoLidaSocket({
    required int idMensagem,
    required int idusuario,
    required int idhospedagem,
  }) {
    final key = '${idusuario}_$idhospedagem';
    
    if (_conversasMobile.containsKey(key)) {
      final conversa = _conversasMobile[key]!;
      final index = conversa.indexWhere((m) => m.idmensagem == idMensagem);
      
      if (index != -1) {
        // Criar nova instância com lida = true
        final mensagemAtualizada = conversa[index].marcarComoLida();
        conversa[index] = mensagemAtualizada;
        
        print('✅ Socket: Mensagem $idMensagem marcada como lida');
        notifyListeners();
      }
    }
  }

  // 4. Marcar todas as mensagens como lidas
  void marcarMensagensComoLidas({
    required int idusuario,
    required int idhospedagem,
  }) {
    final key = '${idusuario}_$idhospedagem';
    
    print('✅ Marcando mensagens como lidas para: $key');
    
    if (_conversasMobile.containsKey(key)) {
      final conversa = _conversasMobile[key]!;
      var atualizado = false;
      
      // Marcar todas as mensagens do destinatário como lidas
      for (var i = 0; i < conversa.length; i++) {
        if (conversa[i].idDestinatario == idusuario && !conversa[i].lida) {
          conversa[i] = conversa[i].marcarComoLida();
          atualizado = true;
        }
      }
      
      if (atualizado) {
        final totalLidas = conversa.where((m) => m.lida && m.idDestinatario == idusuario).length;
        print('✅ $totalLidas mensagens marcadas como lidas');
        notifyListeners();
      }
    }
  }

  // 5. Processar dados recebidos do socket
  void processarDadosSocket({
    required int idusuario,
    required int idhospedagem,
    required Map<String, dynamic> dados,
    required String evento,
  }) {
    print('🔧 Processando evento socket: $evento');
    
    switch (evento) {
      case 'nova-mensagem':
        final mensagem = Mensagem.fromJson(dados);
        adicionarMensagemViaSocket(
          idusuario: idusuario,
          idhospedagem: idhospedagem,
          mensagem: mensagem,
        );
        break;
        
      case 'digitando':
        final digitando = DigitandoStatus.fromJson(dados);
        atualizarStatusDigitando(
          idusuario: idusuario,
          idhospedagem: idhospedagem,
          digitando: digitando.digitando,
          idRemetente: digitando.idRemetente,
          tipoRemetente: digitando.tipoRemetente,
        );
        break;
        
      case 'mensagem-lida':
        final idMensagem = int.tryParse(dados['idMensagem']?.toString() ?? '0') ?? 0;
        marcarMensagemComoLidaSocket(
          idMensagem: idMensagem,
          idusuario: idusuario,
          idhospedagem: idhospedagem,
        );
        break;
        
      case 'conversa-lida':
        marcarMensagensComoLidas(
          idusuario: idusuario,
          idhospedagem: idhospedagem,
        );
        break;
        
      default:
        print('⚠️ Evento socket não tratado: $evento');
    }
  }

  // 6. Verificar se há mensagens não lidas
  int getMensagensNaoLidas(int idusuario, int idhospedagem) {
    final key = '${idusuario}_$idhospedagem';
    
    if (_conversasMobile.containsKey(key)) {
      final conversa = _conversasMobile[key]!;
      return conversa.where((m) => 
        m.idDestinatario == idusuario && !m.lida
      ).length;
    }
    
    return 0;
  }

  // ==================== MÉTODOS AUXILIARES ====================

  // Adicionar mensagem temporária (para feedback UI)
  void _adicionarMensagemTemporaria({
    required int idusuario,
    required int idhospedagem,
    required String texto,
    required bool isMinhaMensagem,
  }) {
    final key = '${idusuario}_$idhospedagem';
    
    final mensagemTemporaria = Mensagem(
      idmensagem: -DateTime.now().millisecondsSinceEpoch, // ID único negativo
      idRemetente: isMinhaMensagem ? idusuario : idhospedagem,
      idDestinatario: isMinhaMensagem ? idhospedagem : idusuario,
      mensagem: texto,
      dataEnvio: DateTime.now(),
      lida: false,
      nomeRemetente: isMinhaMensagem ? 'Você' : null,
    );
    
    if (!_mensagensTemporarias.containsKey(key)) {
      _mensagensTemporarias[key] = [];
    }
    
    _mensagensTemporarias[key]!.add(mensagemTemporaria);
    notifyListeners();
    
    print('⏳ Mensagem temporária adicionada: $texto');
  }

  // Remover mensagens temporárias
  void _removerMensagensTemporarias(String key) {
    if (_mensagensTemporarias.containsKey(key)) {
      _mensagensTemporarias.remove(key);
      notifyListeners();
    }
  }

  // Remover última mensagem temporária por texto
  void _removerUltimaMensagemTemporaria(String key, String texto) {
    if (_mensagensTemporarias.containsKey(key)) {
      final tempList = _mensagensTemporarias[key]!;
      final index = tempList.lastIndexWhere((m) => m.mensagem == texto && m.idmensagem < 0);
      
      if (index != -1) {
        tempList.removeAt(index);
        if (tempList.isEmpty) {
          _mensagensTemporarias.remove(key);
        }
        notifyListeners();
        print('🗑️ Mensagem temporária removida: $texto');
      }
    }
  }

  // Adicionar mensagem real após envio bem-sucedido
  void _adicionarMensagemReal(String key, Mensagem mensagem) {
    if (!_conversasMobile.containsKey(key)) {
      _conversasMobile[key] = [];
    }
    
    _conversasMobile[key]!.add(mensagem);
    _conversasMobile[key]!.sort((a, b) => a.dataEnvio.compareTo(b.dataEnvio));
    
    print('✅ Mensagem real adicionada com ID: ${mensagem.idmensagem}');
    notifyListeners();
  }

  // 7. Limpar estado de uma conversa
  void limparConversa(int idusuario, int idhospedagem) {
    final key = '${idusuario}_$idhospedagem';
    _conversasMobile.remove(key);
    _mensagensTemporarias.remove(key);
    _digitandoStatus.remove(key);
    notifyListeners();
    print('🧹 Conversa $key limpa');
  }

  // 8. Obter última mensagem
  Mensagem? getUltimaMensagem(int idusuario, int idhospedagem) {
    final mensagens = getConversaMobile(idusuario, idhospedagem);
    return mensagens.isNotEmpty ? mensagens.last : null;
  }

  // 9. Verificar se há mensagens novas em qualquer conversa
  bool temMensagensNovas(int idusuario) {
    for (var key in _conversasMobile.keys) {
      final parts = key.split('_');
      if (parts.length == 2) {
        final userId = int.tryParse(parts[0]);
        if (userId == idusuario) {
          final idHospedagem = int.tryParse(parts[1]);
          if (idHospedagem != null && getMensagensNaoLidas(idusuario, idHospedagem) > 0) {
            return true;
          }
        }
      }
    }
    return false;
  }

  // 10. Obter total de mensagens não lidas em todas conversas
  int getTotalMensagensNaoLidas(int idusuario) {
    int total = 0;
    
    for (var key in _conversasMobile.keys) {
      final parts = key.split('_');
      if (parts.length == 2) {
        final userId = int.tryParse(parts[0]);
        if (userId == idusuario) {
          final idHospedagem = int.tryParse(parts[1]);
          if (idHospedagem != null) {
            total += getMensagensNaoLidas(idusuario, idHospedagem);
          }
        }
      }
    }
    
    return total;
  }

  // 11. Atualizar mensagem específica
  void atualizarMensagem({
    required int idusuario,
    required int idhospedagem,
    required int idMensagem,
    String? novoTexto,
    bool? lida,
  }) {
    final key = '${idusuario}_$idhospedagem';
    
    if (_conversasMobile.containsKey(key)) {
      final conversa = _conversasMobile[key]!;
      final index = conversa.indexWhere((m) => m.idmensagem == idMensagem);
      
      if (index != -1) {
        final mensagem = conversa[index];
        
        // Criar cópia atualizada
        final mensagemAtualizada = mensagem.copyWith(
          mensagem: novoTexto ?? mensagem.mensagem,
          lida: lida ?? mensagem.lida,
        );
        
        conversa[index] = mensagemAtualizada;
        notifyListeners();
        print('🔄 Mensagem $idMensagem atualizada');
      }
    }
  }

  // 12. Limpar todas as conversas (logout)
  void limparTodasConversas() {
    _conversasMobile.clear();
    _mensagensTemporarias.clear();
    _digitandoStatus.clear();
    notifyListeners();
    print('🧹 Todas as conversas foram limpas');
  }

  // 13. Carregar lista de conversas
  Future<void> carregarConversasMobile(int idusuario) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      // USANDO SUA URL DIRETAMENTE
      final url = Uri.parse('$_baseUrl/mensagem/mobile/conversas/$idusuario');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          final List<dynamic> conversasData = data['conversas'] ?? [];
          
          // Limpar conversas existentes
          _conversasMobile.clear();
          
          for (var conversaData in conversasData) {
            final idHospedagem = conversaData['idcontato'] ?? conversaData['idhospedagem'];
            final key = '${idusuario}_$idHospedagem';
            
            // Se já tivermos mensagens para esta conversa, manter
            if (!_conversasMobile.containsKey(key)) {
              _conversasMobile[key] = [];
            }
          }
        } else {
          _error = data['message'] ?? 'Erro ao carregar conversas';
        }
      } else {
        _error = 'Erro ${response.statusCode}: ${response.reasonPhrase}';
      }
    } catch (e) {
      _error = 'Erro: $e';
      print('❌ Erro ao carregar conversas: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // 14. Enviar confirmação de leitura para API
  Future<void> _enviarConfirmacaoLeituraApi(int idusuario, int idhospedagem) async {
    try {
      final key = '${idusuario}_$idhospedagem';
      if (!_conversasMobile.containsKey(key)) return;
      
      final conversa = _conversasMobile[key]!;
      final mensagensNaoLidas = conversa.where((m) => 
        m.idDestinatario == idusuario && !m.lida && m.idmensagem > 0
      ).toList();
      
      for (var mensagem in mensagensNaoLidas) {
        try {
          // USANDO SUA URL DIRETAMENTE
          final url = Uri.parse('$_baseUrl/mensagem/${mensagem.idmensagem}/ler');
          await http.put(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'tipo': 'usuario',
              'id': idusuario,
            }),
          );
          
          // Atualizar localmente
          mensagem.lida = true;
          mensagem.dataLeitura = DateTime.now();
          
        } catch (e) {
          print('❌ Erro ao marcar mensagem ${mensagem.idmensagem} como lida: $e');
        }
      }
      
      notifyListeners();
      
    } catch (e) {
      print('❌ Erro geral ao enviar confirmações de leitura: $e');
    }
  }
}