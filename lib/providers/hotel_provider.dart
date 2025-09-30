import 'package:flutter/foundation.dart';
import '../services/hotel_service.dart';

class HotelProvider with ChangeNotifier {
  List<dynamic> _servicos = [];
  List<dynamic> _funcionarios = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic>? _hotelDetalhes;

  // Getters
  List<dynamic> get servicos => _servicos;
  List<dynamic> get funcionarios => _funcionarios;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get hotelDetalhes => _hotelDetalhes;

  // Buscar serviços do hotel
  Future<void> fetchServicos(int hotelId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final servicosData = await HotelService.fetchServicos(hotelId);
      _servicos = servicosData;
      _errorMessage = '';
    } on HotelException catch (e) {
      _errorMessage = e.message;
      _servicos = [];
    } catch (e) {
      _errorMessage = 'Erro inesperado: ${e.toString()}';
      _servicos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Buscar todos os dados do hotel
  Future<void> fetchTodosDadosHotel(int hotelId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Executa múltiplas requisições em paralelo
      await Future.wait([
        fetchServicos(hotelId),
        // Adicione outras chamadas aqui se necessário
      ]);
    } catch (e) {
      _errorMessage = 'Erro ao carregar dados do hotel: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpar dados
  void clearData() {
    _servicos = [];
    _funcionarios = [];
    _hotelDetalhes = null;
    _errorMessage = '';
    notifyListeners();
  }

  // Limpar erro
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // Recarregar dados
  Future<void> recarregarDados(int hotelId) async {
    await fetchTodosDadosHotel(hotelId);
  }
}
