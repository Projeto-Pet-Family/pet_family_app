import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pet_family_app/pages/hotel/template/employee/employee_template.dart';
import 'package:pet_family_app/pages/hotel/template/service_template.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/rating_stars.dart';

class Hotel extends StatefulWidget {
  final Map<String, dynamic> hotelData;

  const Hotel({
    super.key,
    required this.hotelData,
  });

  @override
  State<Hotel> createState() => _HotelState();
}

class _HotelState extends State<Hotel> {
  List<dynamic> servicosData = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchServicos();
  }

  Future<void> _fetchServicos() async {
    try {
      // Substitua pela URL real da sua API
      final response = await http.get(
        Uri.parse('https://sua-api.com/servicos/${widget.hotelData['idhospedagem']}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          servicosData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Erro ao carregar serviços: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro de conexão: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extraindo os dados da API do hotel
    final String nome = widget.hotelData['nome'] ?? 'Nome não disponível';
    final String numero = widget.hotelData['numero']?.toString() ?? '';
    final String complemento = widget.hotelData['complemento'] ?? '';
    final String logradouro = widget.hotelData['logradouro'] ?? '';
    final String bairro = widget.hotelData['bairro'] ?? '';
    final String cidade = widget.hotelData['cidade'] ?? '';
    final String estado = widget.hotelData['estado'] ?? '';

    // Construindo o endereço completo
    final enderecoCompleto = _buildEnderecoCompleto(
      numero: numero,
      complemento: complemento,
      logradouro: logradouro,
      bairro: bairro,
      cidade: cidade,
      estado: estado,
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBarReturn(route: '/core-navigation'),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.house,
                            size: 80,
                          ),
                          Text(
                            nome,
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w200,
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'Aberto',
                            style: TextStyle(
                              fontSize: 40,
                              color: Color(0xFF60F700),
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          Text(
                            '08:00 as 19:30',
                            style: TextStyle(
                              fontSize: 20,
                              color: Color(0xFF4A4A4A),
                              fontWeight: FontWeight.w100,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            enderecoCompleto,
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(
                          'há 2.5km',
                          style: TextStyle(
                            fontWeight: FontWeight.w100,
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '4.5',
                              style: TextStyle(
                                fontWeight: FontWeight.w100,
                                color: Colors.black,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(width: 5),
                            RatingStars(
                              colorStar: Colors.black,
                            ),
                          ],
                        ),
                        Text(
                          '2500 avaliações',
                          style: TextStyle(
                            fontWeight: FontWeight.w100,
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Divider(
                            color: Color(0xFFCCCCCC),
                            thickness: 1,
                          ),
                        ),
                        Text(
                          'Serviços',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w200,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 20),
                        
                        // Estado de carregamento ou erro
                        if (isLoading)
                          Center(
                            child: CircularProgressIndicator(),
                          )
                        else if (errorMessage.isNotEmpty)
                          Center(
                            child: Text(
                              errorMessage,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                            ),
                          )
                        else if (servicosData.isNotEmpty)
                          ...servicosData.map((servico) {
                            final String descricao = servico['descricao'] ?? 'Serviço';
                            final String preco = servico['preco'] ?? '0.00';
                            
                            return ServiceTemplate(
                              service: descricao,
                              price: _formatarPreco(preco),
                            );
                          }).toList()
                        else
                          Text(
                            'Nenhum serviço disponível',
                            style: TextStyle(
                              fontWeight: FontWeight.w100,
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Divider(
                      thickness: 1,
                      color: Color(0xFFCCCCCC),
                    ),
                  ),
                  Text(
                    '5 Funcionários',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w100,
                      color: Colors.black,
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        EmployeeTemplate(),
                        EmployeeTemplate(),
                        EmployeeTemplate(),
                        EmployeeTemplate(),
                        EmployeeTemplate(),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {},
                      child: IntrinsicWidth(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat,
                              size: 20,
                              color: Colors.black,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Enviar mensagem',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w200,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 50, 0, 40),
                    child: AppButton(
                      onPressed: () {
                        context.go('/choose-pet');
                      },
                      label: 'Agendar aqui',
                      fontSize: 25,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // Método auxiliar para construir o endereço completo
  String _buildEnderecoCompleto({
    required String numero,
    required String complemento,
    required String logradouro,
    required String bairro,
    required String cidade,
    required String estado,
  }) {
    final enderecoParts = [
      if (logradouro.isNotEmpty) logradouro,
      if (numero.isNotEmpty) numero,
      if (complemento.isNotEmpty) complemento,
      if (bairro.isNotEmpty) bairro,
      if (cidade.isNotEmpty) cidade,
      if (estado.isNotEmpty) estado,
    ];
    
    return enderecoParts.join(', ');
  }

  // Método para formatar o preço no padrão brasileiro
  String _formatarPreco(String preco) {
    try {
      final valor = double.tryParse(preco) ?? 0.0;
      return 'R\$${valor.toStringAsFixed(2).replaceAll('.', ',')}';
    } catch (e) {
      return 'R\$0,00';
    }
  }
}