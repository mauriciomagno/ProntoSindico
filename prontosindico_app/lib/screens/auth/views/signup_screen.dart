import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:prontosindico/screens/auth/views/components/sign_up_form.dart';
import 'package:prontosindico/route/route_constants.dart';

import '../../../constants.dart';

import 'package:flutter_animate/flutter_animate.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  "assets/images/signUp_dark.png",
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
                        Colors.black.withOpacity(0.1),
                        Theme.of(context).scaffoldBackgroundColor,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: defaultPadding,
                  child: Hero(
                    tag: "logo",
                    child: Image.asset(
                      "assets/logo/ProntoSindico.png", // Assuming this exists or using a placeholder-like logic
                      height: 60,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(),
                    ),
                  ).animate().fadeIn().scale(),
                ),
              ],
            ).animate().fadeIn(duration: 600.ms),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Crie sua conta!",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                  ).animate().fadeIn(delay: 200.ms).moveX(begin: -20),
                  const SizedBox(height: defaultPadding / 4),
                  const Text(
                    "Junte-se à maior plataforma de gestão condominial.",
                  ).animate().fadeIn(delay: 300.ms).moveX(begin: -20),
                  const SizedBox(height: defaultPadding * 1.5),
                  SignUpForm(formKey: _formKey)
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .moveY(begin: 20),
                  const SizedBox(height: defaultPadding),
                  Row(
                    children: [
                      Checkbox(
                        onChanged: (value) {},
                        value: false,
                      ),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: "Eu concordo com os",
                            children: [
                              TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // Navigator.pushNamed(
                                    //     context, termsOfServicesScreenRoute);
                                  },
                                text: " Termos de serviço ",
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const TextSpan(
                                text: "& política de privacidade.",
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: defaultPadding),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, entryPointScreenRoute);
                    },
                    child: const Text("Criar Minha Conta"),
                  ).animate().fadeIn(delay: 600.ms).scale(),
                  const SizedBox(height: defaultPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Já possui acesso?"),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, logInScreenRoute);
                        },
                        child: const Text("Fazer Login"),
                      )
                    ],
                  ).animate().fadeIn(delay: 700.ms),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
