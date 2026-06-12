class cpfValidator{
   // static String? cpfValidate(String cpf){
   //   cpf = cpf.replaceAll(RegExp(r'\D'), '');
   //
   //   if (cpf.length != 11){
   //     return "CPF deve conter 11 dígitos";
   //   }
   //
   //   if (RegExp(r'^(\d)\1+$').hasMatch(cpf)) {
   //     return 'CPF inválido';
   //   }
   //
   //   if (!isValidCpf(cpf)) {
   //     return 'CPF inválido';
   //   }
   //
   //   return null;
   // }

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
