import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/widgets/app_bar_pet_family.dart';
import 'package:pet_family_app/widgets/app_text_field.dart';

class WhoManyPets extends StatefulWidget {
  const WhoManyPets({super.key});

  @override
  State<WhoManyPets> createState() => _WhoManyPetsState();
}

class _WhoManyPetsState extends State<WhoManyPets> {
  final TextEditingController _quantityPetsController = TextEditingController();
  int? _petQuantity;

  String get quantityPets => _quantityPetsController.text;

  void _updatePetQuantity() {
    final quantity = int.tryParse(_quantityPetsController.text);
    setState(() {
      _petQuantity = quantity;
    });
  }

  @override
  void initState() {
    super.initState();
    _quantityPetsController.addListener(_updatePetQuantity);
  }

  @override
  void dispose() {
    _quantityPetsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PetFamilyAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Quantos pets quer adicionar?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              AppTextField(
                controller: _quantityPetsController,
                keyboardType: TextInputType.number,
                hintText: 'Digites quantos pets quer adicionar',
              ),
              const SizedBox(height: 40),
              if (_petQuantity != null && _petQuantity! > 0) ...[
                ElevatedButton(
                  onPressed: () {
                    context.push('/insert-datas-pet');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8692DE),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Próximo',
                        style: TextStyle(fontSize: 20),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        size: 30,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
