// pages/booking/modal/remover_pet_modal.dart - CORRIGIDO
import 'package:flutter/material.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';

class RemoverPetModal extends StatefulWidget {
  final List<dynamic> pets;

  const RemoverPetModal({
    super.key,
    required this.pets,
  });

  @override
  State<RemoverPetModal> createState() => _RemoverPetModalState();
}

class _RemoverPetModalState extends State<RemoverPetModal> {
  int? _petSelecionado;
  Map<int, String> _petNomes = {};

  @override
  void initState() {
    super.initState();
    _processarPets();
  }

  void _processarPets() {
    // Extrai IDs e nomes dos pets
    for (var pet in widget.pets) {
      int? petId;
      String petNome = 'Pet';

      if (pet is Map<String, dynamic>) {
        // Tenta diferentes possíveis chaves para o ID
        petId = pet['id'] ?? pet['idPet'] ?? pet['idpet'] ?? pet['petId'];
        petNome = pet['nome'] ?? 'Pet';
      } else if (pet is PetModel) {
        petId = pet.idPet;
        petNome = pet.nome ?? 'Pet';
      }

      if (petId != null) {
        _petNomes[petId] = petNome;
      }
    }
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Remover Pet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Selecione o pet que deseja remover:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _petNomes.isEmpty
                ? const Center(
                    child: Text('Nenhum pet encontrado'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _petNomes.length,
                    itemBuilder: (context, index) {
                      final petId = _petNomes.keys.elementAt(index);
                      final petNome = _petNomes[petId]!;
                      final pet = widget.pets[index];

                      String? petEspecie;

                      if (pet is Map<String, dynamic>) {
                        petEspecie = pet['especie'] ??
                            pet['descricaoEspecie'] ??
                            pet['especie_nome'];
                      } else if (pet is PetModel) {
                        petEspecie = pet.descricaoEspecie;
                      }

                      final bool isSelected = _petSelecionado == petId;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: isSelected ? Colors.orange[50] : null,
                        child: ListTile(
                          leading: const Icon(Icons.pets, color: Colors.orange),
                          title: Text(petNome),
                          subtitle:
                              petEspecie != null ? Text(petEspecie) : null,
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: Colors.orange)
                              : null,
                          onTap: () {
                            setState(() {
                              _petSelecionado = petId;
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Cancelar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _petSelecionado != null ? Colors.red : Colors.grey[300],
                    foregroundColor: _petSelecionado != null
                        ? Colors.white
                        : Colors.grey[600],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _petSelecionado != null
                      ? () => Navigator.pop(context, _petSelecionado)
                      : null,
                  child: const Text('Remover'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
