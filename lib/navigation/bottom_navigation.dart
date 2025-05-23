import 'package:flutter/material.dart';
import 'package:pet_family_app/pages/booking/booking.dart';
import 'package:pet_family_app/pages/home/home.dart';
import 'package:pet_family_app/pages/profile/profile.dart';
import 'package:pet_family_app/pages/search/search.dart';

class CoreNavigation extends StatefulWidget {
  const CoreNavigation({super.key});

  @override
  State<CoreNavigation> createState() => _CoreNavigationState();

  static _CoreNavigationState? of(BuildContext context) =>
      context.findAncestorStateOfType<_CoreNavigationState>();
}

class _CoreNavigationState extends State<CoreNavigation> {
  int itemSelected = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Home(),
    Search(),
    Booking(),
    Profile()
  ];

  void changePage(int index) {
    setState(() {
      itemSelected = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        backgroundColor: Color(0xFFFBFBFF),
        elevation: 1,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        selectedItemColor: Color(0xFF8692DE),
        unselectedItemColor: Color(0xFF474343),
        selectedIconTheme: IconThemeData(color: Color(0xFF8692DE)),
        unselectedIconTheme: IconThemeData(color: Color(0xFF474343)),
        selectedLabelStyle: TextStyle(color: Color(0xFF8692DE)),
        unselectedLabelStyle: TextStyle(color: Color(0xFF474343)),
        currentIndex: itemSelected,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), label: 'Agendamentos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: changePage,
      ),
      body: _widgetOptions.elementAt(itemSelected),
    );
  }
}
