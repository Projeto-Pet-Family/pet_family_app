import 'package:flutter/material.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/providers/pet/especie_provider.dart';
import 'package:pet_family_app/providers/pet/pet_provider.dart';
import 'package:pet_family_app/providers/pet/porte_provider.dart';
import 'package:pet_family_app/providers/pet/raca_provider.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/pages/profile/edit/edit_pet/modal/modal_edit_pet.dart';
import 'package:pet_family_app/pages/profile/edit/edit_pet/modal/modal_add_pet.dart';
import 'package:pet_family_app/pages/profile/edit/edit_pet/pet_edit_template.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/providers/auth_provider.dart';

class EditPet extends StatefulWidget {
  const EditPet({super.key});

  @override
  State<EditPet> createState() => _EditPetState();
}

class _EditPetState extends State<EditPet> {
  bool _initialLoad = false;

  @override
  void initState() {
    super.initState();
    // Marcador para garantir que carregue apenas uma vez
    _initialLoad = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // didChangeDependencies é chamado depois que o widget está na árvore
    // e podemos acessar os providers com segurança
    if (!_initialLoad) {
      _carregarPets();
      _initialLoad = true;
    }
  }

  Future<void> _carregarPets() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      final usuarioId = authProvider.usuario?.idUsuario;

      if (usuarioId != null) {
        await petProvider.listarPetsPorUsuario(usuarioId);

        if (mounted && petProvider.pets.isNotEmpty) {
          for (var i = 0; i < petProvider.pets.length; i++) {
            var pet = petProvider.pets[i];
            print('✅ Pet $i carregado:');
            print('   - Nome: ${pet.nome}');
            print('   - Sexo: ${pet.sexo}');
            print('   - Espécie: ${pet.descricaoEspecie}');
            print('   - Raça: ${pet.descricaoRaca}');
            print('   - Porte: ${pet.descricaoPorte}');
          }
        } else if (mounted && petProvider.pets.isEmpty) {
          print('ℹ️ Nenhum pet encontrado para o usuário $usuarioId');
        }
      } else {
        print('❌ Usuário não autenticado');
      }
    } catch (e) {
      print('❌ Erro ao carregar pets: $e');
    }
  }

  // Adicione este método para forçar recarregamento quando a tela for aberta novamente
  @override
  void dispose() {
    _initialLoad = false;
    super.dispose();
  }

  // Método atualizado para adicionar pet com recarregamento automático
  void _adicionarNovoPet(PetModel novoPet) async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    try {
      await petProvider.criarPet(novoPet);

      if (petProvider.success) {
        // Recarrega a lista após adicionar
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final usuarioId = authProvider.usuario?.idUsuario;
        if (usuarioId != null) {
          await petProvider.listarPetsPorUsuario(usuarioId);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet adicionado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao adicionar pet: ${petProvider.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar pet: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Método atualizado para editar pet com recarregamento automático
  void _editarPet(int index, PetModel petEditado) async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final pet = petProvider.pets[index];

    if (pet.idPet != null) {
      try {
        await petProvider.atualizarPet(pet.idPet!, petEditado);

        if (petProvider.error == null) {
          // Recarrega a lista após editar
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          final usuarioId = authProvider.usuario?.idUsuario;
          if (usuarioId != null) {
            await petProvider.listarPetsPorUsuario(usuarioId);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pet atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar pet: ${petProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar pet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Método atualizado para remover pet com recarregamento automático
  void _removerPet(int index) async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final pet = petProvider.pets[index];

    if (pet.idPet != null) {
      try {
        await petProvider.excluirPet(pet.idPet!);

        if (petProvider.error == null) {
          // Recarrega a lista após remover
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          final usuarioId = authProvider.usuario?.idUsuario;
          if (usuarioId != null) {
            await petProvider.listarPetsPorUsuario(usuarioId);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${pet.nome} removido com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao remover pet: ${petProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover pet: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // MÉTODO AUXILIAR: Formatar informações para exibição
  String _formatarEspecie(String? especie) {
    if (especie == null || especie.isEmpty || especie.toLowerCase().contains('não informado')) {
      return ''; // Retorna string vazia
    }
    return especie;
  }

  String _formatarRaca(String? raca) {
    if (raca == null || raca.isEmpty || raca.toLowerCase().contains('não informado')) {
      return ''; // Retorna string vazia
    }
    return raca;
  }

  String? _formatarSexo(String? sexo) {
    if (sexo == null || sexo.isEmpty || sexo.toLowerCase().contains('não informado')) {
      return null; // Retorna null para não exibir
    }
    return sexo;
  }

  String? _formatarPorte(String? porte) {
    if (porte == null || porte.isEmpty || porte.toLowerCase().contains('não informado')) {
      return null; // Retorna null para não exibir
    }
    // Remove "Porte" se já estiver na string
    porte = porte.replaceAll('Porte', '').trim();
    return porte.isNotEmpty ? porte : null;
  }

  String? _formatarIdade(String? idade) {
    if (idade == null || idade.isEmpty || idade == '0' || idade == '0 anos') {
      return null; // Retorna null para não exibir
    }
    return idade;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppBarReturn(route: '/core-navigation'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Consumer2<PetProvider, AuthProvider>(
                builder: (context, petProvider, authProvider, child) {
                  final usuarioId = authProvider.usuario?.idUsuario;

                  // Botão de recarregar em caso de erro
                  Widget errorWidget = Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        petProvider.error ?? 'Erro desconhecido',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          if (usuarioId != null) {
                            petProvider.listarPetsPorUsuario(usuarioId);
                          }
                        },
                        child: const Text('Tentar Novamente'),
                      ),
                    ],
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'veja',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w100,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        'seus pets',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      AppButton(
                        onPressed: usuarioId == null || petProvider.loading
                            ? null
                            : () {
                                final especieProvider =
                                    Provider.of<EspecieProvider>(context,
                                        listen: false);
                                final racaProvider = Provider.of<RacaProvider>(
                                    context,
                                    listen: false);
                                final porteProvider =
                                    Provider.of<PorteProvider>(context,
                                        listen: false);

                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) =>
                                      ModalAddPet(
                                    idUsuario: usuarioId,
                                    especieProvider: especieProvider,
                                    racaProvider: racaProvider,
                                    porteProvider: porteProvider,
                                    onPetAdded: (petData) {
                                      _adicionarNovoPet(petData);
                                    },
                                  ),
                                );
                              },
                        label: 'Adicionar pet',
                      ),
                      const SizedBox(height: 20),

                      // CONTEÚDO PRINCIPAL
                      if (petProvider.loading && !_initialLoad)
                        Container(
                          height: 200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (petProvider.error != null &&
                          !petProvider.loading)
                        Container(
                          height: 200,
                          child: Center(
                            child: errorWidget,
                          ),
                        )
                      else if (petProvider.pets.isEmpty && !petProvider.loading)
                        Container(
                          height: 200,
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pets,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Nenhum pet cadastrado',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Clique em "Adicionar pet" para cadastrar seu primeiro pet!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              if (usuarioId != null) {
                                await petProvider
                                    .listarPetsPorUsuario(usuarioId);
                              }
                            },
                            child: ListView.builder(
                              itemCount: petProvider.pets.length,
                              itemBuilder: (context, index) {
                                final pet = petProvider.pets[index];
                                
                                // Formata os dados antes de passar para o template
                                final especieFormatada = _formatarEspecie(pet.descricaoEspecie);
                                final racaFormatada = _formatarRaca(pet.descricaoRaca);
                                final sexoFormatado = _formatarSexo(pet.sexo);
                                final porteFormatado = _formatarPorte(pet.descricaoPorte);
                                final idadeFormatada = _formatarIdade(_calcularIdade(pet.nascimento));
                                
                                return PetEditTemplate(
                                  name: pet.nome ?? 'Sem nome',
                                  especie: especieFormatada,
                                  raca: racaFormatada,
                                  idade: idadeFormatada,
                                  sexo: sexoFormatado,
                                  porte: porteFormatado,
                                  onTap: () => showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) =>
                                        ModalEditPet(
                                      petData: pet,
                                      onPetEdited: (petEditado) {
                                        _editarPet(index, petEditado);
                                      },
                                      onPetDeleted: () {
                                        _removerPet(index);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calcularIdade(DateTime? nascimento) {
    if (nascimento == null) return '';
    try {
      final hoje = DateTime.now();
      final idade = hoje.year - nascimento.year;
      if (hoje.month < nascimento.month ||
          (hoje.month == nascimento.month && hoje.day < nascimento.day)) {
        return (idade - 1).toString();
      }
      return idade.toString();
    } catch (e) {
      return '';
    }
  }
}