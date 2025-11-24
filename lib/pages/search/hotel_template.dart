import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/widgets/app_button.dart';

class HotelTemplate extends StatefulWidget {
  final String name;
  final String street;
  final String number;
  final String neighborhood;
  final String city;
  final String state;
  final String uf;
  final String zipCode;
  final String complement;
  final int idHotel;
  final double valorDiaria; // ✅ NOVO CAMPO

  const HotelTemplate({
    super.key,
    required this.name,
    required this.street,
    required this.number,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.uf,
    required this.zipCode,
    required this.complement,
    required this.idHotel,
    required this.valorDiaria, // ✅ NOVO PARÂMETRO
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
      'valor_diaria': widget.valorDiaria, // ✅ INCLUINDO VALOR DA DIÁRIA
    };
  }

  // Função para formatar o valor em Reais
  String _formatarValor(double valor) {
    return 'R\$${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    // DEBUG para verificar os dados
    print('🏨 HotelTemplate construído:');
    print('   Nome: ${widget.name}');
    print('   ID: ${widget.idHotel}');
    print('   Número: ${widget.number} (tipo: ${widget.number.runtimeType})');
    print('   Valor Diária: ${_formatarValor(widget.valorDiaria)}');

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

                  // Nome do Hotel
                  Text(
                    widget.name,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 8),

                  // ✅ VALOR DA DIÁRIA - Destaque
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF159800),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_formatarValor(widget.valorDiaria)} / dia',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
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

                  SizedBox(height: 16),
                ],
              ),
            ),

            // Botão
            AppButton(
              onPressed: () {
                final hotelData = _getHotelData();

                print('🎯 Navegando para hotel: ${widget.name}');
                print('🎯 ID enviado: ${widget.idHotel}');
                print('🎯 Valor diária: ${_formatarValor(widget.valorDiaria)}');
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
