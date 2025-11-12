import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/pages/edit_booking/informations/title_information_template.dart';
import 'package:pet_family_app/pages/edit_booking/informations/your_pets/pets_booking_template.dart';

class YourPetsInformations extends StatefulWidget {
  final ContratoModel contrato;
  final Function(ContratoModel)? onContratoAtualizado;

  const YourPetsInformations({
    super.key,
    required this.contrato,
    this.onContratoAtualizado,
  });

  @override
  State<YourPetsInformations> createState() => _YourPetsInformationsState();
}

class _YourPetsInformationsState extends State<YourPetsInformations> {
  @override
  Widget build(BuildContext context) {
    final bool temPets =
        widget.contrato.pets != null && widget.contrato.pets!.isNotEmpty;

    return Column(
      children: [
        const TitleInformationTemplate(description: 'Seu(s) pet(s)'),
        const SizedBox(height: 12),
        if (temPets) ...[
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.contrato.pets!.map((pet) {
              String petName = 'Pet';

              if (pet is Map<String, dynamic>) {
                petName = pet['nome'] as String? ?? 'Pet';
              } else if (pet is PetModel) {
                petName = pet.nome ?? 'Pet';
              } else if (pet is String) {
                petName = pet;
              }

              return PetsBookingTemplate(name: petName);
            }).toList(),
          ),
        ] else ...[
          const Text(
            'Nenhum pet incluído',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}
