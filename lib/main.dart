import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/navigation/bottom_navigation.dart';
import 'package:pet_family_app/pages/edit_booking/edit_booking.dart';

import 'package:pet_family_app/pages/forgot_password/pages/forgot_password.dart';
import 'package:pet_family_app/pages/hotel/hotel.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_data/choose_data.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_pet/choose_pet.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/choose_services/choose_service.dart';
import 'package:pet_family_app/pages/hotel/scheduling_accommodation/final_verification/final_verification.dart';
import 'package:pet_family_app/pages/insert_token/insert_token.dart';
import 'package:pet_family_app/pages/login/login.dart';
import 'package:pet_family_app/pages/payment/payment.dart';
import 'package:pet_family_app/pages/payment/payment_process.dart';
import 'package:pet_family_app/pages/payment/payment_sucess.dart';
import 'package:pet_family_app/pages/profile/edit/edit_pet/edit_pet.dart';
import 'package:pet_family_app/pages/profile/edit/edit_profile/edit_profile.dart';
import 'package:pet_family_app/pages/register/confirm_datas.dart';
import 'package:pet_family_app/pages/register/insert_datas_pet.dart';
import 'package:pet_family_app/pages/register/insert_your_address.dart';
import 'package:pet_family_app/pages/register/insert_your_datas.dart';
import 'package:pet_family_app/pages/register/want_host_pet.dart';
import 'package:pet_family_app/pages/register/who_many_pets.dart';

void main() {
  runApp(MaterialApp.router(
    theme: ThemeData(
      fontFamily: 'Lexend',
      textTheme: TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w300),
        bodyLarge: TextStyle(fontWeight: FontWeight.normal),
        titleMedium: TextStyle(fontWeight: FontWeight.w500),
      ),
    ),
    routerConfig: router,
  ));
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const Login(),
    ),
    GoRoute(
      path: '/want-host-pets',
      builder: (context, state) => const WantHostPet(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPassword(),
    ),
    GoRoute(
      path: '/insert-token',
      builder: (context, state) => const InsertToken(),
    ),
    GoRoute(
      path: '/who-many-pets',
      builder: (context, state) => const WhoManyPets(),
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
      builder: (context, state) => Hotel(),
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
      builder: (context, state) => EditPet(),
    ),
    GoRoute(
      path: '/edit-booking',
      builder: (context, state) => EditBooking(),
    ),
  ],
);
