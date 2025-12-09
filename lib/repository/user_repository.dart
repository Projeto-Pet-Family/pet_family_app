// domain/repositories/usuario_repository.dart
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/models/user_model.dart';
import 'package:pet_family_app/services/user_service.dart';

// domain/repositories/usuario_repository.dart
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/models/user_model.dart';

abstract class UserRepository {
  // Usuário
  Future<Map<String, dynamic>> criarUsuario(UsuarioModel usuario);
  Future<Map<String, dynamic>> buscarUsuarioPorId(int idUsuario);
  Future<Map<String, dynamic>> listarUsuarios();
  Future<Map<String, dynamic>> atualizarUsuario(int idUsuario, UsuarioModel usuario);
  Future<Map<String, dynamic>> atualizarPerfil(int idUsuario, Map<String, dynamic> dados);
  Future<Map<String, dynamic>> excluirUsuario(int idUsuario);
  Future<Map<String, dynamic>> buscarUsuarioAtual();
  
  // Usuário com pet
  Future<Map<String, dynamic>> criarUsuarioComPet(UsuarioModel usuario, PetModel? petData);
  
  // Verificações
  Future<Map<String, dynamic>> verificarEmail(String email);
  
  // Senha
  Future<Map<String, dynamic>> alterarSenha(int idUsuario, String senhaAtual, String novaSenha);
}

class UsuarioRepositoryImpl implements UserRepository {
  final UserService userService;

  UsuarioRepositoryImpl({required this.userService});

  @override
  Future<Map<String, dynamic>> criarUsuario(UsuarioModel usuario) async {
    try {
      print('📝 Repositório: Criando usuário ${usuario.nome}');
      return await userService.criarUsuario(usuario);
    } catch (e) {
      print('❌ Erro no repositório ao criar usuário: $e');
      return {
        'success': false,
        'message': 'Erro ao criar usuário: ${e.toString()}',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> buscarUsuarioPorId(int idUsuario) async {
    try {
      print('🔍 Repositório: Buscando usuário ID $idUsuario');
      return await userService.buscarUsuarioPorId(idUsuario);
    } catch (e) {
      print('❌ Erro no repositório ao buscar usuário: $e');
      return {
        'success': false,
        'message': 'Erro ao buscar usuário: ${e.toString()}',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> listarUsuarios() async {
    try {
      print('📋 Repositório: Listando todos os usuários');
      return await userService.listarUsuarios();
    } catch (e) {
      print('❌ Erro no repositório ao listar usuários: $e');
      return {
        'success': false,
        'message': 'Erro ao listar usuários: ${e.toString()}',
        'usuarios': [],
      };
    }
  }

  @override
  Future<Map<String, dynamic>> atualizarUsuario(int idUsuario, UsuarioModel usuario) async {
    try {
      print('🔄 Repositório: Atualizando usuário completo ID $idUsuario');
      return await userService.atualizarUsuario(idUsuario, usuario);
    } catch (e) {
      print('❌ Erro no repositório ao atualizar usuário: $e');
      return {
        'success': false,
        'message': 'Erro ao atualizar usuário: ${e.toString()}',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> atualizarPerfil(int idUsuario, Map<String, dynamic> dados) async {
    try {
      print('🔄 Repositório: Atualizando perfil do usuário ID $idUsuario');
      return await userService.atualizarPerfil(idUsuario, dados);
    } catch (e) {
      print('❌ Erro no repositório ao atualizar perfil: $e');
      return {
        'success': false,
        'message': 'Erro ao atualizar perfil: ${e.toString()}',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> excluirUsuario(int idUsuario) async {
    try {
      print('🗑️ Repositório: Excluindo usuário ID $idUsuario');
      return await userService.excluirUsuario(idUsuario);
    } catch (e) {
      print('❌ Erro no repositório ao excluir usuário: $e');
      return {
        'success': false,
        'message': 'Erro ao excluir usuário: ${e.toString()}',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> buscarUsuarioAtual() async {
    try {
      print('👤 Repositório: Buscando usuário atual');
      return await userService.buscarUsuarioAtual();
    } catch (e) {
      print('❌ Erro no repositório ao buscar usuário atual: $e');
      return {
        'success': false,
        'message': 'Erro ao buscar usuário atual: ${e.toString()}',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> criarUsuarioComPet(UsuarioModel usuario, PetModel? petData) async {
    try {
      print('👤➕🐕 Repositório: Criando usuário com pet');
      return await userService.criarUsuarioComPet(usuario, petData);
    } catch (e) {
      print('❌ Erro no repositório ao criar usuário com pet: $e');
      return {
        'success': false,
        'message': 'Erro ao criar usuário com pet: ${e.toString()}',
      };
    }
  }

  @override
  Future<Map<String, dynamic>> verificarEmail(String email) async {
    try {
      print('📧 Repositório: Verificando email $email');
      return await userService.verificarEmail(email);
    } catch (e) {
      print('❌ Erro no repositório ao verificar email: $e');
      return {
        'success': false,
        'message': 'Erro ao verificar email: ${e.toString()}',
        'disponivel': false,
      };
    }
  }

  @override
  Future<Map<String, dynamic>> alterarSenha(int idUsuario, String senhaAtual, String novaSenha) async {
    try {
      print('🔐 Repositório: Alterando senha do usuário ID $idUsuario');
      return await userService.alterarSenha(idUsuario, senhaAtual, novaSenha);
    } catch (e) {
      print('❌ Erro no repositório ao alterar senha: $e');
      return {
        'success': false,
        'message': 'Erro ao alterar senha: ${e.toString()}',
      };
    }
  }
}