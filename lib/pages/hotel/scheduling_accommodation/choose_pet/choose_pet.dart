import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/providers/pet/pet_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_pet/pet_template.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';

import 'package:pet_family_app/providers/auth_provider.dart';

class ChoosePet extends StatefulWidget {
  const ChoosePet({super.key});

  @override
  State<ChoosePet> createState() => _ChoosePetState();
}

class _ChoosePetState extends State<ChoosePet> {
  final Set<int> _selectedPets = {};
  List<PetModel> _pets = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _carregarPets();
    _carregarPetsSelecionadosDoCache();
  }

  Future<void> _carregarPets() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final petProvider = context.read<PetProvider>();
      final usuarioId = authProvider.usuario?.idUsuario;

      if (usuarioId != null) {
        await petProvider.listarPetsPorUsuario(usuarioId);

        if (petProvider.error == null) {
          setState(() {
            _pets = petProvider.pets;
            _isLoading = false;
            _errorMessage = '';
          });
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Erro ao carregar pets: ${petProvider.error}';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Usuário não logado';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar pets: $e';
      });
    }
  }

  Future<void> _carregarPetsSelecionadosDoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedPetsString = prefs.getStringList('selected_pets') ?? [];

      final selectedPets =
          selectedPetsString.map((id) => int.parse(id)).toSet();

      setState(() {
        _selectedPets.addAll(selectedPets);
      });

      print('✅ Pets selecionados carregados do cache: $_selectedPets');
    } catch (e) {
      print('❌ Erro ao carregar pets do cache: $e');
    }
  }

  Future<void> _salvarPetsSelecionadosNoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final selectedPetsString =
          _selectedPets.map((id) => id.toString()).toList();

      await prefs.setStringList('selected_pets', selectedPetsString);

      print('💾 Pets selecionados salvos no cache: $_selectedPets');
    } catch (e) {
      print('❌ Erro ao salvar pets no cache: $e');
    }
  }

  // Novo método para salvar quantidade de pets
  Future<void> _salvarQuantidadePetsNoCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selected_pets_count', _selectedPets.length);
      print('💾 Quantidade de pets salva no cache: ${_selectedPets.length}');
    } catch (e) {
      print('❌ Erro ao salvar quantidade de pets: $e');
    }
  }

  Future<void> _salvarDetalhesPetsNoCache(
      List<PetModel> petsSelecionados) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Salva os nomes dos pets selecionados
      final petNames = petsSelecionados.map((pet) => pet.nome!).toList();
      await prefs.setStringList('selected_pet_names', petNames);

      // Salva os IDs como string para facilitar o acesso
      final petIds =
          petsSelecionados.map((pet) => pet.idPet.toString()).toList();
      await prefs.setStringList('selected_pet_ids', petIds);

      // Salva a quantidade de pets
      await prefs.setInt('selected_pets_count', petsSelecionados.length);

      // Salva informações individuais de cada pet
      for (final pet in petsSelecionados) {
        await prefs.setString('pet_${pet.idPet}_name', pet.nome!);
        if (pet.idEspecie != null) {
          await prefs.setInt('pet_${pet.idPet}_species', pet.idEspecie!);
        }
        if (pet.idRaca != null) {
          await prefs.setInt('pet_${pet.idPet}_breed', pet.idRaca!);
        }
      }

      print('💾 Detalhes dos pets salvos no cache: $petNames');
      print('💾 Quantidade de pets: ${petsSelecionados.length}');
    } catch (e) {
      print('❌ Erro ao salvar detalhes dos pets: $e');
    }
  }

  void _togglePetSelection(int? petId) {
    if (petId == null) {
      print('⚠️ Tentativa de selecionar pet com ID null');
      return;
    }

    setState(() {
      if (_selectedPets.contains(petId)) {
        _selectedPets.remove(petId);
        print('➖ Pet $petId removido da seleção');
      } else {
        _selectedPets.add(petId);
        print('➕ Pet $petId adicionado à seleção');
      }
    });

    // Salva automaticamente no cache quando a seleção muda
    _salvarPetsSelecionadosNoCache();
    _salvarQuantidadePetsNoCache(); // Novo método
  }

  void _navigateToNext() {
    final selectedPetsList =
        _pets.where((pet) => _selectedPets.contains(pet.idPet)).toList();

    // Salva TUDO no cache (sem ir para API ainda)
    _salvarDetalhesPetsNoCache(selectedPetsList);

    // Navega sem enviar para API
    context.go('/choose-data', extra: {
      'selectedPets': _selectedPets.toList(),
      'pets': selectedPetsList,
    });
  }

  Future<void> _limparPetsSelecionados() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selected_pets');
      await prefs.remove('selected_pet_names');
      await prefs.remove('selected_pet_ids');
      await prefs.remove('selected_pets_count'); // Novo

      // Limpa informações individuais dos pets
      for (final pet in _pets) {
        if (pet.idPet != null) {
          await prefs.remove('pet_${pet.idPet}_name');
          await prefs.remove('pet_${pet.idPet}_species');
          await prefs.remove('pet_${pet.idPet}_breed');
        }
      }

      setState(() {
        _selectedPets.clear();
      });

      print('🗑️ Seleção de pets limpa do cache');
    } catch (e) {
      print('❌ Erro ao limpar pets do cache: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const AppBarReturn(route: '/hotel'),
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

                  // Mostra quantos pets estão selecionados
                  if (_selectedPets.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      '${_selectedPets.length} pet(s) selecionado(s)',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // Exibe loading, erro ou lista de pets
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage.isNotEmpty
                          ? _buildErrorMessage()
                          : _pets.isEmpty
                              ? _buildEmptyState()
                              : _buildPetsList(),

                  const SizedBox(height: 30),

                  if (_selectedPets.isNotEmpty)
                    AppButton(
                      onPressed: _navigateToNext,
                      label: 'Próximo',
                      fontSize: 18,
                    ),

                  const SizedBox(height: 16),

                  // Botão para limpar seleção
                  if (_selectedPets.isNotEmpty)
                    AppButton(
                      onPressed: _limparPetsSelecionados,
                      label: 'Limpar seleção',
                      fontSize: 18,
                      buttonColor: Colors.redAccent,
                    ),

                  if (_selectedPets.isNotEmpty) const SizedBox(height: 16),
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
            key: ValueKey(pet.idPet),
            name: pet.nome!,
            isSelected: _selectedPets.contains(pet.idPet),
            onTap: () => _togglePetSelection(pet.idPet),
          ),
        );
      }).toList(),
    );
  }
}
