import 'package:flutter/material.dart';

class ChooseServiceTemplate extends StatelessWidget {
  const ChooseServiceTemplate({
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
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
          color: isSelected ? Color(0xFF43569B) : Color(0xFFFBFBFF),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: Color(0xFFCCCCCC),
          ),
        ),
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(width: 10),
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
