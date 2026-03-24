import 'package:firebase_auth/firebase_auth.dart';
import 'package:prontosindico/domain/entities/app_user.dart';

abstract interface class IAuthRepository {
  /// Stream de mudanças no estado de autenticação do Firebase.
  Stream<User?> get authStateChanges;

  /// Realiza login com Google e persiste o usuário no banco se for novo.
  Future<AppUser?> signInWithGoogle();

  /// Realiza login com email e senha.
  Future<AppUser?> signInWithEmailAndPassword(String email, String password);

  /// Busca os dados do usuário no Realtime Database pelo [uid].
  Future<AppUser?> fetchUserData(String uid);

  /// Stream reativo dos dados do usuário — detecta mudanças em tempo real.
  /// Usado para desconectar sessões ativas quando o usuário for desativado.
  Stream<AppUser?> watchUserData(String uid);

  /// Encerra a sessão do usuário em todos os provedores.
  Future<void> signOut();
}
