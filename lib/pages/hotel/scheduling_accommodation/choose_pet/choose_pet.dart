import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_pet/pet_template.dart';
import 'package:pet_family_app/repository/pet_repository.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';

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

  void _navigateToNext() {
    final selectedPetsList =
        _pets.where((pet) => _selectedPets.contains(pet.idpet)).toList();

    context.go('/choose-data', extra: {
      'selectedPets': _selectedPets.toList(),
      'pets': selectedPetsList,
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
                  const SizedBox(height: 10),
                  const Text(
                    'Selecione os pets que ficarão hospedados',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Exibe loading, erro ou lista de pets
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage.isNotEmpty
                          ? _buildErrorMessage()
                          : _pets.isEmpty
                              ? _buildEmptyState()
                              : _buildPetsList(),

                  const SizedBox(height: 60),
                  if (_selectedPets.isNotEmpty)
                    AppButton(
                      onPressed: _navigateToNext,
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

  Widget _buildErrorMessage() {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          size: 50,
          color: Colors.red[300],
        ),
        const SizedBox(height: 10),
        Text(
          _errorMessage,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.red[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _carregarPets,
          child: const Text('Tentar Novamente'),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Icon(
          Icons.pets,
          size: 80,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 20),
        const Text(
          'Nenhum pet cadastrado',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Você precisa cadastrar pelo menos um pet\npara agendar hospedagens',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildPetsList() {
    return Column(
      children: _pets.map((pet) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: PetTemplate(
            key: ValueKey(pet.idpet),
            name: pet.nome,
            isSelected: _selectedPets.contains(pet.idpet),
            onTap: () => _togglePetSelection(pet.idpet!),
          ),
        );
      }).toList(),
    );
  }
}
