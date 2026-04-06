// Production Entry Point (Main)
// O padrão agora usa Flutter Flavors e Dart Define
//
// Executar em cada ambiente:
// - DEV:  flutter run --flavor dev --dart-define-from-file=config_dev.json
// - HML:  flutter run --flavor hml --dart-define-from-file=config_hml.json
// - PROD: flutter run --flavor prod --dart-define-from-file=config_prod.json
//
// Build em cada ambiente:
// - DEV:  flutter build apk --flavor dev --dart-define-from-file=config_dev.json --release
// - HML:  flutter build apk --flavor hml --dart-define-from-file=config_hml.json --release
// - PROD: flutter build apk --flavor prod --dart-define-from-file=config_prod.json --release

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ignore: depend_on_referenced_packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prontosindico/config/app_config.dart';
import 'package:prontosindico/firebase_database/firebase_options.dart';
import 'package:prontosindico/route/router.dart' as router;
import 'package:prontosindico/screens/onbording/views/onboarding_screen.dart';
import 'package:prontosindico/services/app_check_service.dart';
import 'package:prontosindico/theme/app_theme.dart';
import 'package:prontosindico/screens/auth/views/auth_wrapper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carregar configurações do ambiente
  final appConfig = AppConfig.fromEnvironment();
  debugPrint(appConfig.toString());

  // Inicializar Firebase (usa o mesmo project em todos os ambientes)
  try {
    final firebaseOptions = DefaultFirebaseOptions.options(appConfig);
    await Firebase.initializeApp(
      options: firebaseOptions,
    );

    // Habilitar persistência offline
    FirebaseDatabase.instance.setPersistenceEnabled(true);

    debugPrint(
        '[Firebase] ✅ Inicializado com sucesso (${appConfig.flavor.name.toUpperCase()}) para: ${firebaseOptions.projectId}');
    debugPrint('[Firebase] 💾 Persistência Offline ATIVADA');
  } catch (e) {
    debugPrint('[Firebase] ❌ Erro CRÍTICO na inicialização: $e');
    rethrow;
  }

  // Inicializar App Check através do serviço
  final appCheckService = AppCheckService();
  await appCheckService.initialize(appConfig);

  // Ler estado do onboarding
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingSeen = prefs.getBool('onboarding_seen') ?? false;

  runApp(ProviderScope(
      child: MyApp(appConfig: appConfig, onboardingSeen: onboardingSeen)));
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.appConfig,
    required this.onboardingSeen,
  });

  final AppConfig appConfig;
  final bool onboardingSeen;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: appConfig.enableDebugBanner,
      title: appConfig.appTitle,
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', ''),
      ],
      locale: const Locale('pt', 'BR'),
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
    if (!mounted) {
      return;
    }

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
