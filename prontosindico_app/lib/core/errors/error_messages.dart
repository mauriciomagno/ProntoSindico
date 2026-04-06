class ErrorMessages {
  // Auth Errors
  static const String invalidEmail = "O endereço de e-mail não é válido.";
  static const String userDisabled = "Este usuário foi desativado.";
  static const String userNotFound = "Nenhum usuário encontrado com este e-mail.";
  static const String wrongPassword = "Senha incorreta. Verifique e tente novamente.";
  static const String emailAlreadyInUse = "Este e-mail já está em uso por outra conta.";
  static const String operationNotAllowed = "Operação não permitida.";
  static const String weakPassword = "A senha fornecida é muito fraca.";
  static const String networkRequestFailed = "Erro de conexão. Verifique sua internet.";
  static const String tooManyRequests = "Muitas tentativas. Tente novamente mais tarde.";

  // Database / Firestore Errors
  static const String permissionDenied = "Você não tem permissão para realizar esta ação.";
  static const String unavailable = "O serviço está temporariamente indisponível.";
  static const String notFound = "O recurso solicitado não foi encontrado.";

  // Generic Errors
  static const String defaultError = "Ocorreu um erro inesperado. Por favor, tente novamente.";
  static const String unknownError = "Erro desconhecido. Se o problema persistir, entre em contato.";
  static const String cancelByUser = "Operação cancelada pelo usuário.";
}
