import 'package:flutter/material.dart';

class PetIconBookingTemplate extends StatefulWidget {
  final String petName;

  const PetIconBookingTemplate({
    super.key,
    required this.petName,
  });

  @override
  State<PetIconBookingTemplate> createState() => _PetIconBookingTemplateState();
}

class _PetIconBookingTemplateState extends State<PetIconBookingTemplate> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Padding(
            padding: EdgeInsets.all(11),
            child: Icon(
              Icons.pets,
              size: 25,
              color: Color(0xff1C1B1F),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          constraints: const BoxConstraints(maxWidth: 80),
          child: Text(
            widget.petName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
