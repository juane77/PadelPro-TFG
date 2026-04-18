import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'screens/splash_screen.dart';
import 'service/notification_push_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar notificaciones push
  await PushService.initialize();

  // Despertar Railway en segundo plano
  _wakeUpRailway();

  runApp(const MyApp());
}

// Ping silencioso para despertar el servidor
void _wakeUpRailway() {
  http.get(
    Uri.parse("https://padelpro-tfg.onrender.com/api/usuarios/login"),
  ).catchError((_) {});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}