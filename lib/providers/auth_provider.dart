import 'package:flutter/foundation.dart';
import 'package:pet_family_app/models/user_model.dart';
import 'package:pet_family_app/repository/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  UsuarioModel? _usuario;
  int? _usuarioId;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  // GETTERS
  UsuarioModel? get usuario => _usuario;
  int? get usuarioId => _usuarioId;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    print('👤 AuthProvider iniciado');
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔄 Carregando usuário atual...');

      // Carregar ID do usuário do cache
      _usuarioId = await getUserIdFromCache();
      print('📋 ID Usuário carregado do cache: $_usuarioId');

      // Carregar dados completos do usuário
      final user = await _repository.getCurrentUser();

      if (user != null && _usuarioId != null) {
        _usuario = user;
        _isAuthenticated = true;
        print('✅ Usuário carregado: ${user.nome} (ID: $_usuarioId)');
      } else {
        print('ℹ️ Nenhum usuário encontrado ou ID ausente');
      }
    } catch (error) {
      _errorMessage = 'Erro ao carregar usuário: $error';
      print('❌ $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String senha) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('🔐 Tentando login: $email');
      final result = await _repository.login(email, senha);

      if (result['success'] == true) {
        _usuario = result['usuario'];
        _usuarioId = _usuario?.idUsuario;
        _isAuthenticated = true;
        _errorMessage = null;
        print('✅ Login realizado - ID Usuário: $_usuarioId');
        return true;
      } else {
        _errorMessage = result['message'];
        _isAuthenticated = false;
        print('❌ Login falhou: $_errorMessage');
        return false;
      }
    } catch (error) {
      _errorMessage = 'Erro: $error';
      _isAuthenticated = false;
      print('❌ $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> alterarSenha(String senhaAtual, String novaSenha) async {
    try {
      if (_usuario == null || _usuario!.idUsuario == null) {
        _errorMessage = 'Usuário não encontrado';
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('🔐 Alterando senha usuário ID: ${_usuario!.idUsuario}');

      final result = await _repository.alterarSenha(
        _usuario!.idUsuario!,
        senhaAtual,
        novaSenha,
      );

      if (result['success'] == true) {
        final updatedUser = await _repository.getCurrentUser();
        if (updatedUser != null) {
          _usuario = updatedUser;
        }
        _errorMessage = null;
        print('✅ Senha alterada com sucesso');
        return true;
      } else {
        _errorMessage = result['message'];
        print('❌ Erro ao alterar senha: $_errorMessage');
        return false;
      }
    } catch (error) {
      _errorMessage = 'Erro: $error';
      print('❌ $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> solicitarRecuperacaoSenha(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _repository.solicitarRecuperacaoSenha(email);

      if (result['success'] == true) {
        _errorMessage = null;
        print('✅ Solicitação de recuperação enviada');
        return true;
      } else {
        _errorMessage = result['message'];
        print('❌ Erro recuperação senha: $_errorMessage');
        return false;
      }
    } catch (error) {
      _errorMessage = 'Erro: $error';
      print('❌ $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> redefinirSenha(String email, String novaSenha) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _repository.redefinirSenha(email, novaSenha);

      if (result['success'] == true) {
        _errorMessage = null;
        print('✅ Senha redefinida com sucesso');
        return true;
      } else {
        _errorMessage = result['message'];
        print('❌ Erro redefinir senha: $_errorMessage');
        return false;
      }
    } catch (error) {
      _errorMessage = 'Erro: $error';
      print('❌ $_errorMessage');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🚪 Fazendo logout do usuário...');
      await _repository.logout();

      _usuario = null;
      _usuarioId = null;
      _isAuthenticated = false;
      _errorMessage = null;
      print('✅ Logout realizado com sucesso');
    } catch (error) {
      _errorMessage = 'Erro ao fazer logout: $error';
      print('❌ $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAuthentication() async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔍 Verificando autenticação usuário...');
      final isLoggedIn = await _repository.isLoggedIn();
      _isAuthenticated = isLoggedIn;

      if (isLoggedIn) {
        _usuarioId = await getUserIdFromCache();
        final user = await _repository.getCurrentUser();
        _usuario = user;
        print('✅ Usuário autenticado - ID: $_usuarioId');
      } else {
        print('ℹ️ Usuário não autenticado');
      }
    } catch (error) {
      _errorMessage = 'Erro ao verificar autenticação: $error';
      _isAuthenticated = false;
      print('❌ $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recarregarUsuario() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('🔄 Recarregando dados do usuário...');

      // Recarregar ID do cache
      _usuarioId = await getUserIdFromCache();

      // Recarregar dados do usuário
      final user = await _repository.getCurrentUser();

      if (user != null && _usuarioId != null) {
        _usuario = user;
        _isAuthenticated = true;
        print('✅ Usuário recarregado: ${user.nome}');
      } else {
        print('⚠️ Não foi possível recarregar usuário');
        _isAuthenticated = false;
      }
    } catch (error) {
      _errorMessage = 'Erro ao recarregar usuário: $error';
      print('❌ $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setUsuario(UsuarioModel usuario) {
    _usuario = usuario;
    _usuarioId = usuario.idUsuario;
    _isAuthenticated = true;
    print('👤 Usuário definido manualmente: ${usuario.nome} (ID: $_usuarioId)');
    notifyListeners();
  }

  // MÉTODO PARA OBTER ID DO USUÁRIO DO CACHE
  Future<int?> getUserIdFromCache() async {
    try {
      final id = await _repository.getUserIdFromCache();
      print('🔍 AuthProvider.getUserIdFromCache() retornou: $id');
      return id;
    } catch (error) {
      print('❌ Erro em getUserIdFromCache(): $error');
      return null;
    }
  }

  // MÉTODOS AUXILIARES
  String? get nomeUsuario => _usuario?.nome;
  String? get emailUsuario => _usuario?.email;
  String? get telefoneUsuario => _usuario?.telefone;
}
