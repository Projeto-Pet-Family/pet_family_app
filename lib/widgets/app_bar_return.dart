import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBarReturn extends StatelessWidget {
  const AppBarReturn({
    super.key,
    required this.route,
  });

  final String route;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              context.go(route);
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
