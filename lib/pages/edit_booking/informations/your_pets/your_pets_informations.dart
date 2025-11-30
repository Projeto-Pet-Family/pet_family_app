import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/pages/edit_booking/informations/title_information_template.dart';
import 'package:pet_family_app/pages/edit_booking/informations/your_pets/pets_booking_template.dart';


class YourPetsInformations extends StatefulWidget {
  final ContratoModel contrato;
  final Function(ContratoModel, {String? tipoAlteracao})? onContratoAtualizado;
  final bool editavel;

  const YourPetsInformations({
    super.key,
    required this.contrato,
    this.onContratoAtualizado,
    this.editavel = false,
  });

  @override
  State<YourPetsInformations> createState() => _YourPetsInformationsState();
}

class _YourPetsInformationsState extends State<YourPetsInformations> {
  bool _carregando = false;

  Future<void> _removerPet(int index) async {
    if (!widget.editavel || _carregando) return;

    if (widget.contrato.pets == null || index >= widget.contrato.pets!.length) {
      return;
    }

    final petParaRemover = widget.contrato.pets![index];
    int? idPet;

    // Extrai o ID do pet baseado no tipo
    if (petParaRemover is Map<String, dynamic>) {
      idPet = petParaRemover['idpet'] as int?;
    } else if (petParaRemover is PetModel) {
      idPet = petParaRemover.idPet; // Corrigido para idPet
    }

    if (idPet == null) {
      print('❌ ID do pet não encontrado');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: ID do pet não encontrado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _carregando = true;
    });

    try {
      print(
          '🗑️ Removendo pet ID: $idPet do contrato ${widget.contrato.idContrato}');

      // TODO: Implementar método para remover pet do contrato na ApiService
      // Por enquanto, vamos apenas simular a remoção
      await Future.delayed(const Duration(seconds: 1)); // Simulação

      // Simulação de sucesso
      final bool sucesso = true;

      if (sucesso) {
        print('✅ Pet removido com sucesso na API');

        final List<dynamic> novosPets = List.from(widget.contrato.pets!);
        novosPets.removeAt(index);

        final contratoAtualizado = widget.contrato.copyWith(
          pets: novosPets.isEmpty ? null : novosPets,
        );

        if (widget.onContratoAtualizado != null) {
          widget.onContratoAtualizado!(contratoAtualizado,
              tipoAlteracao: 'pet_removido');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet removido com sucesso'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Falha ao remover pet na API');
      }
    } catch (e) {
      print('❌ Erro ao remover pet: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao remover pet: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _carregando = false;
      });
    }
  }

  void _confirmarRemocaoPet(int index) {
    String nomePet = 'Pet';

    if (index < widget.contrato.pets!.length) {
      final pet = widget.contrato.pets![index];
      if (pet is Map<String, dynamic>) {
        nomePet = pet['nome'] as String? ?? 'Pet';
      } else if (pet is PetModel) {
        nomePet = pet.nome!; // Já é obrigatório, não precisa de ??
      } else if (pet is String) {
        nomePet = pet;
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Remover Pet",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Tem certeza que deseja remover o pet \"$nomePet\" da hospedagem?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _removerPet(index);
              },
              child: _carregando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      "Remover",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _adicionarPet() {
    if (!widget.editavel || _carregando) return;

    // TODO: Implementar modal para adicionar pets disponíveis
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de adicionar pet em desenvolvimento'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  String? _obterNomeEspecie(dynamic pet) {
    if (pet is Map<String, dynamic>) {
      return pet['especie'] as String?;
    } else if (pet is PetModel) {
      return pet.descricaoEspecie; // Usa a propriedade correta do PetModel
    }
    return null;
  }

  String _obterNomePet(dynamic pet) {
    if (pet is Map<String, dynamic>) {
      return pet['nome'] as String? ?? 'Pet';
    } else if (pet is PetModel) {
      return pet.nome!; // Já é obrigatório
    } else if (pet is String) {
      return pet;
    }
    return 'Pet';
  }

  @override
  Widget build(BuildContext context) {
    final bool temPets =
        widget.contrato.pets != null && widget.contrato.pets!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const TitleInformationTemplate(description: 'Seu(s) pet(s)'),
            if (widget.editavel) ...[
              // Botão de adicionar pode ser adicionado aqui se necessário
            ],
          ],
        ),
        const SizedBox(height: 16),
        if (_carregando) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          ),
        ] else if (temPets) ...[
          Column(
            children: widget.contrato.pets!.asMap().entries.map((entry) {
              final int index = entry.key;
              final dynamic pet = entry.value;

              return PetsBookingTemplate(
                name: _obterNomePet(pet),
                especie: _obterNomeEspecie(pet),
                onRemover:
                    widget.editavel ? () => _confirmarRemocaoPet(index) : null,
                mostrarBotaoRemover: widget.editavel,
              );
            }).toList(),
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: const Text(
              'Nenhum pet incluído',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
        if (widget.editavel && !_carregando) ...[
          const SizedBox(height: 16),
          /* OutlinedButton(
            onPressed: _adicionarPet,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue[600],
              side: BorderSide(color: Colors.blue[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 18, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Adicionar Pet',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ), */
        ],
      ],
    );
  }
}
