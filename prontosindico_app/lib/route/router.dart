import 'package:flutter/material.dart';
import 'package:prontosindico/screens/auth/views/google_login_screen.dart';

import 'screen_export.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case onbordingScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const OnBordingScreen(),
      );
    case logInScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      );
    case googleLoginScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const GoogleLoginScreen(),
      );
    case signUpScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      );
    case passwordRecoveryScreenRoute:
      // Return Onboarding or a generic screen since it's deleted
      return MaterialPageRoute(
        builder: (context) => const OnBordingScreen(),
      );
    case homeScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      );
    case muralScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const MuralScreen(),
      );
    case reservasScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const ReservasScreen(),
      );
    case userInfoScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const UserInfoScreen(),
      );
    case financialReportScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const FinancialReportScreen(),
      );
    case accessManagementScreenRoute:
      return MaterialPageRoute(
        builder: (context) => const AccessManagementScreen(),
      );
    default:
      return MaterialPageRoute(
        builder: (context) => const OnBordingScreen(),
      );
  }
}
