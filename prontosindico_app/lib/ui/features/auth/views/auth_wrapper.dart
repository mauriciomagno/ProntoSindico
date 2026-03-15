import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/entry_point.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/ui/features/auth/views/login_screen.dart';

/// Observa o stream de autenticação do Firebase via Riverpod.
/// Redireciona automaticamente ao fazer login ou logout — sem navegação imperativa.
/// Deve ser o widget raiz após o splash/onboarding.
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      loading: () => const AuthLoadingScreen(),
      error: (_, __) => const LoginScreen(),
      data: (firebaseUser) {
        if (firebaseUser == null) return const LoginScreen();
        return _UserDataGate(uid: firebaseUser.uid);
      },
    );
  }
}

/// Escuta em tempo real os dados do usuário no banco.
/// Reage imediatamente a mudanças — ex: desativação pelo administrador.
class _UserDataGate extends ConsumerWidget {
  const _UserDataGate({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userDataStreamProvider(uid));

    return userAsync.when(
      loading: () => const AuthLoadingScreen(),
      error: (error, _) => _UserDataErrorScreen(
        message: 'Erro ao carregar dados do usuário.\n${error.toString()}',
        onRetry: () => ref.invalidate(userDataStreamProvider(uid)),
      ),
      data: (appUser) {
        if (appUser == null) {
          // Dados não encontrados: faz logout e volta ao login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(authRepositoryProvider).signOut();
          });
          return const AuthLoadingScreen();
        }
        if (!appUser.isActive) {
          // Bloqueia o acesso e exibe mensagem informativa.
          // O usuário deve contatar o síndico para ser reativado.
          return const AccountDeactivatedScreen();
        }
        return const EntryPoint();
      },
    );
  }
}

class _UserDataErrorScreen extends ConsumerWidget {
  const _UserDataErrorScreen({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.read(authRepositoryProvider).signOut(),
                child: const Text('Sair e tentar outra conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tela de loading exibida enquanto verifica autenticação ou dados do usuário.
class AuthLoadingScreen extends StatelessWidget {
  const AuthLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/logo/logo.png',
          width: 140,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Tela exibida quando o usuário foi desativado pelo administrador.
/// O stream [userDataStreamProvider] mantém esta tela enquanto Ativo=Não.
/// Ao reativar, o stream emite o novo estado e o app volta automaticamente.
class AccountDeactivatedScreen extends ConsumerWidget {
  const AccountDeactivatedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.block_rounded,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                'Acesso Desativado',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Sua conta foi desativada pelo administrador do condomínio.\n\nEntre em contato com o síndico para reativar seu acesso.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => ref.read(authRepositoryProvider).signOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair da Conta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
