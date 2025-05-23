import 'package:flutter/material.dart';
import 'package:pet_family_app/navigation/bottom_navigation.dart';
import 'package:pet_family_app/pages/home/widgets/home_buttons.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(Icons.pets),
                Text('PetFamily'),
                Icon(Icons.notifications)
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Bem vindo, Tutor',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w200,
                color: Colors.black,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFFCCCCCC),
                decorationThickness: 1,
              ),
            ),
            SizedBox(height: 60),
            HomeButtons(
              onTap: () {
                CoreNavigation.of(context)?.changePage(1);
              },
              title: 'Hospedagens',
              titleSize: 25,
              icon: Icons.house,
              iconSize: 100,
              width: 330,
              height: 150,
              radius: 20,
            ),
            SizedBox(height: 60),
            HomeButtons(
              onTap: () {
                CoreNavigation.of(context)?.changePage(2);
              },
              title: 'Seu(s) agendamentos',
              titleSize: 20,
              icon: Icons.calendar_month,
              iconSize: 40,
              width: 330,
              height: 80,
              radius: 50,
            ),
            SizedBox(height: 20),
            HomeButtons(
              onTap: () {
                CoreNavigation.of(context)?.changePage(3);
              },
              title: 'Seu(s) pet(s)',
              titleSize: 20,
              icon: Icons.pets,
              iconSize: 40,
              width: 330,
              height: 80,
              radius: 50,
            ),
          ],
        ),
      ),
    ));
  }
}
