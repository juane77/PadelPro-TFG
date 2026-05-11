import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_snackbar.dart';
import 'login_screen.dart';
import 'confirmar_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  bool aceptarTerminos = false;

  final nombreController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  Future<void> registrar(BuildContext context) async {
    final nombre = nombreController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (nombre.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      AppSnackbar.aviso(context, "Rellena todos los campos");
      return;
    }
    if (nombre.length < 2) {
      AppSnackbar.aviso(context, "El nombre debe tener al menos 2 caracteres");
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
    if (password != confirmPassword) {
      AppSnackbar.error(context, "Las contraseñas no coinciden");
      return;
    }
    if (!aceptarTerminos) {
      AppSnackbar.aviso(context, "Debes aceptar los términos");
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("https://padelpro-tfg.onrender.com/api/usuarios/registrar"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nombre": nombre, "email": email, "password": password}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        if (!context.mounted) return;
        AppSnackbar.exito(context, "Usuario registrado correctamente");
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => ConfirmarEmailScreen(email: email, esRegistro: true)),
          (route) => false,
        );
      } else {
        final data = json.decode(response.body);
        AppSnackbar.error(context, data["mensaje"]);
      }
    } catch (e) {
      AppSnackbar.error(context, "Error de conexión. Inténtalo de nuevo.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF1F5DA0),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              SizedBox(height: h * 0.04),

              Image.asset("assets/images/logo.png", width: w * 0.35),

              SizedBox(height: h * 0.02),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.07,
                  vertical: h * 0.035,
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
                      "Registrarse",
                      style: TextStyle(
                        fontSize: (w * 0.09).clamp(28.0, 40.0),
                        fontFamily: "Poppins",
                      ),
                    ),

                    SizedBox(height: h * 0.025),

                    TextField(
                      controller: nombreController,
                      decoration: InputDecoration(
                        hintText: "Nombre",
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),

                    SizedBox(height: h * 0.018),

                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email",
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),

                    SizedBox(height: h * 0.018),

                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Contraseña",
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),

                    SizedBox(height: h * 0.018),

                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Confirmar Contraseña",
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),

                    SizedBox(height: h * 0.015),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: aceptarTerminos,
                          activeColor: const Color(0xFF1F5DA0),
                          onChanged: (value) => setState(() => aceptarTerminos = value!),
                        ),
                        Flexible(
                          child: Text(
                            "Aceptar términos y condiciones",
                            style: TextStyle(
                              fontFamily: "Poppins",
                              fontSize: (w * 0.035).clamp(12.0, 15.0),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: h * 0.02),

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
                        onPressed: () => registrar(context),
                        child: Text(
                          "Registrarse",
                          style: TextStyle(
                            fontSize: (w * 0.05).clamp(16.0, 22.0),
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: h * 0.02),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            "¿Tienes ya una cuenta existente?",
                            style: TextStyle(
                              color: Colors.grey,
                              fontFamily: "Poppins",
                              fontSize: (w * 0.033).clamp(11.0, 14.0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          ),
                          child: Text(
                            "Inicia Sesión",
                            style: TextStyle(
                              color: const Color(0xFF1F5DA0),
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.bold,
                              fontSize: (w * 0.033).clamp(11.0, 14.0),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: h * 0.02),
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