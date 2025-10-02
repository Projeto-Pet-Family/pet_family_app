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
  final bool enabled;

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
    this.enabled = true,
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
            style: const TextStyle(
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
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(color: Color(0xFFCCCCCC)),
              ),
              errorText: isRequired && value == null
                  ? errorMessage ?? 'Este campo é obrigatório'
                  : null,
              filled: !enabled,
              fillColor: !enabled ? Colors.grey[100] : null,
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
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
            onChanged: enabled ? onChanged : null,
            icon: Icon(
              Icons.arrow_drop_down,
              color: enabled ? Colors.grey[700] : Colors.grey[400],
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