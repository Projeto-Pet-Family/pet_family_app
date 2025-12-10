// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Adicione este import
import 'package:http/http.dart' as http;
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
import 'package:pet_family_app/router/app_router.dart';
import 'package:pet_family_app/providers/message/socket_service.dart';

void main() {
  // Configuração das barras do sistema ANTES de iniciar o app
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Opcional: modo de tela cheia com imersão controlada
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth Provider deve vir primeiro
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Outros providers
        ChangeNotifierProvider<HospedagemProvider>(
          create: (_) => HospedagemProvider(),
        ),
        ChangeNotifierProvider<UsuarioProvider>(
          create: (_) => UsuarioProvider(
            usuarioRepository: UsuarioRepositoryImpl(
              userService: UserService(client: http.Client()),
            ),
          ),
        ),
        ChangeNotifierProvider<PetProvider>(
          create: (_) => PetProvider(
            petRepository: PetRepositoryImpl(
              petService: PetService(client: http.Client()),
            ),
          ),
        ),
        ChangeNotifierProvider(create: (_) => SocketProvider()),
        ChangeNotifierProvider<MensagemProvider>(
          create: (_) => MensagemProvider(
            MensagemRepository(
              MensagemService(),
            ),
          ),
        ),
        ChangeNotifierProvider<EspecieProvider>(
          create: (_) => EspecieProvider(
            especieRepository: EspecieRepositoryImpl(
              especieService: EspecieService(client: http.Client()),
            ),
          ),
        ),
        ChangeNotifierProvider<RacaProvider>(
          create: (_) => RacaProvider(
            racaRepository: RacaRepositoryImpl(
              racaService: RacaService(client: http.Client()),
            ),
          ),
        ),
        ChangeNotifierProvider<PorteProvider>(
          create: (_) => PorteProvider(
            porteRepository: PorteRepositoryImpl(
              porteService: PorteService(client: http.Client()),
            ),
          ),
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'Lexend',
              textTheme: const TextTheme(
                displayLarge: TextStyle(fontWeight: FontWeight.w300),
                bodyLarge: TextStyle(fontWeight: FontWeight.normal),
                titleMedium: TextStyle(fontWeight: FontWeight.w500),
              ),
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                elevation: 0,
                systemOverlayStyle: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarIconBrightness: Brightness.dark,
                ),
              ),
            ),
            // AQUI ESTÁ O AJUSTE CRÍTICO
            builder: (context, router) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.dark,
                  systemNavigationBarColor: Colors.transparent,
                  systemNavigationBarIconBrightness: Brightness.dark,
                  // Para Android 10+ com tema escuro automático
                  statusBarBrightness:
                      MediaQuery.of(context).platformBrightness,
                ),
                child: MediaQuery(
                  // Remove o padding do topo do MediaQuery
                  data: MediaQuery.of(context).copyWith(
                    viewPadding: EdgeInsets.only(
                      top: 0, // Remove o padding do topo
                      bottom: MediaQuery.of(context).viewPadding.bottom,
                      left: MediaQuery.of(context).viewPadding.left,
                      right: MediaQuery.of(context).viewPadding.right,
                    ),
                  ),
                  child: SafeArea(
                    // SafeArea apenas no topo
                    top: true,
                    bottom: false,
                    left: false,
                    right: false,
                    minimum: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                    ),
                    child: router ?? const SizedBox(),
                  ),
                ),
              );
            },
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
