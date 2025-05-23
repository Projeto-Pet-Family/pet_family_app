import 'package:flutter/material.dart';
import 'package:pet_family_app/navigation/bottom_navigation.dart';

class HomeButtons extends StatelessWidget {
  const HomeButtons({
    super.key,
    required this.onTap,
    required this.title,
    required this.titleSize,
    required this.icon,
    required this.iconSize,
    required this.width,
    required this.height,
    required this.radius,
    this.targetIndex,
  });

  final VoidCallback onTap;
  final String title;
  final double titleSize;
  final IconData icon;
  final double iconSize;
  final double width;
  final double height;
  final double radius;
  final int? targetIndex;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
        if (targetIndex != null) {
          CoreNavigation.of(context)?.changePage(targetIndex!);
        }
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Color(0xFF8692DE),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: titleSize,
                  color: Colors.white,
                  fontWeight: FontWeight.w200,
                ),
              ),
              Icon(
                icon,
                color: Colors.white,
                size: iconSize,
              )
            ],
          ),
        ),
      ),
    );
  }
}
