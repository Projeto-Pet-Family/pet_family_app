// services/via_cep_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/via_cep_model.dart';

class ViaCepService {
  // Usando BrasilAPI como primeiro serviço, com fallback para ViaCEP
  static const String _brasilApiUrl = 'https://brasilapi.com.br/api/cep/v1/';
  static const String _viaCepUrl = 'https://viacep.com.br/ws/';

  static Future<ViaCepModel?> fetchAddress(String cep) async {
    // Remove formatação do CEP
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanCep.length != 8) {
      return ViaCepModel(
        cep: cep,
        logradouro: '',
        complemento: '',
        bairro: '',
        localidade: '',
        uf: '',
        erro: 'CEP deve conter 8 dígitos',
      );
    }

    // Tenta primeiro a BrasilAPI
    try {
      final response = await http
          .get(Uri.parse('$_brasilApiUrl$cleanCep'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Verifica se a BrasilAPI retornou erro
        if (data.containsKey('errors')) {
          // Se falhar, tenta o ViaCEP
          return await _tryViaCep(cleanCep);
        }
        return ViaCepModel.fromJson(data);
      }
    } catch (e) {
      // Se falhar, tenta o ViaCEP
      return await _tryViaCep(cleanCep);
    }

    return null;
  }

  static Future<ViaCepModel?> _tryViaCep(String cep) async {
    try {
      final response = await http
          .get(Uri.parse('$_viaCepUrl$cep/json/'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ViaCepModel.fromJson(data);
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}