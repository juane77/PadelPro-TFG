import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../service/session.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {

    final response = await http.post(

      Uri.parse("http://10.0.2.2:8080/api/usuarios/login"),

      headers: {
        "Content-Type": "application/json"
      },

      body: jsonEncode({

        "email": emailController.text,
        "password": passwordController.text

      }),
    );

    if(response.statusCode == 200){

      final data = json.decode(response.body);

      Session.usuarioId = data["id"];
      Session.nombre = data["nombre"];
      Session.email = data["email"];

      print("USUARIO LOGUEADO: ${Session.usuarioId}");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email o contraseña incorrectos"),
        ),
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

          Image.asset(
            "assets/images/logo.png",
            width: width * 0.4,
          ),

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
                    "Iniciar Sesión",
                    style: TextStyle(
                      fontSize: 40,
                      fontFamily: "Poppins",
                    ),
                  ),

                  const SizedBox(height: 40),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: "Gmail",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Contraseña",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  GestureDetector(
                    onTap: () {
                      login(context);
                    },

                    child: Container(
                      width: width * 0.7,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F5DA0),
                        borderRadius: BorderRadius.circular(16),
                      ),

                      alignment: Alignment.center,

                      child: const Text(
                        "Iniciar Sesión",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Text(
                        "¿No tienes cuenta todavía?",
                        style: TextStyle(
                          color: Colors.grey,
                          fontFamily: "Poppins",
                        ),
                      ),

                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );

                        },

                        child: const Text(
                          "Registrarme",
                          style: TextStyle(
                            color: Color(0xFF1F5DA0),
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.bold,
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