// domain/repositories/usuario_repository.dart
import 'package:pet_family_app/models/user_model.dart';
import 'package:pet_family_app/services/user_service.dart';

abstract class UserRepository {
  Future<Map<String, dynamic>> criarUsuario(UsuarioModel usuario);
  Future<UsuarioModel> buscarUsuarioPorId(int idUsuario);
  Future<List<UsuarioModel>> listarUsuarios();
  Future<UsuarioModel> atualizarUsuario(int idUsuario, UsuarioModel usuario);
  Future<void> excluirUsuario(int idUsuario);
}

// data/repositories/usuario_repository_impl.dart
class UsuarioRepositoryImpl implements UserRepository {
  final UserService userService;

  UsuarioRepositoryImpl({required this.userService});

  @override
  Future<Map<String, dynamic>> criarUsuario(UsuarioModel usuario) async {
    try {
      return await userService.criarUsuario(usuario);
    } catch (e) {
      throw Exception('Erro no repositório: ${e.toString()}');
    }
  }

  @override
  Future<UsuarioModel> buscarUsuarioPorId(int idUsuario) async {
    try {
      return await userService.buscarUsuarioPorId(idUsuario);
    } catch (e) {
      throw Exception('Erro ao buscar usuário: ${e.toString()}');
    }
  }

  @override
  Future<List<UsuarioModel>> listarUsuarios() async {
    try {
      return await userService.listarUsuarios();
    } catch (e) {
      throw Exception('Erro ao listar usuários: ${e.toString()}');
    }
  }

  @override
  Future<UsuarioModel> atualizarUsuario(int idUsuario, UsuarioModel usuario) async {
    try {
      return await userService.atualizarUsuario(idUsuario, usuario);
    } catch (e) {
      throw Exception('Erro ao atualizar usuário: ${e.toString()}');
    }
  }

  @override
  Future<void> excluirUsuario(int idUsuario) async {
    try {
      await userService.excluirUsuario(idUsuario);
    } catch (e) {
      throw Exception('Erro ao excluir usuário: ${e.toString()}');
    }
  }
}