// providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:pet_family_app/models/user_model.dart';
import 'package:pet_family_app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  // Estado do provider
  UsuarioModel? _usuario;
  int? _usuarioId;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  bool _hasCheckedAuth = false;
  bool _isInitializing = false;

  // GETTERS
  UsuarioModel? get usuario => _usuario;
  int? get usuarioId => _usuarioId;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;
  bool get hasCheckedAuth => _hasCheckedAuth;
  
  // Dados do usuário (conveniência)
  String? get nomeUsuario => _usuario?.nome;
  String? get emailUsuario => _usuario?.email;
  String? get telefoneUsuario => _usuario?.telefone;
  String? get cpfUsuario => _usuario?.cpf;

  AuthProvider() {
    print('👤 AuthProvider iniciado');
    // Inicializar de forma segura após o primeiro frame
    _delayedInitialize();
  }

  // ========== MÉTODOS DE INICIALIZAÇÃO ==========
  
  void _delayedInitialize() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _checkAuthentication();
    });
  }

  Future<void> _checkAuthentication() async {
    // Evitar múltiplas inicializações simultâneas
    if (_isInitializing) return;
    
    _isInitializing = true;
    
    try {
      _isLoading = true;
      _safeNotifyListeners();

      print('🔍 Verificando autenticação do usuário...');
      
      // Verificar se há token válido
      final isLoggedIn = await _authService.isLoggedIn();
      print('📊 Status de login (cache): $isLoggedIn');
      
      if (isLoggedIn) {
        // Carregar ID do usuário do cache
        _usuarioId = await _authService.getUserIdFromCache();
        print('📋 ID carregado do cache: $_usuarioId');
        
        // Carregar dados completos do usuário
        final user = await _authService.getCurrentUser();
        
        if (user != null && _usuarioId != null) {
          _usuario = user;
          _isAuthenticated = true;
          print('✅ Usuário autenticado: ${user.nome} (ID: $_usuarioId)');
        } else {
          // Dados inconsistentes - fazer logout silencioso
          print('⚠️ Dados inconsistentes encontrados, limpando sessão...');
          await _authService.logout();
          _isAuthenticated = false;
        }
      } else {
        print('ℹ️ Usuário não autenticado (cache vazio)');
        _isAuthenticated = false;
      }
      
      _hasCheckedAuth = true;
      print('🎯 Verificação de autenticação concluída');
    } catch (error, stackTrace) {
      _errorMessage = 'Erro ao verificar autenticação: $error';
      _isAuthenticated = false;
      _hasCheckedAuth = true;
      print('❌ ERRO em _checkAuthentication: $_errorMessage');
      print('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      _isInitializing = false;
      _safeNotifyListeners();
    }
  }

  // ========== MÉTODO DE LOGIN ==========
  
  Future<bool> login(String email, String senha) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _safeNotifyListeners();

      print('🔐 Tentando login para: $email');
      
      final result = await _authService.login(email, senha);

      if (result['success'] == true) {
        _usuario = result['usuario'] as UsuarioModel?;
        _usuarioId = _usuario?.idUsuario;
        _isAuthenticated = true;
        _errorMessage = null;
        _hasCheckedAuth = true;
        
        print('✅ Login realizado com sucesso');
        print('👤 Usuário: ${_usuario?.nome}');
        print('🆔 ID: $_usuarioId');
        
        _safeNotifyListeners();
        return true;
      } else {
        _errorMessage = result['message'] as String? ?? 'Erro desconhecido no login';
        _isAuthenticated = false;
        
        print('❌ Login falhou: $_errorMessage');
        _safeNotifyListeners();
        return false;
      }
    } catch (error, stackTrace) {
      _errorMessage = 'Erro ao conectar com o servidor: $error';
      _isAuthenticated = false;
      
      print('❌ ERRO no login: $_errorMessage');
      print('Stack trace: $stackTrace');
      
      _safeNotifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // ========== MÉTODO DE LOGOUT ==========
  
  Future<void> logout() async {
    try {
      _isLoading = true;
      _safeNotifyListeners();

      print('🚪 Iniciando logout...');
      
      await _authService.logout();

      // Limpar estado local
      _usuario = null;
      _usuarioId = null;
      _isAuthenticated = false;
      _errorMessage = null;
      _hasCheckedAuth = true;
      
      print('✅ Logout realizado com sucesso');
    } catch (error, stackTrace) {
      _errorMessage = 'Erro ao fazer logout: $error';
      print('❌ ERRO no logout: $_errorMessage');
      print('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // ========== MÉTODO DE ALTERAÇÃO DE SENHA ==========
  
  Future<bool> alterarSenha(String senhaAtual, String novaSenha) async {
    try {
      if (_usuario == null || _usuario!.idUsuario == null) {
        _errorMessage = 'Usuário não encontrado';
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      _safeNotifyListeners();

      print('🔐 Alterando senha para usuário ID: ${_usuario!.idUsuario}');

      final result = await _authService.alterarSenha(
        _usuario!.idUsuario!,
        senhaAtual,
        novaSenha,
      );

      if (result['success'] == true) {
        // Recarregar dados do usuário após alteração
        await _recarregarDadosUsuario();
        
        _errorMessage = null;
        print('✅ Senha alterada com sucesso');
        return true;
      } else {
        _errorMessage = result['message'] as String? ?? 'Erro ao alterar senha';
        print('❌ Erro ao alterar senha: $_errorMessage');
        return false;
      }
    } catch (error, stackTrace) {
      _errorMessage = 'Erro: $error';
      print('❌ ERRO ao alterar senha: $_errorMessage');
      print('Stack trace: $stackTrace');
      return false;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // ========== MÉTODOS DE RECUPERAÇÃO DE SENHA ==========
  
  Future<bool> solicitarRecuperacaoSenha(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _safeNotifyListeners();

      print('📧 Solicitando recuperação de senha para: $email');

      final result = await _authService.solicitarRecuperacaoSenha(email);

      if (result['success'] == true) {
        _errorMessage = null;
        print('✅ Solicitação de recuperação enviada com sucesso');
        return true;
      } else {
        _errorMessage = result['message'] as String? ?? 'Erro ao solicitar recuperação';
        print('❌ Erro na recuperação de senha: $_errorMessage');
        return false;
      }
    } catch (error, stackTrace) {
      _errorMessage = 'Erro: $error';
      print('❌ ERRO na solicitação de recuperação: $_errorMessage');
      print('Stack trace: $stackTrace');
      return false;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<bool> redefinirSenha(String email, String novaSenha) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _safeNotifyListeners();

      print('🔄 Redefinindo senha para: $email');

      final result = await _authService.redefinirSenha(email, novaSenha);

      if (result['success'] == true) {
        _errorMessage = null;
        print('✅ Senha redefinida com sucesso');
        return true;
      } else {
        _errorMessage = result['message'] as String? ?? 'Erro ao redefinir senha';
        print('❌ Erro ao redefinir senha: $_errorMessage');
        return false;
      }
    } catch (error, stackTrace) {
      _errorMessage = 'Erro: $error';
      print('❌ ERRO ao redefinir senha: $_errorMessage');
      print('Stack trace: $stackTrace');
      return false;
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  // ========== MÉTODOS DE ATUALIZAÇÃO ==========
  
  Future<void> recarregarUsuario() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _safeNotifyListeners();

      print('🔄 Recarregando dados do usuário...');

      await _recarregarDadosUsuario();
      
      print('✅ Dados do usuário recarregados');
    } catch (error, stackTrace) {
      _errorMessage = 'Erro ao recarregar usuário: $error';
      print('❌ ERRO ao recarregar usuário: $_errorMessage');
      print('Stack trace: $stackTrace');
    } finally {
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> _recarregarDadosUsuario() async {
    // Recarregar ID do cache
    _usuarioId = await _authService.getUserIdFromCache();
    print('🆔 ID recarregado: $_usuarioId');

    // Recarregar dados do usuário
    final user = await _authService.getCurrentUser();

    if (user != null && _usuarioId != null) {
      _usuario = user;
      _isAuthenticated = true;
      print('✅ Usuário recarregado: ${user.nome}');
    } else {
      print('⚠️ Não foi possível recarregar usuário');
      _isAuthenticated = false;
    }
  }

  // ========== MÉTODOS AUXILIARES ==========
  
  Future<void> checkAuthentication() async {
    if (!_hasCheckedAuth) {
      await _checkAuthentication();
    }
  }

  Future<String?> getToken() async {
    return await _authService.getToken();
  }

  void clearError() {
    _errorMessage = null;
    _safeNotifyListeners();
  }

  void setUsuario(UsuarioModel usuario) {
    _usuario = usuario;
    _usuarioId = usuario.idUsuario;
    _isAuthenticated = true;
    _hasCheckedAuth = true;
    
    print('👤 Usuário definido manualmente: ${usuario.nome} (ID: $_usuarioId)');
    _safeNotifyListeners();
  }

  Future<int?> getUserIdFromCache() async {
    return await _authService.getUserIdFromCache();
  }

  // ========== MÉTODO SEGURO PARA NOTIFICAÇÃO ==========
  
  void _safeNotifyListeners() {
    // Evitar notificar durante o build
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (hasListeners) notifyListeners();
      });
    } else {
      if (hasListeners) notifyListeners();
    }
  }

  // ========== MÉTODO DE VALIDAÇÃO DE SESSAO ==========
  
  Future<bool> validarSessao() async {
    try {
      print('🔐 Validando sessão atual...');
      
      final token = await _authService.getToken();
      if (token == null) {
        print('❌ Sessão inválida: token não encontrado');
        await logout();
        return false;
      }

      // Aqui você pode adicionar validações adicionais
      // como verificar expiração do token, etc.
      
      print('✅ Sessão válida');
      return true;
    } catch (error) {
      print('❌ Erro ao validar sessão: $error');
      await logout();
      return false;
    }
  }

  // ========== MÉTODO PARA ATUALIZAR DADOS DO USUÁRIO ==========
  
  void atualizarDadosUsuario(UsuarioModel novosDados) {
    if (_usuario != null) {
      _usuario = novosDados;
      print('📝 Dados do usuário atualizados: ${novosDados.nome}');
      _safeNotifyListeners();
    }
  }

  // ========== MÉTODO PARA LIMPAR CACHE ==========
  
  Future<void> limparCache() async {
    print('🧹 Limpando cache de autenticação...');
    await _authService.logout();
    
    _usuario = null;
    _usuarioId = null;
    _isAuthenticated = false;
    _errorMessage = null;
    _hasCheckedAuth = false;
    
    print('✅ Cache limpo');
    _safeNotifyListeners();
  }

  // ========== MÉTODO PARA VERIFICAR CONEXÃO ==========
  
  Future<bool> verificarConexao() async {
    try {
      // Verificar se o token existe
      final token = await _authService.getToken();
      return token != null && token.isNotEmpty;
    } catch (error) {
      return false;
    }
  }

  // ========== DISPOSE ==========
  
  @override
  void dispose() {
    print('👋 AuthProvider disposado');
    super.dispose();
  }
}