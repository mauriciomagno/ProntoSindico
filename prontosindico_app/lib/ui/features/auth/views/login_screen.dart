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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding * 1.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: defaultPadding * 3),
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/logo/logo.png',
                    height: 80,
                    errorBuilder: (_, __, ___) => 
                        const Icon(Icons.business, size: 80, color: primaryColor),
                  ),
                ).animate().fadeIn().scale(),
                const SizedBox(height: defaultPadding * 2),
                
                Text(
                  'Bem-vindo de volta',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                        fontFamily: grandisExtendedFont,
                      ),
                ).animate().fadeIn(delay: 200.ms).moveY(begin: 10),
                const SizedBox(height: defaultPadding / 2),
                Text(
                  'Acesse sua unidade e servicos exclusivos.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: blackColor40,
                      ),
                ).animate().fadeIn(delay: 300.ms).moveY(begin: 10),
                const SizedBox(height: defaultPadding * 3),

                const _EmailLoginForm(),
                const SizedBox(height: defaultPadding * 2),

                Text.rich(
                  TextSpan(
                    text: 'Novo no condominio? ',
                    style: const TextStyle(color: blackColor60),
                    children: [
                      TextSpan(
                        text: 'Cadastre-se como morador',
                        style: const TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),
                
                const SizedBox(height: defaultPadding * 4),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'VERSAO 1.0.0 PLATINUM',
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
                ).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: defaultPadding),
                
                const SizedBox(height: defaultPadding),
                if (!isLoading)
                  TextButton.icon(
                    onPressed: () => ref.read(loginControllerProvider.notifier).signInWithGoogle(),
                    icon: const Icon(Icons.login, size: 16),
                    label: const Text("Entrar com Google", style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(foregroundColor: blackColor40),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailLoginForm extends ConsumerStatefulWidget {
  const _EmailLoginForm();

  @override
  ConsumerState<_EmailLoginForm> createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends ConsumerState<_EmailLoginForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ref.read(loginControllerProvider.notifier).signInWithEmail(_email, _password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(loginControllerProvider) is LoginLoading;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'E-MAIL',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: blackColor40,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            onSaved: (value) => _email = value ?? '',
            validator: emaildValidator.call,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "seu@email.com",
              prefixIcon: const Icon(Icons.email_outlined, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: blackColor10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryColor, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: defaultPadding * 1.5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'SENHA',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: blackColor40,
                  letterSpacing: 1.2,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Esqueceu a senha?',
                  style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            onSaved: (value) => _password = value ?? '',
            validator: passwordValidator.call,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "••••••••",
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: blackColor10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryColor, width: 1.5),
              ),
            ),
            onFieldSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: defaultPadding * 2.5),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Entrar",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
