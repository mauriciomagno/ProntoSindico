import 'package:flutter/foundation.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/firebase_options.dart';
import 'package:prontosindico/route/router.dart' as router;
import 'package:prontosindico/screens/onbording/views/onboarding_screen.dart';
import 'package:prontosindico/theme/app_theme.dart';
import 'package:prontosindico/ui/features/auth/views/auth_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[Firebase] Inicializado com sucesso para: ${DefaultFirebaseOptions.currentPlatform.projectId}');
  } catch (e) {
    debugPrint('[Firebase] Erro CRÍTICO na inicialização: $e');
    // Em caso de erro aqui, o app provavelmente falhará em seguida.
  }
  
  // App Check initialization (Check Logcat for debug token)
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode ? const AndroidDebugProvider() : const AndroidPlayIntegrityProvider(),
    providerApple: kDebugMode ? const AppleDebugProvider() : const AppleDeviceCheckProvider(),
  );


  // Lê o estado do onboarding ANTES do runApp para evitar race conditions.
  // O onboarding é exibido apenas na primeira execução, em qualquer ambiente.
  // Após o usuário concluir ou pular, 'onboarding_seen' é salvo e ele não verá novamente.
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingSeen = prefs.getBool('onboarding_seen') ?? false;
  runApp(ProviderScope(child: MyApp(onboardingSeen: onboardingSeen)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.onboardingSeen});

  final bool onboardingSeen;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      title: 'Pronto Sindíco Template by The Flutter Way',
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.system,
      home: FlutterSplashScreen(onboardingSeen: onboardingSeen),
      onGenerateRoute: router.generateRoute,
    );
  }
}

class FlutterSplashScreen extends StatefulWidget {
  const FlutterSplashScreen({super.key, required this.onboardingSeen});

  final bool onboardingSeen;

  @override
  State<FlutterSplashScreen> createState() => _FlutterSplashScreenState();
}

class _FlutterSplashScreenState extends State<FlutterSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Imagens pré-carregadas durante o splash para que o onboarding apareça instantaneamente.
  static const _onboardingImages = [
    'assets/images/onboarding/building.png',
    'assets/images/onboarding/communication.png',
    'assets/images/onboarding/booking.png',
    'assets/images/onboarding/incidents.png',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    _goToNextScreen();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pré-cache das imagens do onboarding durante o splash (somente na primeira vez).
    if (!widget.onboardingSeen) {
      for (final path in _onboardingImages) {
        precacheImage(AssetImage(path), context);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _goToNextScreen() async {
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // onboardingSeen foi determinado em main() antes do runApp — sem async aqui.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => widget.onboardingSeen
            ? const AuthWrapper()
            : const OnBordingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Background with slight zoom and fade (semi-transparent)
              Opacity(
                opacity: _fadeAnimation.value * 0.4,
                child: Transform.scale(
                  scale: 1.0 + (0.05 * (1.0 - _fadeAnimation.value)),
                  child: Image.asset(
                    'assets/images/login_dark.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Centered Logo with Scale and Fade
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Image.asset(
                      'assets/logo/logo.png',
                      width: 170,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
