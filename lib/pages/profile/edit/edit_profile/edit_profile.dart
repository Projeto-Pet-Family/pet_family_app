// lib/screens/edit_profile/edit_profile.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/models/user_model.dart';
import 'package:pet_family_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  late TextEditingController _cpfController;
  late TextEditingController _senhaController;
  late TextEditingController _confirmarSenhaController;

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isInitializing = true;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _telefoneController = TextEditingController();
    _cpfController = TextEditingController();
    _senhaController = TextEditingController();
    _confirmarSenhaController = TextEditingController();

    // Carregar dados do usuário após o build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDadosUsuario();
    });
  }

  void _carregarDadosUsuario() async {
    try {
      final usuarioProvider = context.read<UsuarioProvider>();
      final usuario = usuarioProvider.usuarioLogado;

      print('🔍 Carregando dados do usuário...');
      print('📊 Usuário no provider: $usuario');

      // Se não há usuário no provider, tenta buscar do cache
      if (usuario == null) {
        print('⚠️ Usuário não encontrado no provider, tentando carregar...');
        await usuarioProvider.carregarUsuarioDoCache();

        final usuarioCarregado = usuarioProvider.usuarioLogado;
        if (usuarioCarregado == null) {
          print('❌ Usuário não encontrado em cache');
          if (mounted) {
            _mostrarErro('Usuário não encontrado. Faça login novamente.');
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) context.go('/login');
            });
          }
          return;
        }

        _preencherCampos(usuarioCarregado);
      } else {
        _preencherCampos(usuario);
      }
    } catch (e) {
      print('❌ Erro ao carregar dados do usuário: $e');
      if (mounted) {
        _mostrarErro('Erro ao carregar dados: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  void _preencherCampos(UsuarioModel usuario) {
    setState(() {
      _nomeController.text = usuario.nome ?? '';
      _emailController.text = usuario.email ?? '';
      _telefoneController.text = usuario.telefone ?? '';
      _cpfController.text = usuario.cpf ?? '';
      _senhaController.text = '';
      _confirmarSenhaController.text = '';
    });

    print('✅ Campos preenchidos:');
    print('👤 Nome: ${usuario.nome}');
    print('📧 Email: ${usuario.email}');
    print('📱 Telefone: ${usuario.telefone}');
    print('🆔 CPF: ${usuario.cpf}');
  }

  String? _validarNome(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nome é obrigatório';
    }
    if (value.length < 3) {
      return 'Nome deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  String? _validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email é obrigatório';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  String? _validarTelefone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Telefone é obrigatório';
    }
    // Permite vários formatos: (11) 99999-9999, 11 999999999, 11999999999
    final telefoneRegex = RegExp(r'^\(?\d{2}\)?[\s-]?\d{4,5}[\s-]?\d{4}$');
    if (!telefoneRegex.hasMatch(value)) {
      return 'Telefone inválido';
    }
    return null;
  }

  String? _validarCPF(String? value) {
    if (value == null || value.isEmpty) {
      return 'CPF é obrigatório';
    }
    // Remove caracteres não numéricos
    final cpf = value.replaceAll(RegExp(r'[^\d]'), '');
    if (cpf.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }
    return null;
  }

  String? _validarSenha(String? value) {
    if (value == null || value.isEmpty) {
      // Senha é opcional na edição
      return null;
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  String? _validarConfirmarSenha(String? value) {
    if (_senhaController.text.isNotEmpty && (value == null || value.isEmpty)) {
      return 'Confirme sua senha';
    }
    if (value != _senhaController.text) {
      return 'Senhas não coincidem';
    }
    return null;
  }

  Future<void> _salvarAlteracoes() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final usuarioProvider = context.read<UsuarioProvider>();
      final usuarioAtual = usuarioProvider.usuarioLogado;

      if (usuarioAtual?.idUsuario == null) {
        _mostrarErro('Usuário não identificado');
        setState(() => _isLoading = false);
        return;
      }

      print('💾 Salvando alterações do usuário ${usuarioAtual!.idUsuario}');

      // Cria usuário atualizado
      final usuarioAtualizado = UsuarioModel(
        idUsuario: usuarioAtual.idUsuario,
        nome: _nomeController.text.trim(),
        cpf: _cpfController.text.trim(),
        email: _emailController.text.trim(),
        telefone: _telefoneController.text.trim(),
        senha: _senhaController.text.isNotEmpty
            ? _senhaController.text.trim()
            : usuarioAtual.senha, // Mantém senha antiga se não alterada
        esqueceuSenha: usuarioAtual.esqueceuSenha,
        dataCadastro: usuarioAtual.dataCadastro,
      );

      // Atualiza no provider
      await usuarioProvider.atualizarUsuario(
          usuarioAtual.idUsuario!, usuarioAtualizado);

      print('✅ Usuário atualizado com sucesso');

      _mostrarSucesso('Perfil atualizado com sucesso!');

      // Navegar de volta após sucesso
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      print('❌ Erro ao atualizar perfil: $e');
      _mostrarErro('Erro ao atualizar perfil: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _mostrarSucesso(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _cpfController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/core-navigation'),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Carregando perfil...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/core-navigation'),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 60, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/core-navigation'),
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(UsuarioModel usuario) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/core-navigation'),
        ),
        actions: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar/Imagem do perfil
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: usuario.nome != null && usuario.nome!.isNotEmpty
                          ? Text(
                              usuario.nome![0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 20),
                          color: Colors.white,
                          onPressed: () {
                            // TODO: Implementar upload de foto
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Upload de foto ainda não implementado'),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Nome
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: _validarNome,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validarEmail,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Telefone
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: _validarTelefone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // CPF
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(
                  labelText: 'CPF',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: _validarCPF,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Data de cadastro (somente leitura)
              TextFormField(
                initialValue: usuario.dataCadastro != null
                    ? '${usuario.dataCadastro!.day.toString().padLeft(2, '0')}/'
                        '${usuario.dataCadastro!.month.toString().padLeft(2, '0')}/'
                        '${usuario.dataCadastro!.year}'
                    : 'Não informada',
                decoration: InputDecoration(
                  labelText: 'Data de cadastro',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                readOnly: true,
              ),
              const SizedBox(height: 24),

              // Seção de alteração de senha
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alterar Senha',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Deixe em branco para manter a senha atual',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nova senha
                      TextFormField(
                        controller: _senhaController,
                        decoration: InputDecoration(
                          labelText: 'Nova senha',
                          prefixIcon: const Icon(Icons.lock),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: !_showPassword,
                        validator: _validarSenha,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      // Confirmar senha
                      TextFormField(
                        controller: _confirmarSenhaController,
                        decoration: InputDecoration(
                          labelText: 'Confirmar nova senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _showConfirmPassword = !_showConfirmPassword;
                              });
                            },
                          ),
                        ),
                        obscureText: !_showConfirmPassword,
                        validator: _validarConfirmarSenha,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _salvarAlteracoes,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'SALVAR ALTERAÇÕES',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Botão para cancelar
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      child: Text(
                        'CANCELAR',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return _buildLoadingScreen();
    }

    final usuarioProvider = context.watch<UsuarioProvider>();
    final usuario = usuarioProvider.usuarioLogado;

    if (usuario == null) {
      return _buildErrorScreen('Usuário não encontrado. Faça login novamente.');
    }

    return _buildForm(usuario);
  }
}

// Componente EditProfileModal (se ainda for necessário em outro lugar)
class EditProfileModal extends StatelessWidget {
  final TextEditingController nomeController;
  final TextEditingController emailController;
  final TextEditingController telefoneController;
  final TextEditingController cpfController;
  final VoidCallback onSalvar;

  const EditProfileModal({
    super.key,
    required this.nomeController,
    required this.emailController,
    required this.telefoneController,
    required this.cpfController,
    required this.onSalvar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Editar Perfil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: nomeController,
            decoration: const InputDecoration(
              labelText: 'Nome',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: telefoneController,
            decoration: const InputDecoration(
              labelText: 'Telefone',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: cpfController,
            decoration: const InputDecoration(
              labelText: 'CPF',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onSalvar,
                  child: const Text('SALVAR'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCELAR'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
