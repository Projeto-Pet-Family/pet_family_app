import 'package:flutter/material.dart';
import '../../models/pet/porte_model.dart';
import '../../services/pet/porte_service.dart';

class PorteProvider with ChangeNotifier {
  final PorteService _porteService;
  List<Porte> _portes = [];
  bool _isLoading = false;
  String? _error;
  bool _hasLoaded = false;
  bool _isDisposed = false;

  PorteProvider({required PorteService porteService}) 
      : _porteService = porteService;

  List<Porte> get portes => _portes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasLoaded => _hasLoaded;

  Future<void> loadPortes({bool forceRefresh = false}) async {
    if (_hasLoaded && !forceRefresh) return;
    
    if (_isDisposed) return;
    
    _isLoading = true;
    _error = null;
    _safeNotifyListeners();

    try {
      final portes = await _porteService.getPortes();
      if (_isDisposed) return;
      
      _portes = portes;
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

  Future<void> refreshPortes() async {
    await loadPortes(forceRefresh: true);
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