import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _usuarioLogado;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get usuarioLogado => _usuarioLogado;
  bool get isLoggedIn => _usuarioLogado != null;

  AuthProvider() {
    _carregarUsuarioDoCache();
  }

  // ✅ MÉTODO UNIFICADO: Carregar usuário do cache
  Future<void> _carregarUsuarioDoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Tenta carregar do formato JSON unificado
      final usuarioJson = prefs.getString('usuario_atual');
      if (usuarioJson != null && usuarioJson.isNotEmpty) {
        _usuarioLogado = jsonDecode(usuarioJson);
        print('✅ Usuário carregado do cache: ${_usuarioLogado?['nome']}');
        notifyListeners();
        return;
      }

      // Fallback: carrega dados individuais (formato antigo)
      final idUsuario = prefs.getInt('idUsuario');
      final email = prefs.getString('email');
      final nome = prefs.getString('nome');
      final telefone = prefs.getString('telefone');

      if (idUsuario != null && email != null && nome != null) {
        _usuarioLogado = {
          'idusuario': idUsuario,
          'idUsuario': idUsuario,
          'email': email,
          'nome': nome,
          if (telefone != null && telefone.isNotEmpty) 'telefone': telefone,
        };

        // Migra para o formato JSON unificado
        await _salvarUsuarioNoCache(_usuarioLogado!);
        notifyListeners();
      }
    } catch (e) {
      print('❌ Erro ao carregar usuário do cache: $e');
    }
  }

  // ✅ MÉTODO UNIFICADO: Salvar usuário no cache
  Future<void> _salvarUsuarioNoCache(Map<String, dynamic> usuario) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Salva como JSON unificado
      await prefs.setString('usuario_atual', jsonEncode(usuario));

      // Também salva individualmente para compatibilidade
      final idUsuario = usuario['idusuario'] ?? usuario['idUsuario'];
      if (idUsuario != null) {
        await prefs.setInt(
            'idUsuario', int.tryParse(idUsuario.toString()) ?? 0);
      }

      await prefs.setString('email', usuario['email']?.toString() ?? '');
      await prefs.setString('nome', usuario['nome']?.toString() ?? '');

      if (usuario.containsKey('telefone')) {
        await prefs.setString(
            'telefone', usuario['telefone']?.toString() ?? '');
      }

      print('✅ Usuário salvo no cache: ${usuario['nome']}');
    } catch (e) {
      print('❌ Erro ao salvar usuário no cache: $e');
      rethrow;
    }
  }

  // ✅ MÉTODO PRINCIPAL: Atualizar perfil na API e cache
  Future<bool> atualizarPerfil(Map<String, dynamic> dadosAtualizados) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners(); // ✅ Notifica imediatamente o loading

      print('🌐 Iniciando atualização do perfil na API...');

      if (_usuarioLogado == null) {
        _errorMessage = 'Usuário não encontrado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final idUsuario =
          _usuarioLogado!['idusuario'] ?? _usuarioLogado!['idUsuario'];
      if (idUsuario == null) {
        _errorMessage = 'ID do usuário não encontrado';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      print('🔑 ID do usuário: $idUsuario');
      print('📤 Dados para enviar: $dadosAtualizados');

      // ✅ CHAMA A API
      final resultado = await AuthService.atualizarPerfil(
        idUsuario: int.parse(idUsuario.toString()),
        dadosAtualizados: dadosAtualizados,
      );

      if (resultado['success'] == true) {
        // ✅ ATUALIZA OS DADOS LOCAIS
        if (resultado['usuario'] != null) {
          _usuarioLogado = {
            ..._usuarioLogado!,
            ...resultado['usuario'],
          };
        } else {
          _usuarioLogado = {
            ..._usuarioLogado!,
            ...dadosAtualizados,
          };
        }

        // ✅ SALVA NO CACHE
        await _salvarUsuarioNoCache(_usuarioLogado!);

        print('✅ Perfil atualizado com sucesso na API e cache!');

        _isLoading = false;
        _errorMessage = null;
        notifyListeners(); // ✅ NOTIFICA AS MUDANÇAS

        return true;
      } else {
        _errorMessage = resultado['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao atualizar perfil: $e';
      notifyListeners();
      return false;
    }
  }

  // ✅ MÉTODO: Login com tratamento correto
  Future<bool> login(String email, String senha) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.login(
        email: email,
        senha: senha,
      );

      _isLoading = false;

      if (result['success'] == true) {
        _usuarioLogado = result['usuario'];
        _errorMessage = null;

        // Garante compatibilidade de IDs
        if (_usuarioLogado != null) {
          final id =
              _usuarioLogado!['idusuario'] ?? _usuarioLogado!['idUsuario'];
          if (id != null) {
            _usuarioLogado!['idusuario'] = id;
            _usuarioLogado!['idUsuario'] = id;
          }
        }

        // Salva no cache
        await _salvarUsuarioNoCache(_usuarioLogado!);

        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Erro inesperado: $error';
      notifyListeners();
      return false;
    }
  }

  // ✅ MÉTODO: Logout com limpeza completa
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('usuario_atual');
      await prefs.remove('idUsuario');
      await prefs.remove('email');
      await prefs.remove('nome');
      await prefs.remove('telefone');

      _usuarioLogado = null;
      _errorMessage = null;
      _isLoading = false;

      print('✅ Logout realizado - cache limpo');
      notifyListeners();
    } catch (e) {
      print('❌ Erro ao fazer logout: $e');
    }
  }

  // ✅ MÉTODO: Forçar recarregamento do cache
  Future<void> recarregarUsuario() async {
    print('🔄 Forçando recarregamento do usuário...');
    await _carregarUsuarioDoCache();
  }

  // ✅ MÉTODO: Verificar se usuário está logado
  Future<bool> checkIfUserIsLoggedIn() async {
    if (_usuarioLogado != null) {
      return true;
    }

    await _carregarUsuarioDoCache();
    return _usuarioLogado != null;
  }

  // ✅ MÉTODO: Atualizar dados localmente (sem API)
  Future<void> updateUserData(Map<String, dynamic> newData) async {
    if (_usuarioLogado != null) {
      _usuarioLogado!.addAll(newData);
      await _salvarUsuarioNoCache(_usuarioLogado!);
      notifyListeners();
    }
  }

  // ✅ MÉTODOS ESTÁTICOS PARA ACESSO AO CACHE
  static Future<int?> getUserIdFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Tenta carregar do JSON unificado
      final usuarioJson = prefs.getString('usuario_atual');
      if (usuarioJson != null) {
        final usuario = jsonDecode(usuarioJson);
        final idUsuario = usuario['idusuario'] ?? usuario['idUsuario'];
        return int.tryParse(idUsuario?.toString() ?? '');
      }

      // Fallback para formato antigo
      return prefs.getInt('idUsuario');
    } catch (e) {
      print('❌ Erro ao obter ID do usuário do cache: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Tenta carregar do JSON unificado
      final usuarioJson = prefs.getString('usuario_atual');
      if (usuarioJson != null) {
        return jsonDecode(usuarioJson);
      }

      // Fallback para formato antigo
      final idUsuario = prefs.getInt('idUsuario');
      final email = prefs.getString('email');
      final nome = prefs.getString('nome');
      final telefone = prefs.getString('telefone');

      if (idUsuario != null && email != null && nome != null) {
        return {
          'idusuario': idUsuario,
          'idUsuario': idUsuario,
          'email': email,
          'nome': nome,
          if (telefone != null && telefone.isNotEmpty) 'telefone': telefone,
        };
      }
      return null;
    } catch (e) {
      print('❌ Erro ao obter usuário do cache: $e');
      return null;
    }
  }

  // ✅ MÉTODO: Debug do cache
  static Future<void> debugCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioJson = prefs.getString('usuario_atual');
      final idUsuario = prefs.getInt('idUsuario');
      final email = prefs.getString('email');
      final nome = prefs.getString('nome');
      final telefone = prefs.getString('telefone');

      print('\n🔍 === DEBUG CACHE ===');
      print('🔍 usuario_atual (JSON): $usuarioJson');
      print('🔍 idUsuario: $idUsuario');
      print('🔍 email: $email');
      print('🔍 nome: $nome');
      print('🔍 telefone: $telefone');
      print('🔍 Todas as chaves: ${prefs.getKeys()}');

      if (usuarioJson != null) {
        try {
          final usuario = jsonDecode(usuarioJson);
          print('🔍 Usuário decodificado: $usuario');
        } catch (e) {
          print('❌ Erro ao decodificar JSON: $e');
        }
      }
      print('🔍 === FIM DEBUG ===\n');
    } catch (e) {
      print('❌ Erro ao debug cache: $e');
    }
  }

  // ✅ MÉTODO: Verificar email
  Future<bool> verificarEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.verificarEmail(email: email);

      _isLoading = false;

      if (result['success'] == true) {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Erro ao verificar email: $error';
      notifyListeners();
      return false;
    }
  }

  // ✅ MÉTODO: Redefinir senha
  Future<bool> redefinirSenhaComEmail(String email, String novaSenha) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.redefinirSenhaComEmail(
        email: email,
        novaSenha: novaSenha,
      );

      _isLoading = false;

      if (result['success'] == true) {
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (error) {
      _isLoading = false;
      _errorMessage = 'Erro ao redefinir senha: $error';
      notifyListeners();
      return false;
    }
  }

  // ✅ MÉTODO: Limpar erros
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ✅ MÉTODO: Verificar estado atual
  void debugEstadoAtual() {
    print('\n🔍 === ESTADO ATUAL ===');
    print('🔍 isLoading: $_isLoading');
    print('🔍 errorMessage: $_errorMessage');
    print('🔍 usuarioLogado: $_usuarioLogado');
    print('🔍 isLoggedIn: $isLoggedIn');
    print('🔍 === FIM ESTADO ===\n');
  }
}
