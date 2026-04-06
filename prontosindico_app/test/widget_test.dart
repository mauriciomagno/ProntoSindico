// Smoke test básico da aplicação ProntoSíndico.

import 'package:flutter_test/flutter_test.dart';
import 'package:prontosindico/config/app_config.dart';
import 'package:prontosindico/main.dart';

void main() {
  testWidgets('App smoke test - widget raiz renderiza sem erros',
      (WidgetTester tester) async {
    // Cria um AppConfig de teste
    const AppConfig testConfig = AppConfig(
      appTitle: 'ProntoSindico Test',
      apiBaseUrl: 'https://test-api.prontosindico.com',
      flavor: Environment.dev,
      firebaseProjectId: 'test-project',
      enableDebugBanner: true,
      isProduction: false,
      firebaseApiKey: 'test-api-key',
      firebaseAppId: '1:123:android:abc',
      firebaseMessagingSenderId: '123',
    );


    // Constrói o widget raiz da aplicação.
    // onboardingSeen: false simula primeira execução (sem SharedPreferences real em testes).
    await tester.pumpWidget(
      MyApp(appConfig: testConfig, onboardingSeen: false),
    );

    // Verifica que o widget MaterialApp foi criado.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
