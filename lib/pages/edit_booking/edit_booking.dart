import 'package:flutter/material.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/pages/edit_booking/informations/data/data_information.dart';
import 'package:pet_family_app/pages/edit_booking/informations/hotel/hotel_information.dart';
import 'package:pet_family_app/pages/edit_booking/informations/services/services_information.dart';
import 'package:pet_family_app/pages/edit_booking/informations/your_pets/your_pets_informations.dart';
import 'package:pet_family_app/pages/edit_booking/modal/booking_edited.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class EditBooking extends StatefulWidget {
  final ContratoModel contrato;
  final Function(ContratoModel)? onContratoEditado;

  const EditBooking({
    super.key,
    required this.contrato,
    this.onContratoEditado,
  });

  // Método estático para abrir como modal
  static Future<void> show({
    required BuildContext context,
    required ContratoModel contrato,
    Function(ContratoModel)? onContratoEditado,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditBooking(
        contrato: contrato,
        onContratoEditado: onContratoEditado,
      ),
    );
  }

  @override
  State<EditBooking> createState() => _EditBookingState();
}

class _EditBookingState extends State<EditBooking> {
  late ContratoModel _contratoEditado;

  @override
  void initState() {
    super.initState();
    // Cria uma cópia do contrato para edição
    _contratoEditado = ContratoModel.fromJson(widget.contrato.toJson());
  }

  void _onContratoAtualizado(ContratoModel contratoAtualizado) {
    setState(() {
      _contratoEditado = contratoAtualizado;
    });
  }

  void _onSalvarAlteracoes() {
    // Chama o callback para atualizar o contrato
    if (widget.onContratoEditado != null) {
      widget.onContratoEditado!(_contratoEditado);
    }

    // Mostra o modal de confirmação
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => BookingEdited(),
    ).then((_) {
      // Fecha o modal de edição após salvar
      Navigator.of(context).pop();
    });
  }

  void _fecharModal() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.95,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header do modal - mais compacto
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Botão de fechar
                IconButton(
                  onPressed: _fecharModal,
                  icon: const Icon(Icons.close, size: 24, color: Colors.grey),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
                const SizedBox(width: 8),
                // Título mais compacto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Editando agendamento',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.contrato.hospedagemNome ?? 'Agendamento',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divisor
          const Divider(height: 1, color: Colors.grey),

          // Conteúdo principal
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Hotel Information
                  Container(
                    width: double.infinity,
                    child: HotelInformation(
                      contrato: _contratoEditado,
                      onContratoAtualizado: _onContratoAtualizado,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Data Information
                  Container(
                    width: double.infinity,
                    child: DataInformation(
                      contrato: _contratoEditado,
                      onContratoAtualizado: _onContratoAtualizado,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Services Information
                  Container(
                    width: double.infinity,
                    child: ServicesInformation(
                      contrato: _contratoEditado,
                      onContratoAtualizado: _onContratoAtualizado,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Your Pets Information
                  Container(
                    width: double.infinity,
                    child: YourPetsInformations(
                      contrato: _contratoEditado,
                      onContratoAtualizado: _onContratoAtualizado,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botões de ação
                  Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        // Botão Salvar
                        AppButton(
                          onPressed: _onSalvarAlteracoes,
                          label: 'Salvar Alterações',
                          fontSize: 16,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          onPressed: _fecharModal,
                          label: 'Cancelar',
                          fontSize: 16,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          buttonColor: Colors.white,
                          textButtonColor: Colors.black,
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),  
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
