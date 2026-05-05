import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'screens/splash_screen.dart';
import 'service/notification_push_service.dart';
import 'service/app_settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PushService.initialize();

  // Cargar ajustes guardados
  await AppSettings().cargar();

  // Ocultar navigation bar y mostrar status bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Despertar Render en segundo plano
  _wakeUpServer();

  runApp(const MyApp());
}

void _wakeUpServer() {
  http.get(
    Uri.parse("https://padelpro-tfg.onrender.com/api/usuarios/login"),
  ).catchError((_) {});
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final settings = AppSettings();

  @override
  void initState() {
    super.initState();
    settings.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: settings.modoOscuro ? ThemeMode.dark : ThemeMode.light,

      // TEMA CLARO
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: "Poppins",
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F5DA0),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      ),

      // TEMA OSCURO
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: "Poppins",
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F5DA0),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F5DA0),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Color(0xFF1F5DA0),
          unselectedItemColor: Colors.grey,
        ),
      ),

      // TAMAÑO DE TEXTO GLOBAL
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(settings.tamanoTexto),
          ),
          child: child!,
        );
      },

      home: const SplashScreen(),
    );
  }
}