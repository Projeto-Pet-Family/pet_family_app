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

  // Construtor que carrega os dados do cache ao inicializar
  AuthProvider() {
    _loadUserFromCache();
  }

  // Carregar usuário do cache
  Future<void> _loadUserFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idUsuario = prefs.getInt('idUsuario');
      final email = prefs.getString('email');
      final nome = prefs.getString('nome');

      if (idUsuario != null && email != null && nome != null) {
        _usuarioLogado = {
          'idUsuario': idUsuario,
          'email': email,
          'nome': nome,
        };
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao carregar usuário do cache: $e');
      }
    }
  }

  // Salvar usuário no cache
  Future<void> _saveUserToCache(Map<String, dynamic> usuario) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Converter idUsuario para int de forma segura
      final idUsuario = usuario['idusuario'];
      if (idUsuario != null) {
        await prefs.setInt(
            'idUsuario', int.tryParse(idUsuario.toString()) ?? 0);
      } else {
        // Se idusuario for null, tentar usar 'idUsuario' como fallback
        final fallbackId = usuario['idUsuario'];
        if (fallbackId != null) {
          await prefs.setInt(
              'idUsuario', int.tryParse(fallbackId.toString()) ?? 0);
        } else {
          throw Exception('ID do usuário não encontrado na resposta');
        }
      }

      // Salvar outros dados
      await prefs.setString('email', usuario['email'] as String? ?? '');
      await prefs.setString('nome', usuario['nome'] as String? ?? '');

      // Salvar outros campos se existirem
      if (usuario.containsKey('telefone')) {
        await prefs.setString('telefone', usuario['telefone'] as String? ?? '');
      }
      if (usuario.containsKey('cpf')) {
        await prefs.setString('cpf', usuario['cpf'] as String? ?? '');
      }

      print(
          '✅ Usuário salvo no cache: ${usuario['nome']} (ID: ${prefs.getInt('idUsuario')})');
    } catch (e) {
      print('❌ Erro ao salvar usuário no cache: $e');
      print('📦 Dados do usuário recebidos: $usuario');
      rethrow;
    }
  }

  // Limpar cache do usuário
  Future<void> _clearUserCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('idUsuario');
      await prefs.remove('email');
      await prefs.remove('nome');
      await prefs.remove('telefone');
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao limpar cache do usuário: $e');
      }
    }
  }

  // Método estático para obter o ID do usuário do cache (usado no PetRepository)
  static Future<int?> getUserIdFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('idUsuario');
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao obter ID do usuário do cache: $e');
      }
      return null;
    }
  }

  // Método estático para obter dados completos do usuário do cache
  static Future<Map<String, dynamic>?> getUserFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idUsuario = prefs.getInt('idUsuario');
      final email = prefs.getString('email');
      final nome = prefs.getString('nome');
      final telefone = prefs.getString('telefone');

      if (idUsuario != null && email != null && nome != null) {
        return {
          'idUsuario': idUsuario,
          'email': email,
          'nome': nome,
          if (telefone != null) 'telefone': telefone,
        };
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao obter usuário do cache: $e');
      }
      return null;
    }
  }

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

  // ✅ MÉTODO REDEFINIR SENHA (usando redefinir-senha)
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

  // Login atualizado para salvar no cache
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

        // Debug: verificar dados recebidos
        print('🔍 Dados do usuário recebidos: $_usuarioLogado');
        print('🔍 ID do usuário: ${_usuarioLogado?['idusuario']}');
        print('🔍 Tipo do ID: ${_usuarioLogado?['idusuario']?.runtimeType}');

        // Salvar usuário no cache
        await _saveUserToCache(_usuarioLogado!);

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

  // Logout atualizado para limpar o cache
  Future<void> logout() async {
    await _clearUserCache();
    _usuarioLogado = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Verificar se usuário está logado (com cache)
  Future<bool> checkIfUserIsLoggedIn() async {
    if (_usuarioLogado != null) {
      return true;
    }

    final userFromCache = await getUserFromCache();
    if (userFromCache != null) {
      _usuarioLogado = userFromCache;
      notifyListeners();
      return true;
    }

    return false;
  }

  // Atualizar dados do usuário no cache
  Future<void> updateUserData(Map<String, dynamic> newData) async {
    if (_usuarioLogado != null) {
      _usuarioLogado!.addAll(newData);
      await _saveUserToCache(_usuarioLogado!);
      notifyListeners();
    }
  }

  static Future<void> debugCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idUsuario = prefs.getInt('idUsuario');
      final email = prefs.getString('email');
      final nome = prefs.getString('nome');

      print('🔍 DEBUG CACHE:');
      print('🔍 idUsuario: $idUsuario');
      print('🔍 email: $email');
      print('🔍 nome: $nome');
      print('🔍 Todas as chaves: ${prefs.getKeys()}');
    } catch (e) {
      print('❌ Erro ao debug cache: $e');
    }
  }

  // Limpar erros
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
