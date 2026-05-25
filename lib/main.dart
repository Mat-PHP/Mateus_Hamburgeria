import 'package:flutter/material.dart';
import 'services/local_storage_service.dart';
import 'screens/login_page.dart';

void main() async {
  // Garante a inicialização dos bindings do Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o SharedPreferences antes do app renderizar a tela
  await LocalStorageService.init();

  runApp(const MateusHamburgueriaApp());
}

class MateusHamburgueriaApp extends StatelessWidget {
  const MateusHamburgueriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mateus Hamburgueria',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
