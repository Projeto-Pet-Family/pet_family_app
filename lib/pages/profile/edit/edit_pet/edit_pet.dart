import 'package:flutter/material.dart';
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
  List<Map<String, dynamic>> _pets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarPets();
  }

  // Simulação de carregamento dos pets do usuário
  Future<void> _carregarPets() async {
    // Aguarda um pouco para simular carregamento
    await Future.delayed(const Duration(seconds: 1));

    // Aqui você deve buscar os pets do usuário logado da sua API
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final usuarioId = authProvider.usuarioLogado?['idusuario'];

    if (usuarioId != null) {
      // TODO: Substituir pela chamada real da API
      // final pets = await PetService.buscarPetsPorUsuario(usuarioId);

      // Dados mockados para exemplo
      setState(() {
        _pets = [
          {
            'id': 1,
            'nome': 'Tico Tico',
            'especie': 'Cachorro',
            'raca': 'Vira-lata',
            'sexo': 'Macho',
            'idade': '2',
            'peso': '8.5',
            'porte': 'Médio'
          },
          {
            'id': 2,
            'nome': 'Mimi',
            'especie': 'Gato',
            'raca': 'Siamês',
            'sexo': 'Fêmea',
            'idade': '1',
            'peso': '4.2',
            'porte': 'Pequeno'
          },
        ];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _adicionarNovoPet(Map<String, dynamic> novoPet) {
    setState(() {
      _pets.add({
        ...novoPet,
        'id': DateTime.now().millisecondsSinceEpoch, // ID temporário
      });
    });

    // TODO: Chamar API para salvar o pet no backend
    // await PetService.adicionarPet(novoPet);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pet adicionado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editarPet(int index, Map<String, dynamic> petEditado) {
    setState(() {
      _pets[index] = {..._pets[index], ...petEditado};
    });

    // TODO: Chamar API para atualizar o pet no backend
    // await PetService.atualizarPet(_pets[index]['id'], petEditado);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pet atualizado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removerPet(int index) {
    final petRemovido = _pets[index];

    setState(() {
      _pets.removeAt(index);
    });

    // TODO: Chamar API para remover o pet no backend
    // await PetService.removerPet(petRemovido['id']);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${petRemovido['nome']} removido com sucesso!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() {
              _pets.insert(index, petRemovido);
            });
          },
        ),
      ),
    );
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
              child: Column(
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
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) => ModalAddPet(
                        onPetAdded: _adicionarNovoPet,
                      ),
                    ),
                    label: 'Adicionar pet',
                  ),
                  const SizedBox(height: 20),
                  if (_isLoading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_pets.isEmpty)
                    const Expanded(
                      child: Center(
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
                        itemCount: _pets.length,
                        itemBuilder: (context, index) {
                          final pet = _pets[index];
                          return PetEditTemplate(
                            name: pet['nome'],
                            especie: pet['especie'],
                            raca: pet['raca'],
                            idade: pet['idade'],
                            sexo: pet['sexo'],
                            porte: pet['porte'],
                            onTap: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (BuildContext context) => ModalEditPet(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
