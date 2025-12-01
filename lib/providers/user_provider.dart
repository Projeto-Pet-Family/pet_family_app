// presentation/providers/usuario_provider.dart
import 'package:flutter/foundation.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/models/user_model.dart';
import 'package:pet_family_app/repository/user_repository.dart';

class UsuarioProvider with ChangeNotifier {
  final UserRepository usuarioRepository;

  List<UsuarioModel> _usuarios = [];
  UsuarioModel? _usuarioLogado;
  bool _loading = false;
  String? _error;
  bool _success = false;
  int? _ultimoIdUsuarioCriado; // ✅ ADICIONAR: para armazenar o ID criado

  UsuarioProvider({required this.usuarioRepository});

  // Getters
  List<UsuarioModel> get usuarios => _usuarios;
  UsuarioModel? get usuarioLogado => _usuarioLogado;
  bool get loading => _loading;
  String? get error => _error;
  bool get success => _success;
  int? get ultimoIdUsuarioCriado => _ultimoIdUsuarioCriado; // ✅ NOVO GETTER
  int? get idUsuarioAtual =>
      _usuarioLogado?.idUsuario; // ✅ GETTER para ID atual

  // Criar usuário - MELHORADO com logs
  Future<void> criarUsuario(UsuarioModel usuario) async {
    _loading = true;
    _error = null;
    _success = false;
    _ultimoIdUsuarioCriado = null; // ✅ Limpar ID anterior
    notifyListeners();

    try {
      print('🔄 UsuarioProvider: Criando usuário...');
      print('📝 Dados do usuário: ${usuario.toJson()}');

      final response = await usuarioRepository.criarUsuario(usuario);

      print('✅ Resposta da API: $response');

      final usuarioCriado = UsuarioModel.fromJson(response['data']['usuario']);
      _usuarioLogado = usuarioCriado;
      _ultimoIdUsuarioCriado = usuarioCriado.idUsuario; // ✅ SALVAR O ID
      _success = true;

      print('🎉 Usuário criado com sucesso!');
      print('🆔 ID do usuário: ${usuarioCriado.idUsuario}');
      print('👤 Dados do usuário logado: ${_usuarioLogado?.toJson()}');

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _success = false;
      print('❌ Erro ao criar usuário: $e');
      notifyListeners();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ✅ NOVO MÉTODO: Criar usuário e pet em sequência
  Future<void> criarUsuarioEPet(UsuarioModel usuario, PetModel pet,
      Function(int idUsuario)? onUsuarioCriado) async {
    _loading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      // 1. Criar usuário primeiro
      print('🔄 UsuarioProvider: Criando usuário...');
      final usuarioResponse = await usuarioRepository.criarUsuario(usuario);
      final usuarioCriado =
          UsuarioModel.fromJson(usuarioResponse['data']['usuario']);
      _usuarioLogado = usuarioCriado;
      _ultimoIdUsuarioCriado = usuarioCriado.idUsuario;

      print('✅ Usuário criado! ID: ${usuarioCriado.idUsuario}');

      // 2. Chamar callback se fornecido (para salvar no cache)
      if (onUsuarioCriado != null && usuarioCriado.idUsuario != null) {
        onUsuarioCriado(usuarioCriado.idUsuario!);
      }

      // 3. Criar pet com o ID do usuário


      _success = true;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _success = false;
      print('❌ Erro ao criar usuário e pet: $e');
      notifyListeners();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ✅ MÉTODO PARA OBTER O ID DO USUÁRIO ATUAL
  int? getIdUsuarioAtual() {
    return _usuarioLogado?.idUsuario;
  }

  // ✅ MÉTODO PARA DEFINIR O ID DO USUÁRIO (útil para testes)
  void setUsuarioComId(int idUsuario, {String? nome, String? email}) {
    _usuarioLogado = UsuarioModel(
      idUsuario: idUsuario,
      nome: nome ?? 'Usuário Teste',
      email: email ?? 'teste@email.com',
      dataCadastro: DateTime.now(), 
      cpf: '', 
      telefone: '', 
      senha: '',
    );
    notifyListeners();
  }

  // Buscar usuário por ID
  Future<void> buscarUsuarioPorId(int idUsuario) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 Buscando usuário ID: $idUsuario');
      _usuarioLogado = await usuarioRepository.buscarUsuarioPorId(idUsuario);
      _error = null;

      if (_usuarioLogado != null) {
        print('✅ Usuário encontrado: ${_usuarioLogado!.nome}');
      } else {
        print('⚠️ Usuário não encontrado');
      }
    } catch (e) {
      _error = e.toString();
      _usuarioLogado = null;
      print('❌ Erro ao buscar usuário: $e');
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
      print('✅ ${_usuarios.length} usuários carregados');
    } catch (e) {
      _error = e.toString();
      _usuarios = [];
      print('❌ Erro ao listar usuários: $e');
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
      print('✅ Usuário ID $idUsuario atualizado');
    } catch (e) {
      _error = e.toString();
      print('❌ Erro ao atualizar usuário: $e');
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
      print('✅ Usuário ID $idUsuario excluído');
    } catch (e) {
      _error = e.toString();
      print('❌ Erro ao excluir usuário: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Criar usuário com pet (método existente - mantido para compatibilidade)
  Future<void> criarUsuarioComPet(
      UsuarioModel usuario, PetModel? petData) async {
    _loading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      final response =
          await usuarioRepository.criarUsuarioComPet(usuario, petData);

      final usuarioCriado = UsuarioModel.fromJson(response['data']['usuario']);
      _usuarioLogado = usuarioCriado;
      _ultimoIdUsuarioCriado = usuarioCriado.idUsuario; // ✅ SALVAR O ID
      _success = true;

      print('✅ Usuário com pet criado! ID: ${usuarioCriado.idUsuario}');

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

  // ✅ NOVO: Limpar dados do último usuário criado
  void limparUltimoId() {
    _ultimoIdUsuarioCriado = null;
    notifyListeners();
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
    _ultimoIdUsuarioCriado =
        usuario.idUsuario; // ✅ Também salva como último criado
    notifyListeners();
  }

  void logout() {
    _usuarioLogado = null;
    _ultimoIdUsuarioCriado = null; // ✅ Limpa também
    notifyListeners();
  }
}
