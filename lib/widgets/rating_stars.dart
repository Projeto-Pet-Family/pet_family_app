import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.colorStar,
  });

  final Color colorStar;

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: 4.5,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemSize: 15,
      itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: colorStar,
      ),
      onRatingUpdate: (rating) {
        print(rating);
      },
    );
  }
}
