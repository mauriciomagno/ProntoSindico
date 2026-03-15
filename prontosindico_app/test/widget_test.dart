// Smoke test básico da aplicação ProntoSíndico.

import 'package:flutter_test/flutter_test.dart';
import 'package:prontosindico/main.dart';

void main() {
  testWidgets('App smoke test - widget raiz renderiza sem erros',
      (WidgetTester tester) async {
    // Constrói o widget raiz da aplicação.
    // onboardingSeen: false simula primeira execução (sem SharedPreferences real em testes).
    await tester.pumpWidget(const MyApp(onboardingSeen: false));

    // Verifica que o widget MaterialApp foi criado.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
