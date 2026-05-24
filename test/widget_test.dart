import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mateus_hamburgueria/main.dart';

void main() {
  testWidgets('App inicia corretamente', (WidgetTester tester) async {
    // Build nosso app e dispara um frame
    await tester.pumpWidget(const MateusHamburgueriaApp());

    // Verifica se o título aparece
    expect(find.text('Mateus Hamburgueria'), findsOneWidget);
  });

  testWidgets('Login possui campos de email e senha', (WidgetTester tester) async {
    await tester.pumpWidget(const MateusHamburgueriaApp());

    // Procura campos de texto
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
