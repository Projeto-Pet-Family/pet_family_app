import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/providers/auth_provider.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  bool _dadosCarregados = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _emailController = TextEditingController();
    _telefoneController = TextEditingController();
    _carregarDadosUsuario();
  }

  void _carregarDadosUsuario() {
    print('🔄 Carregando dados do usuário...');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final usuario = authProvider.usuarioLogado;

      if (usuario != null) {
        _nomeController.text = usuario['nome']?.toString() ?? '';
        _emailController.text = usuario['email']?.toString() ?? '';
        _telefoneController.text = usuario['telefone']?.toString() ?? '';

        print('✅ Dados carregados no EditProfile:');
        print('✅ Nome: ${_nomeController.text}');
        print('✅ Email: ${_emailController.text}');
        print('✅ Telefone: ${_telefoneController.text}');

        setState(() {
          _dadosCarregados = true;
        });
      } else {
        print('❌ Usuário não encontrado no provider');
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recarrega os dados quando o provider mudar
    if (!_dadosCarregados) {
      _carregarDadosUsuario();
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  void _salvarAlteracoes() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final dadosAtualizados = {
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'telefone': _telefoneController.text.trim(),
      };

      print('💾 Salvando alterações...');

      final sucesso = await authProvider.atualizarPerfil(dadosAtualizados);

      if (sucesso) {
        // ✅ ATUALIZA OS CAMPOS COM OS NOVOS DADOS
        _carregarDadosUsuario();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Perfil atualizado com sucesso!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Espera um pouco antes de voltar para mostrar o feedback
        await Future.delayed(Duration(seconds: 1));

        if (context.mounted) {
          context.pop();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${authProvider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final usuario = authProvider.usuarioLogado;

        if (!_dadosCarregados || usuario == null) {
          return Scaffold(
            body: Column(
              children: [
                const AppBarReturn(route: '/profile'),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Carregando dados...'),
                        SizedBox(height: 10),
                        TextButton(
                          onPressed: _carregarDadosUsuario,
                          child: Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: Column(
            children: [
              const AppBarReturn(route: '/profile'),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Text(
                            'editar',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w100,
                              color: Colors.black,
                            ),
                          ),
                          const Text(
                            'seu perfil',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Foto de perfil
                          Center(
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[300],
                                  ),
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFC0C9FF),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Campo Nome
                          Text(
                            'Nome',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nomeController,
                            decoration: InputDecoration(
                              hintText: 'Digite seu nome',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, digite seu nome';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Campo Email
                          Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'Digite seu email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Por favor, digite seu email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Por favor, digite um email válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Campo Telefone
                          Text(
                            'Telefone',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _telefoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: 'Digite seu telefone',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Botão Salvar
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _salvarAlteracoes,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFC0C9FF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: authProvider.isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : Text(
                                      'Salvar Alterações',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
