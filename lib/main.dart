import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/pages/message/message.dart';
import 'package:pet_family_app/providers/hospedagem_provider.dart';
import 'package:pet_family_app/providers/message_provider.dart';
import 'package:pet_family_app/providers/pet/especie_provider.dart';
import 'package:pet_family_app/providers/pet/porte_provider.dart';
import 'package:pet_family_app/providers/pet/raca_provider.dart';
import 'package:pet_family_app/providers/user_provider.dart';
import 'package:pet_family_app/repository/message_repository.dart';
import 'package:pet_family_app/repository/pet/especie_repository.dart';
import 'package:pet_family_app/repository/pet/pet_repository.dart';
import 'package:pet_family_app/repository/pet/porte_repository.dart';
import 'package:pet_family_app/repository/pet/raca_repository.dart';
import 'package:pet_family_app/repository/user_repository.dart';
import 'package:pet_family_app/services/message_service.dart';
import 'package:pet_family_app/services/pet/especie_service.dart';
import 'package:pet_family_app/services/pet/pet_service.dart';
import 'package:pet_family_app/services/pet/porte_service.dart';
import 'package:pet_family_app/services/pet/raca_service.dart';
import 'package:pet_family_app/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/providers/auth_provider.dart';
import 'package:pet_family_app/providers/pet/pet_provider.dart';

// Pages
import 'package:pet_family_app/navigation/bottom_navigation.dart';
import 'package:pet_family_app/pages/edit_booking/edit_booking.dart';
import 'package:pet_family_app/pages/forgot_password/pages/forgot_password.dart';
import 'package:pet_family_app/pages/hotel/hotel.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_data/choose_data.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_pet/choose_pet.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_services/choose_service.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/final_verification.dart';
import 'package:pet_family_app/pages/login/login.dart';
import 'package:pet_family_app/pages/payment/payment.dart';
import 'package:pet_family_app/pages/payment/payment_process.dart';
import 'package:pet_family_app/pages/payment/payment_sucess.dart';
import 'package:pet_family_app/pages/profile/edit/edit_pet/edit_pet.dart';
import 'package:pet_family_app/pages/profile/edit/edit_profile/edit_profile.dart';
import 'package:pet_family_app/pages/profile/profile.dart';
import 'package:pet_family_app/pages/register/confirm_datas.dart';
import 'package:pet_family_app/pages/register/insert_datas_pet.dart';
import 'package:pet_family_app/pages/register/insert_your_address.dart';
import 'package:pet_family_app/pages/register/insert_your_datas.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Providers principais
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HotelProvider()),

        // User Provider
        ChangeNotifierProvider<UsuarioProvider>(
          create: (_) => UsuarioProvider(
            usuarioRepository: UsuarioRepositoryImpl(
              userService: UserService(client: http.Client()),
            ),
          ),
        ),

        // Pet Provider
        ChangeNotifierProvider<PetProvider>(
          create: (_) => PetProvider(
            petRepository: PetRepositoryImpl(
              petService: PetService(client: http.Client()),
            ),
          ),
        ),

        // Message Provider
        ChangeNotifierProvider<MensagemProvider>(
          create: (_) => MensagemProvider(
            MensagemRepository(
              MensagemService(),
            ),
          ),
        ),

        // Especie Provider (simplificado)
        ChangeNotifierProvider<EspecieProvider>(
          create: (_) => EspecieProvider(
            especieRepository: EspecieRepositoryImpl(
              especieService: EspecieService(client: http.Client()),
            ),
          ),
        ),

        // Raca Provider (simplificado)
        ChangeNotifierProvider<RacaProvider>(
          create: (_) => RacaProvider(
            racaRepository: RacaRepositoryImpl(
              racaService: RacaService(client: http.Client()),
            ),
          ),
        ),

        // Porte Provider (simplificado)
        ChangeNotifierProvider<PorteProvider>(
          create: (_) => PorteProvider(
            porteRepository: PorteRepositoryImpl(
              porteService: PorteService(client: http.Client()),
            ),
          ),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Lexend',
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontWeight: FontWeight.w300),
            bodyLarge: TextStyle(fontWeight: FontWeight.normal),
            titleMedium: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        routerConfig: router,
      ),
    );
  }
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Login(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPassword(),
    ),
    GoRoute(
      path: '/insert-datas-pet',
      builder: (context, state) => const InsertDatasPet(),
    ),
    GoRoute(
      path: '/insert-your-datas',
      builder: (context, state) => const InsertYourDatas(),
    ),
    GoRoute(
      path: '/insert-your-address',
      builder: (context, state) => const InsertYourAddress(),
    ),
    GoRoute(
      path: '/confirm-your-datas',
      builder: (context, state) => const ConfirmYourDatas(),
    ),
    GoRoute(
      path: '/core-navigation',
      builder: (context, state) => const CoreNavigation(),
    ),
    GoRoute(
      path: '/hotel',
      builder: (context, state) {
        final hotelData = state.extra as Map<String, dynamic>?;

        print('=== HOTEL ROUTE ===');
        print('Hotel data received: ${hotelData != null}');
        if (hotelData != null) {
          print('Hotel ID: ${hotelData['idhospedagem']}');
          print('Hotel Name: ${hotelData['nome']}');
        }

        return Hotel(hotelData: hotelData);
      },
    ),
    GoRoute(
      path: '/choose-pet',
      builder: (context, state) => ChoosePet(),
    ),
    GoRoute(
      path: '/choose-data',
      builder: (context, state) => ChooseData(),
    ),
    GoRoute(
      path: '/choose-service',
      builder: (context, state) => ChooseService(),
    ),
    GoRoute(
      path: '/final-verification',
      builder: (context, state) => FinalVerification(),
    ),
    GoRoute(
      path: '/payment',
      builder: (context, state) => PaymentScreen(),
    ),
    GoRoute(
      path: '/payment-process',
      builder: (context, state) => PaymentProcessingScreen(),
    ),
    GoRoute(
      path: '/payment-sucess',
      builder: (context, state) => PaymentSuccessScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => EditProfile(),
    ),
    GoRoute(
      path: '/edit-pet',
      builder: (context, state) {
        return const EditPet();
      },
    ),
    GoRoute(
      path: '/edit-booking',
      builder: (context, state) {
        final contrato = state.extra as ContratoModel?;

        if (contrato == null) {
          return Scaffold(
            body: Center(
              child: Text('Erro: Contrato não encontrado'),
            ),
          );
        }

        return EditBooking(contrato: contrato);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const Profile(),
    ),
    GoRoute(
      path: '/message',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return Message(
          idusuario: extra['idusuario'] ?? 0,
          nomeHospedagem: extra['nomeHospedagem'] ?? 'Hospedagem',
          idhospedagem: extra['idhospedagem'] ?? 0,
        );
      },
    )
  ],
);
