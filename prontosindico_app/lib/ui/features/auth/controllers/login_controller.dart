import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/domain/repositories/i_auth_repository.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/ui/features/auth/states/login_state.dart';

class LoginController extends Notifier<LoginState> {
  late IAuthRepository _repository;

  @override
  LoginState build() {
    _repository = ref.watch(authRepositoryProvider);
    return const LoginInitial();
  }

  Future<void> signInWithGoogle() async {
    if (state is LoginLoading) return;
    state = const LoginLoading();

    try {
      final user = await _repository.signInWithGoogle();
      if (user == null) {
        state = const LoginError('Login cancelado. Tente novamente.');
        return;
      }
      // LoginSuccess sinaliza que o Firebase Auth emitiu novo usuário.
      // O AuthWrapper (via authStateChangesProvider) redireciona automaticamente.
      state = const LoginSuccess();
    } catch (e) {
      String message = e.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }
      state = LoginError(message);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    if (state is LoginLoading) return;
    state = const LoginLoading();

    try {
      final user = await _repository.signInWithEmailAndPassword(email, password);
      if (user == null) {
        state = const LoginError('Falha ao autenticar. Verifique seus dados.');
        return;
      }
      state = const LoginSuccess();
    } catch (e) {
      String message = e.toString();
      if (message.contains('invalid-credential') ||
          message.contains('user-not-found') ||
          message.contains('wrong-password')) {
        message = 'Email ou senha incorretos.';
      } else if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }
      state = LoginError(message);
    }
  }

  void reset() => state = const LoginInitial();
}
