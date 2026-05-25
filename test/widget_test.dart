import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mateus_hamburgueria/main.dart';

void main() {
  testWidgets('App inicia corretamente', (WidgetTester tester) async {
    // CORREÇÃO: Usando a classe correta MyApp declarada no seu main.dart
    await tester.pumpWidget(const MyApp());

    // Verifica se o widget do app foi renderizado na árvore
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('Login possui campos de texto', (WidgetTester tester) async {
    // CORREÇÃO: Usando a classe correta MyApp declarada no seu main.dart
    await tester.pumpWidget(const MyApp());

    // Como o app inicia na tela de Login, valida se ela carrega os inputs
    expect(find.byType(TextField), findsAtLeastNWidgets(1));
  });
}
