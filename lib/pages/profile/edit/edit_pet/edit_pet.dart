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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarPets();
    });
  }

  void _carregarPets() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      final usuarioId = authProvider.usuarioLogado?['idusuario'];

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
        }
      }
    } catch (e) {
      print('❌ Erro ao carregar pets: $e');
    }
  }

  void _adicionarNovoPet(PetModel novoPet) async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    try {
      await petProvider.criarPet(novoPet);

      if (petProvider.success) {
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

  void _editarPet(int index, PetModel petEditado) async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final pet = petProvider.pets[index];

    if (pet.idPet != null) {
      try {
        await petProvider.atualizarPet(pet.idPet!, petEditado);

        if (petProvider.error == null) {
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

  void _removerPet(int index) async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final pet = petProvider.pets[index];

    if (pet.idPet != null) {
      try {
        await petProvider.excluirPet(pet.idPet!);

        if (petProvider.error == null) {
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
                  final usuarioId = authProvider.usuarioLogado?['idusuario'];

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
                                // Busque os providers antes de abrir o modal
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
                      if (petProvider.loading)
                        Container(
                          height: 200,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (petProvider.error != null)
                        Container(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  petProvider.error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _carregarPets,
                                  child: const Text('Tentar Novamente'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (petProvider.pets.isEmpty)
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
                          child: ListView.builder(
                            itemCount: petProvider.pets.length,
                            itemBuilder: (context, index) {
                              final pet = petProvider.pets[index];
                              return PetEditTemplate(
                                name: pet.nome ?? 'Nome não informado',
                                especie:
                                    pet.descricaoEspecie ?? 'Não informado',
                                raca: pet.descricaoRaca ?? 'Não informado',
                                idade: _calcularIdade(pet.nascimento),
                                sexo: pet.sexo ?? 'Não informado',
                                porte: pet.descricaoPorte ?? 'Não informado',
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
    if (nascimento == null) return '0';
    try {
      final hoje = DateTime.now();
      final idade = hoje.year - nascimento.year;
      if (hoje.month < nascimento.month ||
          (hoje.month == nascimento.month && hoje.day < nascimento.day)) {
        return (idade - 1).toString();
      }
      return idade.toString();
    } catch (e) {
      return '0';
    }
  }
}
