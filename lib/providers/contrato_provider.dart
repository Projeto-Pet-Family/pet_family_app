// providers/contrato_provider.dart

import 'package:flutter/foundation.dart';
import 'package:pet_family_app/models/contrato_model.dart';
import 'package:pet_family_app/repository/contrato_repository.dart';

class ContratoProvider with ChangeNotifier {
  final ContratoRepository contratoRepository;
  
  List<ContratoModel> _contratos = [];
  ContratoModel? _contratoSelecionado;
  bool _loading = false;
  String? _error;
  bool _success = false;
  
  ContratoProvider({required this.contratoRepository});
  
  // Getters
  List<ContratoModel> get contratos => _contratos;
  ContratoModel? get contratoSelecionado => _contratoSelecionado;
  bool get loading => _loading;
  String? get error => _error;
  bool get success => _success;
  
  // Setters
  void setContratoSelecionado(ContratoModel? contrato) {
    _contratoSelecionado = contrato;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void clearSuccess() {
    _success = false;
    notifyListeners();
  }
  
  // 1. Calcular valor do contrato
  Future<Map<String, dynamic>> calcularValorContrato({
    required int idHospedagem,
    required String dataInicio,
    required String dataFim,
    List<Map<String, dynamic>>? servicos,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final resultado = await contratoRepository.calcularValorContrato(
        idHospedagem: idHospedagem,
        dataInicio: dataInicio,
        dataFim: dataFim,
        servicos: servicos,
      );
      
      _loading = false;
      notifyListeners();
      return resultado;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // 2. Criar contrato
  Future<void> criarContrato({
    required int idHospedagem,
    required int idUsuario,
    required String dataInicio,
    required String dataFim,
    required List<int> pets,
    List<Map<String, dynamic>>? servicos,
    String status = 'em_aprovacao',
  }) async {
    _loading = true;
    _error = null;
    _success = false;
    notifyListeners();
    
    try {
      final contrato = await contratoRepository.criarContrato(
        idHospedagem: idHospedagem,
        idUsuario: idUsuario,
        dataInicio: dataInicio,
        dataFim: dataFim,
        pets: pets,
        servicos: servicos,
        status: status,
      );
      
      _contratos.add(contrato);
      _contratoSelecionado = contrato;
      _success = true;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _success = false;
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // 3. Buscar contrato por ID
  Future<void> buscarContratoPorId(int idContrato) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final contrato = await contratoRepository.buscarContratoPorId(idContrato);
      _contratoSelecionado = contrato;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // 4. Listar contratos do usuário
  Future<void> listarContratosPorUsuario(int idUsuario) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final contratos = await contratoRepository.listarContratosPorUsuario(idUsuario);
      _contratos = contratos;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // 5. Listar contratos por status
  Future<void> listarContratosPorUsuarioEStatus(int idUsuario, String status) async {
    _loading = true;
    _error = null;
    notifyListeners();
    
    try {
      final contratos = await contratoRepository.listarContratosPorUsuarioEStatus(
        idUsuario, 
        status,
      );
      _contratos = contratos;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // 6. Atualizar status
  Future<void> atualizarStatusContrato({
    required int idContrato,
    required String status,
    String? motivo,
  }) async {
    _loading = true;
    _error = null;
    _success = false;
    notifyListeners();
    
    try {
      final contratoAtualizado = await contratoRepository.atualizarStatusContrato(
        idContrato: idContrato,
        status: status,
        motivo: motivo,
      );
      
      // Atualizar na lista
      final index = _contratos.indexWhere((c) => c.idContrato == idContrato);
      if (index != -1) {
        _contratos[index] = contratoAtualizado;
      }
      
      // Atualizar contrato selecionado se for o mesmo
      if (_contratoSelecionado?.idContrato == idContrato) {
        _contratoSelecionado = contratoAtualizado;
      }
      
      _success = true;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _success = false;
      _loading = false;
      notifyListeners();
      rethrow;
    }
  }
  
  // 7. Filtrar contratos por status
  List<ContratoModel> filtrarContratosPorStatus(String status) {
    return _contratos.where((contrato) => contrato.status == status).toList();
  }
  
  // 8. Estatísticas
  Map<String, dynamic> get estatisticas {
    final total = _contratos.length;
    final ativos = filtrarContratosPorStatus('em_execucao').length;
    final pendentes = filtrarContratosPorStatus('em_aprovacao').length;
    final concluidos = filtrarContratosPorStatus('concluido').length;
    
    return {
      'total': total,
      'ativos': ativos,
      'pendentes': pendentes,
      'concluidos': concluidos,
      'valor_total': _contratos.fold(0.0, (sum, contrato) {
        return sum + (contrato.valorTotal ?? 0);
      }),
    };
  }
  
  // 9. Limpar dados
  void limparDados() {
    _contratos = [];
    _contratoSelecionado = null;
    _error = null;
    _success = false;
    notifyListeners();
  }
}