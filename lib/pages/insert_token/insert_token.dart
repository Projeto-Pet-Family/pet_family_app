import 'package:flutter/material.dart';
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';

class InsertToken extends StatefulWidget {
  const InsertToken({super.key});

  @override
  State<InsertToken> createState() => _InsertTokenState();
}

class _InsertTokenState extends State<InsertToken> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PetFamilyAppBar(),
      body: Column(
        children: [
          Text('Insira o token'),
          Text('Digite o token que lhe enviamos')
        ],
      ),
    );
  }
}
