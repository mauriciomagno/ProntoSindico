import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/constants.dart';
import 'package:prontosindico/providers/auth_provider.dart';
import 'package:prontosindico/ui/features/auth/states/login_state.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginControllerProvider);
    final isLoading = loginState is LoginLoading;

    ref.listen<LoginState>(loginControllerProvider, (_, next) {
      if (next is LoginError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: errorColor,
          ),
        );
        ref.read(loginControllerProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: backgroundLightColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo
              Hero(
                tag: 'logo',
                child: Image.asset(
                  'assets/logo/logo.png',
                  height: 90,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.business, size: 90, color: primaryColor),
                ),
              ).animate().fadeIn().scale(),
              const SizedBox(height: defaultPadding * 2),

              // Título
              Text(
                'Bem-vindo ao ProntoSíndico',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontFamily: grandisExtendedFont,
                    ),
              ).animate().fadeIn(delay: 200.ms).moveY(begin: 10),
              const SizedBox(height: defaultPadding / 2),

              Text(
                'Acesse sua unidade e serviços exclusivos.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: blackColor40,
                    ),
              ).animate().fadeIn(delay: 300.ms).moveY(begin: 10),

              const Spacer(),

              // Botão Entrar com Google
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: () =>
                            ref.read(loginControllerProvider.notifier).signInWithGoogle(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: const BorderSide(color: primaryColor, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Ícone "G" do Google estilizado
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'G',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4285F4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Entrar com Google',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms).moveY(begin: 20),

              const SizedBox(height: defaultPadding * 3),

              // Rodapé
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'VERSAO 1.0.0',
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: blackColor20,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    'TERMOS DE USO',
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: blackColor20,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                  Text(
                    'PRIVACIDADE',
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: blackColor20,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: defaultPadding),
            ],
          ),
        ),
      ),
    );
  }
}
