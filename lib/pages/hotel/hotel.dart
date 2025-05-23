import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/pages/hotel/template/employee/employee_template.dart';
import 'package:pet_family_app/pages/hotel/template/service_template.dart';
import 'package:pet_family_app/widgets/app_bar_return.dart';
import 'package:pet_family_app/widgets/app_button.dart';
import 'package:pet_family_app/widgets/rating_stars.dart';

class Hotel extends StatelessWidget {
  const Hotel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            AppBarReturn(),
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
                            'Hotel 1',
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
                            'Rua dos Pinguins, 24, São Bernardo do Campo, São Paulo',
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
                        ServiceTemplate(
                          service: 'Banho & tosa',
                          price: 'R\$ 50,00',
                        ),
                        ServiceTemplate(
                          service: 'Spa',
                          price: 'R\$ 150,00',
                        ),
                        ServiceTemplate(
                          service: 'Massagem',
                          price: 'R\$ 200,00',
                        ),
                        ServiceTemplate(
                          service: 'Fisioterapia',
                          price: 'R\$ 320,00',
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
}
