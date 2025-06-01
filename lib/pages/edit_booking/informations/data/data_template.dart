import 'package:flutter/material.dart';

class DataTemplate extends StatefulWidget {
  final String data;
  const DataTemplate({
    super.key,
    required this.data,
  });

  @override
  State<DataTemplate> createState() => _DataTemplateState();
}

class _DataTemplateState extends State<DataTemplate> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          widget.data,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w200,
            color: Color(0xFF1C1B1F),
          ),
        ),
        Icon(
          Icons.edit,
          size: 15,
          color: Color(0xFF1C1B1F),
        )
      ],
    );
  }
}
