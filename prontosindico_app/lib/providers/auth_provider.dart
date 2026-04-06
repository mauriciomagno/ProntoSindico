import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/data/repositories/auth_repository.dart';
import 'package:prontosindico/domain/entities/app_user.dart';
import 'package:prontosindico/domain/repositories/i_auth_repository.dart';
import 'package:prontosindico/screens/auth/controllers/login_controller.dart';
import 'package:prontosindico/screens/auth/states/login_state.dart';

/// Provedor do repositório de autenticação (única instância).
final authRepositoryProvider = Provider<IAuthRepository>(
  (_) => AuthRepository(),
);

/// Stream reativo do estado de autenticação Firebase.
/// Qualquer widget que observe este provider é re-renderizado em login/logout.
final authStateChangesProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges,
);

/// Provedor dos dados do usuário logado no banco de dados.
/// Utiliza autoDispose para limpar cache ao fazer logout.
final userDataProvider = FutureProvider.autoDispose.family<AppUser?, String>(
  (ref, uid) => ref.read(authRepositoryProvider).fetchUserData(uid),
);

/// Stream reativo dos dados do usuário no banco.
/// Detecta mudanças em tempo real — essencial para desconectar sessões
/// imediatamente quando o usuário for desativado pelo administrador.
final userDataStreamProvider =
    StreamProvider.autoDispose.family<AppUser?, String>(
  (ref, uid) => ref.watch(authRepositoryProvider).watchUserData(uid),
);

final userProfileProvider = StreamProvider.autoDispose<AppUser?>((ref) {
  final authUser = ref.watch(authStateChangesProvider).valueOrNull;
  if (authUser == null) {
    return Stream.value(null);
  }
  return ref.watch(authRepositoryProvider).watchUserData(authUser.uid);
});

/// Provedor do controller de login (Notifier - riverpod v3).
final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);
