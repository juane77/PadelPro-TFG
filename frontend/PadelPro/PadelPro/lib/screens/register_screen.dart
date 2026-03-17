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

    if(!aceptarTerminos){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debes aceptar los términos"),
        ),
      );
      return;
    }

    if(passwordController.text != confirmPasswordController.text){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Las contraseñas no coinciden"),
        ),
      );
      return;
    }

    final response = await http.post(

      Uri.parse("http://10.0.2.2:8080/api/usuarios/registrar"),

      headers: {
        "Content-Type": "application/json"
      },

      body: jsonEncode({

        "nombre": nombreController.text,
        "email": emailController.text,
        "password": passwordController.text

      }),
    );

    if(response.statusCode == 201){

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Usuario registrado correctamente"),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );

    } else {

      final data = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data["mensaje"]),
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
                    "Registrarse",
                    style: TextStyle(
                      fontSize: 40,
                      fontFamily: "Poppins",
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: nombreController,
                    decoration: InputDecoration(
                      hintText: "Nombre",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

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

                  const SizedBox(height: 20),

                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Confirmar Contraseña",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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

                  GestureDetector(
                    onTap: () {
                      registrar(context);
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
                        "Registrarse",
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
                        "¿Tienes ya una cuenta existente?",
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
                              builder: (context) => LoginScreen(),
                            ),
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