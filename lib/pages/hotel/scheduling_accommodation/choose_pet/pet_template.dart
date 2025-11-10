// No arquivo pet_template.dart
import 'dart:ui';

import 'package:flutter/material.dart';

class PetTemplate extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const PetTemplate({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.blue : Color(0xFFCCCCCC),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(50),
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.pets,
              color: isSelected ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 12),
            Text(
              name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.blue : Colors.black,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Colors.blue,
              ),
          ],
        ),
      ),
    );
  }
}
