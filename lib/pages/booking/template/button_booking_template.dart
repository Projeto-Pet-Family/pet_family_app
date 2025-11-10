import 'package:flutter/material.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class ButtonBookingTemplate extends StatelessWidget {
  final String label;

  const ButtonBookingTemplate({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffEDEDED),
      ),
      child: Row(
        children: [
          AppButton(
            label: label,
            onPressed: () {},
          ),
          Icon(Icons.arrow_right)
        ],
      ),
    );
  }
}
