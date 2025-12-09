// lib/services/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory SecureStorage() {
    return _instance;
  }

  SecureStorage._internal();

  // Salvar token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
    print('🔐 Token salvo com sucesso');
  }

  // Obter token
  Future<String?> getToken() async {
    final token = await _storage.read(key: 'auth_token');
    return token;
  }

  // Salvar ID do usuário
  Future<void> saveUserId(int userId) async {
    await _storage.write(key: 'user_id', value: userId.toString());
    print('👤 ID do usuário salvo: $userId');
  }

  // Obter ID do usuário
  Future<int?> getUserId() async {
    final userIdStr = await _storage.read(key: 'user_id');
    if (userIdStr != null) {
      return int.tryParse(userIdStr);
    }
    return null;
  }

  // Limpar todos os dados
  Future<void> clearAll() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_id');
    print('🧹 Todos os dados de autenticação limpos');
  }

  // Verificar se está logado
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final userId = await getUserId();
    return token != null && token.isNotEmpty && userId != null;
  }
}