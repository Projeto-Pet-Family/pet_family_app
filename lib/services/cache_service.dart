// lib/services/cache_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _keyIdHospedagem = 'id_hospedagem';
  static const String _keyIdUsuario = 'id_usuario';
  static const String _keyHospedagemNome = 'hospedagem_nome';
  static const String _keyContratoId = 'contrato_id';

  static Future<void> salvarDadosConversa({
    required int idHospedagem,
    required int idUsuario,
    required String hospedagemNome,
    String? contratoId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt(_keyIdHospedagem, idHospedagem);
    await prefs.setInt(_keyIdUsuario, idUsuario);
    await prefs.setString(_keyHospedagemNome, hospedagemNome);
    
    if (contratoId != null) {
      await prefs.setString(_keyContratoId, contratoId);
    }
    
    print('💾 Dados salvos no cache:');
    print('💾 idHospedagem: $idHospedagem');
    print('💾 idUsuario: $idUsuario');
    print('💾 hospedagemNome: $hospedagemNome');
    print('💾 contratoId: $contratoId');
  }

  static Future<Map<String, dynamic>?> carregarDadosConversa() async {
    final prefs = await SharedPreferences.getInstance();
    
    final idHospedagem = prefs.getInt(_keyIdHospedagem);
    final idUsuario = prefs.getInt(_keyIdUsuario);
    final hospedagemNome = prefs.getString(_keyHospedagemNome);
    final contratoId = prefs.getString(_keyContratoId);

    if (idHospedagem == null || idUsuario == null || hospedagemNome == null) {
      print('❌ Dados incompletos no cache');
      return null;
    }

    print('📂 Dados carregados do cache:');
    print('📂 idHospedagem: $idHospedagem');
    print('📂 idUsuario: $idUsuario');
    print('📂 hospedagemNome: $hospedagemNome');
    print('📂 contratoId: $contratoId');

    return {
      'idHospedagem': idHospedagem,
      'idUsuario': idUsuario,
      'hospedagemNome': hospedagemNome,
      'contratoId': contratoId,
    };
  }

  static Future<void> limparDadosConversa() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove(_keyIdHospedagem);
    await prefs.remove(_keyIdUsuario);
    await prefs.remove(_keyHospedagemNome);
    await prefs.remove(_keyContratoId);
    
    print('🗑️ Dados da conversa removidos do cache');
  }

  static Future<bool> existeDadosConversa() async {
    final prefs = await SharedPreferences.getInstance();
    
    final idHospedagem = prefs.getInt(_keyIdHospedagem);
    final idUsuario = prefs.getInt(_keyIdUsuario);
    final hospedagemNome = prefs.getString(_keyHospedagemNome);
    
    return idHospedagem != null && idUsuario != null && hospedagemNome != null;
  }
}