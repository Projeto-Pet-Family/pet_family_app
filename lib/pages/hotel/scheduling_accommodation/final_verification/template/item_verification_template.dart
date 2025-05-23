import 'package:flutter/material.dart';

class ItemVerification extends StatelessWidget {
  const ItemVerification({
    super.key,
    required this.title,
    this.subTitle,
    this.informations,
  });

  final String title;
  final String? subTitle;
  final String? informations;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: Color(0xFFFBFBFF),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w200,
                      color: Colors.black,
                    ),
                  ),
                  if (subTitle != null)
                    Text(
                      subTitle!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w200,
                        color: Color(0xFF858383),
                      ),
                    ),
                ],
              ),
              if (informations != null)
                Text(
                  informations!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w200,
                    color: Colors.black,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
