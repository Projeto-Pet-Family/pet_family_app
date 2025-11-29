import 'package:test/test.dart';

class MockAuthProvider {
  Map<String, dynamic>? usuarioLogado;

  MockAuthProvider({this.usuarioLogado});

  String getPrimeiroNomeUsuario() {
    final nomeCompleto = usuarioLogado?['nome'] ?? 'Tutor';
    return _extrairPrimeiroNome(nomeCompleto);
  }

  String _extrairPrimeiroNome(String nomeCompleto) {
    if (nomeCompleto.isEmpty || nomeCompleto == 'Tutor') {
      return 'Tutor';
    }
    final nomeLimpo = nomeCompleto.trim();
    final partes = nomeLimpo.split(' ');
    return partes.first;
  }
}

void main() {
  group('Testes do MockAuthProvider', () {
    test('Deve retornar primeiro nome do usuário logado', () {
      final authProvider = MockAuthProvider(
        usuarioLogado: {'nome': 'João Carlos Silva'}
      );
      
      expect(authProvider.getPrimeiroNomeUsuario(), 'João');
    });

    test('Deve retornar "Tutor" quando usuário não tem nome', () {
      final authProvider = MockAuthProvider(usuarioLogado: {});
      
      expect(authProvider.getPrimeiroNomeUsuario(), 'Tutor');
    });

    test('Deve retornar "Tutor" quando usuário é nulo', () {
      final authProvider = MockAuthProvider(usuarioLogado: null);
      
      expect(authProvider.getPrimeiroNomeUsuario(), 'Tutor');
    });

    test('Deve lidar com nome vazio no usuário', () {
      final authProvider = MockAuthProvider(
        usuarioLogado: {'nome': ''}
      );
      
      expect(authProvider.getPrimeiroNomeUsuario(), 'Tutor');
    });
  });
}