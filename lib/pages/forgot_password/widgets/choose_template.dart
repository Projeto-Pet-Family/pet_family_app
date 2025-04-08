import 'package:flutter/material.dart';

class ChooseTemplate extends StatelessWidget {
  const ChooseTemplate({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  final String text;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF000000),
              fontWeight: FontWeight.w200,
            ),
          ),
          Icon(
            icon,
            size: 50,
          )
        ],
      ),
    );
  }
}
