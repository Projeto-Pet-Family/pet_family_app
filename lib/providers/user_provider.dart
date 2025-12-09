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
  int? _ultimoIdUsuarioCriado;

  UsuarioProvider({required this.usuarioRepository});

  // Getters
  List<UsuarioModel> get usuarios => _usuarios;
  UsuarioModel? get usuarioLogado => _usuarioLogado;
  bool get loading => _loading;
  String? get error => _error;
  bool get success => _success;
  int? get ultimoIdUsuarioCriado => _ultimoIdUsuarioCriado;
  int? get idUsuarioAtual => _usuarioLogado?.idUsuario;

  Future<Map<String, dynamic>> loadUserData() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 UsuarioProvider: Carregando dados do usuário...');

      // Primeiro tenta buscar o usuário atual
      final response = await buscarUsuarioAtual();

      if (response['success'] == true) {
        print('✅ Dados do usuário carregados com sucesso');
        return {
          'success': true,
          'message': 'Dados do usuário carregados',
          'usuario': _usuarioLogado,
        };
      } else {
        // Se não conseguiu buscar usuário atual, tenta listar todos
        final listResponse = await listarUsuarios();

        if (listResponse['success'] == true && _usuarios.isNotEmpty) {
          // Usa o primeiro usuário como fallback (se houver)
          _usuarioLogado = _usuarios.first;
          print('✅ Usuários carregados, usando primeiro da lista');

          return {
            'success': true,
            'message': 'Usuários carregados',
            'usuario': _usuarioLogado,
          };
        } else {
          _error = 'Não foi possível carregar dados do usuário';

          return {
            'success': false,
            'message': _error,
          };
        }
      }
    } catch (e) {
      _error = 'Erro ao carregar dados do usuário: ${e.toString()}';
      print('❌ Exceção em loadUserData: $e');

      return {
        'success': false,
        'message': _error,
      };
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Criar usuário - Atualizado para nova estrutura
  Future<Map<String, dynamic>> criarUsuario(UsuarioModel usuario) async {
    _loading = true;
    _error = null;
    _success = false;
    _ultimoIdUsuarioCriado = null;
    notifyListeners();

    try {
      print('🔄 UsuarioProvider: Criando usuário...');
      print('📝 Dados do usuário: ${usuario.toJson()}');

      final response = await usuarioRepository.criarUsuario(usuario);

      print('📥 Resposta do repositório: ${response['success']}');

      if (response['success'] == true) {
        final usuarioCriado = response['data'] != null
            ? UsuarioModel.fromJson(response['data'])
            : UsuarioModel.fromJson(response);

        _usuarioLogado = usuarioCriado;
        _ultimoIdUsuarioCriado = usuarioCriado.idUsuario;
        _success = true;

        print('🎉 Usuário criado com sucesso!');
        print('🆔 ID do usuário: ${usuarioCriado.idUsuario}');

        return {
          'success': true,
          'message': response['message'] ?? 'Usuário criado com sucesso',
          'usuario': usuarioCriado,
        };
      } else {
        _error = response['message'] ?? 'Erro ao criar usuário';
        _success = false;

        print('❌ Erro na resposta: $_error');

        return {
          'success': false,
          'message': _error,
        };
      }
    } catch (e) {
      _error = 'Erro: ${e.toString()}';
      _success = false;
      print('❌ Exceção ao criar usuário: $e');

      return {
        'success': false,
        'message': _error,
      };
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Buscar usuário por ID - Atualizado
  Future<Map<String, dynamic>> buscarUsuarioPorId(int idUsuario) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 UsuarioProvider: Buscando usuário ID: $idUsuario');

      final response = await usuarioRepository.buscarUsuarioPorId(idUsuario);

      print('📥 Resposta do repositório: ${response['success']}');

      if (response['success'] == true) {
        final usuarioEncontrado =
            response['usuario'] ?? UsuarioModel.fromJson(response['data']);
        _usuarioLogado = usuarioEncontrado;
        _error = null;

        print('✅ Usuário encontrado: ${usuarioEncontrado.nome}');

        return {
          'success': true,
          'message': 'Usuário encontrado',
          'usuario': usuarioEncontrado,
        };
      } else {
        _error = response['message'] ?? 'Usuário não encontrado';
        _usuarioLogado = null;

        print('⚠️ $idUsuario');

        return {
          'success': false,
          'message': _error,
        };
      }
    } catch (e) {
      _error = 'Erro: ${e.toString()}';
      _usuarioLogado = null;
      print('❌ Exceção ao buscar usuário: $e');

      return {
        'success': false,
        'message': _error,
      };
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Listar todos os usuários - Atualizado
  Future<Map<String, dynamic>> listarUsuarios() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      print('📋 UsuarioProvider: Listando todos os usuários');

      final response = await usuarioRepository.listarUsuarios();

      print('📥 Resposta do repositório: ${response['success']}');

      if (response['success'] == true) {
        final usuarios = response['usuarios'] ?? [];
        _usuarios = List<UsuarioModel>.from(usuarios);
        _error = null;

        print('✅ ${_usuarios.length} usuários carregados');

        return {
          'success': true,
          'message': 'Usuários carregados com sucesso',
          'usuarios': _usuarios,
        };
      } else {
        _error = response['message'] ?? 'Erro ao listar usuários';
        _usuarios = [];

        print('❌ Erro: $_error');

        return {
          'success': false,
          'message': _error,
          'usuarios': [],
        };
      }
    } catch (e) {
      _error = 'Erro: ${e.toString()}';
      _usuarios = [];
      print('❌ Exceção ao listar usuários: $e');

      return {
        'success': false,
        'message': _error,
        'usuarios': [],
      };
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Atualizar perfil - ATUALIZADO para nova estrutura
  Future<Map<String, dynamic>> atualizarPerfil(
      Map<String, dynamic> dados) async {
    _loading = true;
    _error = null;
    _success = false;
    notifyListeners();

    print('🔄 UsuarioProvider: Atualizando perfil...');
    print('📝 Dados recebidos: $dados');

    try {
      if (_usuarioLogado == null || _usuarioLogado!.idUsuario == null) {
        _error = 'Usuário não está logado';
        _loading = false;
        _success = false;
        notifyListeners();

        print('❌ Erro: Usuário não está logado');

        return {
          'success': false,
          'message': _error,
        };
      }

      final idUsuario = _usuarioLogado!.idUsuario!;
      print('🎯 ID do usuário para atualização: $idUsuario');

      // Usar o método específico de atualizarPerfil do repositório
      final response =
          await usuarioRepository.atualizarPerfil(idUsuario, dados);

      print('📥 Resposta do repositório: ${response['success']}');
      print('📨 Mensagem: ${response['message']}');
      print('👤 Dados do usuário retornado: ${response['usuario']}');

      if (response['success'] == true) {
        // Atualizar o usuário logado com os novos dados
        final usuarioAtualizado = response['usuario'] ??
            _usuarioLogado!.copyWith(
              nome: dados['nome'] ?? _usuarioLogado!.nome,
              email: dados['email'] ?? _usuarioLogado!.email,
              telefone: dados['telefone'] ?? _usuarioLogado!.telefone,
              cpf: dados['cpf'] ?? _usuarioLogado!.cpf,
            );

        _usuarioLogado = usuarioAtualizado;
        _success = true;
        _error = null;

        print('✅ Perfil atualizado com sucesso!');
        print('👤 Dados atualizados: ${usuarioAtualizado.toJson()}');

        return {
          'success': true,
          'message': response['message'] ?? 'Perfil atualizado com sucesso',
          'usuario': usuarioAtualizado,
        };
      } else {
        _error = response['message'] ?? 'Erro ao atualizar perfil';
        _success = false;

        print('❌ Erro na resposta: $_error');

        return {
          'success': false,
          'message': _error,
        };
      }
    } catch (e) {
      _error = 'Erro: ${e.toString()}';
      _success = false;
      print('❌ Exceção ao atualizar perfil: $e');

      return {
        'success': false,
        'message': _error,
      };
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Método alternativo para atualizar usuário completo
  Future<Map<String, dynamic>> atualizarUsuario(UsuarioModel usuario) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (usuario.idUsuario == null) {
        return {
          'success': false,
          'message': 'ID do usuário não fornecido',
        };
      }

      print(
          '🔄 UsuarioProvider: Atualizando usuário completo ID: ${usuario.idUsuario}');

      final response =
          await usuarioRepository.atualizarUsuario(usuario.idUsuario!, usuario);

      if (response['success'] == true) {
        _usuarioLogado = response['usuario'] ?? usuario;
        _error = null;

        return {
          'success': true,
          'message': 'Usuário atualizado com sucesso',
          'usuario': _usuarioLogado,
        };
      } else {
        _error = response['message'];
        return {
          'success': false,
          'message': _error,
        };
      }
    } catch (e) {
      _error = 'Erro: ${e.toString()}';
      return {
        'success': false,
        'message': _error,
      };
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Excluir usuário - Atualizado
  Future<Map<String, dynamic>> excluirUsuario(int idUsuario) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      print('🗑️ UsuarioProvider: Excluindo usuário ID: $idUsuario');

      final response = await usuarioRepository.excluirUsuario(idUsuario);

      if (response['success'] == true) {
        // Remove da lista local
        _usuarios.removeWhere((u) => u.idUsuario == idUsuario);

        // Limpa usuário logado se for o mesmo
        if (_usuarioLogado?.idUsuario == idUsuario) {
          _usuarioLogado = null;
        }

        print('✅ Usuário ID $idUsuario excluído');

        return {
          'success': true,
          'message': 'Usuário excluído com sucesso',
        };
      } else {
        _error = response['message'];
        print('❌ Erro ao excluir usuário: $_error');

        return {
          'success': false,
          'message': _error,
        };
      }
    } catch (e) {
      _error = 'Erro: ${e.toString()}';
      print('❌ Exceção ao excluir usuário: $e');

      return {
        'success': false,
        'message': _error,
      };
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Buscar usuário atual - NOVO MÉTODO
  Future<Map<String, dynamic>> buscarUsuarioAtual() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      print('👤 UsuarioProvider: Buscando dados do usuário atual');

      final response = await usuarioRepository.buscarUsuarioAtual();

      if (response['success'] == true) {
        _usuarioLogado = response['usuario'];
        _error = null;

        print('✅ Dados do usuário atual carregados: ${_usuarioLogado?.nome}');

        return {
          'success': true,
          'message': 'Dados do usuário carregados',
          'usuario': _usuarioLogado,
        };
      } else {
        _error = response['message'] ?? 'Erro ao buscar usuário atual';
        _usuarioLogado = null;

        print('❌ Erro: $_error');

        return {
          'success': false,
          'message': _error,
        };
      }
    } catch (e) {
      _error = 'Erro: ${e.toString()}';
      _usuarioLogado = null;
      print('❌ Exceção ao buscar usuário atual: $e');

      return {
        'success': false,
        'message': _error,
      };
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Criar usuário com pet - Atualizado
  Future<Map<String, dynamic>> criarUsuarioComPet(
      UsuarioModel usuario, PetModel? petData) async {
    _loading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      print('👤➕🐕 UsuarioProvider: Criando usuário com pet');

      final response =
          await usuarioRepository.criarUsuarioComPet(usuario, petData);

      if (response['success'] == true) {
        final usuarioCriado = response['data'] != null
            ? UsuarioModel.fromJson(response['data'])
            : UsuarioModel.fromJson(response);

        _usuarioLogado = usuarioCriado;
        _ultimoIdUsuarioCriado = usuarioCriado.idUsuario;
        _success = true;

        print('✅ Usuário com pet criado! ID: ${usuarioCriado.idUsuario}');

        return {
          'success': true,
          'message': response['message'] ?? 'Usuário criado com sucesso',
          'usuario': usuarioCriado,
        };
      } else {
        _error = response['message'] ?? 'Erro ao criar usuário com pet';
        _success = false;

        return {
          'success': false,
          'message': _error,
        };
      }
    } catch (e) {
      _error = 'Erro: ${e.toString()}';
      _success = false;

      return {
        'success': false,
        'message': _error,
      };
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ========== MÉTODOS AUXILIARES ==========

  // Criar usuário e pet em sequência
  Future<Map<String, dynamic>> criarUsuarioEPet(UsuarioModel usuario,
      PetModel pet, Function(int idUsuario)? onUsuarioCriado) async {
    _loading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      // 1. Criar usuário primeiro
      print('🔄 UsuarioProvider: Criando usuário e pet em sequência');
      final usuarioResultado = await criarUsuario(usuario);

      if (!usuarioResultado['success']) {
        return usuarioResultado;
      }

      final usuarioCriado = usuarioResultado['usuario'] as UsuarioModel;

      // 2. Chamar callback se fornecido
      if (onUsuarioCriado != null && usuarioCriado.idUsuario != null) {
        onUsuarioCriado(usuarioCriado.idUsuario!);
      }

      _success = true;

      return {
        'success': true,
        'message': 'Usuário criado com sucesso',
        'usuario': usuarioCriado,
      };
    } catch (e) {
      _error = 'Erro: ${e.toString()}';
      _success = false;
      print('❌ Erro ao criar usuário e pet: $e');

      return {
        'success': false,
        'message': _error,
      };
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Obter ID do usuário atual
  int? getIdUsuarioAtual() {
    return _usuarioLogado?.idUsuario;
  }

  // Definir usuário com ID
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

  // Limpar ID do último usuário criado
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
    _ultimoIdUsuarioCriado = usuario.idUsuario;
    notifyListeners();
  }

  void logout() {
    _usuarioLogado = null;
    _ultimoIdUsuarioCriado = null;
    notifyListeners();
  }
}
