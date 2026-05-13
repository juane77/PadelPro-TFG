import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/session.dart';
import '../service/foto_service.dart';
import '../service/notificacion_service.dart';
import '../service/amistad_service.dart';
import '../utils/app_snackbar.dart';
import '../widgets/app_header.dart';
import 'home_screen.dart';
import 'matches_screen.dart';
import 'news_screen.dart';
import 'login_screen.dart';
import 'notificaciones_screen.dart';
import 'ajustes_screen.dart';
import 'amigos_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  File? image;
  int noLeidas = 0;
  int solicitudesPendientes = 0;

  @override
  void initState() {
    super.initState();
    cargarNoLeidas();
    cargarFotoGuardada();
    cargarSolicitudesPendientes();
  }

  Future<void> cargarFotoGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    final ruta = prefs.getString('foto_perfil_${Session.usuarioId}');
    if (ruta != null && File(ruta).existsSync()) {
      setState(() {
        image = File(ruta);
      });
    }
  }

  Future<void> cargarNoLeidas() async {
    final count = await NotificacionApi.getNoLeidas(Session.usuarioId!);
    setState(() {
      noLeidas = count;
    });
  }

  Future<void> cargarSolicitudesPendientes() async {
    final pendientes = await AmistadService.getSolicitudesPendientes();
    setState(() {
      solicitudesPendientes = pendientes.length;
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked != null) {
      final file = File(picked.path);
      // Guardar localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('foto_perfil_\${Session.usuarioId}', picked.path);
      setState(() => image = file);
      // Subir a Supabase Storage
      final url = await FotoService.subirFoto(file);
      if (url != null) {
        print("Foto subida correctamente: \$url");
      }
    }
  }

  void logout() {
    Session.clear();
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
                  AppSnackbar.aviso(context, "El nombre debe tener al menos 2 caracteres");
                  return;
                }
                final response = await http.put(
                  Uri.parse("https://padelpro-tfg.onrender.com/api/usuarios/${Session.usuarioId}/nombre"),
                  headers: Session.authHeaders,
                  body: jsonEncode({"nombre": nuevoNombre}),
                );
                if (response.statusCode == 200) {
                  setState(() {
                    Session.nombre = nuevoNombre;
                  });
                  Navigator.pop(context);
                  AppSnackbar.exito(context, "Nombre actualizado correctamente");
                } else {
                  AppSnackbar.error(context, "Error al actualizar el nombre");
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }

  // VENTANA FLOTANTE DE PELOTAS
  void mostrarInfoPelotas() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            const Text("🎾", style: TextStyle(fontSize: 48)),

            const SizedBox(height: 12),

            Text(
              "${Session.pelotas} pelotas",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
                color: Color(0xFF1F5DA0),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Tu moneda dentro de PadelPro",
              style: TextStyle(
                color: Colors.grey,
                fontFamily: "Poppins",
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "¿Para qué sirven?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 12),

            _infoPelota(Icons.sports_tennis, "Reservar una pista", "Cuesta 15 pelotas por reserva"),
            const SizedBox(height: 10),
            _infoPelota(Icons.cancel_outlined, "Cancelar una reserva", "Recuperas 10 pelotas al cancelar"),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "¿Cómo conseguir más?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 12),

            _infoPelota(Icons.login, "Iniciar sesión cada día", "+5 pelotas por día"),
            const SizedBox(height: 10),
            _infoPelota(Icons.emoji_events_outlined, "Ganar partidos", "Próximamente"),
            const SizedBox(height: 10),
            _infoPelota(Icons.people_outline, "Invitar amigos", "Próximamente"),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F5DA0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Entendido",
                  style: TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _infoPelota(IconData icon, String titulo, String subtitulo) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1F5DA0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF1F5DA0), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitulo,
                style: const TextStyle(
                  color: Colors.grey,
                  fontFamily: "Poppins",
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
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

            AppHeader(titulo: "Hola, ${Session.nombre ?? ""} 👋", foto: image),

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
                        style: TextStyle(fontSize: 24, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 30),

                    GestureDetector(
                      onTap: pickImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: MediaQuery.of(context).size.width * 0.15,
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

                    const SizedBox(height: 16),

                    // SALDO DE PELOTAS — al pulsar abre la ventana flotante
                    GestureDetector(
                      onTap: mostrarInfoPelotas,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1F5DA0), Color(0xFF2E7BC4)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("🎾", style: TextStyle(fontSize: 22)),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${Session.pelotas} pelotas",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Poppins",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const Text(
                                  "Tu saldo actual — pulsa para saber más",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontFamily: "Poppins",
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.info_outline, color: Colors.white70, size: 18),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    profileButton(
                      icon: Icons.person_outline,
                      text: "Editar nombre",
                      color: const Color(0xFF1F5DA0),
                      onTap: editarNombre,
                    ),

                    const SizedBox(height: 15),

                    amigosButton(),

                    const SizedBox(height: 15),

                    notificacionButton(),

                    const SizedBox(height: 15),

                    profileButton(
                      icon: Icons.settings,
                      text: "Ajustes",
                      color: const Color(0xFF1F5DA0),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AjustesScreen()),
                      ),
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

  Widget amigosButton() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AmigosScreen()),
        );
        cargarSolicitudesPendientes();
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
              const Icon(Icons.people_outline, color: Colors.white),
              if (solicitudesPendientes > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      solicitudesPendientes > 9 ? "9+" : "$solicitudesPendientes",
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          title: const Text("Amigos", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "Poppins")),
          trailing: solicitudesPendientes > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    "$solicitudesPendientes nueva${solicitudesPendientes > 1 ? 's' : ''}",
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                )
              : const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          onTap: null,
        ),
      ),
    );
  }

  Widget notificacionButton() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificacionesScreen()));
        cargarNoLeidas();
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: const Color(0xFF1F5DA0), borderRadius: BorderRadius.circular(14)),
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
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      noLeidas > 9 ? "9+" : "$noLeidas",
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          title: const Text("Notificaciones", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "Poppins")),
          trailing: noLeidas > 0
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    "$noLeidas nueva${noLeidas > 1 ? 's' : ''}",
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                )
              : const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          onTap: null,
        ),
      ),
    );
  }

  Widget profileButton({required IconData icon, required String text, required Color color, VoidCallback? onTap}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "Poppins")),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        onTap: onTap ?? () {},
      ),
    );
  }
}