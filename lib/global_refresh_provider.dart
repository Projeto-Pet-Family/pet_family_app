import 'package:flutter/material.dart';
import 'package:pet_family_app/providers/auth_provider.dart';
import 'package:pet_family_app/providers/message_provider.dart';
import 'package:pet_family_app/providers/pet/especie_provider.dart';
import 'package:pet_family_app/providers/pet/pet_provider.dart';
import 'package:pet_family_app/providers/pet/porte_provider.dart';
import 'package:pet_family_app/providers/pet/raca_provider.dart';
import 'package:pet_family_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class GlobalRefreshProvider extends ChangeNotifier {
  bool _isRefreshing = false;
  DateTime? _lastRefreshTime;
  
  bool get isRefreshing => _isRefreshing;
  DateTime? get lastRefreshTime => _lastRefreshTime;
  
  // Método para acionar refresh em todos os providers
  Future<void> refreshAll(BuildContext context) async {
    if (_isRefreshing) return;
    
    _isRefreshing = true;
    notifyListeners();
    
    try {
      print('🔄 Iniciando refresh global...');
      
      // Atualiza todos os providers em paralelo
      await Future.wait([
        _refreshAuth(context),
        _refreshUser(context),
        _refreshPets(context),
        _refreshMessages(context),
        _refreshSpecies(context),
        _refreshBreeds(context),
        _refreshSizes(context),
      ]);
      
      _lastRefreshTime = DateTime.now();
      print('✅ Refresh global concluído!');
      
    } catch (e) {
      print('❌ Erro no refresh global: $e');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }
  
  Future<void> _refreshAuth(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      await auth.loadUserData();
    }
  }
  
  Future<void> _refreshUser(BuildContext context) async {
    final userProvider = context.read<UsuarioProvider>();
    await userProvider.loadUserData();
  }
  
  Future<void> _refreshPets(BuildContext context) async {
    final petProvider = context.read<PetProvider>();
    await petProvider.listarPets();
  }
  
  Future<void> _refreshMessages(BuildContext context) async {
    final messageProvider = context.read<MensagemProvider>();
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UsuarioProvider>();
    int? userId;
    if (authProvider.usuarioId != null) {
      userId = authProvider.usuarioId;
    } else if (userProvider.idUsuarioAtual != null) {
      userId = userProvider.idUsuarioAtual;
    } else if (authProvider.usuario?.idUsuario != null) {
      userId = authProvider.usuario?.idUsuario;
    } else if (userProvider.usuarioLogado?.idUsuario != null) {
      userId = userProvider.usuarioLogado?.idUsuario;
    }
    await messageProvider.carregarTodasConversas(idUsuario: userId!);
  }
  
  Future<void> _refreshSpecies(BuildContext context) async {
    final speciesProvider = context.read<EspecieProvider>();
    await speciesProvider.listarEspecies();
  }
  
  Future<void> _refreshBreeds(BuildContext context) async {
    final breedProvider = context.read<RacaProvider>();
    await breedProvider.listarRacas();
  }
  
  Future<void> _refreshSizes(BuildContext context) async {
    final sizeProvider = context.read<PorteProvider>();
    await sizeProvider.listarPortes();
  }
  
  // Método para forçar refresh
  void forceRefresh(BuildContext context) {
    refreshAll(context);
  }
}