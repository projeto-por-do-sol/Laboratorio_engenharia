class cpfValidator {
  static bool isValidCpf(String cpf) {
    cpf = cpf.replaceAll(RegExp(r'\D'), '');

    if (cpf.length != 11) return false;

    if (RegExp(r'^(\d)\1+$').hasMatch(cpf)) return false;

    List<int> numbers = cpf.split('').map((e) => int.parse(e)).toList();

    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += numbers[i] * (10 - i);
    }
    int firstDigit = (sum * 10) % 11;
    if (firstDigit == 10) firstDigit = 0;
    if (numbers[9] != firstDigit) return false;

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += numbers[i] * (11 - i);
    }
    int secondDigit = (sum * 10) % 11;
    if (secondDigit == 10) secondDigit = 0;
    if (numbers[10] != secondDigit) return false;

    return true;
  }
}

class cnpjValidator {
  static bool isValidCnpj(String cnpj) {
    cnpj = cnpj.replaceAll(RegExp(r'\D'), '');

    if (cnpj.length != 14) return false;

    if (RegExp(r'^(\d)\1+$').hasMatch(cnpj)) return false;

    List<int> numbers = cnpj.split('').map((e) => int.parse(e)).toList();

    int calcularDigito(int qtde) {
      const pesos = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
      final inicio = pesos.length - qtde;
      int sum = 0;
      for (int i = 0; i < qtde; i++) {
        sum += numbers[i] * pesos[inicio + i];
      }
      final resto = sum % 11;
      return resto < 2 ? 0 : 11 - resto;
    }

    if (numbers[12] != calcularDigito(12)) return false;
    if (numbers[13] != calcularDigito(13)) return false;

    return true;
  }
}

class phoneValidator {
  // static String? phoneValidate(String phone){
  //   final phoneNumbers = phone.replaceAll(RegExp(r'[^0-9]'), '');
  //
  //   if (phoneNumbers.length != 11) {
  //     return 'Telefone inválido (use DDD + número)';
  //   }
  //   return null;
  // }

  static bool phoneValidate(String phone){
    final phoneNumbers = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return phoneNumbers.length == 11;
  }
}

class emailValidator {
  static bool emailValidate(String email){
    return RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }
}

class phoneEmailValidator {
  static bool phoneEmailValidate(String value){
    return phoneValidator.phoneValidate(value) ||
        emailValidator.emailValidate(value);
  }
}

class passwordsValidator {
  static bool equalsPassword(String password, String confirmPassword){
    return password == confirmPassword;
  }
}
