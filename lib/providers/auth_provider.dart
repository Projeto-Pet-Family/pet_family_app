import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _usuarioLogado;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get usuarioLogado => _usuarioLogado;
  bool get isLoggedIn => _usuarioLogado != null;

  // ✅ MÉTODO VERIFICAR EMAIL (usando ativar-conta)
  Future<bool> verificarEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.verificarEmailNovo(email: email);

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

  // Login
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

  // Logout
  void logout() {
    _usuarioLogado = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Limpar erros
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}