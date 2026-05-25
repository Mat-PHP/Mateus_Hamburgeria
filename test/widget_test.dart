import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mateus_hamburgueria/services/local_storage_service.dart';
import 'package:mateus_hamburgueria/screens/login_page.dart';

void main() {
  // Configura os mocks do SharedPreferences para os testes não quebrarem
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorageService.init();
  });

  testWidgets('App inicia corretamente', (WidgetTester tester) async {
    // Encapsula a LoginPage em um MaterialApp para o teste funcionar
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );

    // Verifica se a estrutura principal foi renderizada
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Login possui campos de texto', (WidgetTester tester) async {
    // Encapsula a LoginPage em um MaterialApp para o teste funcionar
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginPage(),
      ),
    );

    // Valida se a tela carrega os campos de input (TextField)
    expect(find.byType(TextField), findsAtLeastNWidgets(1));
  });
}
