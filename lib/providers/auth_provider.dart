import 'package:flutter/foundation.dart';
import 'package:pet_family_app/models/user_model.dart';
import 'package:pet_family_app/repository/auth_repository.dart';

class AuthenticationProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  
  UsuarioModel? _usuario;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _error;

  UsuarioModel? get usuario => _usuario;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get error => _error;

  AuthenticationProvider() {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await _repository.getCurrentUser();
      if (user != null) {
        _usuario = user;
        _isAuthenticated = true;
      }
    } catch (error) {
      _error = 'Erro ao carregar usuário: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String senha) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _repository.login(email, senha);
      
      if (result['success'] == true) {
        _usuario = result['usuario'];
        _isAuthenticated = true;
        _error = null;
      } else {
        _error = result['message'];
        _isAuthenticated = false;
      }
    } catch (error) {
      _error = 'Erro: $error';
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> alterarSenha(
    String senhaAtual, 
    String novaSenha
  ) async {
    try {
      if (_usuario == null || _usuario!.idUsuario == null) {
        throw Exception('Usuário não encontrado');
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _repository.alterarSenha(
        _usuario!.idUsuario!,
        senhaAtual,
        novaSenha,
      );
      
      if (result['success'] == true) {
        // Recarregar dados do usuário se necessário
        final updatedUser = await _repository.getCurrentUser();
        if (updatedUser != null) {
          _usuario = updatedUser;
        }
        _error = null;
      } else {
        _error = result['message'];
      }
    } catch (error) {
      _error = 'Erro: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> solicitarRecuperacaoSenha(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _repository.solicitarRecuperacaoSenha(email);
      
      if (result['success'] != true) {
        _error = result['message'];
      }
    } catch (error) {
      _error = 'Erro: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> redefinirSenha(String email, String novaSenha) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _repository.redefinirSenha(email, novaSenha);
      
      if (result['success'] != true) {
        _error = result['message'];
      }
    } catch (error) {
      _error = 'Erro: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.logout();
      
      _usuario = null;
      _isAuthenticated = false;
      _error = null;
    } catch (error) {
      _error = 'Erro ao fazer logout: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthentication() async {
    try {
      _isLoading = true;
      notifyListeners();

      final isLoggedIn = await _repository.isLoggedIn();
      _isAuthenticated = isLoggedIn;
      
      if (isLoggedIn) {
        final user = await _repository.getCurrentUser();
        _usuario = user;
      }
    } catch (error) {
      _error = 'Erro ao verificar autenticação: $error';
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setUsuario(UsuarioModel usuario) {
    _usuario = usuario;
    _isAuthenticated = true;
    notifyListeners();
  }
}