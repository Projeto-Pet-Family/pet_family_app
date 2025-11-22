// data_template.dart
import 'package:flutter/material.dart';

class DataTemplate extends StatelessWidget {
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? initialDate;
  final Function(DateTime) onDateSelected;
  final String hintText;
  final bool enabled;

  const DataTemplate({
    super.key,
    required this.firstDate,
    required this.lastDate,
    this.initialDate,
    required this.onDateSelected,
    this.hintText = 'Selecione uma data',
    this.enabled = true,
  });

  Future<void> _selectDate(BuildContext context) async {
    if (!enabled) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.green,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? Colors.grey : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(50),
          color: enabled ? Colors.white : Colors.grey[100],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              initialDate != null
                  ? '${initialDate!.day}/${initialDate!.month}/${initialDate!.year}'
                  : hintText,
              style: TextStyle(
                fontSize: 16,
                color: initialDate != null ? Colors.black : Colors.grey,
                fontWeight:
                    initialDate != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: enabled ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
