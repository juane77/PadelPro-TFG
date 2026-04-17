import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../service/session.dart';
import '../service/notificacion_service.dart';
import 'home_screen.dart';
import 'matches_screen.dart';
import 'news_screen.dart';
import 'login_screen.dart';
import 'notificaciones_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  File? image;
  int noLeidas = 0;

  @override
  void initState() {
    super.initState();
    cargarNoLeidas();
  }

  Future<void> cargarNoLeidas() async {
    final count = await NotificacionApi.getNoLeidas(Session.usuarioId!);
    setState(() {
      noLeidas = count;
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  void logout() {
    Session.usuarioId = null;
    Session.nombre = null;
    Session.email = null;
    Session.token = null;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  void editarNombre() {
    final controller = TextEditingController(text: Session.nombre);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar nombre"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Nuevo nombre"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F5DA0),
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final nuevoNombre = controller.text.trim();
                if (nuevoNombre.isEmpty || nuevoNombre.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("El nombre debe tener al menos 2 caracteres")),
                  );
                  return;
                }
                final response = await http.put(
                  Uri.parse("http://10.0.2.2:8080/api/usuarios/${Session.usuarioId}/nombre"),
                  headers: Session.authHeaders,
                  body: jsonEncode({"nombre": nuevoNombre}),
                );
                if (response.statusCode == 200) {
                  setState(() {
                    Session.nombre = nuevoNombre;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Nombre actualizado correctamente")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error al actualizar el nombre")),
                  );
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  void proximamente(String funcion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$funcion — próximamente disponible")),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: const Color(0xFF1F5DA0),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
          if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MatchesScreen()));
          if (index == 2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const NewsScreen()));
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "INICIO"),
          BottomNavigationBarItem(icon: Icon(Icons.sports_tennis), label: "PARTIDOS"),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: "NOTICIAS"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "PERFIL"),
        ],
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              width: double.infinity,
              height: 100,
              color: const Color(0xFF1F5DA0),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Text(
                "PadelPro",
                style: TextStyle(color: Colors.white, fontSize: 30, fontFamily: "Poppins"),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    const SizedBox(height: 20),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "PERFIL",
                        style: TextStyle(fontSize: 28, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 30),

                    GestureDetector(
                      onTap: pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage: image != null
                                ? FileImage(image!)
                                : const AssetImage("assets/images/profile.jpg") as ImageProvider,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1F5DA0),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      Session.nombre ?? "",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      Session.email ?? "",
                      style: const TextStyle(color: Colors.grey, fontSize: 16, fontFamily: "Poppins"),
                    ),

                    const SizedBox(height: 30),

                    profileButton(
                      icon: Icons.person_outline,
                      text: "Editar nombre",
                      color: const Color(0xFF1F5DA0),
                      onTap: editarNombre,
                    ),

                    const SizedBox(height: 15),

                    // 🔔 NOTIFICACIONES CON CONTADOR
                    notificacionButton(),

                    const SizedBox(height: 15),

                    profileButton(
                      icon: Icons.settings,
                      text: "Ajustes",
                      color: const Color(0xFF1F5DA0),
                      onTap: () => proximamente("Ajustes"),
                    ),

                    const SizedBox(height: 15),

                    profileButton(
                      icon: Icons.logout,
                      text: "Cerrar sesión",
                      color: Colors.red,
                      onTap: logout,
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BOTÓN NOTIFICACIONES CON BADGE
  Widget notificacionButton() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificacionesScreen()),
        );
        cargarNoLeidas(); // recarga el contador al volver
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1F5DA0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: ListTile(
          leading: Stack(
            children: [
              const Icon(Icons.notifications_none, color: Colors.white),
              if (noLeidas > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      noLeidas > 9 ? "9+" : "$noLeidas",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: const Text(
            "Notificaciones",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: "Poppins",
            ),
          ),
          trailing: noLeidas > 0
              ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "$noLeidas nueva${noLeidas > 1 ? 's' : ''}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
              : const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          onTap: null,
        ),
      ),
    );
  }

  Widget profileButton({
    required IconData icon,
    required String text,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        onTap: onTap ?? () {},
      ),
    );
  }
}