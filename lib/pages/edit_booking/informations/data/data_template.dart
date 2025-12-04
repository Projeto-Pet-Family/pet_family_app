import 'package:flutter/material.dart';

class DataTemplate extends StatelessWidget {
  final String data;
  final bool isClickable;

  const DataTemplate({
    super.key,
    required this.data,
    this.isClickable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, // Fundo branco
        border: Border.all(
          color: Colors.grey[300]!, // Borda cinza clara
          width: 1,
        ),
        borderRadius: BorderRadius.circular(25), // Arredondamento máximo (25)
        boxShadow: [ // Adicionada sombra
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: isClickable ? Colors.black87 : Colors.black,
            ),
          ),
          if (isClickable) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ],
      ),
    );
  }
}