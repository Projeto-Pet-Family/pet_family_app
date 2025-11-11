import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/models/pet/pet_model.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import './pet_icon_bookin_template.dart';

class BookingTemplate extends StatelessWidget {
  final ContratoModel contrato;
  final VoidCallback onTap;

  const BookingTemplate({
    super.key,
    required this.contrato,
    required this.onTap,
  });

  String _formatarData(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _obterNomeStatus(int idStatus) {
    final statusMap = {
      1: 'Em Aprovação',
      2: 'Aprovado',
      3: 'Em Execução',
      4: 'Concluído',
      5: 'Negado',
      6: 'Cancelado',
    };
    return statusMap[idStatus] ?? 'Desconhecido';
  }

  Color _obterCorStatus(int idStatus) {
    switch (idStatus) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.grey;
      case 5:
        return Colors.red;
      case 6:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Método para obter a lista de pets como widgets
  List<Widget> _buildPetIcons() {
    if (contrato.pets == null || contrato.pets!.isEmpty) {
      return [
        const PetIconBookingTemplate(
          petName: 'Nenhum pet',
        ),
      ];
    }

    return contrato.pets!.map((pet) {
      String petName = 'Pet';

      // Verifica o tipo do objeto pet e extrai o nome
      if (pet is Map<String, dynamic>) {
        petName = pet['nome'] as String? ?? 'Pet';
      } else if (pet is PetModel) {
        petName = pet.nome ?? 'Pet';
      } else if (pet is String) {
        petName = pet;
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: PetIconBookingTemplate(
          petName: petName,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final petIcons = _buildPetIcons();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
            color: const Color(0xff8692DE),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _obterCorStatus(contrato.idStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _obterCorStatus(contrato.idStatus)),
                ),
                child: Text(
                  _obterNomeStatus(contrato.idStatus),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _obterCorStatus(contrato.idStatus),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Ícone da casa
              const Icon(
                Icons.house,
                size: 80,
                color: Colors.white,
              ),

              // Nome da hospedagem
              Text(
                contrato.hospedagemNome ?? 'Hospedagem',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 12),

              // Período
              Text(
                '${_formatarData(contrato.dataInicio)} - ${_formatarData(contrato.dataFim ?? contrato.dataInicio)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xffD9D9D9),
                  fontWeight: FontWeight.w200,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              if (petIcons.isNotEmpty) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: petIcons,
                  ),
                ),
              ],
            ],
          ),
        ),
        AppButton(
          label: 'Ver Mais',
          onPressed: () {},
          buttonColor: Color(0xffEDEDED),
          textButtonColor: Color(0xff000000),
          borderRadiusValue: 5,
          icon: const Icon(Icons.arrow_forward),
          borderSide: BorderSide(color: Color(0xffCFCCCC)),
        ),
        AppButton(
          label: 'Editar',
          onPressed: () {}, 
          buttonColor: Color(0xffEDEDED),
          textButtonColor: Color(0xff000000),
          borderRadiusValue: 5,
          icon: const Icon(Icons.edit),
          borderSide: BorderSide(color: Color(0xffCFCCCC)),
        ),
        AppButton(
          label: 'Cancelar',
          onPressed: () {},
          buttonColor: Color(0xffEDEDED),
          textButtonColor: Color(0xff000000),
          borderRadiusValue: 5,
          icon: const Icon(Icons.close),
          borderSide: BorderSide(color: Color(0xffCFCCCC)),
        ),
      ],
    );
  }
}
