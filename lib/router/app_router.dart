// router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/pages/splash_screen.dart/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/providers/auth_provider.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/pages/login/login.dart';
import 'package:pet_family_app/navigation/bottom_navigation.dart';
import 'package:pet_family_app/pages/forgot_password/pages/forgot_password.dart';
import 'package:pet_family_app/pages/register/insert_datas_pet.dart';
import 'package:pet_family_app/pages/register/insert_your_datas.dart';
import 'package:pet_family_app/pages/register/insert_your_address.dart';
import 'package:pet_family_app/pages/register/confirm_datas.dart';
import 'package:pet_family_app/pages/hotel/hotel.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_data/choose_data.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_pet/choose_pet.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_services/choose_service.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/final_verification.dart';
import 'package:pet_family_app/pages/payment/payment.dart';
import 'package:pet_family_app/pages/payment/payment_process.dart';
import 'package:pet_family_app/pages/payment/payment_sucess.dart';
import 'package:pet_family_app/pages/profile/edit/edit_pet/edit_pet.dart';
import 'package:pet_family_app/pages/profile/edit/edit_profile/edit_profile.dart';
import 'package:pet_family_app/pages/profile/profile.dart';
import 'package:pet_family_app/pages/edit_booking/edit_booking.dart';
import 'package:pet_family_app/pages/message/message.dart';

class AppRouter {
  static GoRouter get router => _router;

  static final GoRouter _router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    redirect: (context, state) {
      // Ignorar redirecionamento para a SplashScreen
      if (state.uri.path == '/') {
        return null;
      }
      
      print('\n🔄 Router Redirect chamado');
      print('📍 Localização solicitada: ${state.uri.path}');
      
      final authProvider = context.read<AuthProvider>();
      
      print('🔐 Provider Status:');
      print('   • isAuthenticated: ${authProvider.isAuthenticated}');
      print('   • hasCheckedAuth: ${authProvider.hasCheckedAuth}');
      print('   • isLoading: ${authProvider.isLoading}');

      // Se ainda não verificou autenticação, não redirecionar (a SplashScreen cuida disso)
      if (!authProvider.hasCheckedAuth) {
        print('⏳ Aguardando verificação de autenticação...');
        return null;
      }

      // Lista de rotas públicas (não requerem autenticação)
      final publicRoutes = [
        '/login',
        '/forgot-password',
        '/insert-datas-pet',
        '/insert-your-datas',
        '/insert-your-address',
        '/confirm-your-datas',
      ];

      // Verificar se a rota atual é pública
      final isPublicRoute = publicRoutes.any((route) => 
          state.uri.path == route || state.uri.path.startsWith('$route/'));

      // Se usuário está autenticado e tenta acessar rota pública
      if (authProvider.isAuthenticated && isPublicRoute) {
        print('✅ Usuário já autenticado, redirecionando para home...');
        return '/core-navigation';
      }

      // Se usuário NÃO está autenticado e tenta acessar rota privada
      if (!authProvider.isAuthenticated && !isPublicRoute) {
        print('❌ Usuário não autenticado, redirecionando para login...');
        return '/login';
      }

      print('✅ Redirecionamento aprovado para: ${state.uri.path}');
      return null; // Permite acesso à rota
    },
    routes: [
      // Rota raiz - SplashScreen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Rotas públicas (não requerem autenticação)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const Login(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPassword(),
      ),
      GoRoute(
        path: '/insert-datas-pet',
        name: 'insert-datas-pet',
        builder: (context, state) => const InsertDatasPet(),
      ),
      GoRoute(
        path: '/insert-your-datas',
        name: 'insert-your-datas',
        builder: (context, state) => const InsertYourDatas(),
      ),
      GoRoute(
        path: '/insert-your-address',
        name: 'insert-your-address',
        builder: (context, state) => const InsertYourAddress(),
      ),
      GoRoute(
        path: '/confirm-your-datas',
        name: 'confirm-your-datas',
        builder: (context, state) => const ConfirmYourDatas(),
      ),
      
      // Rotas privadas (requerem autenticação)
      GoRoute(
        path: '/core-navigation',
        name: 'core-navigation',
        builder: (context, state) => const CoreNavigation(),
      ),
      GoRoute(
        path: '/hotel',
        name: 'hotel',
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
        name: 'choose-pet',
        builder: (context, state) => const ChoosePet(),
      ),
      GoRoute(
        path: '/choose-data',
        name: 'choose-data',
        builder: (context, state) => const ChooseData(),
      ),
      GoRoute(
        path: '/choose-service',
        name: 'choose-service',
        builder: (context, state) => const ChooseService(),
      ),
      GoRoute(
        path: '/final-verification',
        name: 'final-verification',
        builder: (context, state) => const FinalVerification(),
      ),
      GoRoute(
        path: '/payment',
        name: 'payment',
        builder: (context, state) => const PaymentScreen(),
      ),
      GoRoute(
        path: '/payment-process',
        name: 'payment-process',
        builder: (context, state) => const PaymentProcessingScreen(),
      ),
      GoRoute(
        path: '/payment-sucess',
        name: 'payment-sucess',
        builder: (context, state) => const PaymentSuccessScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfile(),
      ),
      GoRoute(
        path: '/edit-pet',
        name: 'edit-pet',
        builder: (context, state) => const EditPet(),
      ),
      GoRoute(
        path: '/edit-booking',
        name: 'edit-booking',
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
        name: 'profile',
        builder: (context, state) => const Profile(),
      ),
      GoRoute(
        path: '/message',
        name: 'message',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return Message(
            idusuario: extra['idusuario'] ?? 0,
            nomeHospedagem: extra['nomeHospedagem'] ?? 'Hospedagem',
            idhospedagem: extra['idhospedagem'] ?? 0,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'Página não encontrada',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'A rota "${state.uri.path}" não existe.',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home),
              label: const Text('Voltar para Home'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}