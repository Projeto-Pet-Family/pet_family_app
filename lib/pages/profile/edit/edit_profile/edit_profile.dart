// lib/screens/edit_profile/edit_profile.dart
import 'package:flutter/material.dart';
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

  void _carregarDadosUsuario() {
    final usuarioProvider =
        Provider.of<UsuarioProvider>(context, listen: false);
    final usuario = usuarioProvider.usuarioLogado;

    if (usuario != null) {
      setState(() {
        _nomeController.text = usuario.nome;
        _emailController.text = usuario.email;
        _telefoneController.text = usuario.telefone;
        _cpfController.text = usuario.cpf;
        // Não carregamos a senha por segurança
      });
    }
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
    final telefoneRegex = RegExp(r'^\(?\d{2}\)?[\s-]?\d{4,5}-?\d{4}$');
    if (!telefoneRegex.hasMatch(value)) {
      return 'Telefone inválido (ex: (11) 99999-9999)';
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

    final usuarioProvider =
        Provider.of<UsuarioProvider>(context, listen: false);
    final usuarioAtual = usuarioProvider.usuarioLogado;

    if (usuarioAtual?.idUsuario == null) {
      _mostrarErro('Usuário não identificado');
      return;
    }

    try {
      // Cria usuário atualizado
      final usuarioAtualizado = UsuarioModel(
        idUsuario: usuarioAtual!.idUsuario,
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

      await usuarioProvider.atualizarUsuario(
          usuarioAtual.idUsuario!, usuarioAtualizado);

      _mostrarSucesso('Perfil atualizado com sucesso!');

      // Navegar de volta após sucesso
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = Provider.of<UsuarioProvider>(context);
    final usuario = usuarioProvider.usuarioLogado;

    if (usuario == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Editar Perfil'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                      backgroundColor: Colors.grey[300],
                      child: usuario.nome.isNotEmpty
                          ? Text(
                              usuario.nome[0].toUpperCase(),
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
                            _mostrarErro(
                                'Upload de foto ainda não implementado');
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
                decoration: const InputDecoration(
                  labelText: 'Data de cadastro',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                  filled: true,
                  enabled: false,
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
                      ),
                      child: const Text('CANCELAR'),
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
