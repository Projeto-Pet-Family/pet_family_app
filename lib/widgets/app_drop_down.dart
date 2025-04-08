import 'package:flutter/material.dart';

class AppDropDown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String label;
  final String? hint;
  final Function(T?)? onChanged;
  final String Function(T)? itemText;
  final bool isRequired;
  final String? errorMessage;
  final EdgeInsetsGeometry? padding;

  const AppDropDown({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    this.hint,
    this.onChanged,
    this.itemText,
    this.isRequired = false,
    this.errorMessage,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<T>(
            value: value,
            decoration: InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: Color(0xFFCCCCCC)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: Color(0xFFCCCCCC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(color: Color(0xFFCCCCCC)),
              ),
              errorText: isRequired && value == null
                  ? errorMessage ?? 'This field is required'
                  : null,
            ),
            hint: hint != null
                ? Text(
                    hint!,
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  )
                : null,
            items: items.map((T item) {
              return DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemText != null ? itemText!(item) : item.toString(),
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.grey[700],
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(30),
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}
