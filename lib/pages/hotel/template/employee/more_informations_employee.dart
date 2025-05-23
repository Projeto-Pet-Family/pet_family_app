import 'package:flutter/material.dart';

class MoreInformationsEmployee extends StatelessWidget {
  const MoreInformationsEmployee({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.close),
              ),
            ),
            SizedBox(height: 40),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF8692DE),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Funcionário 1 da Silva',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Veterinário',
              style: TextStyle(
                fontWeight: FontWeight.w200,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            Text(
              '26 anos',
              style: TextStyle(
                fontWeight: FontWeight.w200,
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/certificate.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 26),
            Text(
              'Descrição',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFFBFBFF),
                borderRadius: BorderRadius.circular(20)
              ),
              child: Text(
                'Lorem Ipsum is simply dummy text of the printing and typesetting  industry. Lorem Ipsum has been the industrys standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w100,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
