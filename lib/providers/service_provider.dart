// presentation/providers/service_provider.dart
import 'package:flutter/foundation.dart';
import 'package:pet_family_app/models/service_model.dart';
import 'package:pet_family_app/repository/service_repository.dart';

class ServiceProvider with ChangeNotifier {
  final ServiceRepository serviceRepository;

  List<ServiceModel> _servicos = [];
  ServiceModel? _servicoSelecionado;
  bool _loading = false;
  String? _error;
  bool _success = false;

  ServiceProvider({required this.serviceRepository});

  // Getters
  List<ServiceModel> get servicos => _servicos;
  ServiceModel? get servicoSelecionado => _servicoSelecionado;
  bool get loading => _loading;
  String? get error => _error;
  bool get success => _success;

  // Listar serviços por hospedagem
  Future<void> listarServicosPorHospedagem(int idHospedagem) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 ServiceProvider: Listando serviços para hospedagem $idHospedagem');
      
      _servicos = await serviceRepository.listarServicosPorHospedagem(idHospedagem);
      _error = null;
      
      print('✅ ${_servicos.length} serviços carregados');
      
    } catch (e) {
      _error = e.toString();
      _servicos = [];
      print('❌ Erro ao listar serviços: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Criar serviço
  Future<void> criarServico(int idHospedagem, ServiceModel servico) async {
    _loading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      print('🔄 ServiceProvider: Criando serviço...');
      print('📝 Dados do serviço: ${servico.toJson()}');
      
      final servicoCriado = await serviceRepository.criarServico(idHospedagem, servico);
      
      // Adiciona à lista local
      _servicos.add(servicoCriado);
      _success = true;
      
      print('✅ Serviço criado com sucesso! ID: ${servicoCriado.idservico}');
      
    } catch (e) {
      _error = e.toString();
      _success = false;
      print('❌ Erro ao criar serviço: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Atualizar serviço
  Future<void> atualizarServico(ServiceModel servico) async {
    _loading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      print('🔄 ServiceProvider: Atualizando serviço ${servico.idservico}');
      
      final servicoAtualizado = await serviceRepository.atualizarServico(servico);
      
      // Atualiza na lista local
      final index = _servicos.indexWhere((s) => s.idservico == servico.idservico);
      if (index != -1) {
        _servicos[index] = servicoAtualizado;
      }
      
      // Atualiza serviço selecionado se for o mesmo
      if (_servicoSelecionado?.idservico == servico.idservico) {
        _servicoSelecionado = servicoAtualizado;
      }
      
      _success = true;
      
      print('✅ Serviço atualizado com sucesso!');
      
    } catch (e) {
      _error = e.toString();
      _success = false;
      print('❌ Erro ao atualizar serviço: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Remover serviço
  Future<void> removerServico(int idServico) async {
    _loading = true;
    _error = null;
    _success = false;
    notifyListeners();

    try {
      print('🔄 ServiceProvider: Removendo serviço $idServico');
      
      await serviceRepository.removerServico(idServico);
      
      // Remove da lista local
      _servicos.removeWhere((s) => s.idservico == idServico);
      
      // Limpa serviço selecionado se for o mesmo
      if (_servicoSelecionado?.idservico == idServico) {
        _servicoSelecionado = null;
      }
      
      _success = true;
      
      print('✅ Serviço removido com sucesso!');
      
    } catch (e) {
      _error = e.toString();
      _success = false;
      print('❌ Erro ao remover serviço: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Selecionar serviço
  void selecionarServico(ServiceModel servico) {
    _servicoSelecionado = servico;
    notifyListeners();
  }

  // Limpar seleção
  void limparSelecao() {
    _servicoSelecionado = null;
    notifyListeners();
  }

  // Buscar serviço por ID
  ServiceModel? buscarServicoPorId(int idServico) {
    return _servicos.firstWhere(
      (servico) => servico.idservico == idServico,
      orElse: () => throw Exception('Serviço não encontrado'),
    );
  }

  // Calcular total dos serviços
  double calcularTotalServicos() {
    return _servicos.fold(0.0, (total, servico) => total + servico.preco);
  }

  // Limpar estados
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSuccess() {
    _success = false;
    notifyListeners();
  }

  // Limpar dados
  void limparDados() {
    _servicos.clear();
    _servicoSelecionado = null;
    notifyListeners();
  }
}