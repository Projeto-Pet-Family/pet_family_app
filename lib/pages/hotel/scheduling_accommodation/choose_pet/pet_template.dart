import 'package:flutter/material.dart';

class PetTemplate extends StatelessWidget {
  const PetTemplate({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          color: isSelected ? const Color(0xFF43569B) : const Color(0xFFFBFBFF),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: const Color(0xFFCCCCCC),
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.pets,
              color: isSelected ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 10),
            Text(
              name,
              style: TextStyle(
                fontSize: 20,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}