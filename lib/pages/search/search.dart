import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/search/hotel_template.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            SizedBox(height: 50),
            Text(
              'Hospedagens',
              style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w200,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 50),
            HotelTemplate(),
            HotelTemplate(),
            HotelTemplate(),
          ],
        ),
      ),
    ));
  }
}
