import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/constants.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/ui/features/auth/states/login_state.dart';

/// View de login seguindo MVVM:
/// - Sem lógica de negócio.
/// - Delega ações ao [LoginController] via [loginControllerProvider].
/// - Navegação pós-login gerenciada pelo AuthWrapper (authStateChangesProvider).
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginControllerProvider);
    final isLoading = loginState is LoginLoading;

    // Reage a erros sem bloquear a UI
    ref.listen<LoginState>(loginControllerProvider, (_, next) {
      if (next is LoginError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
        ref.read(loginControllerProvider.notifier).reset();
      }
    });

    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _LoginHeader(size: size),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo(a) de volta!',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                  ).animate().fadeIn(delay: 200.ms).moveX(begin: -20),
                  const SizedBox(height: defaultPadding / 4),
                  const Text(
                    'Gerencie seu condomínio com praticidade e segurança.',
                  ).animate().fadeIn(delay: 300.ms).moveX(begin: -20),
                  const SizedBox(height: defaultPadding * 1.5),
                  _GoogleSignInButton(
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () => ref
                            .read(loginControllerProvider.notifier)
                            .signInWithGoogle(),
                  ).animate().fadeIn(delay: 550.ms).scale(),
                  const SizedBox(height: defaultPadding),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Header com imagem de fundo e logo, responsabilidade única de apresentação.
class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/images/login_dark.png',
          height: size.height * 0.35,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Container(
          height: size.height * 0.35,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.1),
                Theme.of(context).scaffoldBackgroundColor,
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: defaultPadding,
          child: Hero(
            tag: 'logo',
            child: Image.asset(
              'assets/logo/logo.png',
              height: 60,
              errorBuilder: (_, __, ___) => const SizedBox(),
            ),
          ).animate().fadeIn().scale(),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms);
  }
}

/// Botão de login com Google — apresentação pura, sem acesso a providers.
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.grey),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
            height: 24,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.login, size: 24, color: Colors.black54),
          ),
          const SizedBox(width: defaultPadding),
          const Text(
            'Entrar com Google',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
