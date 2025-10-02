import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/pages/profile/edit/edit_pet/modal/modal_edit_pet.dart';
import 'package:pet_family_app/pages/profile/edit/edit_pet/modal/modal_add_pet.dart';
import 'package:pet_family_app/pages/profile/edit/edit_pet/pet_edit_template.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/providers/auth_provider.dart';
import 'package:pet_family_app/providers/pet/pet_provider.dart';
import 'package:pet_family_app/services/pet/especie_service.dart';
import 'package:pet_family_app/services/pet/raca_service.dart';
import 'package:pet_family_app/services/pet/porte_service.dart';
import 'package:pet_family_app/providers/pet/especie_provider.dart';
import 'package:pet_family_app/providers/pet/raca_provider.dart';
import 'package:pet_family_app/providers/pet/porte_provider.dart';

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

  void _carregarPets() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final usuarioId = authProvider.usuarioLogado?['idusuario'];

    if (usuarioId != null) {
      petProvider.buscarPetsPorUsuario(usuarioId);
    }
  }

  void _adicionarNovoPet(Map<String, dynamic> novoPet) async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);

    final sucesso = await petProvider.adicionarPet(novoPet);

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet adicionado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao adicionar pet: ${petProvider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editarPet(int index, Map<String, dynamic> petEditado) async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final pet = petProvider.pets[index];

    final sucesso = await petProvider.atualizarPet(pet['idpet'], petEditado);

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pet atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao atualizar pet: ${petProvider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removerPet(int index) async {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    final pet = petProvider.pets[index];

    final sucesso = await petProvider.removerPet(pet['idpet']);

    if (sucesso) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${pet['nome']} removido com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover pet: ${petProvider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const AppBarReturn(route: '/core-navigation'),
          Expanded(
            // MOVER O EXPANDED PARA AQUI
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
                        onPressed: usuarioId == null
                            ? null
                            : () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) =>
                                      MultiProvider(
                                    providers: [
                                      ChangeNotifierProvider(
                                        create: (_) => EspecieProvider(
                                          especieService: EspecieService(
                                              client: http.Client()),
                                        ),
                                      ),
                                      ChangeNotifierProvider(
                                        create: (_) => RacaProvider(
                                          racaService: RacaService(
                                              client: http.Client()),
                                        ),
                                      ),
                                      ChangeNotifierProvider(
                                        create: (_) => PorteProvider(
                                          porteService: PorteService(
                                              client: http.Client()),
                                        ),
                                      ),
                                    ],
                                    child: ModalAddPet(
                                      idUsuario: usuarioId as int,
                                      onPetAdded: _adicionarNovoPet,
                                    ),
                                  ),
                                );
                              },
                        label: 'Adicionar pet',
                      ),
                      const SizedBox(height: 20),

                      // CONTEÚDO PRINCIPAL COM ALTURA FIXA
                      if (petProvider.isLoading)
                        Container(
                          height: 200, // Altura fixa
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (petProvider.errorMessage.isNotEmpty)
                        Container(
                          height: 200, // Altura fixa
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
                                  petProvider.errorMessage,
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
                          height: 200, // Altura fixa
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
                          // EXPANDED APENAS AQUI, DENTRO DE UM CONTEXTO COM ALTURA DEFINIDA
                          child: ListView.builder(
                            itemCount: petProvider.pets.length,
                            itemBuilder: (context, index) {
                              final pet = petProvider.pets[index];
                              return PetEditTemplate(
                                name: pet['nome'] ?? 'Sem nome',
                                especie: pet['descricaoespecie'] ??
                                    pet['idespecie']?.toString() ??
                                    'Não informado',
                                raca: pet['descricaoraca'] ??
                                    pet['idraca']?.toString() ??
                                    'Não informado',
                                idade: _calcularIdade(pet['nascimento']),
                                sexo: pet['sexo'],
                                porte: pet['descricaoporte'] ??
                                    pet['idporte']?.toString() ??
                                    'Não informado',
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

  String _calcularIdade(String? nascimento) {
    if (nascimento == null) return '0';
    try {
      final nasc = DateTime.parse(nascimento);
      final hoje = DateTime.now();
      final idade = hoje.year - nasc.year;
      return idade.toString();
    } catch (e) {
      return '0';
    }
  }
}
