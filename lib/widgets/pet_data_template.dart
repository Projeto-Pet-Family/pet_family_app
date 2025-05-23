import 'package:flutter/material.dart';

class PetDataTemplate extends StatelessWidget {
  const PetDataTemplate({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Color(0xFFCCCCCC)
          )
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.pets),
                  Text(
                    'Tico Tico',
                    style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  )
                ],
              ),
              Text(
                'Gato de raça',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w200),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Macho',
                    style: TextStyle(
                      fontWeight: FontWeight.w200,
                      color: Colors.black,
                      fontSize: 17
                    ),
                  ),
                  Icon(
                    Icons.male,
                    color: Colors.blue,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
