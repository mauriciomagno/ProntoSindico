/// Estados possíveis da tela de login.
/// Utiliza sealed classes do Dart 3 para exaustividade em switch.
sealed class LoginState {
  const LoginState();
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginLoading extends LoginState {
  const LoginLoading();
}

final class LoginSuccess extends LoginState {
  const LoginSuccess();
}

final class LoginError extends LoginState {
  final String message;
  const LoginError(this.message);
}
