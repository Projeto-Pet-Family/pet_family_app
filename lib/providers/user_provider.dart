// presentation/providers/usuario_provider.dart
import 'package:flutter/foundation.dart';
import 'package:pet_family_app/models/user_model.dart';
import 'package:pet_family_app/repository/user_repository.dart';

class UsuarioProvider with ChangeNotifier {
  final UserRepository usuarioRepository;

  List<UsuarioModel> _usuarios = [];
  UsuarioModel? _usuarioLogado;
  bool _loading = false;
  String? _error;
  bool _success = false;

  UsuarioProvider({required this.usuarioRepository});

  // Getters
  List<UsuarioModel> get usuarios => _usuarios;
  UsuarioModel? get usuarioLogado => _usuarioLogado;
  bool get loading => _loading;
  String? get error => _error;
  bool get success => _success;

  // Criar usuário
  Future<void> criarUsuario(UsuarioModel usuario) async {
    _loading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      final response = await usuarioRepository.criarUsuario(usuario);

      // Atualiza o usuário com os dados retornados do servidor
      final usuarioCriado = UsuarioModel.fromJson(response['data']['usuario']);
      _usuarioLogado = usuarioCriado;
      _success = true;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _success = false;
      notifyListeners();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Buscar usuário por ID
  Future<void> buscarUsuarioPorId(int idUsuario) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _usuarioLogado = await usuarioRepository.buscarUsuarioPorId(idUsuario);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _usuarioLogado = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Listar todos os usuários
  Future<void> listarUsuarios() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _usuarios = await usuarioRepository.listarUsuarios();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _usuarios = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Atualizar usuário
  Future<void> atualizarUsuario(int idUsuario, UsuarioModel usuario) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final usuarioAtualizado =
          await usuarioRepository.atualizarUsuario(idUsuario, usuario);

      // Atualiza na lista local se existir
      final index = _usuarios.indexWhere((u) => u.idUsuario == idUsuario);
      if (index != -1) {
        _usuarios[index] = usuarioAtualizado;
      }

      // Atualiza usuário logado se for o mesmo
      if (_usuarioLogado?.idUsuario == idUsuario) {
        _usuarioLogado = usuarioAtualizado;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Excluir usuário
  Future<void> excluirUsuario(int idUsuario) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await usuarioRepository.excluirUsuario(idUsuario);

      // Remove da lista local
      _usuarios.removeWhere((u) => u.idUsuario == idUsuario);

      // Limpa usuário logado se for o mesmo
      if (_usuarioLogado?.idUsuario == idUsuario) {
        _usuarioLogado = null;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Limpar estados
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSuccess() {
    _success = false;
    notifyListeners();
  }

  void setUsuarioLogado(UsuarioModel usuario) {
    _usuarioLogado = usuario;
    notifyListeners();
  }

  void logout() {
    _usuarioLogado = null;
    notifyListeners();
  }
}
