import 'package:flutter/material.dart';

class ServiceForPetTemplate extends StatefulWidget {
  final String servicoNome;
  final double preco;

  const ServiceForPetTemplate({
    super.key,
    required this.servicoNome,
    required this.preco,
  });

  @override
  State<ServiceForPetTemplate> createState() => _ServiceForPetTemplateState();
}

class _ServiceForPetTemplateState extends State<ServiceForPetTemplate> {
  String _formatarMoeda(double valor) {
    return 'R\$${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: IntrinsicWidth(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              '${_formatarMoeda(widget.preco)} - ${widget.servicoNome}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
