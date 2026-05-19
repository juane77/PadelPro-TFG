import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../service/session.dart';
import '../service/recuperar_service.dart';
import '../utils/responsive.dart';
import '../utils/app_snackbar.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'recuperar_password_screen.dart';
import 'confirmar_email_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _cargando = false;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      AppSnackbar.aviso(context, "Rellena todos los campos");
      return;
    }
    if (!email.contains("@") || !email.contains(".")) {
      AppSnackbar.error(context, "El email no es válido");
      return;
    }
    if (password.length < 4) {
      AppSnackbar.error(context, "La contraseña debe tener mínimo 4 caracteres");
      return;
    }

    setState(() => _cargando = true);

    try {
      final response = await http.post(
        Uri.parse("https://padelpro-tfg.onrender.com/api/usuarios/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(const Duration(seconds: 30));

      setState(() => _cargando = false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        Session.usuarioId = data["id"];
        Session.nombre = data["nombre"];
        Session.email = data["email"];
        Session.token = data["token"];
        Session.pelotas = data["pelotas"] ?? 0;
        Session.rol = data["rol"];
        Session.idClub = data["idClub"];
        Session.clubNombre = data["clubNombre"];
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        final data = json.decode(response.body);
        if (!context.mounted) return;
        if (data["emailNoVerificado"] == true) {
          _mostrarDialogoEmailNoVerificado(context, email);
        } else {
          AppSnackbar.error(context, data["mensaje"] ?? "Email o contraseña incorrectos");
        }
      }
    } catch (e) {
      setState(() => _cargando = false);
      if (!context.mounted) return;
      AppSnackbar.error(context, "Error de conexión. Inténtalo de nuevo.");
    }
  }

  void _mostrarDialogoEmailNoVerificado(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Email no confirmado"),
        content: const Text("Debes confirmar tu email antes de iniciar sesión.\n\n¿Quieres que te reenviemos el código de confirmación?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await RecuperarService.reenviarConfirmacion(email);
              if (!context.mounted) return;
              if (result["success"]) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ConfirmarEmailScreen(email: email)),
                );
              } else {
                AppSnackbar.error(context, result["mensaje"]);
              }
            },
            child: const Text("Reenviar código"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final w = Responsive.width;
    final h = Responsive.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF1F5DA0),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              SizedBox(height: h * 0.05),

              Image.asset("assets/images/logo.png", width: w * 0.38),

              SizedBox(height: h * 0.03),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.07,
                  vertical: h * 0.04,
                ),
                decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

                        Text(
                          "Iniciar Sesión",
                          style: TextStyle(
                            fontSize: (w * 0.09).clamp(28.0, 40.0),
                            fontFamily: "Poppins",
                          ),
                        ),

                        SizedBox(height: h * 0.04),

                        TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Email",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),

                        SizedBox(height: h * 0.02),

                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Contraseña",
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),

                        SizedBox(height: h * 0.04),

                        SizedBox(
                          width: w * 0.7,
                          height: h * 0.065,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F5DA0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _cargando ? null : login,
                            child: _cargando
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    "Iniciar Sesión",
                                    style: TextStyle(
                                      fontSize: (w * 0.05).clamp(16.0, 22.0),
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: Responsive.h(2.5)),

                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RecuperarPasswordScreen()),
                          ),
                          child: Text(
                            "¿Olvidaste tu contraseña?",
                            style: TextStyle(
                              color: Color(0xFF1F5DA0),
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w600,
                              fontSize: Responsive.font(14),
                            ),
                          ),
                        ),

                        SizedBox(height: Responsive.h(1.2)),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "¿No tienes cuenta todavía?",
                              style: TextStyle(
                                color: Colors.grey,
                                fontFamily: "Poppins",
                                fontSize: (w * 0.035).clamp(12.0, 15.0),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterScreen()),
                              ),
                              child: Text(
                                "Registrarme",
                                style: TextStyle(
                                  color: const Color(0xFF1F5DA0),
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.bold,
                                  fontSize: (w * 0.035).clamp(12.0, 15.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}