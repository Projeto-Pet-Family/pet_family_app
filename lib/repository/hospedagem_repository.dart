import '../models/hospedagem_model.dart';
import '../services/hospedagem_service.dart';

class HospedagemRepository {
  final HospedagemService _service = HospedagemService();

  Future<List<HospedagemModel>> getHospedagens() async {
    try {
      return await _service.getHospedagens();
    } catch (error) {
      print('❌ Repository - Erro ao buscar hospedagens: $error');
      throw Exception('Erro ao buscar hospedagens: ${error.toString()}');
    }
  }

  Future<HospedagemModel> getHospedagemById(int idHospedagem) async {
    try {
      return await _service.getHospedagemById(idHospedagem);
    } catch (error) {
      print('❌ Repository - Erro ao buscar hospedagem por ID: $error');
      throw Exception('Erro ao buscar hospedagem: ${error.toString()}');
    }
  }

  Future<Map<String, dynamic>> createHospedagem(HospedagemModel hospedagem) async {
    try {
      return await _service.createHospedagem(hospedagem);
    } catch (error) {
      print('❌ Repository - Erro ao criar hospedagem: $error');
      return {
        'success': false,
        'message': 'Erro ao criar hospedagem: ${error.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateHospedagem(int idHospedagem, HospedagemModel hospedagem) async {
    try {
      return await _service.updateHospedagem(idHospedagem, hospedagem);
    } catch (error) {
      print('❌ Repository - Erro ao atualizar hospedagem: $error');
      return {
        'success': false,
        'message': 'Erro ao atualizar hospedagem: ${error.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteHospedagem(int idHospedagem) async {
    try {
      return await _service.deleteHospedagem(idHospedagem);
    } catch (error) {
      print('❌ Repository - Erro ao excluir hospedagem: $error');
      return {
        'success': false,
        'message': 'Erro ao excluir hospedagem: ${error.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> loginHospedagem(String email, String senha) async {
    try {
      return await _service.loginHospedagem(email, senha);
    } catch (error) {
      print('❌ Repository - Erro no login: $error');
      return {
        'success': false,
        'message': 'Erro no login: ${error.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> alterarSenhaHospedagem(
    int idHospedagem, 
    String senhaAtual, 
    String novaSenha
  ) async {
    try {
      return await _service.alterarSenhaHospedagem(idHospedagem, senhaAtual, novaSenha);
    } catch (error) {
      print('❌ Repository - Erro ao alterar senha: $error');
      return {
        'success': false,
        'message': 'Erro ao alterar senha: ${error.toString()}',
      };
    }
  }

  Future<HospedagemModel?> getCurrentHospedagem() async {
    try {
      return await _service.getCurrentHospedagem();
    } catch (error) {
      print('❌ Repository - Erro ao obter hospedagem atual: $error');
      return null;
    }
  }

  Future<bool> isHospedagemLoggedIn() async {
    try {
      return await _service.isHospedagemLoggedIn();
    } catch (error) {
      print('❌ Repository - Erro ao verificar login: $error');
      return false;
    }
  }

  Future<void> logoutHospedagem() async {
    try {
      await _service.logoutHospedagem();
    } catch (error) {
      print('❌ Repository - Erro ao fazer logout: $error');
      throw Exception('Erro ao fazer logout: ${error.toString()}');
    }
  }

  Future<String?> getHospedagemToken() async {
    try {
      return await _service.getHospedagemToken();
    } catch (error) {
      print('❌ Repository - Erro ao obter token: $error');
      return null;
    }
  }
}