// presentation/providers/hospedagem_provider.dart
import 'package:flutter/foundation.dart';
import 'package:pet_family_app/models/service_model.dart';
import 'package:pet_family_app/repository/service_repository.dart';
import 'package:pet_family_app/services/service_service.dart';
import 'package:http/http.dart' as http;

class HospedagemProvider with ChangeNotifier {
  List<ServiceModel> _servicos = [];
  bool _loading = false;
  String? _error;
  Map<String, dynamic>? _hotelData;

  HospedagemProvider();

  // Getters
  List<ServiceModel> get servicos => _servicos;
  bool get isLoading => _loading;
  String? get error => _error;
  Map<String, dynamic>? get hotelData => _hotelData;

  // Set hotel data
  void setHotelData(Map<String, dynamic> hotelData) {
    _hotelData = hotelData;
    notifyListeners();
  }

  // Carregar serviços da hospedagem
  Future<void> carregarServicos(int idHospedagem) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 HospedagemProvider: Carregando serviços para ID $idHospedagem');
      
      final serviceService = ServiceService(client: http.Client());
      final servicosCarregados = await serviceService.listarServicosPorHospedagem(idHospedagem);
      
      // Filtra serviços válidos
      _servicos = servicosCarregados.where((servico) {
        return servico.descricao.isNotEmpty && servico.preco > 0;
      }).toList();
      
      _error = null;
      
      print('✅ ${_servicos.length} serviços carregados para hospedagem $idHospedagem');
      
    } catch (e) {
      _error = 'Erro ao carregar serviços: ${e.toString()}';
      _servicos = [];
      print('❌ Erro ao carregar serviços: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Carregar serviços automaticamente baseado no hotelData
  Future<void> carregarServicosDoHotel() async {
    if (_hotelData == null || _hotelData!['idhospedagem'] == null) {
      _error = 'Hotel não selecionado';
      notifyListeners();
      return;
    }
    
    final hotelId = _hotelData!['idhospedagem'] as int;
    await carregarServicos(hotelId);
  }

  // Limpar serviços
  void limparServicos() {
    _servicos.clear();
    notifyListeners();
  }

  // Limpar todos os dados
  void limparDados() {
    _servicos.clear();
    _hotelData = null;
    _error = null;
    notifyListeners();
  }
}