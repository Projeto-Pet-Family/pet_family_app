import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class HotelTemplate extends StatelessWidget {
  const HotelTemplate({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF8692DE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.domain,
                      size: 100,
                      color: Color(0xFF1C1B1F),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hotel 1',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Aberto',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF60F700),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Rua dos Pinguins, 24, São Caetano do Sul, São Paulo',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFCCCCCC),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    'há 2.5km',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFCCCCCC),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '4.45',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Color(0xFFFFFFFF),
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(width: 5),
                      RatingBar.builder(
                        initialRating: 4.5,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 15,
                        itemPadding: EdgeInsets.symmetric(horizontal: 1.0),
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                        onRatingUpdate: (rating) {
                          print(rating);
                        },
                      ),
                    ],
                  ),
                  Text(
                    '2500 avaliações',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFFFFFFF),
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
            AppButton(
              onPressed: () {
                context.go('/hotel');
              },
              label: 'Hospedar aqui',
              buttonColor: Color(0xFF159800),
              fontSize: 20,
            ),
          ],
        ),
      ),
    );
  }
}
