import 'package:flutter/material.dart';

class PetEditTemplate extends StatelessWidget {
  const PetEditTemplate({
    super.key,
    required this.name,
    required this.onTap,
  });

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Color(0xFFCCCCCC)),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.pets,
                    size: 40,
                    color: Colors.black,
                  ),
                  SizedBox(width: 5),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w200,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_right,
                size: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
