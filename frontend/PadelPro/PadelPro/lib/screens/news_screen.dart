import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../widgets/app_header.dart';
import 'home_screen.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {

  static const String _apiKey = "fa4f3a36c32c857fe26640fa9de56f77";

  List<dynamic> noticias = [];
  bool cargando = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    cargarNoticias();
  }

  Future<void> cargarNoticias() async {
    setState(() {
      cargando = true;
      error = false;
    });

    try {
      final response = await http.get(
        Uri.parse("https://padelpro-tfg.onrender.com/api/noticias"),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final articulos = (data["articles"] as List?)
            ?.where((a) =>
                a["title"] != null &&
                a["image"] != null)
            .toList() ?? [];

        setState(() {
          noticias = articulos;
          cargando = false;
        });
      } else {
        setState(() {
          error = true;
          cargando = false;
        });
      }
    } catch (e) {
      setState(() {
        error = true;
        cargando = false;
      });
    }
  }

  Future<void> abrirNoticia(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception("No se pudo abrir la noticia");
    }
  }

  String _tiempoTranscurrido(String? fechaStr) {
    if (fechaStr == null) return "";
    try {
      final fecha = DateTime.parse(fechaStr);
      final diff = DateTime.now().difference(fecha);
      if (diff.inMinutes < 60) return "Hace ${diff.inMinutes} min";
      if (diff.inHours < 24) return "Hace ${diff.inHours}h";
      return "Hace ${diff.inDays} días";
    } catch (_) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        selectedItemColor: const Color(0xFF1F5DA0),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          if (index == 1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MatchesScreen()));
          if (index == 3) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "INICIO"),
          BottomNavigationBarItem(icon: Icon(Icons.sports_tennis), label: "PARTIDOS"),
          BottomNavigationBarItem(icon: Icon(Icons.article_rounded), label: "NOTICIAS"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "PERFIL"),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [

            const AppHeader(
              titulo: "Últimas noticias del mundo del pádel",
            ),

            Expanded(
              child: cargando
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF1F5DA0)))
                  : error
                      ? _estadoError()
                      : noticias.isEmpty
                          ? _estadoVacio()
                          : _listaNoticias(w),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listaNoticias(double w) {
    return RefreshIndicator(
      color: const Color(0xFF1F5DA0),
      onRefresh: cargarNoticias,
      child: ListView.builder(
        padding: EdgeInsets.all(w * 0.04),
        itemCount: noticias.length,
        itemBuilder: (context, index) {
          final noticia = noticias[index];
          if (index == 0) return _noticiaDestacada(noticia);
          return _noticiaCard(noticia);
        },
      ),
    );
  }

  Widget _noticiaDestacada(dynamic noticia) {
    final imagen = noticia["image"] ?? "";
    final titulo = noticia["title"] ?? "";
    final fecha = noticia["publishedAt"] ?? "";
    final fuente = noticia["source"]?["name"] ?? "";
    final url = noticia["url"] ?? "";

    return GestureDetector(
      onTap: () => abrirNoticia(url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Image.network(
                imagen,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 220,
                  color: const Color(0xFF1F5DA0).withOpacity(0.2),
                  child: const Icon(Icons.sports_tennis, size: 60, color: Colors.white54),
                ),
              ),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F5DA0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "DESTACADO",
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        titulo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: "Poppins"),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.white70, size: 12),
                          const SizedBox(width: 4),
                          Text(_tiempoTranscurrido(fecha),
                              style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: "Poppins")),
                          const SizedBox(width: 12),
                          const Icon(Icons.source_outlined, color: Colors.white70, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(fuente,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: "Poppins")),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _noticiaCard(dynamic noticia) {
    final imagen = noticia["image"] ?? "";
    final titulo = noticia["title"] ?? "";
    final fecha = noticia["publishedAt"] ?? "";
    final fuente = noticia["source"]?["name"] ?? "";
    final url = noticia["url"] ?? "";

    return GestureDetector(
      onTap: () => abrirNoticia(url),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imagen,
                width: 85,
                height: 85,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 85,
                  height: 85,
                  color: const Color(0xFF1F5DA0).withOpacity(0.1),
                  child: const Icon(Icons.sports_tennis, color: Color(0xFF1F5DA0)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fuente,
                    style: const TextStyle(color: Color(0xFF1F5DA0), fontSize: 11, fontFamily: "Poppins", fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontFamily: "Poppins", fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.grey, size: 11),
                      const SizedBox(width: 3),
                      Text(_tiempoTranscurrido(fecha),
                          style: const TextStyle(color: Colors.grey, fontSize: 11, fontFamily: "Poppins")),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _estadoError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No se pudieron cargar las noticias",
              style: TextStyle(fontFamily: "Poppins", color: Colors.grey, fontSize: 15)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F5DA0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: cargarNoticias,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Reintentar", style: TextStyle(fontFamily: "Poppins")),
          ),
        ],
      ),
    );
  }

  Widget _estadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No hay noticias disponibles",
              style: TextStyle(fontFamily: "Poppins", color: Colors.grey, fontSize: 15)),
        ],
      ),
    );
  }
}