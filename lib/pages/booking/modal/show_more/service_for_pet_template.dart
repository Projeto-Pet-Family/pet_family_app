import 'package:flutter/material.dart';

class ServiceForPetTemplate extends StatefulWidget {
  const ServiceForPetTemplate({super.key});

  @override
  State<ServiceForPetTemplate> createState() => _ServiceForPetTemplateState();
}

class _ServiceForPetTemplateState extends State<ServiceForPetTemplate> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IntrinsicWidth(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  'R\$ 20,00 - Passeio',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w200,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}