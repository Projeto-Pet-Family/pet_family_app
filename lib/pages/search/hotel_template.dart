import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class HotelTemplate extends StatefulWidget {
  final String name;
  final String street;
  final String number; // ✅ MUDEI de int para String
  final String neighborhood;
  final String city;
  final String state;
  final String uf;
  final String zipCode;
  final String complement;
  final int idHotel;

  const HotelTemplate({
    super.key,
    required this.name,
    required this.street,
    required this.number, // ✅ Agora é String
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.uf,
    required this.zipCode,
    required this.complement,
    required this.idHotel,
  });

  @override
  State<HotelTemplate> createState() => _HotelTemplateState();
}

class _HotelTemplateState extends State<HotelTemplate> {
  Map<String, dynamic> _getHotelData() {
    return {
      'idhospedagem': widget.idHotel,
      'nome': widget.name,
      'logradouro': widget.street,
      'numero': widget.number,
      'complemento': widget.complement,
      'bairro': widget.neighborhood,
      'cidade': widget.city,
      'estado': widget.state,
      'sigla': widget.uf,
      'cep': widget.zipCode,
    };
  }

  @override
  Widget build(BuildContext context) {
    // DEBUG para verificar os dados
    print('🏨 HotelTemplate construído:');
    print('   Nome: ${widget.name}');
    print('   ID: ${widget.idHotel}');
    print('   Número: ${widget.number} (tipo: ${widget.number.runtimeType})');

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
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '${widget.street}, ${widget.number}, ${widget.neighborhood}, ${widget.city}, ${widget.state}, ${widget.uf}, ${widget.zipCode}, ${widget.complement}',
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
                        onRatingUpdate: (rating) {},
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
                final hotelData = _getHotelData();

                print('🎯 Navegando para hotel: ${widget.name}');
                print('🎯 ID enviado: ${widget.idHotel}');
                print('🎯 Dados completos enviados: $hotelData');

                context.go('/hotel', extra: hotelData);
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
