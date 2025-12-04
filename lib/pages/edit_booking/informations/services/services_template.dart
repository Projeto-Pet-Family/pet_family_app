import 'package:flutter/material.dart';

class ServicesTemplate extends StatelessWidget {
  final double price;
  final String service;
  final VoidCallback? onRemover;

  const ServicesTemplate({
    super.key,
    required this.price,
    required this.service,
    this.onRemover,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // Fundo branco
        border: Border.all(color: Colors.grey[300]!), // Borda cinza clara
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          // Adicionada sombra
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Informações do serviço
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'R\$${price.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),

          // Botão de remover
          if (onRemover != null) ...[
            const SizedBox(width: 12),
            InkWell(
              onTap: onRemover,
              borderRadius: BorderRadius.circular(50),
              child: Icon(
                  Icons.close,
                  size: 25,
                  color: Colors.red,
                ),
            ),
          ],
        ],
      ),
    );
  }
}
