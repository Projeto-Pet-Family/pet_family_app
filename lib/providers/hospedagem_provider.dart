import 'package:flutter/foundation.dart';
import 'package:pet_family_app/repository/hospedagem_repository.dart';
import '../models/hospedagem_model.dart';

class HospedagemProvider extends ChangeNotifier {
  final HospedagemRepository _repository = HospedagemRepository();

  List<HospedagemModel> _hospedagens = [];
  HospedagemModel? _currentHospedagem;
  bool _isLoading = false;
  bool _isHospedagemAuthenticated = false;
  String? _error;

  List<HospedagemModel> get hospedagens => _hospedagens;
  HospedagemModel? get currentHospedagem => _currentHospedagem;
  bool get isLoading => _isLoading;
  bool get isHospedagemAuthenticated => _isHospedagemAuthenticated;
  String? get error => _error;

  HospedagemProvider() {
    print('🏨 HospedagemProvider iniciado');
    _loadCurrentHospedagem();
  }

  Future<void> _loadCurrentHospedagem() async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔄 Carregando hospedagem atual do storage...');
      final hospedagem = await _repository.getCurrentHospedagem();

      if (hospedagem != null) {
        _currentHospedagem = hospedagem;
        _isHospedagemAuthenticated = true;
        print(
            '✅ Hospedagem carregada: ${hospedagem.nome} (ID: ${hospedagem.idHospedagem})');
      } else {
        print('ℹ️ Nenhuma hospedagem encontrada no storage');
      }
    } catch (error) {
      _error = 'Erro ao carregar hospedagem: $error';
      print('❌ $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHospedagens() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 Carregando lista de hospedagens...');
      _hospedagens = await _repository.getHospedagens();
      print('✅ ${_hospedagens.length} hospedagens carregadas');
    } catch (error) {
      _error = 'Erro ao carregar hospedagens: $error';
      print('❌ $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHospedagemById(int idHospedagem) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔄 Carregando hospedagem por ID: $idHospedagem');
      final hospedagem = await _repository.getHospedagemById(idHospedagem);
      _currentHospedagem = hospedagem;
      print('✅ Hospedagem carregada: ${hospedagem.nome}');
    } catch (error) {
      _error = 'Erro ao carregar hospedagem: $error';
      print('❌ $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createHospedagem(HospedagemModel hospedagem) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('➕ Criando nova hospedagem: ${hospedagem.nome}');
      final result = await _repository.createHospedagem(hospedagem);

      if (result['success'] == true) {
        print('✅ Hospedagem criada com sucesso');
        await loadHospedagens();
        _error = null;
      } else {
        _error = result['message'];
        print('❌ Erro ao criar hospedagem: $_error');
      }
    } catch (error) {
      _error = 'Erro: $error';
      print('❌ $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateHospedagem(
      int idHospedagem, HospedagemModel hospedagem) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('✏️ Atualizando hospedagem ID: $idHospedagem');
      final result =
          await _repository.updateHospedagem(idHospedagem, hospedagem);

      if (result['success'] == true) {
        if (_currentHospedagem != null &&
            _currentHospedagem!.idHospedagem == idHospedagem) {
          _currentHospedagem = result['hospedagem'];
          print('✅ Hospedagem atual atualizada');
        }

        await loadHospedagens();
        _error = null;
        print('✅ Hospedagem atualizada com sucesso');
      } else {
        _error = result['message'];
        print('❌ Erro ao atualizar hospedagem: $_error');
      }
    } catch (error) {
      _error = 'Erro: $error';
      print('❌ $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteHospedagem(int idHospedagem) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🗑️ Excluindo hospedagem ID: $idHospedagem');
      final result = await _repository.deleteHospedagem(idHospedagem);

      if (result['success'] == true) {
        _hospedagens.removeWhere(
            (hospedagem) => hospedagem.idHospedagem == idHospedagem);

        if (_currentHospedagem != null &&
            _currentHospedagem!.idHospedagem == idHospedagem) {
          await logoutHospedagem();
        }

        _error = null;
        print('✅ Hospedagem excluída com sucesso');
      } else {
        _error = result['message'];
        print('❌ Erro ao excluir hospedagem: $_error');
      }
    } catch (error) {
      _error = 'Erro: $error';
      print('❌ $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginHospedagem(String email, String senha) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('🔐 Tentando login hospedagem: $email');
      final result = await _repository.loginHospedagem(email, senha);

      if (result['success'] == true) {
        _currentHospedagem = result['hospedagem'];
        _isHospedagemAuthenticated = true;
        _error = null;
        print('✅ Login realizado com sucesso');
      } else {
        _error = result['message'];
        _isHospedagemAuthenticated = false;
        print('❌ Login falhou: $_error');
      }
    } catch (error) {
      _error = 'Erro: $error';
      _isHospedagemAuthenticated = false;
      print('❌ $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> alterarSenhaHospedagem(
      String senhaAtual, String novaSenha) async {
    try {
      if (_currentHospedagem == null ||
          _currentHospedagem!.idHospedagem == null) {
        throw Exception('Hospedagem não encontrada');
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      final idHospedagem = _currentHospedagem!.idHospedagem;
      print('🔐 Alterando senha hospedagem ID: $idHospedagem');

      final result = await _repository.alterarSenhaHospedagem(
        idHospedagem,
        senhaAtual,
        novaSenha,
      );

      if (result['success'] == true) {
        _error = null;
        print('✅ Senha alterada com sucesso');
      } else {
        _error = result['message'];
        print('❌ Erro ao alterar senha: $_error');
      }
    } catch (error) {
      _error = 'Erro: $error';
      print('❌ $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logoutHospedagem() async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🚪 Fazendo logout da hospedagem...');
      await _repository.logoutHospedagem();

      _currentHospedagem = null;
      _isHospedagemAuthenticated = false;
      _error = null;
      print('✅ Logout realizado com sucesso');
    } catch (error) {
      _error = 'Erro ao fazer logout: $error';
      print('❌ $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkHospedagemAuthentication() async {
    try {
      _isLoading = true;
      notifyListeners();

      print('🔍 Verificando autenticação da hospedagem...');
      final isLoggedIn = await _repository.isHospedagemLoggedIn();
      _isHospedagemAuthenticated = isLoggedIn;

      if (isLoggedIn) {
        final hospedagem = await _repository.getCurrentHospedagem();
        _currentHospedagem = hospedagem;
        print('✅ Hospedagem autenticada');
      } else {
        print('ℹ️ Hospedagem não autenticada');
      }
    } catch (error) {
      _error = 'Erro ao verificar autenticação: $error';
      _isHospedagemAuthenticated = false;
      print('❌ $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void setCurrentHospedagem(HospedagemModel hospedagem) {
    _currentHospedagem = hospedagem;
    _isHospedagemAuthenticated = true;
    print('🏨 Hospedagem definida manualmente: ${hospedagem.nome}');
    notifyListeners();
  }
}
