import 'package:flutter/material.dart';

class TitleInformationTemplate extends StatelessWidget {
  const TitleInformationTemplate({
    super.key,
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF858383),
            fontWeight: FontWeight.w200,
          ),
        ),
      ],
    );
  }
}
