import 'package:flutter/material.dart';

class ServicesTemplate extends StatefulWidget {
  final double price;
  final String service;
  const ServicesTemplate({
    super.key,
    required this.price,
    required this.service,
  });

  @override
  State<ServicesTemplate> createState() => _ServicesTemplateState();
}

class _ServicesTemplateState extends State<ServicesTemplate> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF0FFFE),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'R\$ ${widget.price} - ${widget.service}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w200,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Row(
                children: [Icon(Icons.close), Icon(Icons.edit)],
              )
            ],
          ),
        ),
      ),
    );
  }
}
