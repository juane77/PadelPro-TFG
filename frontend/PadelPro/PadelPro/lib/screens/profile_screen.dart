import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../service/session.dart';
import 'home_screen.dart';
import 'matches_screen.dart';
import 'news_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  File? image;

  /// SELECCIONAR FOTO
  Future<void> pickImage() async {

    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  /// LOGOUT
  void logout() {

    Session.usuarioId = null;
    Session.nombre = null;
    Session.email = null;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xFFF7F8FA),

      /// BOTTOM NAVIGATION (igual que en Home)
      bottomNavigationBar: BottomNavigationBar(

        currentIndex: 3,
        selectedItemColor: const Color(0xFF1F5DA0),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        onTap: (index) {

          if(index == 0){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
            );
          }

          if(index == 1){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MatchesScreen(),
              ),
            );
          }

          if(index == 2){
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const NewsScreen(),
              ),
            );
          }

        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "INICIO",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.sports_tennis),
            label: "PARTIDOS",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: "NOTICIAS",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "PERFIL",
          ),

        ],
      ),

      body: SafeArea(

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /// HEADER
            Container(
              width: double.infinity,
              height: 100,
              color: const Color(0xFF1F5DA0),

              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),

              child: const Text(
                "PadelPro",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontFamily: "Poppins",
                ),
              ),
            ),

            Expanded(

              child: SingleChildScrollView(

                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [

                    const SizedBox(height: 20),

                    /// TITULO
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "PERFIL",
                        style: TextStyle(
                          fontSize: 28,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// FOTO PERFIL (CLICKABLE)
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: image != null
                            ? FileImage(image!)
                            : const AssetImage("assets/images/profile.jpg") as ImageProvider,
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// NOMBRE REAL
                    Text(
                      Session.nombre ?? "",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                    ),

                    const SizedBox(height: 5),

                    /// EMAIL REAL
                    Text(
                      Session.email ?? "",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: "Poppins",
                      ),
                    ),

                    const SizedBox(height: 30),

                    profileButton(
                      icon: Icons.person_outline,
                      text: "Editar perfil",
                      color: const Color(0xFF1F5DA0),
                    ),

                    const SizedBox(height: 15),

                    profileButton(
                      icon: Icons.notifications_none,
                      text: "Notificaciones",
                      color: const Color(0xFF1F5DA0),
                    ),

                    const SizedBox(height: 15),

                    profileButton(
                      icon: Icons.settings,
                      text: "Ajustes",
                      color: const Color(0xFF1F5DA0),
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

            )

          ],

        ),

      ),

    );
  }

  /// BOTÓN PERFIL (SOLO AÑADIMOS onTap OPCIONAL)
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

        leading: Icon(
          icon,
          color: Colors.white,
        ),

        title: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: "Poppins",
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white,
          size: 16,
        ),

        onTap: onTap ?? () {},

      ),

    );
  }
}