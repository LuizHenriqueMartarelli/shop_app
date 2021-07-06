class AuthException implements Exception {
  static const Map<String, String> errors = {
    "EMAIL_EXISTS": "Email informado já existe!",
    "OPERATION_NOT_ALLOWED": "Operação não permitida!",
    "TOO_MANY_ATTEMPTS_TRY_LATER": "Excesso de tentativas!",
    "EMAIL_NOT_FOUND": "Email não localizado",
    "INVALID_PASSWORD": "Senha inválida",
    "USER_DISABLED": "Usuário não está ativo",
    "MISSING_PASSWORD": "Login e/ou Senha erradas!",
  };

  final String key;

  const AuthException(this.key);

  @override
  String toString() {
    if (errors.containsKey(key)) {
      return errors[key]!;
    } else {
      return "Ocorreu um erro na autenticação!";
    }
  }
}
