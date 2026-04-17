import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'service/notification_push_service.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar notificaciones push
  await PushService.initialize();

  runApp(const MyApp());
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