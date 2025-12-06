// router/auth_guard.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pet_family_app/providers/auth_provider.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  
  const AuthGuard({super.key, required this.child});
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus(context, authProvider);
    });
    
    return child;
  }
  
  void _checkAuthStatus(BuildContext context, AuthProvider authProvider) async {
    // Aguardar um pouco para garantir que o provider foi inicializado
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Verificar se está autenticado
    if (!authProvider.isAuthenticated) {
      // Redirecionar para login se não estiver autenticado
      if (ModalRoute.of(context)?.settings.name != '/login') {
        context.go('/login');
      }
    }
  }
}