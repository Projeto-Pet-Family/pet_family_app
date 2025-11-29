import 'package:test/test.dart';

String extrairPrimeiroNome(String nomeCompleto) {
  if (nomeCompleto.isEmpty || nomeCompleto == 'Tutor') {
    return 'Tutor';
  }

  final nomeLimpo = nomeCompleto.trim();
  final partes = nomeLimpo.split(' ');
  return partes.first;
}

void main() {
  group('Testes da função extrairPrimeiroNome', () {
    test('Deve retornar "Tutor" quando nomeCompleto for vazio', () {
      expect(extrairPrimeiroNome(''), 'Tutor');
    });

    test('Deve retornar "Tutor" quando nomeCompleto for "Tutor"', () {
      expect(extrairPrimeiroNome('Tutor'), 'Tutor');
    });

    test('Deve extrair primeiro nome corretamente', () {
      expect(extrairPrimeiroNome('João Silva'), 'João');
    });

    test('Deve extrair primeiro nome com múltiplos espaços', () {
      expect(extrairPrimeiroNome('  Maria   Santos  '), 'Maria');
    });

    test('Deve extrair primeiro nome com nome único', () {
      expect(extrairPrimeiroNome('Carlos'), 'Carlos');
    });

    test('Deve lidar com nomes com hífen', () {
      expect(extrairPrimeiroNome('Ana-Clara Souza'), 'Ana-Clara');
    });

    test('Deve lidar com nomes com acentos', () {
      expect(extrairPrimeiroNome('José Antônio'), 'José');
    });
  });

  group('Testes de formatação de texto', () {
    test('Deve criar saudação correta', () {
      final primeiroNome = extrairPrimeiroNome('Maria Silva');
      final saudacao = 'Bem vindo, $primeiroNome';
      
      expect(saudacao, 'Bem vindo, Maria');
    });

    test('Deve criar saudação com Tutor quando não há nome', () {
      final primeiroNome = extrairPrimeiroNome('');
      final saudacao = 'Bem vindo, $primeiroNome';
      
      expect(saudacao, 'Bem vindo, Tutor');
    });
  });
}