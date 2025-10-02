import 'package:flutter/material.dart';
import '../../models/pet/raca_model.dart';
import '../../services/pet/raca_service.dart';

class RacaProvider with ChangeNotifier {
  final RacaService _racaService;
  List<Raca> _racas = [];
  bool _isLoading = false;
  String? _error;
  bool _hasLoaded = false;
  bool _isDisposed = false;

  RacaProvider({required RacaService racaService}) 
      : _racaService = racaService;

  List<Raca> get racas => _racas;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLoaded => _hasLoaded;

  Future<void> loadRacas({bool forceRefresh = false}) async {
    if (_hasLoaded && !forceRefresh) return;
    
    if (_isDisposed) return;
    
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      final racas = await _racaService.getRacas();
      if (_isDisposed) return;
      
      _racas = racas;
      _hasLoaded = true;
      _error = null;
    } catch (e) {
      if (_isDisposed) return;
      _error = e.toString();
      _hasLoaded = false;
    } finally {
      if (!_isDisposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  void clearError() {
    if (_isDisposed) return;
    _error = null;
    _safeNotifyListeners();
  }

  Future<void> refreshRacas() async {
    await loadRacas(forceRefresh: true);
  }

  void _safeNotifyListeners() {
    if (!_isDisposed && hasListeners) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && hasListeners) {
          notifyListeners();
        }
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}