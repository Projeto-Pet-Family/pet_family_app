import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/edit_booking/modal/remove_pet/remove_pet.dart';

class PetsBookingTemplate extends StatefulWidget {
  final String name;
  final String? especie;
  final VoidCallback? onRemover;
  final bool mostrarBotaoRemover;

  const PetsBookingTemplate({
    super.key,
    required this.name,
    this.especie,
    this.onRemover,
    this.mostrarBotaoRemover = true,
  });

  @override
  State<PetsBookingTemplate> createState() => _PetsBookingTemplateState();
}

class _PetsBookingTemplateState extends State<PetsBookingTemplate> {
  void _onRemoverPet() {
    if (widget.onRemover != null) {
      widget.onRemover!();
    } else {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) => RemovePet(
          petName: widget.name,
          onConfirmarRemocao: () {
            Navigator.of(context).pop();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFFE),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.pets,
              size: 20,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.especie != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.especie!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.mostrarBotaoRemover && widget.onRemover != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _onRemoverPet,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
