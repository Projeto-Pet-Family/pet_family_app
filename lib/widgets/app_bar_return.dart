import 'package:flutter/material.dart';

class AppBarReturn extends StatelessWidget {
  const AppBarReturn({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              size: 30,
              color: Colors.black,
            ),
          ),
          Text(
            'PetFamily',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w200,
              color: Color(0xFF8F8F8F),
            ),
          ),
          SizedBox(width: 30)
        ],
      ),
    );
  }
}
