import 'package:flutter/material.dart';
import '../../models/pet/especie_model.dart';
import '../../services/pet/especie_service.dart';

class EspecieProvider with ChangeNotifier {
  final EspecieService _especieService;
  List<Especie> _especies = [];
  bool _isLoading = false;
  String? _error;
  bool _hasLoaded = false;
  bool _isDisposed = false;

  EspecieProvider({required EspecieService especieService}) 
      : _especieService = especieService;

  List<Especie> get especies => _especies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLoaded => _hasLoaded;

  Future<void> loadEspecies({bool forceRefresh = false}) async {
    // Se já carregou e não é um refresh forçado, não carrega novamente
    if (_hasLoaded && !forceRefresh) return;
    
    if (_isDisposed) return;
    
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      final especies = await _especieService.getEspecies();
      if (_isDisposed) return;
      
      _especies = especies;
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

  // Método para forçar recarregamento
  Future<void> refreshEspecies() async {
    await loadEspecies(forceRefresh: true);
  }

  // Método seguro para notificar listeners
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