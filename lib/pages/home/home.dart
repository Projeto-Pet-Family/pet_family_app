import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/navigation/bottom_navigation.dart';
import 'package:pet_family_app/pages/home/widgets/home_buttons.dart';
import 'package:pet_family_app/providers/auth_provider.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  // Função para extrair apenas o primeiro nome
  String _extrairPrimeiroNome(String nomeCompleto) {
    if (nomeCompleto.isEmpty || nomeCompleto == 'Tutor') {
      return 'Tutor';
    }

    // Remove espaços extras e divide pelo primeiro espaço
    final nomeLimpo = nomeCompleto.trim();
    final partes = nomeLimpo.split(' ');

    // Retorna a primeira parte (primeiro nome)
    return partes.first;
  }

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
                  SizedBox.shrink(),
                  Text('PetFamily'),
                  SizedBox.shrink(),
                ],
              ),
              SizedBox(height: 20),

              // ✅ Selector com formatação do primeiro nome
              Selector<AuthProvider, String>(
                selector: (context, authProvider) {
                  final nomeCompleto =
                      authProvider.usuario?.nome ?? 'Tutor';
                  return _extrairPrimeiroNome(nomeCompleto);
                },
                builder: (context, primeiroNome, child) {
                  return Text(
                    'Bem vindo, $primeiroNome',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w200,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFFCCCCCC),
                      decorationThickness: 1,
                    ),
                  );
                },
              ),

              SizedBox(height: 60),
              HomeButtons(
                onTap: () {
                  CoreNavigation.of(context)?.changePage(1);
                },
                title: 'Hospedagens',
                titleSize: 25,
                icon: Icons.house,
                iconSize: 40,
                width: 330,
                height: 80,
                radius: 50,
              ),
              SizedBox(height: 20),
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
      ),
    );
  }
}
