import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_pet/pet_template.dart';
import 'package:pet_family_app/repository/pet_repository.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class ChoosePet extends StatefulWidget {
  const ChoosePet({super.key});

  @override
  State<ChoosePet> createState() => _ChoosePetState();
}

class _ChoosePetState extends State<ChoosePet> {
  final Set<int> _selectedPets = {};
  final PetRepository _petRepository = PetRepository();
  List<PetModel> _pets = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _carregarPets();
  }

  Future<void> _carregarPets() async {
    try {
      final pets = await _petRepository.lerPet();
      setState(() {
        _pets = pets;
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar pets: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar pets: $e')),
      );
    }
  }

  void _togglePetSelection(int petId) {
    setState(() {
      if (_selectedPets.contains(petId)) {
        _selectedPets.remove(petId);
      } else {
        _selectedPets.add(petId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBarReturn(route: '/hotel'),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  const Text(
                    'Escolha o(s) pet(s)',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w200,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Exibe loading, erro ou lista de pets
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage.isNotEmpty
                          ? Center(child: Text(_errorMessage))
                          : _pets.isEmpty
                              ? const Text('Nenhum pet cadastrado')
                              : Column(
                                  children: _pets.map((pet) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: PetTemplate(
                                        key: ValueKey(pet.idPet),
                                        name: pet.nome,
                                        isSelected: _selectedPets.contains(pet.idPet),
                                        onTap: () => _togglePetSelection(pet.idPet),
                                      ),
                                    );
                                  }).toList(),
                                ),
                  
                  const SizedBox(height: 60),
                  if (_selectedPets.isNotEmpty)
                    AppButton(
                      onPressed: () {
                        context.go('/choose-data', extra: {
                          'selectedPets': _selectedPets.toList(),
                          'pets': _pets.where((pet) => _selectedPets.contains(pet.idPet)).toList(),
                        });
                      },
                      label: 'Próximo',
                      fontSize: 18,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}