import 'package:flutter/material.dart';
import 'package:prontosindico/screens/auth/views/google_login_screen.dart';

import 'screen_export.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case onbordingScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OnBordingScreen(),
        settings: settings,
      );
    case logInScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
        settings: settings,
      );
    case googleLoginScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const GoogleLoginScreen(),
        settings: settings,
      );
    case signUpScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
        settings: settings,
      );
    case passwordRecoveryScreenRoute:
      // Return Onboarding or a generic screen since it's deleted
      return MaterialPageRoute(
        builder: (context) => const OnBordingScreen(),
        settings: settings,
      );
    case homeScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
        settings: settings,
      );
    case profileScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ProfileScreen(),
        settings: settings,
      );
    case muralScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const MuralScreen(),
        settings: settings,
      );
    case reservasScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ReservasScreen(),
        settings: settings,
      );
    case userInfoScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const UserInfoScreen(),
        settings: settings,
      );
    case financialReportScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const FinancialReportScreen(),
        settings: settings,
      );
    case accessManagementScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AccessManagementScreen(),
        settings: settings,
      );
    case residentsScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ResidentsScreen(),
        settings: settings,
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const OnBordingScreen(),
        settings: settings,
      );
  }
}
