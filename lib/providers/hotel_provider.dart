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

  // Buscar serviços do hotel - CORRIGIDO
  Future<void> fetchServicos(int hotelId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      print('🔄 Buscando serviços para hospedagem ID: $hotelId');
      final servicosData = await HotelService.fetchServicos(hotelId);
      _servicos = servicosData;
      _errorMessage = '';
      print('✅ ${_servicos.length} serviços carregados com sucesso');
    } on HotelException catch (e) {
      _errorMessage = e.message;
      _servicos = [];
      print('❌ Erro ao buscar serviços: ${e.message}');
    } catch (e) {
      _errorMessage = 'Erro inesperado: ${e.toString()}';
      _servicos = [];
      print('❌ Erro inesperado: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Buscar todos os dados do hotel - CORRIGIDO
  Future<void> fetchTodosDadosHotel(int hotelId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      print('🏨 Carregando todos os dados para hospedagem ID: $hotelId');
      // Executa múltiplas requisições em paralelo
      await Future.wait([
        fetchServicos(hotelId),
        // Adicione outras chamadas aqui quando necessário
        // fetchFuncionarios(hotelId),
        // fetchDetalhesHotel(hotelId),
      ]);
      print('✅ Todos os dados carregados com sucesso');
    } catch (e) {
      _errorMessage = 'Erro ao carregar dados do hotel: ${e.toString()}';
      print('❌ Erro ao carregar dados do hotel: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Buscar funcionários do hotel (método adicional se necessário)
  Future<void> fetchFuncionarios(int hotelId) async {
    try {
      print('👥 Buscando funcionários para hospedagem ID: $hotelId');
      // Implemente a chamada para buscar funcionários quando tiver o endpoint
      // _funcionarios = await HotelService.fetchFuncionarios(hotelId);
      _funcionarios = []; // Placeholder por enquanto
    } catch (e) {
      print('❌ Erro ao buscar funcionários: $e');
      _funcionarios = [];
    }
    notifyListeners();
  }

  // Buscar detalhes do hotel (método adicional se necessário)
  Future<void> fetchDetalhesHotel(int hotelId) async {
    try {
      print('📋 Buscando detalhes da hospedagem ID: $hotelId');
      // Implemente a chamada para buscar detalhes quando tiver o endpoint
      // _hotelDetalhes = await HotelService.fetchDetalhesHotel(hotelId);
    } catch (e) {
      print('❌ Erro ao buscar detalhes do hotel: $e');
      _hotelDetalhes = null;
    }
    notifyListeners();
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
    print('🔄 Recarregando dados para hospedagem ID: $hotelId');
    await fetchTodosDadosHotel(hotelId);
  }
}
