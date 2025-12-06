// pages/splash/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final authProvider = context.read<AuthProvider>();
    
    // Aguardar um pouco para animação
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Se o provider ainda não verificou, esperar mais
    if (!authProvider.hasCheckedAuth) {
      print('⏳ Splash: Aguardando verificação do AuthProvider...');
      await Future.delayed(const Duration(milliseconds: 1000));
    }
    
    if (authProvider.isAuthenticated) {
      print('✅ Splash: Usuário autenticado, redirecionando para home');
      if (mounted) context.go('/core-navigation');
    } else {
      print('❌ Splash: Usuário não autenticado, redirecionando para login');
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.pets,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'PetFamily',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            CircularProgressIndicator(
              color: Colors.blue[300],
            ),
            const SizedBox(height: 20),
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isLoading) {
                  return const Text(
                    'Verificando autenticação...',
                    style: TextStyle(color: Colors.grey),
                  );
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}