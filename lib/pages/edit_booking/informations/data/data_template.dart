import 'package:flutter/material.dart';

class DataTemplate extends StatelessWidget {
  final String data;
  final bool isClickable;

  const DataTemplate({
    super.key,
    required this.data,
    this.isClickable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isClickable ? Colors.grey[50] : Colors.transparent,
        border: Border.all(
          color: isClickable ? Colors.grey[300]! : Colors.transparent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: isClickable ? Colors.black87 : Colors.black,
            ),
          ),
          if (isClickable) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.calendar_today,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ],
      ),
    );
  }
}