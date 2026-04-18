import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rellena todos los campos")),
      );
      return;
    }

    if (nombre.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El nombre debe tener al menos 2 caracteres")),
      );
      return;
    }

    if (!email.contains("@") || !email.contains(".")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("El email no es válido")),
      );
      return;
    }

    if (password.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La contraseña debe tener mínimo 4 caracteres")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    if (!aceptarTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes aceptar los términos")),
      );
      return;
    }

    try {

      final response = await http.post(
        Uri.parse("https://padelpro-tfg.onrender.com/api/usuarios/registrar"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nombre": nombre,
          "email": email,
          "password": password,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario registrado correctamente")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );

      } else {

        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["mensaje"])),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF1F5DA0),

      body: Column(
        children: [

          const SizedBox(height: 40),

          Image.asset("assets/images/logo.png", width: width * 0.4),

          const SizedBox(height: 20),

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),

              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45),
                  topRight: Radius.circular(45),
                ),
              ),

              child: Column(
                children: [

                  const Text(
                    "Registrarse",
                    style: TextStyle(fontSize: 40, fontFamily: "Poppins"),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: nombreController,
                    decoration: InputDecoration(
                      hintText: "Nombre",
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Email",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Contraseña",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Confirmar Contraseña",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: aceptarTerminos,
                        activeColor: const Color(0xFF1F5DA0),
                        onChanged: (value) {
                          setState(() {
                            aceptarTerminos = value!;
                          });
                        },
                      ),
                      const Text(
                        "Aceptar términos y condiciones",
                        style: TextStyle(fontFamily: "Poppins"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F5DA0),
                      foregroundColor: Colors.white,
                      minimumSize: Size(width * 0.7, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => registrar(context),
                    child: const Text(
                      "Registrarse",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "¿Tienes ya una cuenta existente?",
                        style: TextStyle(color: Colors.grey, fontFamily: "Poppins"),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: const Text(
                          "Inicia Sesión",
                          style: TextStyle(
                            color: Color(0xFF1F5DA0),
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}