import 'package:flutter/material.dart';

class ChooseServiceTemplate extends StatefulWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const ChooseServiceTemplate({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<ChooseServiceTemplate> createState() => _ChooseServiceTemplateState();
}

class _ChooseServiceTemplateState extends State<ChooseServiceTemplate> {
  bool _isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isTapped = true),
      onTapUp: (_) => setState(() => _isTapped = false),
      onTapCancel: () => setState(() => _isTapped = false),
      onTap: () {
        setState(() => _isTapped = false);
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.isSelected
                ? Colors.green
                : _isTapped
                    ? Colors.green
                    : Colors.grey,
            width: widget.isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(50),
          color: widget.isSelected
              ? Colors.green[50]
              : _isTapped
                  ? Colors.grey[100]
                  : Colors.white,
          boxShadow: _isTapped
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: widget.isSelected ? Colors.green : Colors.black,
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                widget.isSelected
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: widget.isSelected ? Colors.green : Colors.grey,
                key: ValueKey(widget.isSelected),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
