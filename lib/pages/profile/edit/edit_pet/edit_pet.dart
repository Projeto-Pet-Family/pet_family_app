import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/pages/profile/edit/edit_pet/modal/modal_edit_pet.dart';
import 'package:pet_family_app/pages/profile/edit/edit_pet/modal/modal_add_pet.dart';
import 'package:pet_family_app/pages/profile/edit/edit_pet/pet_edit_template.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/providers/auth_provider.dart';
import 'package:pet_family_app/providers/pet_provider.dart'; // ✅ Importe o PetProvider

class EditPet extends StatefulWidget {
  const EditPet({super.key});

  @override
  State<EditPet> createState() => _EditPetState();
}

class _EditPetState extends State<EditPet> {
  @override
  void initState() {
    super.initState();
    _carregarPets();
  }

  Future<void> _carregarPets() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    
    final usuario = authProvider.usuarioLogado;
    if (usuario != null && usuario['idusuario'] != null) {
      await petProvider.loadPetsByUsuario(usuario['idusuario']);
    }
  }

  void _adicionarNovoPet(Map<String, dynamic> novoPet) {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    
    // ✅ Adiciona o novo pet à lista
    final novoPetComId = {
      ...novoPet,
      'idpet': DateTime.now().millisecondsSinceEpoch, // ID temporário
    };
    
    // TODO: Chamar API para salvar o pet no backend
    // await PetService.adicionarPet(novoPet);
    
    // ✅ Atualiza a lista local (você pode recarregar da API se preferir)
    _carregarPets();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pet adicionado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _editarPet(String petId, Map<String, dynamic> petEditado) {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    
    // TODO: Chamar API para atualizar o pet no backend
    // await PetService.atualizarPet(petId, petEditado);
    
    // ✅ Recarrega os pets da API para garantir dados atualizados
    _carregarPets();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pet atualizado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removerPet(String petId, String petNome) {
    final petProvider = Provider.of<PetProvider>(context, listen: false);
    
    // TODO: Chamar API para remover o pet no backend
    // await PetService.removerPet(petId);
    
    // ✅ Recarrega os pets da API
    _carregarPets();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$petNome removido com sucesso!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            // TODO: Implementar funcionalidade de desfazer se necessário
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final petProvider = Provider.of<PetProvider>(context);
    final usuario = authProvider.usuarioLogado;

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
                  
                  // ✅ Botão para adicionar novo pet
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

                  // ✅ MOSTRANDO PETS REAIS DA API
                  if (petProvider.isLoading)
                    const Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Carregando seus pets...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (petProvider.errorMessage != null)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Erro ao carregar pets',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              petProvider.errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _carregarPets,
                              child: Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (petProvider.pets.isEmpty)
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
                      child: Column(
                        children: [
                          // ✅ Contador de pets
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${petProvider.pets.length} pet(s) cadastrado(s)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          // ✅ Lista de pets
                          Expanded(
                            child: ListView.builder(
                              itemCount: petProvider.pets.length,
                              itemBuilder: (context, index) {
                                final pet = petProvider.pets[index];
                                return PetEditTemplate(
                                  name: pet['nome'] ?? 'Sem nome',
                                  especie: pet['especie'] ?? 'Não informado',
                                  raca: pet['raca'] ?? 'Não informado',
                                  idade: pet['idade']?.toString() ?? 'Não informado',
                                  sexo: pet['sexo'] ?? 'Não informado',
                                  porte: pet['porte'] ?? 'Não informado',
                                  peso: pet['peso']?.toString() ?? 'Não informado',
                                  onTap: () => showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (BuildContext context) => ModalEditPet(
                                      petData: {
                                        'id': pet['idpet']?.toString(),
                                        'nome': pet['nome'],
                                        'especie': pet['especie'],
                                        'raca': pet['raca'],
                                        'sexo': pet['sexo'],
                                        'idade': pet['idade']?.toString(),
                                        'peso': pet['peso']?.toString(),
                                        'porte': pet['porte'],
                                        'descricao': pet['descricao'],
                                      },
                                      onPetEdited: (petEditado) {
                                        _editarPet(
                                          pet['idpet']?.toString() ?? '',
                                          petEditado,
                                        );
                                      },
                                      onPetDeleted: () {
                                        _removerPet(
                                          pet['idpet']?.toString() ?? '',
                                          pet['nome'] ?? 'Pet',
                                        );
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}