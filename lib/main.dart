import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_family_app/pages/forgot_password/pages/forgot_password.dart';
import 'package:pet_family_app/pages/home/home.dart';
import 'package:pet_family_app/pages/insert_token/insert_token.dart';
import 'package:pet_family_app/pages/login/login.dart';
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
      builder: (context, state) => const WantHostPet(),
      routes: [
        GoRoute(
          path: 'login',
          builder: (context, state) => const Login(),
        ),
        GoRoute(
          path: 'forgot-password',
          builder: (context, state) => const ForgotPassword(),
        ),
        GoRoute(
          path: 'insert-token',
          builder: (context, state) => const InsertToken(),
        ),
        GoRoute(
          path: 'who-many-pets',
          builder: (context, state) => const WhoManyPets(),
        ),
        GoRoute(
          path: 'insert-datas-pet',
          builder: (context, state) => const InsertDatasPet(),
        ),
        GoRoute(
          path: 'insert-your-datas',
          builder: (context, state) => const InsertYourDatas(),
        ),
        GoRoute(
          path: 'insert-your-address',
          builder: (context, state) => const InsertYourAddress(),
        ),
      ],
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const Home(),
    ),
  ],
);
