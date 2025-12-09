// TODO Implement this library.
class FormattingUtils {
  // Remove todos os caracteres não numéricos
  static String removeFormatting(String formattedValue) {
    return formattedValue.replaceAll(RegExp(r'[^\d]'), '');
  }
  
  // Formata CPF para exibição
  static String formatCpfForDisplay(String cpf) {
    final cleanCpf = removeFormatting(cpf);
    if (cleanCpf.length == 11) {
      return '${cleanCpf.substring(0, 3)}.${cleanCpf.substring(3, 6)}.${cleanCpf.substring(6, 9)}-${cleanCpf.substring(9)}';
    }
    return cpf;
  }
  
  // Formata telefone para exibição
  static String formatPhoneForDisplay(String phone) {
    final cleanPhone = removeFormatting(phone);
    if (cleanPhone.length == 11) {
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 7)}-${cleanPhone.substring(7)}';
    } else if (cleanPhone.length == 10) {
      return '(${cleanPhone.substring(0, 2)}) ${cleanPhone.substring(2, 6)}-${cleanPhone.substring(6)}';
    }
    return phone;
  }
  
  // Formata CEP para exibição
  static String formatCepForDisplay(String cep) {
    final cleanCep = removeFormatting(cep);
    if (cleanCep.length == 8) {
      return '${cleanCep.substring(0, 2)}.${cleanCep.substring(2, 5)}-${cleanCep.substring(5)}';
    }
    return cep;
  }
}