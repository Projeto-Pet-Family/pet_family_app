import 'package:pet_family_app/models/user_model.dart';
import 'package:pet_family_app/services/auth_service.dart';

class AuthRepository {
  final AuthService _service = AuthService();

  Future<Map<String, dynamic>> login(String email, String senha) async {
    return await _service.login(email, senha);
  }

  Future<Map<String, dynamic>> alterarSenha(
    int idUsuario, 
    String senhaAtual, 
    String novaSenha
  ) async {
    return await _service.alterarSenha(idUsuario, senhaAtual, novaSenha);
  }

  Future<Map<String, dynamic>> solicitarRecuperacaoSenha(String email) async {
    return await _service.solicitarRecuperacaoSenha(email);
  }

  Future<Map<String, dynamic>> redefinirSenha(String email, String novaSenha) async {
    return await _service.redefinirSenha(email, novaSenha);
  }

  Future<void> logout() async {
    await _service.logout();
  }

  Future<bool> isLoggedIn() async {
    return await _service.isLoggedIn();
  }

  Future<UsuarioModel?> getCurrentUser() async {
    return await _service.getCurrentUser();
  }

  Future<String?> getToken() async {
    return await _service.getToken();
  }
}